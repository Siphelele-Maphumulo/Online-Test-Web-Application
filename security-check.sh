#!/bin/bash

# Security Check Script
# This script helps verify that API keys are properly secured

echo "🔍 Security Configuration Check"
echo "=================================="

# Check for .env file
if [ -f ".env" ]; then
    echo "✅ .env file exists"
    if grep -q "your_.*_here" .env; then
        echo "⚠️  WARNING: .env contains placeholder values"
    else
        echo "✅ .env appears to be configured"
    fi
else
    echo "❌ .env file not found (copy from .env.example)"
fi

# Check for openrouter.properties
if [ -f "openrouter.properties" ]; then
    echo "✅ openrouter.properties exists"
    if grep -q "your_.*_here" openrouter.properties; then
        echo "⚠️  WARNING: openrouter.properties contains placeholder values"
    else
        echo "✅ openrouter.properties appears to be configured"
    fi
else
    echo "❌ openrouter.properties not found (copy from openrouter.properties.example)"
fi

# Check for secrets.properties
if [ -f "config/secrets.properties" ]; then
    echo "✅ config/secrets.properties exists"
    if grep -q "your_.*_here" config/secrets.properties; then
        echo "⚠️  WARNING: config/secrets.properties contains placeholder values"
    else
        echo "✅ config/secrets.properties appears to be configured"
    fi
else
    echo "❌ config/secrets.properties not found (copy from config/secrets.properties.example)"
fi

# Check environment variables
echo ""
echo "🔧 Environment Variables:"
echo "OPENROUTER_API_KEY: ${OPENROUTER_API_KEY:+✅ Set}${OPENROUTER_API_KEY:-❌ Not set}"

# Check git status
echo ""
echo "📁 Git Status Check:"
if command -v git &> /dev/null; then
    if git rev-parse --git-dir > /dev/null 2>&1; then
        # Check if sensitive files are tracked
        if git ls-files | grep -E "\.env$|openrouter\.properties$|secrets\.properties$" > /dev/null; then
            echo "❌ WARNING: Sensitive files are tracked in git!"
            echo "Files that should not be tracked:"
            git ls-files | grep -E "\.env$|openrouter\.properties$|secrets\.properties$"
        else
            echo "✅ No sensitive files tracked in git"
        fi
        
        # Check .gitignore
        if [ -f ".gitignore" ]; then
            if grep -q "\.env" .gitignore && grep -q "openrouter.properties" .gitignore; then
                echo "✅ .gitignore properly configured"
            else
                echo "⚠️  .gitignore may need updating"
            fi
        else
            echo "❌ .gitignore not found"
        fi
    else
        echo "ℹ️  Not a git repository"
    fi
else
    echo "ℹ️  Git not available"
fi

echo ""
echo "📋 Security Checklist:"
echo "1. ✅ Copy .env.example to .env and configure"
echo "2. ✅ Copy openrouter.properties.example to openrouter.properties and configure"
echo "3. ✅ Copy config/secrets.properties.example to config/secrets.properties and configure"
echo "4. ✅ Set environment variables in production"
echo "5. ✅ Never commit sensitive files to version control"
echo "6. ✅ Regularly rotate API keys"
echo "7. ✅ Use HTTPS in production"

echo ""
echo "🔐 Security setup complete!"
