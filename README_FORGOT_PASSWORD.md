# Forgot Password Feature - Implementation Guide

## Overview
This document describes the implementation of the forgot password feature for the Online Test Web Application.

## Features Implemented

### 1. User-Friendly Interface
- **Responsive Design**: Matches the styling of other pages with header, sidebar, and footer
- **Multi-Step Process**: 3-step wizard for password reset
  - Step 1: Email Verification
  - Step 2: Code Verification  
  - Step 3: New Password Entry
- **Real-time Validation**: Email existence check, password strength meter
- **Visual Feedback**: Icons, colors, and animations for better UX

### 2. Security Features
- **8-Character Verification Code**: Randomly generated alphanumeric code
- **Time-Limited Codes**: Codes expire after 1 hour
- **Password Hashing**: Uses BCrypt for secure password storage
- **Password Requirements**: 
  - Minimum 8 characters
  - At least one uppercase letter
  - At least one lowercase letter
  - At least one number
  - At least one special character
- **Code Verification**: Server-side validation before password reset

### 3. Email Integration
- **Professional HTML Emails**: Styled email templates
- **Personalized Content**: Uses user's first name in emails
- **Clear Instructions**: Step-by-step guide in email
- **Expiry Warning**: Clearly states code validity period

## Database Schema

### verification_codes Table
```sql
CREATE TABLE `verification_codes` (
  `id` INT(11) NOT NULL AUTO_INCREMENT,
  `email` VARCHAR(100) NOT NULL,
  `code` VARCHAR(8) NOT NULL,
  `user_type` VARCHAR(20) NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  INDEX `idx_email` (`email`),
  INDEX `idx_created_at` (`created_at`)
);
```

## Installation Steps

### 1. Database Setup
Run the SQL script to create the verification_codes table:
```bash
mysql -u root -p exam_system < "db script/add_verification_codes_table.sql"
```

Or execute in phpMyAdmin/MySQL Workbench:
- Navigate to `db script/add_verification_codes_table.sql`
- Execute the script

### 2. Email Configuration
Ensure your `mail.properties` file is properly configured:
```properties
EMAIL_USER=your-email@gmail.com
EMAIL_PASS=your-app-password
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
EMAIL_FROM=noreply@yourdomain.com
```

**Note**: For Gmail, you need to create an App Password:
1. Go to Google Account Settings
2. Security → 2-Step Verification
3. App passwords → Generate new app password
4. Use the generated password in `EMAIL_PASS`

### 3. Files Modified/Created

#### Modified Files:
- `web/Forgot_Password.jsp` - Complete redesign with header/footer integration
- `src/java/myPackage/DatabaseClass.java` - Added password reset methods
- `web/controller.jsp` - Added forgot password handlers

#### New Files:
- `db script/add_verification_codes_table.sql` - Database migration script
- `README_FORGOT_PASSWORD.md` - This documentation file

## Usage Flow

### For Users:

1. **Access Forgot Password Page**
   - Click "Forgot Password" link on login page
   - Or navigate directly to `Forgot_Password.jsp`

2. **Step 1: Enter Email**
   - Enter registered email address
   - System checks if email exists in database
   - "Send Verification Code" button enables only for valid emails

3. **Step 2: Receive and Enter Code**
   - Check email for 8-character verification code
   - Enter code on the page
   - Code expires after 1 hour
   - Option to resend code (with 60-second cooldown)

4. **Step 3: Set New Password**
   - Enter new password meeting requirements
   - Confirm password
   - Password strength indicator shows security level
   - Submit to complete reset

5. **Success**
   - Password successfully updated
   - Redirect to login page
   - User can now login with new password

## API Endpoints (controller.jsp)

### Check Email Existence
```
POST /controller.jsp
Parameters: page=forgot_password&action=check_email&email={email}
Response: "exists" or "not_exists"
```

### Send Verification Code
```
POST /controller.jsp
Parameters: page=forgot_password&action=send_code&email={email}
Response: "success" or "error"
```

### Verify Code
```
POST /controller.jsp
Parameters: page=forgot_password&action=verify_code&email={email}&code={code}
Response: "valid" or "invalid"
```

### Resend Code
```
POST /controller.jsp
Parameters: page=forgot_password&action=resend_code&email={email}
Response: "success" or "error"
```

### Reset Password
```
POST /controller.jsp
Parameters: 
  - page=forgot_password
  - action=reset_password
  - email={email}
  - code={code}
  - password={new_password}
  - confirm_password={confirm_password}
Response: "success", "password_mismatch", "weak_password", or "error"
```

## Backend Methods (DatabaseClass.java)

### New Methods Added:

1. **storeVerificationCode(String email, String code, String userType)**
   - Stores verification code in database
   - Deletes any existing codes for the email
   - Returns true if successful

2. **verifyResetCode(String email, String code)**
   - Verifies if code is valid and not expired
   - Checks code created within last hour
   - Returns true if valid

3. **updatePasswordByEmail(String email, String newPassword, String code)**
   - Updates user password after verification
   - Uses transaction for atomicity
   - Deletes used verification code
   - Returns true if successful

4. **getUserTypeByEmail(String email)**
   - Gets user type for email
   - Used for storing correct user type with code

5. **getFirstNameByEmail(String email)**
   - Gets first name for personalized emails
   - Returns "User" if not found

## Email Templates

The system sends professional HTML emails with:
- Company branding
- Clear verification code display
- Step-by-step instructions
- Expiry warning (1 hour)
- Contact information
- Responsive design

## Security Considerations

1. **Rate Limiting**: Consider adding rate limiting to prevent abuse
2. **CAPTCHA**: Consider adding CAPTCHA for additional security
3. **Audit Logging**: Log all password reset attempts
4. **Account Lockout**: Consider locking accounts after multiple failed attempts
5. **Email Verification**: Ensure emails are verified before allowing password reset

## Testing Checklist

- [ ] Email exists check works correctly
- [ ] Email does not exist shows proper error
- [ ] Verification code is sent to email
- [ ] Code is stored in database correctly
- [ ] Code verification works
- [ ] Expired codes are rejected
- [ ] Invalid codes are rejected
- [ ] Password requirements are enforced
- [ ] Password confirmation works
- [ ] Password is properly hashed
- [ ] Password is updated in database
- [ ] Used codes are deleted
- [ ] User can login with new password
- [ ] Resend code functionality works
- [ ] 60-second cooldown for resend works
- [ ] All UI elements display correctly
- [ ] Responsive design works on mobile
- [ ] Header and footer display correctly

## Troubleshooting

### Email not sending:
1. Check `mail.properties` configuration
2. Verify SMTP credentials
3. Check for firewall blocking SMTP port
4. Enable "Less secure app access" for Gmail (or use App Password)

### Database errors:
1. Ensure `verification_codes` table exists
2. Check database connection settings
3. Verify user has proper permissions

### Code not verifying:
1. Check code is entered correctly (case-sensitive)
2. Verify code hasn't expired (1 hour limit)
3. Ensure email matches exactly

## Future Enhancements

1. **SMS Verification**: Add option to receive code via SMS
2. **Security Questions**: Add security questions as alternative
3. **Two-Factor Authentication**: Implement 2FA for password reset
4. **Password History**: Prevent reuse of recent passwords
5. **Account Recovery**: Add additional recovery options
6. **Analytics Dashboard**: Track password reset statistics

## Support

For issues or questions:
- Email: Siphelelemaphumulo@gmail.com
- Phone: 068 676 4623

---
**Last Updated**: January 2026
**Version**: 1.0
