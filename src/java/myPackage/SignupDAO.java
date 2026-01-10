
package myPackage;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class SignupDAO {

    private Connection conn;

    public SignupDAO() throws SQLException, ClassNotFoundException {
        this.conn = DatabaseClass.getInstance().getConnection();
    }

    public void saveSignupCode(String firstNames, String surname, String email, String code) throws SQLException {
        String sql = "INSERT INTO signup_codes (first_names, surname, email_address, code) VALUES (?, ?, ?, ?)";
        try (PreparedStatement pstm = conn.prepareStatement(sql)) {
            pstm.setString(1, firstNames);
            pstm.setString(2, surname);
            pstm.setString(3, email);
            pstm.setString(4, code);
            pstm.executeUpdate();
        }
    }

    public boolean verifySignupCode(String email, String code) throws SQLException {
        String selectSql = "SELECT id FROM signup_codes WHERE email_address = ? AND code = ?";
        try (PreparedStatement selectPstm = conn.prepareStatement(selectSql)) {
            selectPstm.setString(1, email);
            selectPstm.setString(2, code);
            try (ResultSet rs = selectPstm.executeQuery()) {
                return rs.next();
            }
        }
    }

    public void deleteSignupCode(String email, String code) throws SQLException {
        String deleteSql = "DELETE FROM signup_codes WHERE email_address = ? AND code = ?";
        try (PreparedStatement deletePstm = conn.prepareStatement(deleteSql)) {
            deletePstm.setString(1, email);
            deletePstm.setString(2, code);
            deletePstm.executeUpdate();
        }
    }

    public void createUserAfterVerification(String fName, String lName, String uName, String email, String hashedPass, String contactNo, String city, String address, String userType, String code) throws SQLException, ClassNotFoundException {
        conn.setAutoCommit(false);
        try {
            if (verifySignupCode(email, code)) {
                DatabaseClass.getInstance().addNewUser(fName, lName, uName, email, hashedPass, contactNo, city, address, userType);
                deleteSignupCode(email, code);
                conn.commit();
            } else {
                conn.rollback();
                throw new SQLException("Invalid verification code.");
            }
        } catch (SQLException e) {
            conn.rollback();
            throw e;
        } finally {
            conn.setAutoCommit(true);
        }
    }
}
