# Exchange Plugin Connectivity Fix

## Problem Analysis
The error indicates that Maven cannot resolve the `exchange-mule-maven-plugin:0.1.4` dependency due to network connectivity issues to `repository.mulesoft.org`.

## Root Cause
- Connection timeout to repository.mulesoft.org (ports 443)
- The exchange plugin is being pulled as a transitive dependency of the mule-maven-plugin
- Network firewall or connectivity issues blocking access to MuleSoft repositories

## Solutions

### Solution 1: Skip Exchange Publishing (Fastest Fix)
Add the following property to disable exchange publishing during deployment:

```xml
<properties>
    <exchange.skip>true</exchange.skip>
</properties>
```

### Solution 2: Network Connectivity Fixes

#### Option A: Use Alternative Repository URLs
Add these repositories with fallback URLs:

```xml
<repositories>
    <repository>
        <id>mulesoft-releases-fallback</id>
        <url>https://repository-master.mulesoft.org/releases/</url>
    </repository>
</repositories>
```

#### Option B: Configure Proxy Settings
If behind a corporate firewall, add proxy settings to Maven settings.xml:

```xml
<proxies>
    <proxy>
        <id>corporate-proxy</id>
        <active>true</active>
        <protocol>https</protocol>
        <host>your-proxy-host</host>
        <port>8080</port>
        <username>your-username</username>
        <password>your-password</password>
    </proxy>
</proxies>
```

### Solution 3: Force Plugin Version
Explicitly declare the exchange plugin version in parent POM:

```xml
<pluginManagement>
    <plugins>
        <plugin>
            <groupId>org.mule.tools.maven</groupId>
            <artifactId>exchange-mule-maven-plugin</artifactId>
            <version>0.1.5</version> <!-- Use newer version -->
        </plugin>
    </plugins>
</pluginManagement>
```

### Solution 4: Offline Mode
Run Maven in offline mode to skip repository checks:
```bash
mvn clean install -o
```

## Immediate Fix Implementation
The quickest fix is to disable exchange publishing since it's optional for deployment.
