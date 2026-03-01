# GitLab CI/CD Pipeline for Employee Onboarding Agent Fabric

This document provides comprehensive information about the GitLab CI/CD pipeline implementation for the Employee Onboarding Agent Fabric system.

## 🚀 Overview

The GitLab CI/CD pipeline provides automated build, test, security scanning, deployment, and monitoring for the MuleSoft-based Employee Onboarding MCP system. The pipeline supports multiple environments (development, production) and includes comprehensive quality gates.

## 📁 Directory Structure

```
cicd/gitlab/
├── .gitlab-ci.yml                 # Main pipeline configuration
├── README.md                      # This documentation
├── environments/
│   ├── development.yml            # Development environment variables
│   └── production.yml             # Production environment variables
└── scripts/
    └── deploy-to-cloudhub.sh      # CloudHub deployment script
```

## 🔧 Pipeline Stages

The CI/CD pipeline consists of the following stages:

### 1. 🔍 Validation Stage
- **Environment Validation**: Checks Java, Maven, Node.js versions
- **Project Structure Validation**: Validates required files and directories

### 2. 🏗️ Build Stage
- **Parent POM Build**: Builds the parent Maven project
- **MCP Services Build**: Parallel builds for all 4 MCP services
- **React Client Build**: Builds the frontend application with environment-specific configs

### 3. 🧪 Test Stage
- **Unit Tests (MCP Services)**: JUnit tests with PostgreSQL integration
- **Unit Tests (React Client)**: Jest tests with coverage reporting
- **Integration Tests**: Full Docker-based integration testing

### 4. 🔍 Analysis Stage
- **SonarQube Analysis**: Code quality and coverage analysis
- **Security Scanning**: OWASP dependency check, Snyk, and ZAP security scans

### 5. 📦 Package Stage
- **Maven Packaging**: Creates deployable JAR artifacts
- **Docker Containerization**: Builds and pushes Docker images to GitLab Registry

### 6. 📤 Publish Stage
- **Anypoint Exchange Publication**: Publishes MCP assets to Exchange

### 7. 🚀 Deploy Stage
- **Development Deployment**: Auto-deploys develop branch to dev environment
- **Production Deployment**: Manual deploy of main branch to production

### 8. 🧪 Integration Stage
- **End-to-End Tests**: Complete user journey testing
- **API Integration Tests**: Cross-service communication validation

### 9. ⚡ Performance Stage
- **Load Testing**: JMeter-based performance testing
- **Stress Testing**: High-load system validation (production only)

### 10. 📊 Monitoring Stage
- **Health Checks**: Application health validation
- **System Status Monitoring**: CloudHub application status checks

### 11. 📢 Notification Stage
- **Slack Notifications**: Real-time pipeline status updates
- **Email Notifications**: Failure notifications for critical environments

## 🌍 Environment Configuration

### Development Environment (`develop` branch)
- **CloudHub Workers**: 1 x MICRO
- **Persistent Queues**: Disabled
- **Performance Users**: 25
- **Security Threshold**: CVSS 8+
- **Debug Endpoints**: Enabled

### Production Environment (`main` branch)
- **CloudHub Workers**: 2 x MEDIUM  
- **Persistent Queues**: Enabled
- **Performance Users**: 100
- **Security Threshold**: CVSS 5+
- **Debug Endpoints**: Disabled
- **Manual Deployment**: Required

## 🔐 Required Variables

### GitLab CI/CD Variables (Settings → CI/CD → Variables)

#### MuleSoft Anypoint Platform
```bash
ANYPOINT_CLIENT_ID          # Connected App Client ID
ANYPOINT_CLIENT_SECRET      # Connected App Client Secret (masked)
ANYPOINT_ORG_ID            # Organization ID
```

#### Code Quality & Security
```bash
SONAR_URL                   # SonarQube server URL
SONAR_TOKEN                # SonarQube authentication token (masked)
SNYK_TOKEN                 # Snyk authentication token (masked)
OWASP_NVD_API_KEY          # OWASP NVD API key (masked)
```

#### Notifications
```bash
SLACK_WEBHOOK_URL          # Slack webhook for notifications (masked)
```

#### Docker Registry (automatically provided by GitLab)
```bash
CI_REGISTRY_USER           # GitLab Registry username
CI_REGISTRY_PASSWORD       # GitLab Registry password
CI_REGISTRY                # GitLab Registry URL
```

## 🚀 Getting Started

### 1. Repository Setup

1. **Fork/Clone** the repository to your GitLab instance
2. **Configure Variables** in GitLab Settings → CI/CD → Variables
3. **Set up Anypoint Connected App** with required scopes:
   - CloudHub Organization Administrator
   - Exchange Administrator
   - Runtime Manager

### 2. Connected App Scopes Required

```
Design Center Developer
Exchange Administrator  
CloudHub Organization Administrator
Runtime Manager
API Manager
```

### 3. Branch Configuration

- **`main` branch**: Production deployments (manual approval required)
- **`develop` branch**: Development deployments (automatic)
- **Feature branches**: Build and test only (no deployment)

## 📋 Pipeline Execution Rules

### Automatic Triggers
- **Push to `main`**: Full pipeline with manual production deployment
- **Push to `develop`**: Full pipeline with automatic dev deployment  
- **Merge Requests**: Build, test, and analysis (no deployment)
- **Feature branches**: Build and test only

### Manual Triggers
- **Production deployment**: Manual approval required
- **Stress testing**: Manual trigger on main branch
- **Docker image builds**: Manual trigger for MR branches

### Scheduled Jobs
- **Weekly security scan**: Every Sunday at 2 AM UTC
- **Monthly performance baseline**: First Sunday of each month

## 🔍 Monitoring and Troubleshooting

### Pipeline Monitoring

1. **GitLab Pipeline View**: Real-time status and logs
2. **SonarQube Dashboard**: Code quality metrics
3. **CloudHub Runtime Manager**: Application status
4. **Slack Notifications**: Real-time updates

### Common Issues

#### Build Failures
- **Maven dependency issues**: Check `.m2/settings.xml` configuration
- **Java version mismatch**: Ensure Java 17 is used consistently
- **Node.js issues**: Verify package.json and npm cache

#### Deployment Failures  
- **Authentication**: Verify Anypoint credentials
- **CloudHub limits**: Check organization limits and quotas
- **Network issues**: Verify connectivity to Anypoint Platform

#### Test Failures
- **Database connectivity**: Check PostgreSQL service status
- **Integration tests**: Verify Docker service availability
- **Performance tests**: Check JMeter configuration and thresholds

### Debugging Commands

```bash
# Check pipeline variables
echo $ANYPOINT_CLIENT_ID | head -c 10

# Validate Maven settings
mvn help:effective-settings

# Test Docker connectivity
docker info

# Check Java version
java -version && mvn --version
```

## 📊 Performance Metrics

### Build Times (Approximate)
- **Validation**: 2-3 minutes
- **Build**: 5-8 minutes
- **Tests**: 8-12 minutes
- **Security Scanning**: 10-15 minutes
- **Deployment**: 15-25 minutes
- **Total Pipeline**: 40-65 minutes

### Resource Usage
- **Runners**: Linux Docker executors
- **Memory**: 4GB recommended minimum
- **Storage**: 10GB for artifacts and caches
- **Network**: Reliable internet for CloudHub deployment

## 🔄 Pipeline Optimization

### Caching Strategy
- **Maven dependencies**: Cached per branch
- **Node.js modules**: Cached per branch
- **Docker layers**: Built-in GitLab registry caching

### Parallel Execution
- **Service builds**: All 4 MCP services build in parallel
- **Tests**: MCP and React tests run simultaneously
- **Security scans**: OWASP and Snyk run in parallel

### Artifact Management
- **Build artifacts**: Retained for 1 week
- **Test reports**: Retained for 1 week  
- **Security reports**: Retained for 1 week
- **Performance results**: Retained for 1 week (3 months for baselines)

## 🛠️ Customization

### Adding New Services

1. **Update pipeline matrix**: Add service to parallel builds
2. **Add environment variables**: Configure service-specific settings
3. **Update deployment script**: Include in deployment automation
4. **Add health checks**: Configure service monitoring

### Modifying Environments

1. **Edit environment files**: `environments/development.yml`, `environments/production.yml`
2. **Update deployment logic**: Modify `.gitlab-ci.yml` rules
3. **Adjust thresholds**: Update performance and security limits

### Custom Quality Gates

1. **SonarQube rules**: Configure in SonarQube server
2. **Security thresholds**: Adjust OWASP and Snyk settings  
3. **Performance limits**: Modify JMeter test parameters
4. **Coverage requirements**: Set minimum code coverage

## 📚 Additional Resources

### Documentation Links
- [GitLab CI/CD Documentation](https://docs.gitlab.com/ee/ci/)
- [MuleSoft CloudHub Deployment](https://docs.mulesoft.com/mule-runtime/4.4/deploy-to-cloudhub)
- [Anypoint Exchange](https://docs.mulesoft.com/exchange/)
- [Docker in GitLab CI](https://docs.gitlab.com/ee/ci/docker/)

### Tools and Integrations
- **SonarQube**: Code quality analysis
- **Snyk**: Security vulnerability scanning
- **OWASP ZAP**: Dynamic application security testing  
- **JMeter**: Performance and load testing
- **Slack**: Team notifications
- **Docker**: Containerization and deployment

### Best Practices
- **Security**: Never commit credentials to repository
- **Testing**: Maintain high test coverage (>80%)
- **Performance**: Monitor and alert on performance degradation
- **Documentation**: Keep pipeline documentation updated
- **Monitoring**: Implement comprehensive health checks

## 🆘 Support

### Internal Support
- **DevOps Team**: Pipeline configuration and troubleshooting
- **Development Team**: Application-specific issues
- **Platform Team**: Infrastructure and connectivity

### External Resources
- **MuleSoft Support**: CloudHub and platform issues
- **GitLab Support**: CI/CD pipeline problems
- **Tool Documentation**: SonarQube, Snyk, JMeter references

---

**Last Updated**: March 2026  
**Version**: 1.0  
**Maintainer**: DevOps Team
