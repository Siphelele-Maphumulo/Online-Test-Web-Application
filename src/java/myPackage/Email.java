package myPackage;

import java.io.IOException;
import java.io.InputStream;
import java.security.SecureRandom;
import java.util.Properties;
import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.MessagingException;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

public class Email {

    private static Properties mailProperties = new Properties();

    static {
        try (InputStream input = Email.class.getClassLoader().getResourceAsStream("mail.properties")) {
            if (input == null) {
                // Debug: Show what's in classpath
                System.err.println("✗ mail.properties NOT found in classpath (WEB-INF/classes)");
                System.err.println("  Classpath resource URL: " + Email.class.getClassLoader().getResource("mail.properties"));
                throw new RuntimeException("mail.properties NOT found in classpath (WEB-INF/classes)");
            }

            mailProperties.load(input);
            System.out.println("✓ Mail properties loaded successfully");
            System.out.println("  EMAIL_USER: " + mailProperties.getProperty("EMAIL_USER"));
            System.out.println("  SMTP_HOST: " + mailProperties.getProperty("SMTP_HOST"));
            System.out.println("  SMTP_PORT: " + mailProperties.getProperty("SMTP_PORT"));

        } catch (Exception e) {
            throw new ExceptionInInitializerError("Failed to load mail.properties: " + e.getMessage());
        }
    }

    public static String generateRandomCode() {
        String chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
        SecureRandom random = new SecureRandom();
        StringBuilder sb = new StringBuilder(8);
        for (int i = 0; i < 8; i++) {
            sb.append(chars.charAt(random.nextInt(chars.length())));
        }
        return sb.toString();
    }

    public static void sendAcceptanceEmail(String to, String firstName, String code) throws MessagingException {
        sendEmail(to, firstName, code, "CONGRATULATIONS: You are nearly there - Code SA Institute Pty Ltd");
    }
    
    public static void sendVerificationEmail(String to, String firstName, String code) throws MessagingException {
        sendEmail(to, firstName, code, "Verify Your Email - Code SA Institute");
    }
    
    public static void sendPasswordResetEmail(String to, String firstName, String code) throws MessagingException {
        sendEmail(to, firstName, code, "Password Reset Request - Code SA Institute");
    }

    private static void sendEmail(String to, String firstName, String code, String subject) throws MessagingException {
        // Validate mail properties are loaded
        if (mailProperties == null || mailProperties.isEmpty()) {
            System.err.println("ERROR: Mail properties not loaded!");
            throw new MessagingException("Mail properties not loaded. Check if mail.properties file exists.");
        }
        
        System.out.println("Mail properties loaded successfully");
        
        final String username = mailProperties.getProperty("EMAIL_USER");
        final String password = mailProperties.getProperty("EMAIL_PASS");
        final String smtpHost = mailProperties.getProperty("SMTP_HOST");
        final String smtpPort = mailProperties.getProperty("SMTP_PORT");
        final String emailFrom = mailProperties.getProperty("EMAIL_FROM");
        
        System.out.println("EMAIL_USER: " + username);
        System.out.println("SMTP_HOST: " + smtpHost);
        System.out.println("SMTP_PORT: " + smtpPort);
        System.out.println("Sending to: " + to);
        
        // Validate all required properties are present
        if (username == null || username.trim().isEmpty()) {
            throw new MessagingException("EMAIL_USER property is missing or empty");
        }
        if (password == null || password.trim().isEmpty()) {
            throw new MessagingException("EMAIL_PASS property is missing or empty");
        }
        if (smtpHost == null || smtpHost.trim().isEmpty()) {
            throw new MessagingException("SMTP_HOST property is missing or empty");
        }
        if (smtpPort == null || smtpPort.trim().isEmpty()) {
            throw new MessagingException("SMTP_PORT property is missing or empty");
        }
        if (emailFrom == null || emailFrom.trim().isEmpty()) {
            throw new MessagingException("EMAIL_FROM property is missing or empty");
        }

        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.starttls.required", "true");
        props.put("mail.smtp.host", smtpHost);
        props.put("mail.smtp.port", smtpPort);
        props.put("mail.smtp.ssl.trust", smtpHost);
        props.put("mail.smtp.ssl.protocols", "TLSv1.2");
        props.put("mail.debug", "true"); // Enable debug output

        System.out.println("Creating email session...");
        
        Session session = Session.getInstance(props, new Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(username, password);
            }
        });
        
        // Enable debug mode
        session.setDebug(true);

        System.out.println("Creating message...");
        
        Message message = new MimeMessage(session);
        message.setFrom(new InternetAddress(emailFrom));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
        message.setSubject(subject);
        
        // Create dynamic HTML content based on subject
        String emailContent = "";
        if (subject.contains("Verify Your Email")) {
            emailContent = getVerificationEmailHtml(firstName, code);
        } else if (subject.contains("Password Reset")) {
            emailContent = getPasswordResetEmailHtml(firstName, code);
        } else {
            emailContent = getAcceptanceEmailHtml(firstName, code);
        }
        
        message.setContent(emailContent, "text/html; charset=utf-8");
        
        System.out.println("Sending email...");
        Transport.send(message);
        System.out.println("Email sent successfully!");
    }
    
    private static String getVerificationEmailHtml(String firstName, String code) {
        return "<!DOCTYPE html>" +
            "<html lang='en'>" +
            "<head>" +
            "    <meta charset='UTF-8'>" +
            "    <meta name='viewport' content='width=device-width, initial-scale=1.0'>" +
            "    <title>Email Verification</title>" +
            "    <style>" +
            "        body { font-family: Arial, sans-serif; background-color: #f4f4f4; margin: 0; padding: 20px; }" +
            "        .container { max-width: 600px; margin: 0 auto; background-color: #ffffff; padding: 30px; border-radius: 10px; box-shadow: 0 4px 12px rgba(0,0,0,0.1); }" +
            "        .header { text-align: center; border-bottom: 2px solid #09294D; padding-bottom: 20px; margin-bottom: 20px; }" +
            "        .header h1 { color: #09294D; margin: 0; font-size: 24px; }" +
            "        .header p { color: #555; font-size: 16px; margin-top: 5px; }" +
            "        .content { color: #333; line-height: 1.6; font-size: 16px; }" +
            "        .content h2 { color: #09294D; font-size: 20px; margin-bottom: 15px; }" +
            "        .code-container { text-align: center; margin: 25px 0; }" +
            "        .code { font-size: 32px; font-weight: bold; color: #ffffff; background-color: #09294D; padding: 15px 25px; border-radius: 8px; display: inline-block; letter-spacing: 4px; font-family: monospace; }" +
            "        .instructions { margin: 20px 0; }" +
            "        .instructions ol { padding-left: 20px; }" +
            "        .instructions li { margin-bottom: 10px; font-size: 15px; }" +
            "        .important { background-color: #FFF3CD; border-left: 5px solid #FFC107; padding: 15px; margin-top: 20px; border-radius: 5px; }" +
            "        .important p, .important ul { margin: 0; }" +
            "        .important ul { padding-left: 20px; }" +
            "        .important li { margin-bottom: 5px; font-size: 14px; }" +
            "        .expiry { color: #dc3545; font-weight: bold; }" +
            "        .footer { text-align: center; margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd; font-size: 14px; color: #777; }" +
            "        a { color: #09294D; text-decoration: none; font-weight: bold; }" +
            "        a:hover { text-decoration: underline; }" +
            "    </style>" +
            "</head>" +
            "<body>" +
            "    <div class='container'>" +
            "        <div class='header'>" +
            "            <h1>Email Verification</h1>" +
            "            <p>Code SA Institute Online System</p>" +
            "        </div>" +
            "        <div class='content'>" +
            "            <h2>Hello " + firstName + ",</h2>" +
            "            <p>Thank you for registering with Code SA Institute. To complete your registration, please use the verification code below:</p>" +
            "            <div class='code-container'>" +
            "                <div class='code'>" + code + "</div>" +
            "            </div>" +
            "            <div class='instructions'>" +
            "                <h3>How to use this code:</h3>" +
            "                <ol>" +
            "                    <li>Return to the signup page</li>" +
            "                    <li>Enter the verification code shown above</li>" +
            "                    <li>Complete your account setup</li>" +
            "                </ol>" +
            "            </div>" +
            "            <div class='important'>" +
            "                <p><strong>Important Information:</strong></p>" +
            "                <ul>" +
            "                    <li>This verification code will expire in <span class='expiry'>30 minutes</span></li>" +
            "                    <li>Do not share this code with anyone</li>" +
            "                    <li>If you didn't request this registration, please ignore this email</li>" +
            "                </ul>" +
            "            </div>" +
            "            <p>If you encounter any issues, please contact our support team.</p>" +
            "        </div>" +
            "        <div class='footer'>" +
            "            <p><strong>Code SA Institute Pty Ltd</strong><br>" +
            "            New Germany, South Africa<br>" +
            "            Unit 8E trio Industrial Park, 8 Shepstone Road, The Wolds | Tel: +27 633137391<br>" +
            "            Email: info@codingmadeeasy.org | Website: https://codingmadeeasy.org/</p>" +
            "            <p><em>This is an automated email. Please do not reply.</em></p>" +
            "        </div>" +
            "    </div>" +
            "</body>" +
            "</html>";
    }
    
    private static String getAcceptanceEmailHtml(String firstName, String code) {
        return "<!DOCTYPE html>" +
            "<html lang='en'>" +
            "<head>" +
            "    <meta charset='UTF-8'>" +
            "    <meta name='viewport' content='width=device-width, initial-scale=1.0'>" +
            "    <title>Registration Almost Complete!</title>" +
            "    <style>" +
            "        body { font-family: Arial, sans-serif; background-color: #f4f4f4; margin: 0; padding: 20px; }" +
            "        .container { max-width: 600px; margin: 0 auto; background-color: #ffffff; padding: 30px; border-radius: 10px; box-shadow: 0 4px 12px rgba(0,0,0,0.1); }" +
            "        .header { text-align: center; border-bottom: 2px solid #09294D; padding-bottom: 20px; margin-bottom: 20px; }" +
            "        .header h1 { color: #09294D; margin: 0; }" +
            "        .header p { color: #555; font-size: 1.1rem; }" +
            "        .content { color: #333; line-height: 1.6; }" +
            "        .content h2 { color: #09294D; }" +
            "        .code-container { text-align: center; margin: 25px 0; }" +
            "        .code { font-size: 2.5rem; font-weight: bold; color: #ffffff; background-color: #09294D; padding: 15px 25px; border-radius: 8px; display: inline-block; letter-spacing: 4px; }" +
            "        .instructions ol { padding-left: 20px; }" +
            "        .instructions li { margin-bottom: 10px; }" +
            "        .important { background-color: #FFF3CD; border-left: 5px solid #FFC107; padding: 15px; margin-top: 20px; border-radius: 5px; }" +
            "        .important p, .important ul { margin: 0; }" +
            "        a { color: #09294D; text-decoration: none; font-weight: bold; }" +
            "        a:hover { text-decoration: underline; }" +
            "        .footer { text-align: center; margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd; font-size: 0.9rem; color: #777; }" +
            "    </style>" +
            "</head>" +
            "<body>" +
            "    <div class='container'>" +
            "        <div class='header'>" +
            "            <h1>Code SA Institute Pty Ltd</h1>" +
            "            <p>Online Testing System</p>" +
            "        </div>" +
            "        <div class='content'>" +
            "            <h2>Dear " + firstName + ",</h2>" +
            "            <p>Congratulations! We've received your registration request. Please use the code below to complete your sign-up process.</p>" +
            "            <div class='code-container'>" +
            "                <div class='code'>" + code + "</div>" +
            "            </div>" +
            "            <div class='instructions'>" +
            "                <h3>Next Steps:</h3>" +
            "                <ol>" +
            "                    <li>Return to the signup page on our portal.</li>" +
            "                    <li>Enter the registration code above when prompted.</li>" +
            "                    <li>Complete your profile setup.</li>" +
            "                </ol>" +
            "            </div>" +
            "            <div class='important'>" +
            "                <p><strong>Important:</strong></p>" +
            "                <ul>" +
            "                    <li>This code is valid for a single use and will expire in 30 days.</li>" +
            "                    <li>Keep this code confidential.</li>" +
            "                    <li>If you did not request this, please ignore this email.</li>" +
            "                </ul>" +
            "            </div>" +
            "            <p>We look forward to supporting you in your learning journey.</p>" +
            "        </div>" +
            "        <div class='footer'>" +
            "            <p><strong>Code SA Institute Pty Ltd</strong><br>" +
            "            New Germany, South Africa<br>" +
            "            Unit 8E trio Industrial Park, 8 Shepstone Road, The Wolds | Tel: +27 633137391<br>" +
            "            Email: info@codingmadeeasy.org | Website: https://codingmadeeasy.org/</p>" +
            "            <p><em>This is an automated email. Please do not reply.</em></p>" +
            "        </div>" +
            "    </div>" +
            "</body>" +
            "</html>";
    }

    private static String getPasswordResetEmailHtml(String firstName, String code) {
        return "<!DOCTYPE html>" +
            "<html lang='en'>" +
            "<head>" +
            "    <meta charset='UTF-8'>" +
            "    <meta name='viewport' content='width=device-width, initial-scale=1.0'>" +
            "    <title>Password Reset</title>" +
            "    <style>" +
            "        body { font-family: Arial, sans-serif; background-color: #f4f4f4; margin: 0; padding: 20px; }" +
            "        .container { max-width: 600px; margin: 0 auto; background-color: #ffffff; padding: 30px; border-radius: 10px; box-shadow: 0 4px 12px rgba(0,0,0,0.1); }" +
            "        .header { text-align: center; border-bottom: 2px solid #09294D; padding-bottom: 20px; margin-bottom: 20px; }" +
            "        .header h1 { color: #09294D; margin: 0; font-size: 24px; }" +
            "        .header p { color: #555; font-size: 16px; margin-top: 5px; }" +
            "        .content { color: #333; line-height: 1.6; font-size: 16px; }" +
            "        .content h2 { color: #09294D; font-size: 20px; margin-bottom: 15px; }" +
            "        .code-container { text-align: center; margin: 25px 0; }" +
            "        .code { font-size: 32px; font-weight: bold; color: #ffffff; background-color: #09294D; padding: 15px 25px; border-radius: 8px; display: inline-block; letter-spacing: 4px; font-family: monospace; }" +
            "        .instructions { margin: 20px 0; }" +
            "        .instructions ol { padding-left: 20px; }" +
            "        .instructions li { margin-bottom: 10px; font-size: 15px; }" +
            "        .important { background-color: #FFF3CD; border-left: 5px solid #FFC107; padding: 15px; margin-top: 20px; border-radius: 5px; }" +
            "        .important p, .important ul { margin: 0; }" +
            "        .important ul { padding-left: 20px; }" +
            "        .important li { margin-bottom: 5px; font-size: 14px; }" +
            "        .expiry { color: #dc3545; font-weight: bold; }" +
            "        .footer { text-align: center; margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd; font-size: 14px; color: #777; }" +
            "        a { color: #09294D; text-decoration: none; font-weight: bold; }" +
            "        a:hover { text-decoration: underline; }" +
            "    </style>" +
            "</head>" +
            "<body>" +
            "    <div class='container'>" +
            "        <div class='header'>" +
            "            <h1>Password Reset</h1>" +
            "            <p>Code SA Institute Online System</p>" +
            "        </div>" +
            "        <div class='content'>" +
            "            <h2>Hello " + firstName + ",</h2>" +
            "            <p>We received a request to reset your password. Use the code below to reset it:</p>" +
            "            <div class='code-container'>" +
            "                <div class='code'>" + code + "</div>" +
            "            </div>" +
            "            <div class='instructions'>" +
            "                <h3>How to use this code:</h3>" +
            "                <ol>" +
            "                    <li>Return to the password reset page.</li>" +
            "                    <li>Enter the code shown above.</li>" +
            "                    <li>Choose a new password.</li>" +
            "                </ol>" +
            "            </div>" +
            "            <div class='important'>" +
            "                <p><strong>Important Information:</strong></p>" +
            "                <ul>" +
            "                    <li>This code will expire in <span class='expiry'>1 hour</span>.</li>" +
            "                    <li>If you didn't request a password reset, please ignore this email.</li>" +
            "                </ul>" +
            "            </div>" +
            "        </div>" +
            "        <div class='footer'>" +
            "            <p><strong>Code SA Institute Pty Ltd</strong><br>" +
            "            New Germany, South Africa<br>" +
            "            Unit 8E trio Industrial Park, 8 Shepstone Road, The Wolds | Tel: +27 633137391<br>" +
            "            Email: info@codingmadeeasy.org | Website: https://codingmadeeasy.org/</p>" +
            "            <p><em>This is an automated email. Please do not reply.</em></p>" +
            "        </div>" +
            "    </div>" +
            "</body>" +
            "</html>";
    }
}