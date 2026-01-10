
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
                System.out.println("Sorry, unable to find mail.properties");
            } else {
                mailProperties.load(input);
            }
        } catch (IOException ex) {
            ex.printStackTrace();
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
        final String username = mailProperties.getProperty("EMAIL_USER");
        final String password = mailProperties.getProperty("EMAIL_PASS");

        Properties props = new Properties();
        props.put("mail.smtp.auth", "true");
        props.put("mail.smtp.starttls.enable", "true");
        props.put("mail.smtp.host", mailProperties.getProperty("SMTP_HOST"));
        props.put("mail.smtp.port", mailProperties.getProperty("SMTP_PORT"));
        props.put("mail.smtp.ssl.trust", mailProperties.getProperty("SMTP_HOST"));


        Session session = Session.getInstance(props, new Authenticator() {
            protected PasswordAuthentication getPasswordAuthentication() {
                return new PasswordAuthentication(username, password);
            }
        });

        Message message = new MimeMessage(session);
        message.setFrom(new InternetAddress(mailProperties.getProperty("EMAIL_FROM")));
        message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(to));
        message.setSubject("CONGRATULATIONS: You are nearly there - Code SA Institute Pty Ltd");
        message.setContent(
              "<!DOCTYPE html>"
            + "<html lang='en'>"
            + "<head>"
            + "    <meta charset='UTF-8'>"
            + "    <meta name='viewport' content='width=device-width, initial-scale=1.0'>"
            + "    <title>Registration Almost Complete!</title>"
            + "    <style>"
            + "        body { font-family: Arial, sans-serif; background-color: #f4f4f4; margin: 0; padding: 20px; }"
            + "        .container { max-width: 600px; margin: 0 auto; background-color: #ffffff; padding: 30px; border-radius: 10px; box-shadow: 0 4px 12px rgba(0,0,0,0.1); }"
            + "        .header { text-align: center; border-bottom: 2px solid #09294D; padding-bottom: 20px; margin-bottom: 20px; }"
            + "        .header h1 { color: #09294D; margin: 0; }"
            + "        .header p { color: #555; font-size: 1.1rem; }"
            + "        .content { color: #333; line-height: 1.6; }"
            + "        .content h2 { color: #09294D; }"
            + "        .code-container { text-align: center; margin: 25px 0; }"
            + "        .code { font-size: 2.5rem; font-weight: bold; color: #ffffff; background-color: #09294D; padding: 15px 25px; border-radius: 8px; display: inline-block; letter-spacing: 4px; }"
            + "        .instructions ol { padding-left: 20px; }"
            + "        .instructions li { margin-bottom: 10px; }"
            + "        .important { background-color: #FFF3CD; border-left: 5px solid #FFC107; padding: 15px; margin-top: 20px; border-radius: 5px; }"
            + "        .important p, .important ul { margin: 0; }"
            + "        a { color: #09294D; text-decoration: none; font-weight: bold; }"
            + "        a:hover { text-decoration: underline; }"
            + "        .footer { text-align: center; margin-top: 30px; padding-top: 20px; border-top: 1px solid #ddd; font-size: 0.9rem; color: #777; }"
            + "    </style>"
            + "</head>"
            + "<body>"
            + "    <div class='container'>"
            + "        <div class='header'>"
            + "            <h1>Code SA Institute Pty Ltd</h1>"
            + "            <p>Online Testing System</p>"
            + "        </div>"
            + "        <div class='content'>"
            + "            <h2>Dear " + firstName + ",</h2>"
            + "            <p>Congratulations! We've received your registration request. Please use the code below to complete your sign-up process.</p>"
            + "            <div class='code-container'>"
            + "                <div class='code'>" + code + "</div>"
            + "            </div>"
            + "            <div class='instructions'>"
            + "                <h3>Next Steps:</h3>"
            + "                <ol>"
            + "                    <li>Return to the signup page on our portal.</li>"
            + "                    <li>Enter the registration code above when prompted.</li>"
            + "                    <li>Complete your profile setup.</li>"
            + "                </ol>"
            + "            </div>"
            + "            <div class='important'>"
            + "                <p><strong>Important:</strong></p>"
            + "                <ul>"
            + "                    <li>This code is valid for a single use and will expire in 30 days.</li>"
            + "                    <li>Keep this code confidential.</li>"
            + "                    <li>If you did not request this, please ignore this email.</li>"
            + "                </ul>"
            + "            </div>"
            + "            <p>We look forward to supporting you in your learning journey.</p>"
            + "        </div>"
            + "        <div class='footer'>"
            + "            <p><strong>Code SA Institute Pty Ltd</strong><br>"
            + "            New Germany, South Africa<br>"
            + "            Unit 8E trio Industrial Park, 8 Shepstone Road, The Wolds | Tel: +27 633137391<br>"
            + "            Email: info@codingmadeeasy.org | Website: https://codingmadeeasy.org/</p>"
            + "            <p><em>This is an automated email. Please do not reply.</em></p>"
            + "        </div>"
            + "    </div>"
            + "</body>"
            + "</html>",
            "text/html");
        Transport.send(message);
    }
}
