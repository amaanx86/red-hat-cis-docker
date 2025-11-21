# WordPress on Red Hat Universal Base Image 10

<img  alt="red-hat-logo" src="https://github.com/user-attachments/assets/53b940ad-c05f-41ce-8c35-0d048b7da04a" width="460" height="100" />

## Overview

Enterprise-grade WordPress deployment built on Red Hat Universal Base Image 10 (UBI10), featuring Apache 2.4.62 and PHP 8.3.19 with FPM. This solution is designed for production environments with CIS baseline readiness and multi-cloud compatibility.

## Architecture

### Container Stack
- **Base Image**: Red Hat Universal Base Image 10 (UBI10)
- **Web Server**: Apache 2.4.62 (Red Hat Enterprise Linux)
- **PHP Runtime**: PHP 8.3.19 with FPM
- **Database**: MySQL 8.0 (separate container)
- **Application**: WordPress (latest stable release)

### Key Features
- CIS baseline ready for security compliance
- Optimized for enterprise container orchestration platforms
- Externalized configuration management
- Cloud-native storage integration support
- Separation of concerns (application vs. persistent data)

## Project Structure

```
.
├── Dockerfile                 # Container image definition
├── docker-compose.yml         # Local development orchestration
├── entrypoint.sh              # Container startup script
├── config/
│   ├── apache.conf            # Apache web server configuration
│   └── php-fpm.conf           # PHP-FPM process manager configuration
└── wp-content/                # WordPress content directory (mounted)
    ├── plugins/               # WordPress plugins
    ├── themes/                # WordPress themes
    └── uploads/               # User-uploaded media files
```

## Persistent Storage Requirements

### Critical: Uploads Directory

The WordPress `uploads` directory (`/var/www/html/wp-content/uploads`) requires persistent, shared storage when running in distributed or orchestrated environments. This directory contains user-generated content (images, documents, media files) that must be accessible across all container instances.

### Cloud Storage Solutions

#### Amazon Web Services (AWS)
**Primary Option: Amazon Elastic File System (EFS)**
- Fully managed NFS file system designed for containerized workloads
- Supports concurrent access from multiple ECS tasks or EKS pods
- Automatic scaling with high availability across multiple availability zones
- Can be mounted directly to `/var/www/html/wp-content/uploads`
- Integration with ECS task definitions and EKS persistent volumes

**Alternative: Amazon S3 with Mounting Solutions**
- Mount S3 buckets using s3fs-fuse, Goofys, or AWS S3 CSI Driver
- S3-compatible object storage with MinIO gateway for hybrid scenarios
- Suitable for read-heavy workloads with appropriate caching strategies

#### Microsoft Azure
**Primary Option: Azure Files**
- Enterprise file shares using SMB 3.0 protocol
- Native integration with Azure Container Instances (ACI) and Azure Kubernetes Service (AKS)
- Supports Azure AD authentication and role-based access control
- Can be mounted as persistent volumes in containerized environments
- Automatic backup and disaster recovery capabilities

#### Google Cloud Platform (GCP)
**Primary Option: Cloud Filestore**
- Fully managed NFS file server service
- High-performance, low-latency access for containerized applications
- Native integration with Google Kubernetes Engine (GKE) and Cloud Run
- Automatic backups, snapshots, and point-in-time recovery
- Supports both standard and high-scale configurations

#### Oracle Cloud Infrastructure (OCI)
**Primary Option: OCI File Storage Service**
- Enterprise-grade NFS file system service
- Compatible with Container Instances and Oracle Kubernetes Engine (OKE)
- Supports snapshots and cross-region replication
- NFSv3 protocol support for broad compatibility
- Integration with OCI Identity and Access Management

#### On-Premises and Hybrid Cloud
**Primary Option: MinIO Object Storage**
- Self-hosted, S3-compatible object storage solution
- High-performance alternative for on-premises deployments
- Multi-tenant architecture with IAM policy support
- Can be mounted using S3-compatible file systems (s3fs, Goofys, JuiceFS)
- Supports hybrid cloud architectures with public cloud gateways
- Suitable for air-gapped environments and regulatory compliance requirements

### Storage Integration Strategy

When deploying to container orchestration platforms:

1. **Shared File Systems**: Use managed NFS-based solutions (EFS, Azure Files, Cloud Filestore, OCI File Storage) for simplicity and reliability
2. **Object Storage**: Consider S3-compatible object storage (AWS S3, MinIO) for cost-effective, scalable storage with appropriate mounting solutions
3. **Performance Considerations**: Evaluate latency requirements and choose storage tiers accordingly
4. **Backup Strategy**: Ensure the chosen storage solution supports automated backups and point-in-time recovery
5. **Access Patterns**: For high-traffic WordPress sites, implement CDN for serving uploaded media files

## Local Development

### Prerequisites
- Docker Engine 20.10 or higher
- Docker Compose 2.0 or higher

### Quick Start

1. Clone the repository and navigate to the project directory

2. Configure environment variables (optional):
   ```bash
   cp .env.example .env
   ```
   Edit `.env` file with your database credentials

3. Start the application:
   ```bash
   docker compose up -d --build
   ```

4. Access WordPress at http://localhost and complete the installation wizard

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `MYSQL_ROOT_PASSWORD` | MySQL root password | `rootpassword` |
| `MYSQL_DATABASE` | WordPress database name | `wordpress` |
| `MYSQL_USER` | Database username | `wpuser` |
| `MYSQL_PASSWORD` | Database user password | `wppassword` |

## Production Deployment Considerations

### Security
- Change all default passwords before production deployment
- Implement network policies and security groups to restrict database access
- Enable HTTPS/TLS termination at load balancer or ingress controller
- Configure Web Application Firewall (WAF) rules
- Implement regular security scanning and vulnerability management
- Use secrets management solutions (AWS Secrets Manager, Azure Key Vault, GCP Secret Manager)
- Apply principle of least privilege for IAM roles and service accounts

### High Availability
- Deploy multiple container replicas behind a load balancer
- Use managed database services (Amazon RDS, Azure Database for MySQL, Cloud SQL)
- Implement health checks and auto-scaling policies
- Configure session affinity or use shared session storage (Redis)
- Set up database read replicas for read-heavy workloads
- Deploy across multiple availability zones for fault tolerance

### Backup and Disaster Recovery
- Schedule automated database backups with appropriate retention policies
- Backup uploaded files from shared storage regularly
- Test disaster recovery procedures quarterly
- Implement point-in-time recovery capabilities
- Document Recovery Time Objective (RTO) and Recovery Point Objective (RPO)
- Maintain off-site backup copies for compliance

### Monitoring and Observability
- Configure application performance monitoring (APM) tools
- Set up centralized log aggregation and analysis
- Implement metrics collection (Prometheus, CloudWatch, Stackdriver)
- Create alerting rules for critical errors and resource exhaustion
- Establish dashboards for key performance indicators (KPIs)
- Monitor database performance and slow query logs

### Performance Optimization
- Configure PHP OpCache for improved execution performance
- Implement Content Delivery Network (CDN) for static assets and media files
- Enable Redis or Memcached for WordPress object caching
- Optimize database queries and create appropriate indexes
- Configure HTTP/2 and compression at load balancer level
- Implement database connection pooling

## Maintenance

### Updating WordPress Core
WordPress core files are downloaded during image build. To update:
1. Rebuild the container image with the latest WordPress version
2. Deploy the new image version following your change management process
3. Run WordPress database migrations via the admin panel

### Managing Plugins and Themes
Plugins and themes are managed via the mounted `wp-content` directory:
- Local development: Place files in `./wp-content/plugins` and `./wp-content/themes`
- Production: Manage through WordPress admin panel or CI/CD pipelines with appropriate testing

### Database Migrations
- Use WordPress CLI (wp-cli) for automated database migrations
- Schedule maintenance windows for major version updates
- Always create database backups before running migrations
- Test migrations in staging environment before production deployment

## Troubleshooting

### View Container Logs
```bash
docker logs wordpress_app
docker logs wordpress_db
```

### Verify File Permissions
```bash
docker exec wordpress_app ls -la /var/www/html/wp-content
```

### Check PHP-FPM Configuration
```bash
docker exec wordpress_app php-fpm -t
```

### Test Apache Configuration
```bash
docker exec wordpress_app httpd -t
```

### Access Container Shell
```bash
docker exec -it wordpress_app bash
```

## Support and Maintenance

### Maintainer
**Amaan Ul Haq Siddiqui**

### Version History
- **v1.0**: Initial release with UBI10, Apache 2.4, PHP 8.3, WordPress latest

### License
This project follows enterprise licensing guidelines. Please refer to your organization's policies for usage and distribution.

---

**Important**: This solution is designed for enterprise deployments. Always follow your organization's security policies, compliance requirements, and change management procedures when deploying to production environments. Conduct thorough testing in non-production environments before releasing to production.
