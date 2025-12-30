package myPackage;

import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.text.SimpleDateFormat;
import java.util.logging.Level;
import java.util.logging.Logger;
import myPackage.classes.Answers;
import myPackage.classes.Exams;
import myPackage.classes.Questions;
import myPackage.classes.User;
import org.mindrot.jbcrypt.BCrypt;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.sql.Types;
import myPackage.classes.Result;


public class DatabaseClass {
    private static DatabaseClass instance; // Singleton instance
    private Connection conn;

    // Private constructor to prevent direct instantiation
    private DatabaseClass() throws ClassNotFoundException, SQLException {
        establishConnection();
    }

public boolean updateUserAccount(int userId,
                                 String firstName,
                                 String lastName,
                                 String userName,
                                 String email,
                                 String passwordHash,
                                 String userType,
                                 String contact,
                                 String city,
                                 String address,
                                 String courseName) {
    PreparedStatement updateUsersStmt = null;
    PreparedStatement upsertStudentStmt = null;
    PreparedStatement upsertLecturerStmt = null;
    PreparedStatement deleteStudentsStmt = null;
    PreparedStatement deleteLecturesStmt = null;

    String normalizedContact = (contact != null && !contact.trim().isEmpty()) ? contact.trim() : null;
    String normalizedCity = (city != null && !city.trim().isEmpty()) ? city.trim() : null;
    String normalizedAddress = (address != null && !address.trim().isEmpty()) ? address.trim() : null;
    String normalizedCourse = (courseName != null && !courseName.trim().isEmpty()) ? courseName.trim() : null;

    try {
        conn.setAutoCommit(false);

        String updateUsersSql = "UPDATE users SET first_name=?, last_name=?, user_name=?, email=?, password=?, user_type=?, contact_no=?, city=?, address=? WHERE user_id=?";
        updateUsersStmt = conn.prepareStatement(updateUsersSql);
        updateUsersStmt.setString(1, firstName);
        updateUsersStmt.setString(2, lastName);
        updateUsersStmt.setString(3, userName);
        updateUsersStmt.setString(4, email);
        updateUsersStmt.setString(5, passwordHash);
        updateUsersStmt.setString(6, userType);

        if (normalizedContact != null) {
            updateUsersStmt.setString(7, normalizedContact);
        } else {
            updateUsersStmt.setNull(7, Types.VARCHAR);
        }

        if (normalizedCity != null) {
            updateUsersStmt.setString(8, normalizedCity);
        } else {
            updateUsersStmt.setNull(8, Types.VARCHAR);
        }

        if (normalizedAddress != null) {
            updateUsersStmt.setString(9, normalizedAddress);
        } else {
            updateUsersStmt.setNull(9, Types.VARCHAR);
        }

        updateUsersStmt.setInt(10, userId);

        int updatedRows = updateUsersStmt.executeUpdate();
        if (updatedRows == 0) {
            conn.rollback();
            return false;
        }

        if ("student".equalsIgnoreCase(userType)) {
            String upsertStudentSql = "INSERT INTO students (user_id, first_name, last_name, user_name, email, password, user_type, contact_no, city, address) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?) " +
                    "ON DUPLICATE KEY UPDATE first_name=VALUES(first_name), last_name=VALUES(last_name), user_name=VALUES(user_name), email=VALUES(email), " +
                    "password=VALUES(password), user_type=VALUES(user_type), contact_no=VALUES(contact_no), city=VALUES(city), address=VALUES(address)";
            upsertStudentStmt = conn.prepareStatement(upsertStudentSql);
            upsertStudentStmt.setInt(1, userId);
            upsertStudentStmt.setString(2, firstName);
            upsertStudentStmt.setString(3, lastName);
            upsertStudentStmt.setString(4, userName);
            upsertStudentStmt.setString(5, email);
            upsertStudentStmt.setString(6, passwordHash);
            upsertStudentStmt.setString(7, "student");

            if (normalizedContact != null) {
                upsertStudentStmt.setString(8, normalizedContact);
            } else {
                upsertStudentStmt.setNull(8, Types.VARCHAR);
            }

            if (normalizedCity != null) {
                upsertStudentStmt.setString(9, normalizedCity);
            } else {
                upsertStudentStmt.setNull(9, Types.VARCHAR);
            }

            if (normalizedAddress != null) {
                upsertStudentStmt.setString(10, normalizedAddress);
            } else {
                upsertStudentStmt.setNull(10, Types.VARCHAR);
            }

            upsertStudentStmt.executeUpdate();

            deleteLecturesStmt = conn.prepareStatement("DELETE FROM lectures WHERE user_id=?");
            deleteLecturesStmt.setInt(1, userId);
            deleteLecturesStmt.executeUpdate();

        } else if ("lecture".equalsIgnoreCase(userType)) {
            String upsertLectureSql = "INSERT INTO lectures (user_id, first_name, last_name, user_name, email, password, user_type, contact_no, city, address, course_name) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) " +
                    "ON DUPLICATE KEY UPDATE first_name=VALUES(first_name), last_name=VALUES(last_name), user_name=VALUES(user_name), email=VALUES(email), " +
                    "password=VALUES(password), user_type=VALUES(user_type), contact_no=VALUES(contact_no), city=VALUES(city), address=VALUES(address), course_name=VALUES(course_name)";
            upsertLecturerStmt = conn.prepareStatement(upsertLectureSql);
            upsertLecturerStmt.setInt(1, userId);
            upsertLecturerStmt.setString(2, firstName);
            upsertLecturerStmt.setString(3, lastName);
            upsertLecturerStmt.setString(4, userName);
            upsertLecturerStmt.setString(5, email);
            upsertLecturerStmt.setString(6, passwordHash);
            upsertLecturerStmt.setString(7, "lecture");

            if (normalizedContact != null) {
                upsertLecturerStmt.setString(8, normalizedContact);
            } else {
                upsertLecturerStmt.setNull(8, Types.VARCHAR);
            }

            if (normalizedCity != null) {
                upsertLecturerStmt.setString(9, normalizedCity);
            } else {
                upsertLecturerStmt.setNull(9, Types.VARCHAR);
            }

            if (normalizedAddress != null) {
                upsertLecturerStmt.setString(10, normalizedAddress);
            } else {
                upsertLecturerStmt.setNull(10, Types.VARCHAR);
            }

            if (normalizedCourse != null) {
                upsertLecturerStmt.setString(11, normalizedCourse);
            } else {
                upsertLecturerStmt.setNull(11, Types.VARCHAR);
            }

            upsertLecturerStmt.executeUpdate();

            deleteStudentsStmt = conn.prepareStatement("DELETE FROM students WHERE user_id=?");
            deleteStudentsStmt.setInt(1, userId);
            deleteStudentsStmt.executeUpdate();

        } else {
            deleteStudentsStmt = conn.prepareStatement("DELETE FROM students WHERE user_id=?");
            deleteStudentsStmt.setInt(1, userId);
            deleteStudentsStmt.executeUpdate();

            deleteLecturesStmt = conn.prepareStatement("DELETE FROM lectures WHERE user_id=?");
            deleteLecturesStmt.setInt(1, userId);
            deleteLecturesStmt.executeUpdate();
        }

        conn.commit();
        return true;
    } catch (SQLException ex) {
        try {
            if (conn != null) {
                conn.rollback();
            }
        } catch (SQLException rollbackEx) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, "Rollback failed", rollbackEx);
        }
        Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, "Failed to update user account for ID: " + userId, ex);
        return false;
    } finally {
        try {
            if (updateUsersStmt != null) updateUsersStmt.close();
            if (upsertStudentStmt != null) upsertStudentStmt.close();
            if (upsertLecturerStmt != null) upsertLecturerStmt.close();
            if (deleteStudentsStmt != null) deleteStudentsStmt.close();
            if (deleteLecturesStmt != null) deleteLecturesStmt.close();
            conn.setAutoCommit(true);
        } catch (SQLException e) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, e);
        }
    }
}

    // Get singleton instance
    public static synchronized DatabaseClass getInstance() throws ClassNotFoundException, SQLException {
        if (instance == null || instance.conn == null || instance.conn.isClosed()) {
            instance = new DatabaseClass();
        }
        return instance;
    }

    // Establish database connection
    private void establishConnection() throws ClassNotFoundException, SQLException {
        Class.forName("com.mysql.cj.jdbc.Driver"); // Load JDBC driver

//        this.conn = DriverManager.getConnection(
//            "jdbc:mysql://bdsnprm5vq9h4edsklxk-mysql.services.clever-cloud.com:3306/bdsnprm5vq9h4edsklxk?useSSL=true&requireSSL=false&serverTimezone=UTC",
//            "ugkdapgfbsc11xgj",
//            "vioCKbicD0jgZ8pjeJAa"
//        );
        
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/exam_system", "root", "");
    }

    // Get the connection
    public Connection getConnection() throws SQLException {
        if (conn == null || conn.isClosed()) {
            try {
                establishConnection();
            } catch (ClassNotFoundException e) {
                throw new SQLException("JDBC Driver not found", e);
            }
        }
        return conn;
    }

    String user_Type = "";
    
    public boolean checkLecturerByEmail(String email) {
        System.out.println("Here");
        boolean exists = false;
        try {
            String sql = "SELECT * FROM staff WHERE email = ?";  // Assuming you have a column 'email' in 'staff' table
            PreparedStatement pstm = conn.prepareStatement(sql);
            pstm.setString(1, email);
            ResultSet rs = pstm.executeQuery();
            if (rs.next()) {
                exists = true;
                user_Type = "lecture";
                System.out.println("Lecturer with email " + email + " found.");
            } else {
                user_Type = "student";
                System.out.println("Lecturer with email " + email + " not found.");
            }
            pstm.close();
        } catch (SQLException ex) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
        }
        return exists;
    }

// Fetch all students
public ArrayList<User> getAllStudents() {
    ArrayList<User> list = new ArrayList<>();
    User user = null;
    PreparedStatement pstm = null;
    ResultSet rs = null;

    try {
        String sql = "SELECT * FROM students";
        pstm = conn.prepareStatement(sql);
        rs = pstm.executeQuery();

        while (rs.next()) {
            user = new User(
                rs.getInt("user_id"),
                rs.getString("first_name"),
                rs.getString("last_name"),
                rs.getString("user_name"),
                rs.getString("email"),
                rs.getString("password"),
                rs.getString("user_type"),
                rs.getString("contact_no"),
                rs.getString("city"),
                rs.getString("address"),
                null // Students do not have a course assigned here
            );
            list.add(user);
        }
    } catch (SQLException ex) {
        System.out.println("Error fetching students: " + ex.getMessage());
    } finally {
        try {
            if (rs != null) rs.close();
            if (pstm != null) pstm.close();
        } catch (SQLException e) {
            System.out.println("Error closing resources: " + e.getMessage());
        }
    }

    return list;
}

// Fetch all lecturers
public ArrayList<User> getAllLecturers() {
    ArrayList<User> list = new ArrayList<>();
    User user = null;
    PreparedStatement pstm = null;
    ResultSet rs = null;

    try {
        // Get from lectures table (which has course_name)
        String sql = "SELECT * FROM lectures ORDER BY first_name, last_name";
        pstm = conn.prepareStatement(sql);
        rs = pstm.executeQuery();

        while (rs.next()) {
            user = new User(
                rs.getInt("user_id"),
                rs.getString("first_name"),
                rs.getString("last_name"),
                rs.getString("user_name"),
                rs.getString("email"),
                rs.getString("password"),
                rs.getString("user_type"),
                rs.getString("contact_no"),
                rs.getString("city"),
                rs.getString("address"),
                rs.getString("course_name")
            );
            list.add(user);
        }
    } catch (SQLException ex) {
        System.out.println("Error fetching lecturers: " + ex.getMessage());
    } finally {
        try {
            if (rs != null) rs.close();
            if (pstm != null) pstm.close();
        } catch (SQLException e) {
            System.out.println("Error closing resources: " + e.getMessage());
        }
    }

    return list;
}



    
     public String getUserType(String userId){
        String str="";
        PreparedStatement pstm;
        try {
            pstm = conn.prepareStatement("Select * from users where user_id=?");
            pstm.setInt(1, Integer.parseInt(userId));
            ResultSet rs=pstm.executeQuery();
            while(rs.next()){
                str= rs.getString("user_type");
            }
        } catch (SQLException ex) {
            System.out.println(ex.getMessage());
            str= "error";
        }
        return str;
    }
     public int getUserId(String userName){
        int str=0;
        PreparedStatement pstm;
        try {
            pstm = conn.prepareStatement("Select * from users where user_name=?");
            pstm.setString(1,userName);
            ResultSet rs=pstm.executeQuery();
            while(rs.next()){
                str= rs.getInt("user_id");
            }
        } catch (SQLException ex) {
            System.out.println(ex.getMessage());
            
        }
        return str;
    }

public User getUserByUsername(String username) {
    PreparedStatement ps = null;
    ResultSet rs = null;
    try {
        String sql = "SELECT * FROM users WHERE user_name = ?";
        ps = conn.prepareStatement(sql);
        ps.setString(1, username);
        rs = ps.executeQuery();
        
        if (rs.next()) {
            return new User(
                rs.getInt("user_id"),
                rs.getString("first_name"),
                rs.getString("last_name"),
                rs.getString("user_name"),
                rs.getString("email"),
                rs.getString("password"),
                rs.getString("user_type"),
                rs.getString("contact_no"),
                rs.getString("city"),
                rs.getString("address"),
                null
            );
        }
    } catch (SQLException e) {
        e.printStackTrace();
    } finally {
        try {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    return null;
}

public User getUserByEmail(String email) {
    PreparedStatement ps = null;
    ResultSet rs = null;
    try {
        String sql = "SELECT * FROM users WHERE email = ?";
        ps = conn.prepareStatement(sql);
        ps.setString(1, email);
        rs = ps.executeQuery();
        
        if (rs.next()) {
            return new User(
                rs.getInt("user_id"),
                rs.getString("first_name"),
                rs.getString("last_name"),
                rs.getString("user_name"),
                rs.getString("email"),
                rs.getString("password"),
                rs.getString("user_type"),
                rs.getString("contact_no"),
                rs.getString("city"),
                rs.getString("address"),
                null
            );
        }
    } catch (SQLException e) {
        e.printStackTrace();
    } finally {
        try {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
    return null;
}
     
public User getUserDetails(String userId) {
    User userDetails = null;
    
    if (userId == null || userId.trim().isEmpty()) {
        return null;
    }
    
    PreparedStatement pstm = null;
    ResultSet rs = null;
    
    try {
        // Improved query with explicit column selection
        String sql = "SELECT " +
                     "u.user_id AS uid, u.first_name AS ufname, u.last_name AS ulname, " +
                     "u.user_name AS uname, u.email AS uemail, u.password AS upass, " +
                     "u.user_type AS utype, u.contact_no AS ucontact, u.city AS ucity, " +
                     "u.address AS uaddr, " +
                     "l.user_id AS lid, l.course_name AS lcourse " +
                     "FROM users u " +
                     "LEFT JOIN lectures l ON u.user_id = l.user_id " +
                     "WHERE u.user_id = ?";
        
        pstm = conn.prepareStatement(sql);
        pstm.setString(1, userId);
        rs = pstm.executeQuery();
        
        if (rs.next()) {
            // Determine if user is a lecturer (has entry in lectures table)
            boolean isLecturer = rs.getInt("lid") > 0;
            
            // Get common fields from users table
            int user_id = rs.getInt("uid");
            String firstName = rs.getString("ufname");
            String lastName = rs.getString("ulname");
            String userName = rs.getString("uname");
            String email = rs.getString("uemail");
            String password = rs.getString("upass");
            String userType = rs.getString("utype");
            String contactNo = rs.getString("ucontact");
            String city = rs.getString("ucity");
            String address = rs.getString("uaddr");
            
            // Get course name if lecturer
            String courseName = null;
            if (isLecturer) {
                courseName = rs.getString("lcourse");
                // If user type is not already set to lecture, update it
                if (!"lecture".equalsIgnoreCase(userType)) {
                    userType = "lecture";
                }
            }
            
            // Handle null values
            firstName = (firstName != null) ? firstName : "";
            lastName = (lastName != null) ? lastName : "";
            userName = (userName != null) ? userName : "";
            email = (email != null) ? email : "";
            password = (password != null) ? password : "";
            userType = (userType != null) ? userType : "student";
            contactNo = (contactNo != null) ? contactNo : "";
            city = (city != null) ? city : "";
            address = (address != null) ? address : "";
            courseName = (courseName != null) ? courseName : null;
            
            userDetails = new User(
                user_id,
                firstName,
                lastName,
                userName,
                email,
                password,
                userType,
                contactNo,
                city,
                address,
                courseName
            );
        }
        
    } catch (SQLException ex) {
        Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, "Error getting user details for ID: " + userId, ex);
    } finally {
        // Close resources properly
        try {
            if (rs != null) rs.close();
            if (pstm != null) pstm.close();
        } catch (SQLException e) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, "Error closing resources", e);
        }
    }
    
    return userDetails;
}
     
// add new lecturer/staff
public void addNewStaff(String staffNum, String email, String fullNames, String course_name) {
    String sql = "INSERT INTO staff (staffNum, email, fullNames, course_name) VALUES (?, ?, ?, ?)";
    try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
        pstmt.setString(1, staffNum);
        pstmt.setString(2, email);
        pstmt.setString(3, fullNames);
        pstmt.setString(4, course_name);
        pstmt.executeUpdate();
    } catch (SQLException e) {
        e.printStackTrace();
    }
}


    
public void addNewUser(String fName, String lName, String uName, String email, String pass,
                       String contact, String city, String address, String staffNum) {
    PreparedStatement pstmCheckStaff = null;
    PreparedStatement pstmUsers = null;
    PreparedStatement pstmInsert = null;
    ResultSet rsCheck = null;
    ResultSet rsUserId = null;

    try {
        conn.setAutoCommit(false);

        // 1. Determine user type
        String sqlCheckStaff = "SELECT course_name FROM staff WHERE email = ? OR staffnum = ?";
        pstmCheckStaff = conn.prepareStatement(sqlCheckStaff);
        pstmCheckStaff.setString(1, email);
        pstmCheckStaff.setString(2, staffNum);
        rsCheck = pstmCheckStaff.executeQuery();

        String userType;
        String staffCourseName = null;
        if (rsCheck.next()) {
            userType = "lecture";
            staffCourseName = rsCheck.getString("course_name");
        } else {
            userType = "student";
        }
        rsCheck.close();
        pstmCheckStaff.close();

        // 2. Insert into users table (DO NOT include course_name here)
        String sqlUsers = "INSERT INTO users (first_name, last_name, user_name, email, password, user_type, contact_no, city, address) " +
                          "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        pstmUsers = conn.prepareStatement(sqlUsers, Statement.RETURN_GENERATED_KEYS);
        pstmUsers.setString(1, fName);
        pstmUsers.setString(2, lName);
        pstmUsers.setString(3, uName);
        pstmUsers.setString(4, email);
        pstmUsers.setString(5, pass);
        pstmUsers.setString(6, userType);
        pstmUsers.setString(7, contact);
        pstmUsers.setString(8, city);
        pstmUsers.setString(9, address);
        pstmUsers.executeUpdate();

        // 3. Get the generated user_id
        rsUserId = pstmUsers.getGeneratedKeys();
        if (!rsUserId.next()) {
            throw new SQLException("Failed to retrieve generated user_id for " + email);
        }
        int userId = rsUserId.getInt(1);

        // 4. Insert into students or lectures table
        String sqlInsert;
        // In addNewUser method, replace the lecturer insertion part:
        // In addNewUser method, replace the lecturer insertion part:
        if ("student".equals(userType)) {
            sqlInsert = "INSERT INTO students (user_id, first_name, last_name, user_name, email, password, user_type, contact_no, city, address) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            pstmInsert = conn.prepareStatement(sqlInsert);
            pstmInsert.setInt(1, userId);
            pstmInsert.setString(2, fName);
            pstmInsert.setString(3, lName);
            pstmInsert.setString(4, uName);
            pstmInsert.setString(5, email);
            pstmInsert.setString(6, pass);
            pstmInsert.setString(7, userType);
            pstmInsert.setString(8, contact);
            pstmInsert.setString(9, city);
            pstmInsert.setString(10, address);
        } else {
            // For lecturers, insert into lectures table
            sqlInsert = "INSERT INTO lectures (user_id, first_name, last_name, user_name, email, password, user_type, contact_no, city, address, course_name) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            pstmInsert = conn.prepareStatement(sqlInsert);
            pstmInsert.setInt(1, userId);
            pstmInsert.setString(2, fName);
            pstmInsert.setString(3, lName);
            pstmInsert.setString(4, uName);
            pstmInsert.setString(5, email);
            pstmInsert.setString(6, pass);
            pstmInsert.setString(7, userType);
            pstmInsert.setString(8, contact);
            pstmInsert.setString(9, city);
            pstmInsert.setString(10, address);
            pstmInsert.setString(11, staffCourseName != null ? staffCourseName : "");
        }
        pstmInsert.executeUpdate();

        conn.commit();
    } catch (SQLException ex) {
        try {
            if (conn != null) conn.rollback();
        } catch (SQLException rollbackEx) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, "Rollback failed", rollbackEx);
        }
        Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
    } finally {
        try {
            if (rsCheck != null) rsCheck.close();
            if (rsUserId != null) rsUserId.close();
            if (pstmUsers != null) pstmUsers.close();
            if (pstmInsert != null) pstmInsert.close();
            conn.setAutoCommit(true);
        } catch (SQLException e) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, e);
        }
    }
}


    public boolean loginValidate(String userName, String userPass) throws SQLException {
        boolean status = false;
        
        String sql = "SELECT * FROM users WHERE user_name = ?";
        PreparedStatement pstm = conn.prepareStatement(sql);
        pstm.setString(1, userName);
        ResultSet rs = pstm.executeQuery();
        String uname;
        String pass;
        while (rs.next()) {
            uname = rs.getString("user_name");
            pass = rs.getString("password");

            // Verify the provided password with the hashed password using BCrypt
            if (BCrypt.checkpw(userPass, pass)) {
                return true;
            }
        }
        return false;
    }  
    
public boolean updateUser(User user) {
    PreparedStatement ps = null;
    PreparedStatement psLecture = null;
    
    try {
        conn.setAutoCommit(false);
        
        // Update users table - CORRECTED COLUMN NAMES
        String query = "UPDATE users SET first_name=?, last_name=?, user_name=?, email=?, password=?, user_type=?, contact_no=?, city=?, address=? WHERE user_id=?";
        ps = conn.prepareStatement(query);
        ps.setString(1, user.getFirstName());
        ps.setString(2, user.getLastName());
        ps.setString(3, user.getUserName());
        ps.setString(4, user.getEmail());
        ps.setString(5, user.getPassword());
        ps.setString(6, user.getType());
        ps.setString(7, user.getContact());
        ps.setString(8, user.getCity());
        ps.setString(9, user.getAddress());
        ps.setInt(10, user.getUserId());
        
        int rowsAffected = ps.executeUpdate();
        
        // If user is a lecturer, update/insert in lectures table
        if ("lecture".equalsIgnoreCase(user.getType())) {
            // Check if lecturer exists in lectures table
            String checkSql = "SELECT COUNT(*) FROM lectures WHERE user_id = ?";
            PreparedStatement checkStmt = conn.prepareStatement(checkSql);
            checkStmt.setInt(1, user.getUserId());
            ResultSet rs = checkStmt.executeQuery();
            
            if (rs.next() && rs.getInt(1) > 0) {
                // Update existing lecturer
                String updateSql = "UPDATE lectures SET first_name=?, last_name=?, user_name=?, email=?, password=?, user_type=?, contact_no=?, city=?, address=?, course_name=? WHERE user_id=?";
                psLecture = conn.prepareStatement(updateSql);
                psLecture.setString(1, user.getFirstName());
                psLecture.setString(2, user.getLastName());
                psLecture.setString(3, user.getUserName());
                psLecture.setString(4, user.getEmail());
                psLecture.setString(5, user.getPassword());
                psLecture.setString(6, user.getType());
                psLecture.setString(7, user.getContact());
                psLecture.setString(8, user.getCity());
                psLecture.setString(9, user.getAddress());
                psLecture.setString(10, user.getCourseName());
                psLecture.setInt(11, user.getUserId());
            } else {
                // Insert new lecturer
                String insertSql = "INSERT INTO lectures (user_id, first_name, last_name, user_name, email, password, user_type, contact_no, city, address, course_name) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                psLecture = conn.prepareStatement(insertSql);
                psLecture.setInt(1, user.getUserId());
                psLecture.setString(2, user.getFirstName());
                psLecture.setString(3, user.getLastName());
                psLecture.setString(4, user.getUserName());
                psLecture.setString(5, user.getEmail());
                psLecture.setString(6, user.getPassword());
                psLecture.setString(7, user.getType());
                psLecture.setString(8, user.getContact());
                psLecture.setString(9, user.getCity());
                psLecture.setString(10, user.getAddress());
                psLecture.setString(11, user.getCourseName());
            }
            
            if (psLecture != null) {
                psLecture.executeUpdate();
            }
            checkStmt.close();
        } else {
            // If not a lecturer, delete from lectures table if exists
            String deleteSql = "DELETE FROM lectures WHERE user_id = ?";
            PreparedStatement deleteStmt = conn.prepareStatement(deleteSql);
            deleteStmt.setInt(1, user.getUserId());
            deleteStmt.executeUpdate();
            deleteStmt.close();
        }
        
        conn.commit();
        return rowsAffected > 0;
        
    } catch (SQLException e) {
        try {
            if (conn != null) conn.rollback();
        } catch (SQLException rollbackEx) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, "Rollback failed", rollbackEx);
        }
        e.printStackTrace();
        return false;
    } finally {
        try {
            if (ps != null) ps.close();
            if (psLecture != null) psLecture.close();
            conn.setAutoCommit(true);
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}

    
public int updateStudent(int uId, String fName, String lName, String uName, String email, String pass,
        String contact, String city, String address, String userType) {
    int rows = 0;
    PreparedStatement pstmUsers = null;
    PreparedStatement pstmStudents = null;
    
    try {
        conn.setAutoCommit(false);
        
        // Update users table
        String sqlUsers = "UPDATE users SET first_name=?, last_name=?, user_name=?, email=?, password=?, user_type=?, contact_no=?, city=?, address=? WHERE user_id=?";
        pstmUsers = conn.prepareStatement(sqlUsers);
        pstmUsers.setString(1, fName);
        pstmUsers.setString(2, lName);
        pstmUsers.setString(3, uName);
        pstmUsers.setString(4, email);
        pstmUsers.setString(5, pass);
        pstmUsers.setString(6, userType);
        pstmUsers.setString(7, contact);
        pstmUsers.setString(8, city);
        pstmUsers.setString(9, address);
        pstmUsers.setInt(10, uId);
        rows = pstmUsers.executeUpdate();
        
        // Update students table
        String sqlStudents = "UPDATE students SET first_name=?, last_name=?, user_name=?, email=?, password=?, user_type=?, contact_no=?, city=?, address=? WHERE user_id=?";
        pstmStudents = conn.prepareStatement(sqlStudents);
        pstmStudents.setString(1, fName);
        pstmStudents.setString(2, lName);
        pstmStudents.setString(3, uName);
        pstmStudents.setString(4, email);
        pstmStudents.setString(5, pass);
        pstmStudents.setString(6, userType);
        pstmStudents.setString(7, contact);
        pstmStudents.setString(8, city);
        pstmStudents.setString(9, address);
        pstmStudents.setInt(10, uId);
        pstmStudents.executeUpdate();
        
        conn.commit();
    } catch (SQLException ex) {
        try {
            if (conn != null) conn.rollback();
        } catch (SQLException rollbackEx) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, "Rollback failed", rollbackEx);
        }
        Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
        rows = 0;
    } finally {
        try {
            if (pstmUsers != null) pstmUsers.close();
            if (pstmStudents != null) pstmStudents.close();
            conn.setAutoCommit(true);
        } catch (SQLException e) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, e);
        }
    }
    return rows;
}

public int updateLecturer(int uId, String fName, String lName, String uName, String email, String pass,
                          String contact, String city, String address, String userType, String courseName) {
    int rows = 0;
    PreparedStatement pstmUsers = null;
    PreparedStatement pstmLectures = null;
    
    try {
        conn.setAutoCommit(false);
        
        // 1. Update users table
        String sqlUsers = "UPDATE users SET first_name=?, last_name=?, user_name=?, email=?, password=?, user_type=?, contact_no=?, city=?, address=? WHERE user_id=?";
        pstmUsers = conn.prepareStatement(sqlUsers);
        pstmUsers.setString(1, fName);
        pstmUsers.setString(2, lName);
        pstmUsers.setString(3, uName);
        pstmUsers.setString(4, email);
        pstmUsers.setString(5, pass);
        pstmUsers.setString(6, userType);
        pstmUsers.setString(7, contact);
        pstmUsers.setString(8, city);
        pstmUsers.setString(9, address);
        pstmUsers.setInt(10, uId);
        rows = pstmUsers.executeUpdate();
        
        // 2. Update lectures table (which has all user fields duplicated)
        // First check if lecturer exists in lectures table
        String checkSql = "SELECT COUNT(*) FROM lectures WHERE user_id = ?";
        PreparedStatement checkStmt = conn.prepareStatement(checkSql);
        checkStmt.setInt(1, uId);
        ResultSet rs = checkStmt.executeQuery();
        
        if (rs.next() && rs.getInt(1) > 0) {
            // Update existing lecturer - update ALL fields
            String sqlLectures = "UPDATE lectures SET first_name=?, last_name=?, user_name=?, email=?, password=?, user_type=?, contact_no=?, city=?, address=?, course_name=? WHERE user_id=?";
            pstmLectures = conn.prepareStatement(sqlLectures);
            pstmLectures.setString(1, fName);
            pstmLectures.setString(2, lName);
            pstmLectures.setString(3, uName);
            pstmLectures.setString(4, email);
            pstmLectures.setString(5, pass);
            pstmLectures.setString(6, userType);
            pstmLectures.setString(7, contact);
            pstmLectures.setString(8, city);
            pstmLectures.setString(9, address);
            pstmLectures.setString(10, courseName);
            pstmLectures.setInt(11, uId);
        } else {
            // Insert new lecturer record with ALL fields
            String sqlLectures = "INSERT INTO lectures (user_id, first_name, last_name, user_name, email, password, user_type, contact_no, city, address, course_name) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            pstmLectures = conn.prepareStatement(sqlLectures);
            pstmLectures.setInt(1, uId);
            pstmLectures.setString(2, fName);
            pstmLectures.setString(3, lName);
            pstmLectures.setString(4, uName);
            pstmLectures.setString(5, email);
            pstmLectures.setString(6, pass);
            pstmLectures.setString(7, userType);
            pstmLectures.setString(8, contact);
            pstmLectures.setString(9, city);
            pstmLectures.setString(10, address);
            pstmLectures.setString(11, courseName);
        }
        
        if (pstmLectures != null) {
            pstmLectures.executeUpdate();
        }
        
        conn.commit();
        checkStmt.close();
    } catch (SQLException ex) {
        try {
            if (conn != null) conn.rollback();
        } catch (SQLException rollbackEx) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, "Rollback failed", rollbackEx);
        }
        Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
        rows = 0; // Indicate failure
    } finally {
        try {
            if (pstmUsers != null) pstmUsers.close();
            if (pstmLectures != null) pstmLectures.close();
            conn.setAutoCommit(true);
        } catch (SQLException e) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, e);
        }
    }
    
    return rows;
}

public ArrayList<String> getAllCourseNames() {
    ArrayList<String> courses = new ArrayList<>();
    // CORRECTED: The courses table has 'course_name' field as per your schema
    String sql = "SELECT DISTINCT course_name FROM courses WHERE course_name IS NOT NULL AND course_name != '' ORDER BY course_name";

    try (PreparedStatement pstmt = conn.prepareStatement(sql);
         ResultSet rs = pstmt.executeQuery()) {
        
        while (rs.next()) {
            String courseName = rs.getString("course_name");
            if (courseName != null && !courseName.trim().isEmpty()) {
                courses.add(courseName.trim());
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    
    return courses;
}




    
public ArrayList getAllCourses() {
    ArrayList list = new ArrayList();
    try {
        String sql = "SELECT course_name, total_marks, time, exam_date FROM courses";
        PreparedStatement pstm = conn.prepareStatement(sql);
        ResultSet rs = pstm.executeQuery();

        while (rs.next()) {
            list.add(rs.getString("course_name")); // 0
            list.add(rs.getInt("total_marks"));    // 1
            list.add(rs.getString("time"));        // 2 ✅ FIX
            list.add(rs.getDate("exam_date"));     // 3
        }

        rs.close();
        pstm.close();
    } catch (SQLException ex) {
        Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
    }
    return list;
}

   
public boolean addNewCourse(String courseName, int tMarks, String time, String examDate) {
    try {
        String sql = "INSERT INTO courses(course_name, total_marks, time, exam_date) VALUES (?, ?, ?, ?)";
        PreparedStatement pstm = conn.prepareStatement(sql);
        pstm.setString(1, courseName);
        pstm.setInt(2, tMarks);
        pstm.setString(3, time);
        pstm.setString(4, examDate); 
        int rows = pstm.executeUpdate();
        pstm.close();
        return rows > 0;
    } catch (SQLException ex) {
        Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
        return false;
    }
}


    public void delCourse(String cName){
        try {
            String sql="DELETE from courses where course_name=?";
            PreparedStatement pstm=conn.prepareStatement(sql);
            pstm.setString(1,cName);
            pstm.executeUpdate();
            pstm.close();
        } catch (SQLException ex) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
    
    
public void addNewQuestion(String questionText, String opt1, String opt2, String opt3, String opt4, String correctAnswer, String courseName, String questionType) {
    try {
        String sql;
        PreparedStatement pstm;

        // If it's a True/False question, only use two options.
        if ("TrueFalse".equalsIgnoreCase(questionType)) {
            sql = "INSERT INTO questions (question, opt1, opt2, correct, course_name, question_type) VALUES (?, ?, ?, ?, ?, ?)";
            pstm = conn.prepareStatement(sql);
            pstm.setString(1, questionText);
            pstm.setString(2, "True");  // Hardcoded options for True/False
            pstm.setString(3, "False");
            pstm.setString(4, correctAnswer);
            pstm.setString(5, courseName);
            pstm.setString(6, questionType);
        } else {
            // Otherwise, handle multiple-choice questions
            sql = "INSERT INTO questions (question, opt1, opt2, opt3, opt4, correct, course_name, question_type) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            pstm = conn.prepareStatement(sql);
            pstm.setString(1, questionText);
            pstm.setString(2, opt1);
            pstm.setString(3, opt2);
            pstm.setString(4, opt3);
            pstm.setString(5, opt4);
            pstm.setString(6, correctAnswer);
            pstm.setString(7, courseName);
            pstm.setString(8, questionType);
        }

        // Execute the update
        pstm.executeUpdate();
        pstm.close();
        System.out.println("Question inserted successfully: " + questionText);

    } catch (SQLException ex) {
        System.out.println("Error inserting question: " + ex.getMessage());
        Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
    }
}  
    
public Questions getQuestionById(int questionId) {
    Questions question = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        // SQL query to fetch question by ID
        String sql = "SELECT * FROM questions WHERE question_id = ?";
        pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, questionId);

        // Execute the query
        rs = pstmt.executeQuery();

        // Populate the Questions object if a record is found
        if (rs.next()) {
            question = new Questions();
            question.setQuestionId(rs.getInt("question_id"));
            question.setQuestion(rs.getString("question"));
            question.setOpt1(rs.getString("opt1"));
            question.setOpt2(rs.getString("opt2"));
            question.setOpt3(rs.getString("opt3"));
            question.setOpt4(rs.getString("opt4"));
            question.setCorrect(rs.getString("correct"));
        }
    } catch (SQLException e) {
        e.printStackTrace();
    } finally {
        // Close resources
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
    }

    return question;
}



 // Modify updateQuestion method to accept a Questions object
public boolean updateQuestion(Questions question) {
    String sql = "UPDATE questions SET question=?, opt1=?, opt2=?, opt3=?, opt4=?, correct=?, course_name=? WHERE question_id=?";
    try (PreparedStatement pstm = conn.prepareStatement(sql)) {
        pstm.setString(1, question.getQuestion());
        pstm.setString(2, question.getOpt1());
        pstm.setString(3, question.getOpt2());
        pstm.setString(4, question.getOpt3());
        pstm.setString(5, question.getOpt4());
        pstm.setString(6, question.getCorrect());
        pstm.setString(7, question.getCourseName());
        pstm.setInt(8, question.getQuestionId());

        int rowsAffected = pstm.executeUpdate();
        return rowsAffected > 0;
    } catch (SQLException e) {
        e.printStackTrace();
        return false;
    }
}

 
    
public void delQuestion(int qId) {
    
            // SQL statement to delete a question by its ID
        String sql = "DELETE FROM questions WHERE question_id=?";
    try {
        
        // Prepare the SQL statement using the existing connection
        PreparedStatement pstm = conn.prepareStatement(sql);
        pstm.setInt(1, qId);
        
        // Execute the statement
        pstm.executeUpdate();
        
        // Close the prepared statement
        pstm.close();
    } catch (SQLException ex) {
        Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
    }
}

public void deleteUserCascade(int userId) {
    try {
        conn.setAutoCommit(false);

        String userType = getUserType(String.valueOf(userId));

        if ("student".equalsIgnoreCase(userType)) {
            // Step 1: Get all exam_ids for the student
            ArrayList<Integer> examIds = new ArrayList<>();
            String selectExamsSql = "SELECT exam_id FROM exams WHERE std_id = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(selectExamsSql)) {
                pstmt.setInt(1, userId);
                try (ResultSet rs = pstmt.executeQuery()) {
                    while (rs.next()) {
                        examIds.add(rs.getInt("exam_id"));
                    }
                }
            }

            // Step 2: Delete from answers table for each exam_id
            if (!examIds.isEmpty()) {
                String deleteAnswersSql = "DELETE FROM answers WHERE exam_id = ?";
                try (PreparedStatement pstmt = conn.prepareStatement(deleteAnswersSql)) {
                    for (int examId : examIds) {
                        pstmt.setInt(1, examId);
                        pstmt.executeUpdate();
                    }
                }
            }

            // Step 3: Delete from exams table
            String deleteExamsSql = "DELETE FROM exams WHERE std_id = ?";
            try (PreparedStatement pstmt = conn.prepareStatement(deleteExamsSql)) {
                pstmt.setInt(1, userId);
                pstmt.executeUpdate();
            }

            // Step 4: Delete from students table
            delStudent(userId);

        } else if ("lecture".equalsIgnoreCase(userType)) {
            // For a lecturer, we just remove their association from the 'lectures' table.
            // We do NOT delete the course or questions as they might be shared with other lecturers.
            delLecture(userId);
        }

        // Finally, delete from the main users table for all user types
        deleteUser(userId);

        conn.commit();
    } catch (SQLException ex) {
        try {
            conn.rollback();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
    } finally {
        try {
            conn.setAutoCommit(true);
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}

public void deleteQuestion(int questionId) {
    String sql = "DELETE FROM questions WHERE question_id = ?";
    
    try {
        // Prepare the SQL statement
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, questionId);
        
        // Execute the statement
        pstmt.executeUpdate();
        
        // Close the prepared statement
        pstmt.close();
    } catch (SQLException ex) {
        Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
    }
}


public void deleteUser(int userId) {
    String sql = "DELETE FROM users WHERE user_id = ?";
    
    try {
        // Prepare the SQL statement
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, userId);
        
        // Execute the statement
        pstmt.executeUpdate();
        
        // Close the prepared statement
        pstmt.close();
    } catch (SQLException ex) {
        Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
    }
}

    public void delStudent(int uid){
        try {
            String sql="DELETE from students where user_id=?";
            PreparedStatement pstm=conn.prepareStatement(sql);
            pstm.setInt(1,uid);
            pstm.executeUpdate();
            pstm.close();
        } catch (SQLException ex) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
    
    public void delLecture(int uid){
        try {
            String sql="DELETE from lectures where user_id=?";
            PreparedStatement pstm=conn.prepareStatement(sql);
            pstm.setInt(1,uid);
            pstm.executeUpdate();
            pstm.close();
        } catch (SQLException ex) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
    
public void deleteLecturer(int userId) {
    String sql = "DELETE FROM lectures WHERE user_id = ?";
    
    try {
        // Prepare the SQL statement
        PreparedStatement pstmt = conn.prepareStatement(sql);
        pstmt.setInt(1, userId);
        
        // Execute the statement
        pstmt.executeUpdate();
        
        // Close the prepared statement
        pstmt.close();
    } catch (SQLException ex) {
        Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
    }
}   


    
public void addQuestion(String cName, String question, String opt1, String opt2, String opt3, String opt4, String correct, String questionType) {
    try {
        String sql;
        PreparedStatement pstm;

        // If the question type is True/False, only use two options (True/False)
        if (questionType.equals("TrueFalse")) {
            sql = "INSERT INTO questions (question, opt1, opt2, correct, course_name, question_type) VALUES (?, ?, ?, ?, ?, ?)";
            pstm = conn.prepareStatement(sql);
            pstm.setString(1, question);
            pstm.setString(2, "True");  // True as the first option
            pstm.setString(3, "False"); // False as the second option
            pstm.setString(4, correct); // Correct answer should be "True" or "False"
            pstm.setString(5, cName); // Set the course name
            pstm.setString(6, questionType);
        } else {
            // Multiple Choice Question logic
            sql = "INSERT INTO questions (question, opt1, opt2, opt3, opt4, correct, course_name, question_type) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
            pstm = conn.prepareStatement(sql);
            pstm.setString(1, question);
            pstm.setString(2, opt1);
            pstm.setString(3, opt2);
            pstm.setString(4, opt3);
            pstm.setString(5, opt4);
            pstm.setString(6, correct);
            pstm.setString(7, cName); // Set the course name
            pstm.setString(8, questionType);
        }

        // Execute the update
        pstm.executeUpdate();
        pstm.close();
        System.out.println("Question inserted successfully: " + question);

    } catch (SQLException ex) {
        System.out.println("Error inserting question: " + ex.getMessage());
        Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
    }
}



    
    
    public ArrayList getQuestions(String courseName,int questions){
        ArrayList list=new ArrayList();
        try {
            
            String sql="Select * from questions where course_name=? ORDER BY RAND() LIMIT ?";
            PreparedStatement pstm=conn.prepareStatement(sql);
            pstm.setString(1,courseName);
            pstm.setInt(2,questions);
            ResultSet rs=pstm.executeQuery();
            Questions question;
            while(rs.next()){
               question = new Questions(
                       rs.getInt(1),rs.getString(3),rs.getString(4),rs.getString(5),
                       rs.getString(6),rs.getString(7),rs.getString(8),rs.getString(2)
                    ); 
               list.add(question);
            }
            pstm.close();
        } catch (SQLException ex) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }
    
    public int startExam(String rawName, int sId) throws SQLException {
        /* ----  FK-SAFE WRAPPER  ---- */
        if (rawName == null) throw new SQLException("Course name is null");

        // 1. normalise the name exactly as stored in courses
        String cName = rawName.trim().toLowerCase();

        // 2. parent row MUST exist
        if (!courseExists(cName)) {
            throw new SQLException("Course '" + rawName + "' does not exist in courses table");
        }

        /* ----  ORIGINAL INSERT LOGIC  ---- */
        int examId = 0;
        String sql = "INSERT INTO exams(course_name, date, start_time, exam_time, std_id, total_marks, status, result_status) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement pstm = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            pstm.setString(1, cName);               // cleaned name
            pstm.setString(2, LocalDate.now().toString());
            pstm.setString(3, LocalTime.now().toString());
            pstm.setString(4, getCourseTimeByName(cName));
            pstm.setInt(5, sId);
            pstm.setInt(6, getTotalMarksByName(cName));
            pstm.setString(7, "in_progress");       // Set initial status
            pstm.setNull(8, Types.VARCHAR);         // result_status is NULL initially

            pstm.executeUpdate();

            try (ResultSet keys = pstm.getGeneratedKeys()) {
                if (keys.next()) examId = keys.getInt(1);
            }
        }
        return examId;
    }
    
    public int getLastExamId(){
        int id=0;
         try {
            
            String sql="Select * from exams";
            PreparedStatement pstm=conn.prepareStatement(sql);
            ResultSet rs=pstm.executeQuery();
            
            while(rs.next()){
               id=rs.getInt(1);
            }
            pstm.close();
        } catch (SQLException ex) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
        }
         return id;
    }
    public String getStartTime(int examId){
        String time="";
        try {
            
            String sql="Select start_time from exams where exam_id=?";
            PreparedStatement pstm=conn.prepareStatement(sql);
            pstm.setInt(1, examId);
            ResultSet rs=pstm.executeQuery();
            
            while(rs.next()){
               time=rs.getString(1);
            }
            pstm.close();
        } catch (SQLException ex) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
        }
        return time;
    }
    public String getCourseTimeByName(String cName){
     String c=null;
     try{
         PreparedStatement pstm=conn.prepareStatement("Select time from courses where course_name=?");
         pstm.setString(1,cName);
         ResultSet rs=pstm.executeQuery();
         while(rs.next()){
             c=rs.getString(1);
         }
         pstm.close();
     }catch(Exception e){
          Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, e);
     }
     
     return c;
    }
    public int getTotalMarksByName(String cName){
     int marks=0;
     try{
         PreparedStatement pstm=conn.prepareStatement("Select total_marks from courses where course_name=?");
         pstm.setString(1,cName);
         ResultSet rs=pstm.executeQuery();
         while(rs.next()){
             marks=rs.getInt(1);
             System.out.println(rs.getInt(1));
         }
         pstm.close();
     }catch(Exception e){
          e.printStackTrace();
     }
     
     return marks;
    }
    
    public ArrayList getAllQuestions(String courseName){
        ArrayList list=new ArrayList();
        try {
            
            String sql="Select * from questions where course_name=?";
            PreparedStatement pstm=conn.prepareStatement(sql);
            pstm.setString(1,courseName);
            ResultSet rs=pstm.executeQuery();
            Questions question;
            while(rs.next()){
               question = new Questions(
                       rs.getInt(1),rs.getString(3),rs.getString(4),rs.getString(5),
                       rs.getString(6),rs.getString(7),rs.getString(8),rs.getString(2)
                    ); 
               list.add(question);
            }
            pstm.close();
        } catch (SQLException ex) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }
    
    public ArrayList getAllAnswersByExamId(int examId){
        ArrayList list=new ArrayList();
        try {
            
            String sql="Select * from answers where exam_id=?";
            PreparedStatement pstm=conn.prepareStatement(sql);
            pstm.setInt(1,examId);
            ResultSet rs=pstm.executeQuery();
            Answers a;
            while(rs.next()){
               a = new Answers(
                       rs.getString(3),rs.getString(4),rs.getString(5),rs.getString(6)
                    ); 
               list.add(a);
            }
            pstm.close();
        } catch (SQLException ex) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }
    
    private  String getFormatedDate(String date){
        LocalDate localDate=LocalDate.parse(date);
        return localDate.format(DateTimeFormatter.ofPattern("dd-MM-yyyy"));
    }
    private String getNormalDate(String date){
        String[] d=date.split("-");
        return d[2]+"-"+d[1]+"-"+d[0];
    }
    private String getFormatedTime(String time){
        if(time!=null){
            LocalTime localTime=LocalTime.parse(time);
        return  localTime.format(DateTimeFormatter.ofPattern("hh:mm a"));
        }else{
            
        return  "-";
        }
    }

    public int getRemainingTime(int examId){
        int time=0;
        try {
            
            String sql="Select start_time,exam_time from exams where exam_id=?";
            PreparedStatement pstm=conn.prepareStatement(sql);
            pstm.setInt(1, examId);
            ResultSet rs=pstm.executeQuery();
            
            while(rs.next()){
                //totalTime-(Math.abs(currentTime-examStartTime))
                //Duration.between(first,sec) returns difference between 2 dates or 2 times
               time=Integer.parseInt(rs.getString(2))-(int)Math.abs((Duration.between(LocalTime.now(),LocalTime.parse(rs.getString(1))).getSeconds()/60));
            }
            pstm.close();
        } catch (SQLException ex) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
        }
        System.out.println(time);
        return time;
    }
    
    
    public void insertAnswer(int eId, int qid, String question, String ans) {
        try {
            String correct = getCorrectAnswer(qid); // Fetch correct answer
            String status = getAnswerStatus(ans == null ? "" : ans, correct); // Handle null answers

            PreparedStatement pstm = conn.prepareStatement(
                "INSERT INTO answers (exam_id, question, answer, correct_answer, status) VALUES (?, ?, ?, ?, ?)"
            );
            pstm.setInt(1, eId); // Exam ID
            pstm.setString(2, question); // Question text
            pstm.setString(3, ans == null ? "N/A" : ans); // User's answer (or "N/A" if unanswered)
            pstm.setString(4, correct); // Correct answer
            pstm.setString(5, status); // Status (correct/incorrect)
            pstm.executeUpdate();
        } catch (SQLException ex) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
        }
    }


    private String getCorrectAnswer(int qid) {
        String ans="";
        
        try {
            PreparedStatement pstm=conn.prepareStatement("Select correct from questions where question_id=?");
            pstm.setInt(1,qid);
            ResultSet rs=pstm.executeQuery();
            while(rs.next()){
                ans=rs.getString(1);
            }
        } catch (SQLException ex) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
        }
        
        
        return ans;
    }

private String getAnswerStatus(String ans, String correct) {
    if (ans.equals(correct)) {
        return "correct";
    } else {
        return "incorrect";
    }
}


public boolean courseExists(String courseName) {
    if (courseName == null) return false;
    String sql = "SELECT 1 FROM courses WHERE LOWER(TRIM(course_name)) = LOWER(TRIM(?)) LIMIT 1";
    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setString(1, courseName);
        try (ResultSet rs = ps.executeQuery()) {
            return rs.next();
        }
    } catch (SQLException e) {
        Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, "courseExists failed", e);
        return false;
    }
}


/// Method to get results for a specific student by student ID
public ArrayList<Exams> getResultsFromExams(Integer stdId) {
    ArrayList<Exams> list = new ArrayList<>();
    try {
        String query;
        PreparedStatement pstm;
        
        if (stdId != null) {
            // Get results for specific student
            query = "SELECT u.first_name, u.last_name, u.user_name, u.email, " +
                    "e.exam_id, e.std_id, e.course_name, e.total_marks, e.obt_marks, " +
                    "e.date, e.start_time, e.end_time, e.exam_time, e.status, e.result_status " +
                    "FROM exams e " +
                    "JOIN users u ON e.std_id = u.user_id " +
                    "WHERE e.std_id = ? " +
                    "ORDER BY e.date DESC";
            pstm = conn.prepareStatement(query);
            pstm.setInt(1, stdId);
        } else {
            // Get all results for admin
            query = "SELECT u.first_name, u.last_name, u.user_name, u.email, " +
                    "e.exam_id, e.std_id, e.course_name, e.total_marks, e.obt_marks, " +
                    "e.date, e.start_time, e.end_time, e.exam_time, e.status, e.result_status " +
                    "FROM exams e " +
                    "JOIN users u ON e.std_id = u.user_id " +
                    "WHERE u.user_type = 'student' " + // Only students
                    "ORDER BY e.date DESC, e.exam_id DESC";
            pstm = conn.prepareStatement(query);
        }
        
        ResultSet rs = pstm.executeQuery();

        while (rs.next()) {
            String formattedDate = rs.getDate("date") != null ? rs.getDate("date").toString() : null;
            
            // Get result_status
            String resultStatus = rs.getString("result_status");
            if (resultStatus == null) {
                // Calculate from marks
                int totalMarks = rs.getInt("total_marks");
                int obtMarks = rs.getInt("obt_marks");
                if (totalMarks > 0) {
                    double percentage = (obtMarks * 100.0) / totalMarks;
                    resultStatus = (percentage >= 45.0) ? "Pass" : "Fail";
                } else {
                    resultStatus = rs.getString("status");
                }
            }

            Exams exam = new Exams(
                rs.getString("first_name"),
                rs.getString("last_name"),
                rs.getString("user_name"),
                rs.getString("email"),
                rs.getInt("exam_id"),
                rs.getString("std_id"),
                rs.getString("course_name"),
                rs.getInt("total_marks"),
                rs.getInt("obt_marks"),
                formattedDate,
                rs.getString("start_time"),
                rs.getString("end_time"),
                rs.getString("exam_time"),
                resultStatus
            );
            list.add(exam);
        }
        
        pstm.close();
    } catch (SQLException ex) {
        Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
    }
    return list;
}

public int getExamDuration(String courseName) {
    int duration = 120; // Default 2 hours in minutes
    try {
        String sql = "SELECT time FROM courses WHERE course_name = ?";
        PreparedStatement pstm = conn.prepareStatement(sql);
        pstm.setString(1, courseName);
        ResultSet rs = pstm.executeQuery();
        if (rs.next()) {
            String timeStr = rs.getString("time");
            // Parse time string like "02:00" or "1:30" to minutes
            if (timeStr != null && timeStr.contains(":")) {
                String[] parts = timeStr.split(":");
                int hours = 0;
                int minutes = 0;
                
                try {
                    hours = Integer.parseInt(parts[0].trim());
                    minutes = Integer.parseInt(parts[1].trim());
                    duration = (hours * 60) + minutes;
                } catch (NumberFormatException e) {
                    System.out.println("Error parsing time format: " + timeStr);
                }
            }
        }
        rs.close();
        pstm.close();
    } catch (SQLException ex) {
        System.out.println("Error getting exam duration: " + ex.getMessage());
    }
    return duration;
}

// Method to get an Exam by Exam ID
public Exams getResultByExamId(int examId) {
    Exams exam = null;
    PreparedStatement pstm = null;
    ResultSet rs = null;

    try {
        String query = "SELECT u.first_name, u.last_name, u.user_name, u.email, " +
                       "e.exam_id, e.std_id, e.course_name, e.total_marks, e.obt_marks, " +
                       "e.date, e.start_time, e.end_time, e.exam_time, e.status, e.result_status " + // ADDED result_status
                       "FROM exams e " +
                       "INNER JOIN users u ON e.std_id = u.user_id " +
                       "WHERE e.exam_id = ?";

        pstm = conn.prepareStatement(query);
        pstm.setInt(1, examId);
        rs = pstm.executeQuery();

        if (rs.next()) {
            String formattedDate = rs.getDate("date") != null ? rs.getDate("date").toString() : null;
            
            // Get result_status, fallback to status if NULL
            String resultStatus = rs.getString("result_status");
            if (resultStatus == null) {
                // Calculate from marks
                int totalMarks = rs.getInt("total_marks");
                int obtMarks = rs.getInt("obt_marks");
                if (totalMarks > 0) {
                    double percentage = (obtMarks * 100.0) / totalMarks;
                    resultStatus = (percentage >= 45.0) ? "Pass" : "Fail";
                } else {
                    resultStatus = rs.getString("status"); // Fallback
                }
            }
            
            exam = new Exams(
                rs.getString("first_name"), 
                rs.getString("last_name"), 
                rs.getString("user_name"),
                rs.getString("email"),
                rs.getInt("exam_id"),
                rs.getString("std_id"),
                rs.getString("course_name"),
                rs.getInt("total_marks"),
                rs.getInt("obt_marks"),
                formattedDate,
                rs.getString("start_time"),
                rs.getString("end_time"),
                rs.getString("exam_time"),
                resultStatus  // Use result_status NOT status
            );
        }
    } catch (SQLException ex) {
        ex.printStackTrace();
    } finally {
        closeResources(pstm, rs);
    }
    return exam;
}

// Add this method to DatabaseClass.java
// Add this method to DatabaseClass.java to get ALL exam results (for admin)
public ArrayList<Exams> getAllExamResults() {
    ArrayList<Exams> list = new ArrayList<>();
    try {
        String query = "SELECT u.first_name, u.last_name, u.user_name, u.email, " +
                       "e.exam_id, e.std_id, e.course_name, e.total_marks, e.obt_marks, " +
                       "e.date, e.start_time, e.end_time, e.exam_time, e.status, e.result_status " +
                       "FROM exams e " +
                       "JOIN users u ON e.std_id = u.user_id " +
                       "WHERE u.user_type = 'student' " + // Only student results
                       "ORDER BY e.date DESC, e.exam_id DESC";
        
        PreparedStatement pstm = conn.prepareStatement(query);
        ResultSet rs = pstm.executeQuery();

        while (rs.next()) {
            String formattedDate = rs.getDate("date") != null ? rs.getDate("date").toString() : null;
            
            // Get result_status
            String resultStatus = rs.getString("result_status");
            if (resultStatus == null) {
                // Calculate from marks
                int totalMarks = rs.getInt("total_marks");
                int obtMarks = rs.getInt("obt_marks");
                if (totalMarks > 0) {
                    double percentage = (obtMarks * 100.0) / totalMarks;
                    resultStatus = (percentage >= 45.0) ? "Pass" : "Fail";
                } else {
                    resultStatus = rs.getString("status");
                }
            }

            Exams exam = new Exams(
                rs.getString("first_name"),
                rs.getString("last_name"),
                rs.getString("user_name"),
                rs.getString("email"),
                rs.getInt("exam_id"),
                rs.getString("std_id"),
                rs.getString("course_name"),
                rs.getInt("total_marks"),
                rs.getInt("obt_marks"),
                formattedDate,
                rs.getString("start_time"),
                rs.getString("end_time"),
                rs.getString("exam_time"),
                resultStatus
            );
            list.add(exam);
        }
        
        pstm.close();
    } catch (SQLException ex) {
        Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
    }
    return list;
}



// Method to get all exams with results
public ArrayList<Exams> getAllExamsWithResults() {
    ArrayList<Exams> exams = new ArrayList<>();

    String query = "SELECT u.first_name, u.last_name, u.user_name, u.email, " +
                   "e.exam_id, e.std_id, e.course_name, e.total_marks, e.obt_marks, " +
                   "e.date, e.start_time, e.end_time, e.exam_time, e.status, e.result_status " + // ADDED
                   "FROM exams e " +
                   "INNER JOIN users u ON e.std_id = u.user_id";

    try (PreparedStatement ps = conn.prepareStatement(query);
         ResultSet rs = ps.executeQuery()) {

        while (rs.next()) {
            String formattedDate = rs.getDate("date") != null 
                                    ? new SimpleDateFormat("yyyy-MM-dd").format(rs.getDate("date")) 
                                    : null;
            
            // Get result_status
            String resultStatus = rs.getString("result_status");
            if (resultStatus == null) {
                // Calculate
                int totalMarks = rs.getInt("total_marks");
                int obtMarks = rs.getInt("obt_marks");
                if (totalMarks > 0) {
                    double percentage = (obtMarks * 100.0) / totalMarks;
                    resultStatus = (percentage >= 45.0) ? "Pass" : "Fail";
                } else {
                    resultStatus = rs.getString("status");
                }
            }

            Exams exam = new Exams(
                rs.getString("first_name"),
                rs.getString("last_name"),
                rs.getString("user_name"),
                rs.getString("email"),
                rs.getInt("exam_id"),
                rs.getString("std_id"),
                rs.getString("course_name"),
                rs.getInt("total_marks"),
                rs.getInt("obt_marks"),
                formattedDate,
                rs.getString("start_time"),
                rs.getString("end_time"),
                rs.getString("exam_time"),
                resultStatus  // Use result_status
            );
            exams.add(exam);
        }
    } catch (SQLException e) {
        Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, "Error fetching exams with results", e);
    }

    return exams;
}


private int getObtMarks(int examId, int tMarks, int size) {
    int correctAnswersCount = 0;
    try {
        PreparedStatement pstm = conn.prepareStatement("SELECT COUNT(answer_id) FROM answers WHERE exam_id=? AND status='correct'");
        pstm.setInt(1, examId);
        ResultSet rs = pstm.executeQuery();

        if (rs.next()) {
            correctAnswersCount = rs.getInt(1);
        }
        
        // Calculate marks per question (float to avoid integer division)
        float marksPerQuestion = (size > 0) ? (float) tMarks / size : 0;
        float obtainedMarks = correctAnswersCount * marksPerQuestion;
        
        // Round to nearest integer
        return Math.round(obtainedMarks);
        
    } catch (SQLException ex) {
        Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
        return 0;
    }
}

public void calculateResult(int eid, int tMarks, String endTime, int size) {
    try {
        // First, calculate obtained marks
        int obt = getObtMarks(eid, tMarks, size);
        
        // Calculate percentage
        float percentage = 0;
        if (tMarks > 0) {
            percentage = ((float) obt / tMarks) * 100;
        }
        
        // Determine result status based on percentage (45% passing threshold)
        String resultStatus = (percentage >= 45.0) ? "Pass" : "Fail";
        
        // DEBUG LOGGING
        System.out.println("=== DEBUG calculateResult ===");
        System.out.println("Exam ID: " + eid);
        System.out.println("Marks: " + obt + "/" + tMarks);
        System.out.println("Percentage: " + percentage + "%");
        System.out.println("Result Status: " + resultStatus);
        
        // Update the exams table with both status and result_status
        String sql = "UPDATE exams SET obt_marks=?, end_time=?, status=?, result_status=? WHERE exam_id=?";
        PreparedStatement pstm = conn.prepareStatement(sql);
        pstm.setInt(1, obt);
        pstm.setString(2, endTime);
        pstm.setString(3, "completed");
        pstm.setString(4, resultStatus); // CRITICAL: This sets result_status
        pstm.setInt(5, eid);
        
        int rowsUpdated = pstm.executeUpdate();
        System.out.println("Rows updated: " + rowsUpdated);
        
        pstm.close();
        
    } catch (SQLException ex) {
        System.err.println("ERROR in calculateResult: " + ex.getMessage());
        Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
    }
}


/* Add this method in your DatabaseClass */

public String getLastCourseName() {
    String lastCourseName = null;
    try {
        String query = "SELECT course_name FROM questions ORDER BY question_id DESC LIMIT 1"; // Your SQL query
        PreparedStatement pstmt = conn.prepareStatement(query);
        ResultSet rs = pstmt.executeQuery();

        if (rs.next()) {
            lastCourseName = rs.getString("course_name");
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return lastCourseName;
}

public boolean updateExamResult(int examId, int obtMarks, int totalMarks) {
    String resultStatus = ((double) obtMarks / totalMarks) * 100 >= 45 ? "Pass" : "Fail";
    String sql = "UPDATE exams SET obt_marks = ?, result_status = ? WHERE exam_id = ?";
    try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
        pstmt.setInt(1, obtMarks);
        pstmt.setString(2, resultStatus);
        pstmt.setInt(3, examId);
        return pstmt.executeUpdate() > 0;
    } catch (SQLException e) {
        e.printStackTrace();
        return false;
    }
}

public void deleteExamCascade(int examId) {
    try {
        conn.setAutoCommit(false);

        String deleteAnswersSql = "DELETE FROM answers WHERE exam_id = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(deleteAnswersSql)) {
            pstmt.setInt(1, examId);
            pstmt.executeUpdate();
        }

        String deleteExamSql = "DELETE FROM exams WHERE exam_id = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(deleteExamSql)) {
            pstmt.setInt(1, examId);
            pstmt.executeUpdate();
        }

        conn.commit();
    } catch (SQLException ex) {
        try {
            conn.rollback();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
    } finally {
        try {
            conn.setAutoCommit(true);
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}

    // Method to close resources
    private void closeResources(Statement stmt, ResultSet rs) {
        try {
            if (rs != null) {
                rs.close();
            }
            if (stmt != null) {
                stmt.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Overloaded method to close PreparedStatement
    private void closeResources(PreparedStatement ps, ResultSet rs) {
        try {
            if (rs != null) {
                rs.close();
            }
            if (ps != null) {
                ps.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    // Method to close the connection (optional, if you want to close at the end)
    public void closeConnection() {
        try {
            if (conn != null) {
                conn.close();
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }
}