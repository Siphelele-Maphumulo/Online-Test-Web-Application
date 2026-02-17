# Security Configuration Guide

This document explains how to properly configure API keys and sensitive data to keep them secure and out of version control.

## 🚨 IMPORTANT: Never Commit Sensitive Data

All API keys, passwords, and secrets should be kept **OUT** of version control. This repository is configured to automatically ignore sensitive files.

## 📁 Security File Structure

```
Online-Test-Web-Application/
├── .env.example                    # Environment variables template
├── .env                           # Your actual environment variables (DO NOT COMMIT)
├── openrouter.properties.example    # OpenRouter config template
├── openrouter.properties           # Your actual OpenRouter config (DO NOT COMMIT)
├── config/
│   ├── secrets.properties.example   # Secrets configuration template
│   └── secrets.properties         # Your actual secrets (DO NOT COMMIT)
└── .gitignore                     # Configured to ignore sensitive files
```

## 🔧 Setup Instructions

### 1. Environment Variables (.env)

```bash
# Copy the example file
cp .env.example .env

# Edit with your actual values
# NEVER commit .env to git!
```

### 2. OpenRouter Configuration

```bash
# Copy the example file
cp openrouter.properties.example openrouter.properties

# Edit with your actual OpenRouter API key
# NEVER commit openrouter.properties to git!
```

### 3. Application Secrets

```bash
# Copy the example file
cp config/secrets.properties.example config/secrets.properties

# Edit with your actual database credentials and API keys
# NEVER commit secrets.properties to git!
```

## 🔑 API Keys Used in This Project

### OpenRouter API Key
- **Environment Variable**: `OPENROUTER_API_KEY`
- **Properties File**: `openrouter.api.key`
- **Used in**: `OpenRouterConfig.java`, `OpenRouterClient.java`

### Database Credentials
- **Properties File**: `db.url`, `db.username`, `db.password`
- **Used in**: Database connection configuration

## 🛡️ Security Best Practices

### 1. Environment Variables (Recommended)
```bash
# Set environment variables in your server environment
export OPENROUTER_API_KEY="your_actual_api_key_here"
export DB_PASSWORD="your_actual_db_password_here"
```

### 2. Properties Files (Development Only)
```properties
# In openrouter.properties
openrouter.api.key=your_actual_api_key_here

# In config/secrets.properties
db.password=your_actual_db_password_here
```

### 3. Server Configuration (Production)
```bash
# For Tomcat, set in catalina.properties or as JVM properties
-Dopenrouter.api.key=your_actual_api_key_here
```

## 🚫 Files Already Ignored by Git

The following files are automatically ignored by `.gitignore`:
- `.env` and all `.env.*` files
- `openrouter.properties`
- `config/secrets.properties`
- `*.properties` files (except examples)
- API key and secret files
- Build outputs that might contain secrets

## 🔍 How API Keys Are Loaded

The application follows this priority order:

1. **System Properties** (highest priority)
2. **Environment Variables** 
3. **Properties Files** (lowest priority)

This allows you to override configuration for different environments.

## 🚀 Deployment Security

### Development
- Use `.env` file for local development
- Keep API keys in properties files
- Never commit sensitive data

### Staging
- Use environment variables
- Keep secrets in secure configuration
- Rotate API keys regularly

### Production
- **NEVER** use properties files for secrets
- Use environment variables or secure vault
- Enable encryption for sensitive data
- Regular security audits

## 🔄 Rotating API Keys

1. Generate new API key from service provider
2. Update environment variables or configuration
3. Restart application
4. Revoke old API key
5. Verify application still works

## 📞 Security Issues

If you discover any security vulnerabilities or accidentally commit sensitive data:

1. **Immediately**: Remove the sensitive data from the repository
2. **Rotate**: Change all exposed API keys and passwords
3. **History**: Remove from git history if necessary
4. **Contact**: Report security issues through proper channels

## 🛠️ Additional Security Measures

- Enable HTTPS in production
- Use strong, unique passwords
- Implement rate limiting
- Regular security updates
- Monitor for unauthorized access
- Use secure coding practices

---

**Remember**: Security is everyone's responsibility. Keep sensitive data secure! 🛡️
