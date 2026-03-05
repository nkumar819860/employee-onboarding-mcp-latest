# Azure DevOps Pipeline Variables Configuration Guide

## Overview
This document provides comprehensive guidance on configuring all variables required for the production-grade Azure DevOps pipeline for Angular + MuleSoft deployment with BeyondTrust PAM and MFA.

## Variable Groups Configuration

### 1. beyondtrust-config
Configure these variables in Azure DevOps Library under variable group `beyondtrust-config`:

| Variable Name | Type | Description | Example Value |
|---------------|------|-------------|---------------|
| `btApiKey` | **Secret** | BeyondTrust API key for authentication | `bt_api_key_xyz123...` |
| `beyondtrustApiUrl` | Variable | BeyondTrust Password Safe API base URL | `https://beyondtrust.company.com` |
| `managedAccountId` | Variable | BeyondTrust managed account ID for VM access | `12345` |
| `deploymentUser` | Variable | Username for deployment approval | `deployment.admin` |
| `deploymentApprovers` | Variable | Email addresses for MFA approval notifications | `admin@company.com;ops@company.com` |
| `deploymentEnvironment` | Variable | Target deployment environment | `production` |

**Setup Instructions:**
1. Navigate to Azure DevOps → Pipelines → Library
2. Create new variable group named `beyondtrust-config`
3. Add all variables above
4. Mark `btApiKey` as secret by clicking the lock icon
5. Link this variable group to your pipeline

### 2. vm-infrastructure
Configure VM and network infrastructure variables:

| Variable Name | Type | Description | Example Value |
|---------------|------|-------------|---------------|
| `vmHostname` | Variable | Production VM hostname | `prod-app-vm01.company.com` |
| `vmPrivateIp` | Variable | VM private IP address | `10.0.1.100` |
| `vmPublicIp` | Variable | VM public IP address | `203.0.113.100` |
| `serviceAccount` | Variable | Service account for VM deployment | `svc-deploy` |
| `sshPort` | Variable | SSH port for VM connection | `22` |

### 3. mulesoft-config
Configure MuleSoft deployment variables:

| Variable Name | Type | Description | Example Value |
|---------------|------|-------------|---------------|
| `muleRuntimePath` | Variable | Path to Mule runtime installation | `/opt/mule` |
| `muleAppsPath` | Variable | Path to Mule applications directory | `/opt/mule/apps` |
| `muleConfigPath` | Variable | Path to Mule configuration directory | `/opt/mule/conf` |
| `muleServiceName` | Variable | MuleSoft service name | `mule` |
| `muleHealthEndpoint` | Variable | MuleSoft health check endpoint | `/api/health` |
| `muleServicePort` | Variable | MuleSoft service port | `8081` |

### 4. security-config
Configure security and compliance variables:

| Variable Name | Type | Description | Example Value |
|---------------|------|-------------|---------------|
| `sonarCloudServiceConnection` | Variable | SonarCloud service connection name (optional) | `SonarCloud-Connection` |
| `sonarCloudOrganization` | Variable | SonarCloud organization key (optional) | `my-org-key` |
| `securityScanEnabled` | Variable | Enable/disable security scanning | `true` |
| `owaspSuppressionFile` | Variable | Path to OWASP suppression file | `owasp-suppressions.xml` |

## Pipeline-Level Variables

Configure these variables directly in your Azure DevOps pipeline:

### Build Configuration Variables

```yaml
variables:
  # Build Configuration
  - name: nodeVersion
    value: '20.x'
  - name: angularCliVersion  
    value: '18.x'
  - name: mavenVersion
    value: '3.9.x'
  - name: javaVersion
    value: '17'
```

### Application Configuration Variables

```yaml
  # Application Configuration
  - name: angularAppName
    value: 'employee-onboarding-app'
  - name: appContext
    value: 'onboarding'
  - name: muleSoftAppName
    value: 'employee-onboarding-backend'
```

### Deployment Configuration Variables

```yaml
  # Deployment Configuration
  - name: deploymentStrategy
    value: 'rolling' # options: rolling, blue-green, canary
  - name: healthCheckRetries
    value: 12
  - name: healthCheckInterval
    value: 10
```

## Environment-Specific Configuration

### Development Environment
Create variable group `dev-environment` with:

| Variable | Value |
|----------|-------|
| `vmPrivateIp` | `10.0.1.10` |
| `vmPublicIp` | `203.0.113.10` |
| `deploymentEnvironment` | `development` |
| `healthCheckRetries` | `5` |

### Staging Environment  
Create variable group `staging-environment` with:

| Variable | Value |
|----------|-------|
| `vmPrivateIp` | `10.0.1.50` |
| `vmPublicIp` | `203.0.113.50` |
| `deploymentEnvironment` | `staging` |
| `healthCheckRetries` | `8` |

### Production Environment
Create variable group `prod-environment` with:

| Variable | Value |
|----------|-------|
| `vmPrivateIp` | `10.0.1.100` |
| `vmPublicIp` | `203.0.113.100` |
| `deploymentEnvironment` | `production` |
| `healthCheckRetries` | `12` |

## Runtime Variables (Auto-Generated)

These variables are automatically set during pipeline execution:

| Variable Name | Source | Description |
|---------------|--------|-------------|
| `btPassword` | BeyondTrust API | Privileged account password (secret) |
| `btSessionId` | BeyondTrust API | Active PAM session identifier |
| `sessionExpiryTime` | BeyondTrust API | Session expiration timestamp |
| `mfaChallengeId` | BeyondTrust API | MFA challenge identifier |

## BeyondTrust PAM Setup Requirements

### API Key Generation
1. Log into BeyondTrust Password Safe
2. Navigate to Configuration → Application Registration
3. Create new application registration
4. Generate API key with following permissions:
   - Managed Account Checkout
   - MFA Challenge
   - Session Management
5. Copy API key to Azure DevOps variable `btApiKey`

### Managed Account Configuration
1. In BeyondTrust, navigate to Managed Systems
2. Add your production VM as managed system
3. Create managed account for deployment service account
4. Configure password rotation policy
5. Note the managed account ID for `managedAccountId` variable

### MFA Configuration
1. Configure MFA provider in BeyondTrust
2. Associate MFA with deployment user account
3. Test MFA challenge workflow
4. Configure notification preferences

## VM Infrastructure Setup Requirements

### Prerequisites
The target VM must have the following installed and configured:

#### Required Software
```bash
# Java 17
sudo apt update
sudo apt install openjdk-17-jdk

# Maven
sudo apt install maven

# Tomcat 9
sudo apt install tomcat9

# MuleSoft Runtime (install separately)
# Download from MuleSoft website and install to /opt/mule

# Required utilities
sudo apt install curl jq unzip
```

#### Required Directories
```bash
# Create backup directories
sudo mkdir -p /opt/backups/mulesoft
sudo mkdir -p /opt/backups/tomcat

# Create temporary deployment directories
sudo mkdir -p /tmp/mulesoft-deploy
sudo mkdir -p /tmp/tomcat-deploy

# Set proper permissions
sudo chown -R deployment-user:deployment-group /opt/backups
sudo chown -R tomcat:tomcat /var/lib/tomcat9/webapps
sudo chown -R mule:mule /opt/mule
```

#### Service Configuration
```bash
# Enable services
sudo systemctl enable tomcat9
sudo systemctl enable mule

# Configure service accounts
sudo useradd -r -s /bin/false tomcat
sudo useradd -r -s /bin/false mule
```

### Network Configuration
- Ensure VM can communicate with BeyondTrust server
- Configure firewall rules for required ports:
  - SSH: 22
  - Tomcat: 8080
  - MuleSoft: 8081
  - HTTPS: 443 (if using SSL termination)

### Security Configuration
```bash
# Configure SSH for deployment user
sudo useradd -m -s /bin/bash svc-deploy
sudo usermod -aG sudo svc-deploy

# Add SSH public key for BeyondTrust managed account
sudo mkdir -p /home/svc-deploy/.ssh
# Add public key to authorized_keys

# Configure sudo access
echo "svc-deploy ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/svc-deploy
```

## Pipeline Environments Setup

### Create Deployment Environments
1. Navigate to Azure DevOps → Pipelines → Environments
2. Create environment named `production-vm`
3. Add your production VM as a resource
4. Configure approval gates if required
5. Set environment variables if needed

### Environment-Specific Variables
For each environment, you can override variables:

```yaml
# In your pipeline, use environment-specific variable groups
variables:
- ${{ if eq(variables['Build.SourceBranch'], 'refs/heads/main') }}:
  - group: prod-environment
- ${{ if eq(variables['Build.SourceBranch'], 'refs/heads/develop') }}:
  - group: dev-environment
- ${{ if startsWith(variables['Build.SourceBranch'], 'refs/heads/release/') }}:
  - group: staging-environment
```

## Security Best Practices

### Secret Management
1. **Never commit secrets to code**
2. **Use Azure Key Vault integration** for sensitive data
3. **Enable secret scanning** in repositories
4. **Rotate secrets regularly**
5. **Use managed identities** where possible

### Access Control
1. **Limit pipeline edit permissions**
2. **Require approvals for production deployments**
3. **Use service connections** for external integrations
4. **Enable audit logging**
5. **Regular access reviews**

### Network Security
1. **Use private endpoints** where possible
2. **Enable VPN/ExpressRoute** for hybrid connectivity
3. **Configure network security groups**
4. **Use HTTPS/TLS** for all communications
5. **Regular security assessments**

## Troubleshooting Guide

### Common Variable Issues

#### BeyondTrust Authentication Failures
```
Error: BeyondTrust checkout failed: 401 Unauthorized
```
**Solution:** 
- Verify `btApiKey` is correct and has proper permissions
- Check `beyondtrustApiUrl` is accessible from Azure DevOps agents
- Ensure managed account exists and is active

#### VM Connection Issues
```
Error: SSH connection failed
```
**Solution:**
- Verify `vmPrivateIp` and `sshPort` are correct
- Check BeyondTrust session is active
- Ensure network connectivity from Azure DevOps agents

#### MFA Challenge Issues
```
Error: MFA challenge failed
```
**Solution:**
- Verify `deploymentUser` has MFA configured
- Check MFA provider is accessible
- Ensure notification settings are correct

### Variable Validation Script

Create this PowerShell script to validate your variables:

```powershell
# validate-variables.ps1
param(
    [string]$VariableGroupName
)

# Test BeyondTrust connectivity
$btUrl = "$(beyondtrustApiUrl)/PasswordSafe/api/v3/Auth/SignAppIn"
try {
    $response = Invoke-WebRequest -Uri $btUrl -Method GET
    Write-Host "✅ BeyondTrust API accessible"
} catch {
    Write-Host "❌ BeyondTrust API not accessible: $_"
}

# Test VM connectivity
$vmIp = "$(vmPrivateIp)"
$vmPort = "$(sshPort)"
try {
    $connection = Test-NetConnection -ComputerName $vmIp -Port $vmPort
    if ($connection.TcpTestSucceeded) {
        Write-Host "✅ VM SSH connectivity successful"
    } else {
        Write-Host "❌ VM SSH connectivity failed"
    }
} catch {
    Write-Host "❌ VM connectivity test failed: $_"
}
```

## Environment Validation Checklist

Before running the pipeline, ensure:

### BeyondTrust Configuration
- [ ] API key is valid and has required permissions
- [ ] Managed account is configured for target VM
- [ ] MFA is configured for deployment user
- [ ] BeyondTrust server is accessible from Azure DevOps

### VM Infrastructure
- [ ] VM is accessible via SSH
- [ ] Required software is installed (Java, Maven, Tomcat, MuleSoft)
- [ ] Service accounts are configured
- [ ] Backup directories exist with proper permissions
- [ ] Network connectivity is established

### Azure DevOps Configuration
- [ ] Variable groups are created and populated
- [ ] Secrets are marked as secret variables
- [ ] Environment is created with proper approvals
- [ ] Service connections are configured
- [ ] Pipeline permissions are set correctly

### Application Configuration
- [ ] Angular application builds successfully
- [ ] MuleSoft application builds and passes tests
- [ ] Application-specific configurations are correct
- [ ] Health check endpoints are accessible

## Support and Maintenance

### Regular Tasks
1. **Monthly:** Review and rotate secrets
2. **Quarterly:** Update dependency versions
3. **Annually:** Security assessment and penetration testing

### Monitoring
- Set up alerts for pipeline failures
- Monitor deployment success rates
- Track deployment duration trends
- Monitor security scan results

### Documentation Updates
Keep this document updated when:
- Adding new environments
- Changing infrastructure
- Updating security requirements
- Modifying deployment processes

---

## Quick Reference

### Essential Variable Groups
1. `beyondtrust-config` - PAM and security settings
2. `vm-infrastructure` - Target infrastructure details  
3. `mulesoft-config` - MuleSoft deployment settings
4. `security-config` - Security scanning configuration

### Critical Secrets
- `btApiKey` - BeyondTrust API authentication
- Auto-generated: `btPassword` - Privileged account password

### Key Endpoints to Test
- BeyondTrust API: `$(beyondtrustApiUrl)/PasswordSafe/api/v3/Auth/SignAppIn`
- VM SSH: `$(vmPrivateIp):$(sshPort)`
- MuleSoft Health: `http://$(vmPrivateIp):8081/api/health`
- Angular App: `http://$(vmPublicIp):8080/$(appContext)/`

For additional support, consult your platform team or refer to the troubleshooting section above.
