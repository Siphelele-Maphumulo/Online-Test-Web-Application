# Forgot Password - Quick Test Guide

## Prerequisites
1. XAMPP/MySQL running
2. Database `exam_system` exists with test users
3. Email configuration in `mail.properties` is correct

## Step-by-Step Testing

### 1. Database Setup
```sql
-- First, create the verification_codes table
-- Execute the script: db script/add_verification_codes_table.sql

-- Verify table was created
DESCRIBE verification_codes;

-- You should see:
-- id, email, code, user_type, created_at columns
```

### 2. Test User Setup
Make sure you have a test user in the database:
```sql
-- Check if you have test users
SELECT user_id, first_name, email, user_type FROM users;

-- If not, insert a test user
INSERT INTO users (first_name, last_name, user_name, email, password, user_type, contact_no, city, address)
VALUES 
('Test', 'User', '12345678', 'testuser@gmail.com', 
 '$2a$10$KIXQGqYvMb.vOPbQdHWqguJXq2B8aLtKvFx.ZJdL3CkLQjJ0LqFXi', 
 'student', '0123456789', 'Durban', '123 Test Street');

-- Password for above user is: Test@1234
```

### 3. Access the Forgot Password Page
1. Open browser: `http://localhost/Online-Test-Web-Application/Forgot_Password.jsp`
2. You should see a professional page with:
   - Header with logo
   - Sidebar navigation
   - 3-step indicator
   - Email input form
   - Footer

### 4. Test Email Verification (Step 1)
1. Enter an invalid email: `invalid@test.com`
   - Status should show: "Email not found in our system"
   - Button should remain disabled
   
2. Enter a valid email: `testuser@gmail.com`
   - Status should show: "Email verified" (green checkmark)
   - "Send Verification Code" button should enable

3. Click "Send Verification Code"
   - Loading indicator should appear
   - Should move to Step 2
   - Email should be sent

### 5. Test Code Verification (Step 2)
1. Check your email inbox
   - You should receive a professional HTML email
   - Subject: "Password Reset Request - Code SA Institute"
   - Email contains 8-character code (e.g., "AB12CD34")

2. Enter the code from email
   - Enter the exact code (case-insensitive)
   - Click "Verify Code"
   - Should move to Step 3

3. Test invalid code
   - Go back to Step 2 (click Back button on Step 3)
   - Enter wrong code: "XXXXXXXX"
   - Should show error: "Invalid verification code"

4. Test resend functionality
   - Click "Resend Code"
   - 60-second countdown should start
   - New code should be sent to email

### 6. Test Password Reset (Step 3)
1. Enter weak password: `test`
   - Password strength should show "Weak password"
   - Reset button should be disabled

2. Enter strong password: `NewPass@123`
   - Requirements should turn green as you type:
     - ✓ At least 8 characters
     - ✓ One uppercase letter
     - ✓ One lowercase letter
     - ✓ One number
     - ✓ One special character
   - Password strength should show "Strong password"

3. Enter mismatched confirmation: `DifferentPass@123`
   - Should show "Passwords do not match" (red)
   - Reset button should be disabled

4. Enter matching confirmation: `NewPass@123`
   - Should show "Passwords match" (green)
   - Reset button should be enabled

5. Click "Reset Password"
   - Loading indicator should appear
   - Should move to Step 4 (Success page)
   - Success message should display

### 7. Verify Password Change
1. Click "Go to Login" button
2. Try logging in with old password
   - Should fail: "Invalid username or password"

3. Log in with new password
   - Email: `testuser@gmail.com`
   - Password: `NewPass@123`
   - Should successfully login

### 8. Database Verification
```sql
-- Check if code was stored
SELECT * FROM verification_codes WHERE email = 'testuser@gmail.com';
-- Should be empty (code deleted after successful reset)

-- Check password was updated
SELECT email, password FROM users WHERE email = 'testuser@gmail.com';
-- Password hash should be different from before
```

## Common Issues and Solutions

### Issue 1: Email not received
**Solution:**
1. Check spam/junk folder
2. Verify mail.properties settings
3. Check console/logs for error messages
4. Test with a different email provider

### Issue 2: Code always invalid
**Solution:**
1. Make sure code is entered correctly (no spaces)
2. Check code hasn't expired (1 hour limit)
3. Verify database has the code stored:
   ```sql
   SELECT * FROM verification_codes WHERE email = 'your-email';
   ```

### Issue 3: Page styling broken
**Solution:**
1. Check Bootstrap CDN is accessible
2. Verify header.jsp and footer.jsp exist
3. Clear browser cache
4. Check browser console for errors

### Issue 4: Database connection error
**Solution:**
1. Verify MySQL is running
2. Check database connection settings in DatabaseClass.java
3. Ensure `verification_codes` table exists

## Expected Results Summary

✓ Email validation works correctly
✓ Verification code sent to email
✓ Code stored in database
✓ Code verification works
✓ Password requirements enforced
✓ Password confirmation validated
✓ Password successfully updated
✓ Used code deleted from database
✓ User can login with new password
✓ Page styling matches other pages
✓ All animations and transitions smooth
✓ Responsive design works on mobile

## Security Tests

### Test 1: Expired Code
1. Insert old code manually:
   ```sql
   INSERT INTO verification_codes (email, code, user_type, created_at)
   VALUES ('test@test.com', 'OLDCODE1', 'student', DATE_SUB(NOW(), INTERVAL 2 HOUR));
   ```
2. Try to use this code
3. Should fail: "Invalid verification code"

### Test 2: Code Reuse
1. Complete password reset successfully
2. Try to use the same code again
3. Should fail (code deleted after use)

### Test 3: SQL Injection
1. Try entering SQL in email field:
   ```
   test@test.com'; DROP TABLE users; --
   ```
2. Should be safely handled (prepared statements protect against this)

## Performance Tests

1. **Load Test**: Multiple password reset requests
   - Send 10 codes in quick succession
   - All should be delivered successfully

2. **Cleanup Test**: Expired codes removal
   - Wait 1 hour after creating codes
   - Check if automatic cleanup runs
   - Old codes should be deleted

## Browser Compatibility

Test on:
- [ ] Chrome
- [ ] Firefox
- [ ] Edge
- [ ] Safari
- [ ] Mobile browsers

## Report Issues

If you encounter any issues, collect:
1. Browser console errors (F12 → Console)
2. Network tab errors (F12 → Network)
3. Server logs from XAMPP
4. Database query results
5. Screenshots of the issue

---
**Happy Testing!** 🚀
