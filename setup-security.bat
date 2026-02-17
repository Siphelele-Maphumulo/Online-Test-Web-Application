@echo off
echo 🔐 Setting up Security Configuration
echo ==================================

echo.
echo 📁 Creating security configuration files...

REM Create .env file if it doesn't exist
if not exist ".env" (
    echo ✅ Creating .env file...
    copy ".env.example" ".env" >nul
    echo    Please edit .env with your actual API keys
) else (
    echo ℹ️  .env file already exists
)

REM Create openrouter.properties if it doesn't exist
if not exist "openrouter.properties" (
    echo ✅ Creating openrouter.properties...
    copy "openrouter.properties.example" "openrouter.properties" >nul
    echo    Please edit openrouter.properties with your OpenRouter API key
) else (
    echo ℹ️  openrouter.properties already exists
)

REM Create config directory if it doesn't exist
if not exist "config" (
    echo ✅ Creating config directory...
    mkdir "config"
)

REM Create secrets.properties if it doesn't exist
if not exist "config\secrets.properties" (
    echo ✅ Creating config\secrets.properties...
    copy "config\secrets.properties.example" "config\secrets.properties" >nul
    echo    Please edit config\secrets.properties with your database credentials
) else (
    echo ℹ️  config\secrets.properties already exists
)

echo.
echo 🚀 Next Steps:
echo 1. Edit .env file with your environment variables
echo 2. Edit openrouter.properties with your OpenRouter API key
echo 3. Edit config\secrets.properties with your database credentials
echo 4. Run security-check.bat to verify your setup
echo 5. Never commit these files to version control!

echo.
echo 📚 For detailed instructions, see: SECURITY.md

echo.
echo 🔐 Security setup complete!
pause
