@echo off
echo 🔍 Security Configuration Check
echo ==================================

REM Check for .env file
if exist ".env" (
    echo ✅ .env file exists
    findstr /C:"your_" .env >nul
    if %errorlevel%==0 (
        echo ⚠️  WARNING: .env contains placeholder values
    ) else (
        echo ✅ .env appears to be configured
    )
) else (
    echo ❌ .env file not found ^(copy from .env.example^)
)

REM Check for openrouter.properties
if exist "openrouter.properties" (
    echo ✅ openrouter.properties exists
    findstr /C:"your_" openrouter.properties >nul
    if %errorlevel%==0 (
        echo ⚠️  WARNING: openrouter.properties contains placeholder values
    ) else (
        echo ✅ openrouter.properties appears to be configured
    )
) else (
    echo ❌ openrouter.properties not found ^(copy from openrouter.properties.example^)
)

REM Check for secrets.properties
if exist "config\secrets.properties" (
    echo ✅ config\secrets.properties exists
    findstr /C:"your_" config\secrets.properties >nul
    if %errorlevel%==0 (
        echo ⚠️  WARNING: config\secrets.properties contains placeholder values
    ) else (
        echo ✅ config\secrets.properties appears to be configured
    )
) else (
    echo ❌ config\secrets.properties not found ^(copy from config\secrets.properties.example^)
)

echo.
echo 🔧 Environment Variables:
if defined OPENROUTER_API_KEY (
    echo ✅ OPENROUTER_API_KEY: Set
) else (
    echo ❌ OPENROUTER_API_KEY: Not set
)

REM Check git status
echo.
echo 📁 Git Status Check:
git --version >nul 2>&1
if %errorlevel%==0 (
    git rev-parse --git-dir >nul 2>&1
    if %errorlevel%==0 (
        REM Check if sensitive files are tracked
        git ls-files | findstr /R "\.env$ openrouter\.properties$ secrets\.properties$" >nul
        if %errorlevel%==0 (
            echo ❌ WARNING: Sensitive files are tracked in git!
            echo Files that should not be tracked:
            git ls-files | findstr /R "\.env$ openrouter\.properties$ secrets\.properties$"
        ) else (
            echo ✅ No sensitive files tracked in git
        )
        
        REM Check .gitignore
        if exist ".gitignore" (
            findstr /C:".env" .gitignore >nul
            if %errorlevel%==0 (
                findstr /C:"openrouter.properties" .gitignore >nul
                if %errorlevel%==0 (
                    echo ✅ .gitignore properly configured
                ) else (
                    echo ⚠️  .gitignore may need updating
                )
            ) else (
                echo ⚠️  .gitignore may need updating
            )
        ) else (
            echo ❌ .gitignore not found
        )
    ) else (
        echo ℹ️  Not a git repository
    )
) else (
    echo ℹ️  Git not available
)

echo.
echo 📋 Security Checklist:
echo 1. ✅ Copy .env.example to .env and configure
echo 2. ✅ Copy openrouter.properties.example to openrouter.properties and configure
echo 3. ✅ Copy config\secrets.properties.example to config\secrets.properties and configure
echo 4. ✅ Set environment variables in production
echo 5. ✅ Never commit sensitive files to version control
echo 6. ✅ Regularly rotate API keys
echo 7. ✅ Use HTTPS in production

echo.
echo 🔐 Security setup complete!
pause
