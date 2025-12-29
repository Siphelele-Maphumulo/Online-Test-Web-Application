package myPackage;

import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.util.Base64;
import javax.crypto.Cipher;
import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;
import java.util.logging.Level;
import java.util.logging.Logger;
import org.mindrot.jbcrypt.BCrypt;

public class PasswordUtils {

    // Method to hash the password using SHA-256
    public static String hashPassword(String password) {
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(password.getBytes());
            StringBuilder hexString = new StringBuilder();
            for (byte b : hash) {
                String hex = Integer.toHexString(0xff & b);
                if (hex.length() == 1) hexString.append('0');
                hexString.append(hex);
            }
            return hexString.toString();
        } catch (NoSuchAlgorithmException e) {
            throw new RuntimeException(e);
        }
    }

    // Method to hash the password using BCrypt
    public static String bcryptHashPassword(String password) {
        return BCrypt.hashpw(password, BCrypt.gensalt());
    }

    // Method to encrypt the password
    public static String encryptPassword(String password, String secret) throws Exception {
        SecretKeySpec secretKey = new SecretKeySpec(secret.getBytes(), "AES");
        Cipher cipher = Cipher.getInstance("AES");
        cipher.init(Cipher.ENCRYPT_MODE, secretKey);
        byte[] encryptedPasswordBytes = cipher.doFinal(password.getBytes());
        return Base64.getEncoder().encodeToString(encryptedPasswordBytes);
    }

    public static void main(String[] args) {
        try {
            String password = "mypassword";

            // Hash the password using SHA-256
            String hashedPassword = hashPassword(password);
            System.out.println("Hashed Password (SHA-256): " + hashedPassword);

            // Hash the password using BCrypt
            String bcryptHashedPassword = bcryptHashPassword(password);
            System.out.println("BCrypt Hashed Password: " + bcryptHashedPassword);

            // Encrypt the password
            String secretKey = "mysecretkey12345"; // Key length must be 16 bytes for AES-128
            String encryptedPassword = encryptPassword(password, secretKey);
            System.out.println("Encrypted Password: " + encryptedPassword);

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}