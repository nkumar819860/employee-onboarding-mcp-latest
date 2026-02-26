# Token Authentication Guide for Anypoint Exchange

## Overview
You have two authentication methods configured in your settings.xml:

### 1. Bearer Token Authentication (~~~Token~~~)
```xml
<server>
  <id>anypoint-exchange</id>
  <username>~~~Token~~~</username>
  <password>9857e72e-ea97-4826-8887-a872d2849aab</password>
</server>
```

### 2. Connected App Credentials (~~~Client~~~)
```xml
<server>
  <id>anypoint-exchange</id>
  <username>~~~Client~~~</username>
  <password>867ff64da92f4dd89c428f27c3f7c7f1~~~09f4C0a99F494785be2918F6e0Cd6e9B</password>
</server>
```

## Current Configuration Analysis

Based on your .env file, you have:
- **Client ID**: `867ff64da92f4dd89c428f27c3f7c7f1`
- **Client Secret**: `09f4C0a99F494785be2918F6e0Cd6e9B`
- **Organization ID**: `47562e5d-bf49-440a-a0f5-a9cea0a89aa9`

## How to Obtain Bearer Tokens

### Method 1: Generate from Anypoint Platform UI
1. **Login to Anypoint Platform**: https://anypoint.mulesoft.com/
2. **Navigate to Access Management**:
   - Click on your profile (top-right)
   - Select "Access Management"
3. **Generate Personal Token**:
   - Go to "Personal" → "My Profile"
   - Click "Generate Token"
   - **IMPORTANT**: Copy the token immediately - it's only shown once!

### Method 2: Using REST API (Programmatic)
```bash
# Get Bearer Token using your Connected App credentials
curl -X POST "https://anypoint.mulesoft.com/accounts/api/v2/oauth2/token" \
  -H "Content-Type: application/json" \
  -d '{
    "client_id": "867ff64da92f4dd89c428f27c3f7c7f1",
    "client_secret": "09f4C0a99F494785be2918F6e0Cd6e9B",
    "grant_type": "client_credentials"
  }'
```

Response:
```json
{
  "access_token": "9857e72e-ea97-4826-8887-a872d2849aab",
  "token_type": "Bearer",
  "expires_in": 3600
}
```

### Method 3: Using Anypoint CLI
```bash
# Install Anypoint CLI
npm install -g anypoint-cli

# Configure with your credentials
anypoint-cli conf client_id 867ff64da92f4dd89c428f27c3f7c7f1
anypoint-cli conf client_secret 09f4C0a99F494785be2918F6e0Cd6e9B

# Get token info
anypoint-cli account describe
```

## Authentication Method Comparison

| Method | Format | Usage | Security | Duration |
|--------|--------|-------|----------|----------|
| **~~~Token~~~** | Bearer Token | Personal/Individual | Medium | Limited (expires) |
| **~~~Client~~~** | Connected App | Automated/CI/CD | High | Renewable |

## When to Use Each Method

### Use Bearer Token (~~~Token~~~) when:
- ✅ Individual developer authentication
- ✅ Quick testing/prototyping
- ✅ Personal projects
- ❌ **NOT for production/CI/CD**

### Use Connected App (~~~Client~~~) when:
- ✅ Production deployments
- ✅ CI/CD pipelines
- ✅ Automated systems
- ✅ Team collaboration
- ✅ **RECOMMENDED for your project**

## Token Expiration and Renewal

### Bearer Tokens:
- **Expire**: Typically 1-24 hours
- **Renewal**: Must regenerate manually from UI or API
- **Risk**: Can break builds if expired

### Connected App Tokens:
- **Expire**: Based on org settings (usually longer)
- **Renewal**: Automatic via client credentials
- **Risk**: Lower, self-renewing

## Script to Generate Fresh Token

```bash
@echo off
echo Getting fresh bearer token...

curl -X POST "https://anypoint.mulesoft.com/accounts/api/v2/oauth2/token" ^
  -H "Content-Type: application/json" ^
  -d "{\"client_id\": \"867ff64da92f4dd89c428f27c3f7c7f1\", \"client_secret\": \"09f4C0a99F494785be2918F6e0Cd6e9B\", \"grant_type\": \"client_credentials\"}" ^
  -o token.json

echo Token saved to token.json
type token.json
```

## Best Practices

### 1. Settings.xml Configuration
**Recommended** - Use only Connected App:
```xml
<server>
  <id>anypoint-exchange</id>
  <username>~~~Client~~~</username>
  <password>867ff64da92f4dd89c428f27c3f7c7f1~~~09f4C0a99F494785be2918F6e0Cd6e9B</password>
</server>
```

### 2. Environment Variables
Store credentials in environment variables:
```bash
set ANYPOINT_CLIENT_ID=867ff64da92f4dd89c428f27c3f7c7f1
set ANYPOINT_CLIENT_SECRET=09f4C0a99F494785be2918F6e0Cd6e9B
```

### 3. Security
- ✅ **Never commit credentials to Git**
- ✅ Use environment variables or secure vaults
- ✅ Rotate credentials regularly
- ✅ Use Connected Apps for production

## Your Token Source Analysis

Looking at your current token `9857e72e-ea97-4826-8887-a872d2849aab`:
- **Format**: UUID-like format
- **Source**: Likely generated from your Connected App
- **Method**: Probably obtained via OAuth2 client credentials flow
- **Status**: Should be valid for API calls

## Troubleshooting Common Issues

### 401 Unauthorized
```bash
# Test your current token
curl -H "Authorization: Bearer 9857e72e-ea97-4826-8887-a872d2849aab" \
  "https://anypoint.mulesoft.com/accounts/api/me"
```

### Token Expired
```bash
# Generate new token using your Connected App
curl -X POST "https://anypoint.mulesoft.com/accounts/api/v2/oauth2/token" \
  -H "Content-Type: application/json" \
  -d '{"client_id":"867ff64da92f4dd89c428f27c3f7c7f1","client_secret":"09f4C0a99F494785be2918F6e0Cd6e9B","grant_type":"client_credentials"}'
```

## Recommendations for Your Setup

1. **Current Status**: Your setup is correctly configured with both methods
2. **Production Use**: Stick with Connected App (~~~Client~~~) method
3. **Token Management**: Automate token refresh in your deployment scripts
4. **Security**: Consider rotating your Connected App credentials quarterly

## Connected App Scopes Required

Ensure your Connected App has these scopes:
- `read:full`
- `write:full` 
- `cloudhub:application-deployment`
- `exchange:author`
- `exchange:viewer`

Your Connected App should be configured at: https://anypoint.mulesoft.com/accounts/#/cs/core/applications
