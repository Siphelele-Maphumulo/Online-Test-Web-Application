package myPackage;

import java.time.DayOfWeek;
import java.time.Duration;
import java.time.LocalDate;
import java.time.LocalTime;
import java.time.format.DateTimeFormatter;
import java.text.SimpleDateFormat;
import java.math.BigDecimal;
import java.util.logging.Level;
import java.util.logging.Logger;
import myPackage.classes.Answers;
import myPackage.classes.Exams;
import myPackage.classes.Questions;
import myPackage.classes.User;
import myPackage.classes.DragItem;
import myPackage.classes.DropTarget;
import myPackage.classes.DragDropAnswer;
import myPackage.classes.RearrangeItem;
import org.mindrot.jbcrypt.BCrypt;
import java.sql.Connection;
import java.sql.Date;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Time;
import java.util.ArrayList;
import java.sql.Types;
import java.util.Map;
import java.util.HashMap;
import java.util.HashSet;
import java.util.Set;
import java.util.HashMap;
import java.util.HashSet;
import myPackage.classes.Result;
import org.json.JSONObject;
import org.json.JSONArray;
import org.json.JSONException;

public class DatabaseClass {
    private static DatabaseClass instance; // Singleton instance
    private Connection conn;
    private static final Logger LOGGER = Logger.getLogger(DatabaseClass.class.getName()); 

    // PUBLIC NO-ARGUMENT CONSTRUCTOR REQUIRED FOR JSP BEAN
    public DatabaseClass() throws ClassNotFoundException, SQLException {
        establishConnection();
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
        
        // Test connection
        if (conn != null && !conn.isClosed()) {
            LOGGER.info("Database connection established successfully");
        }
    }

    public void updateDragDropQuestionColumns(int questionId,
            java.util.List<String> dragItems,
            java.util.List<String> dropTargets,
            java.util.List<String> correctTargets,
            Integer totalMarks) {

        Connection conn = null;
        PreparedStatement pstm = null;

        try {
            conn = getConnection();
            String sql = "UPDATE questions SET drag_items=?, drop_targets=?, drag_correct_targets=?, marks=? WHERE question_id=?";
            pstm = conn.prepareStatement(sql);
            pstm.setString(1, toJsonArray(dragItems));
            pstm.setString(2, toJsonArray(dropTargets));
            pstm.setString(3, toJsonArray(correctTargets));
            if (totalMarks != null) {
                // Default to number of targets if marks is 1 (default) and we have multiple targets
                // Following rubric: 1 mark per target matched unless stated
                if (totalMarks == 1 && dropTargets != null && dropTargets.size() > 1) {
                    totalMarks = dropTargets.size();
                }
                pstm.setBigDecimal(4, new BigDecimal(totalMarks));
            } else {
                // If not stated, default to number of targets
                int calculatedMarks = (dropTargets != null) ? dropTargets.size() : 1;
                pstm.setBigDecimal(4, new BigDecimal(calculatedMarks));
            }
            pstm.setInt(5, questionId);

            int updated = pstm.executeUpdate();
            LOGGER.log(Level.INFO, "Updated questions drag-drop columns for questionId={0}, rows={1}", new Object[]{questionId, updated});
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating questions drag-drop columns: " + e.getMessage(), e);
        } finally {
            try { if (pstm != null) pstm.close(); } catch (SQLException e) { LOGGER.log(Level.SEVERE, "Error closing statement", e); }
        }
    }

    public void updateDragDropQuestionJson(int questionId,
            String dragItemsJson,
            String dropTargetsJson,
            String correctTargetsJson,
            Integer totalMarks) {

        Connection conn = null;
        PreparedStatement pstm = null;

        try {
            conn = getConnection();
            String sql = "UPDATE questions SET drag_items=?, drop_targets=?, drag_correct_targets=?, marks=? WHERE question_id=?";
            pstm = conn.prepareStatement(sql);
            pstm.setString(1, dragItemsJson);
            pstm.setString(2, dropTargetsJson);
            pstm.setString(3, correctTargetsJson);
            if (totalMarks != null) {
                // Default to number of targets if marks is 1 (default) and we have multiple targets
                if (totalMarks == 1 && dropTargetsJson != null && dropTargetsJson.startsWith("[")) {
                    try {
                        org.json.JSONArray targetsArr = new org.json.JSONArray(dropTargetsJson);
                        if (targetsArr.length() > 1) {
                            totalMarks = targetsArr.length();
                        }
                    } catch (org.json.JSONException e) {
                        // Keep as 1 if JSON parsing fails
                    }
                }
                pstm.setBigDecimal(4, new BigDecimal(totalMarks));
            } else {
                // If not stated, try to determine from targets
                int calculatedMarks = 1;
                if (dropTargetsJson != null && dropTargetsJson.startsWith("[")) {
                    try {
                        org.json.JSONArray targetsArr = new org.json.JSONArray(dropTargetsJson);
                        calculatedMarks = Math.max(1, targetsArr.length());
                    } catch (org.json.JSONException e) {}
                }
                pstm.setBigDecimal(4, new BigDecimal(calculatedMarks));
            }
            pstm.setInt(5, questionId);

            int updated = pstm.executeUpdate();
            LOGGER.log(Level.INFO, "Updated questions drag-drop JSON for questionId={0}, rows={1}", new Object[]{questionId, updated});
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating questions drag-drop JSON: " + e.getMessage(), e);
        } finally {
            try { if (pstm != null) pstm.close(); } catch (SQLException e) { LOGGER.log(Level.SEVERE, "Error closing statement", e); }
        }
    }

    public String toJsonArray(java.util.List<String> values) {
        if (values == null) {
            return "[]";
        }
        StringBuilder sb = new StringBuilder();
        sb.append('[');
        for (int i = 0; i < values.size(); i++) {
            if (i > 0) sb.append(',');
            sb.append('"').append(escapeJson(values.get(i))).append('"');
        }
        sb.append(']');
        return sb.toString();
    }

    private String escapeJson(String s) {
        if (s == null) {
            return "";
        }
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\r", "\\r")
                .replace("\n", "\\n")
                .replace("\t", "\\t");
    }

// Get drag drop data from the questions table
public Map<String, String> getDragDropData(int questionId) {
    Map<String, String> data = new HashMap<>();
    
    try {
        ensureConnection();
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Connection error in getDragDropData", e);
        return data;
    }
    
    try {
        String sql = "SELECT drag_items, drop_targets, drag_correct_targets FROM questions WHERE question_id = ?";
        PreparedStatement pstm = conn.prepareStatement(sql);
        pstm.setInt(1, questionId);
        ResultSet rs = pstm.executeQuery();
        
        if (rs.next()) {
            data.put("drag_items", rs.getString("drag_items") != null ? rs.getString("drag_items") : "[]");
            data.put("drop_targets", rs.getString("drop_targets") != null ? rs.getString("drop_targets") : "[]");
            data.put("drag_correct_targets", rs.getString("drag_correct_targets") != null ? rs.getString("drag_correct_targets") : "[]");
        }
        
        rs.close();
        pstm.close();
        
    } catch (SQLException ex) {
        LOGGER.log(Level.SEVERE, "Error getting drag drop data: " + ex.getMessage(), ex);
    }
    
    return data;
}

    // Get the connection with lazy initialization
    public Connection getConnection() throws SQLException {
        try {
            if (conn == null || conn.isClosed()) {
                establishConnection();
            }
        } catch (ClassNotFoundException e) {
            throw new SQLException("JDBC Driver not found", e);
        }
        return conn;
    }
    
    // Ensure connection is valid before any database operation
    private void ensureConnection() throws SQLException {
        try {
            if (conn == null || conn.isClosed()) {
                establishConnection();
            }
        } catch (ClassNotFoundException e) {
            throw new SQLException("JDBC Driver not found", e);
        }
    }
    
    // Add this method to check if connection is valid
    public boolean isConnectionValid() {
        try {
            return conn != null && !conn.isClosed() && conn.isValid(2);
        } catch (SQLException e) {
            return false;
        }
    }

    String user_Type = "";
    
    public boolean checkLecturerByEmail(String email) {
        try {
            ensureConnection();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Connection error in checkLecturerByEmail", e);
            return false;
        }
        
                boolean exists = false;
        try {
            String sql = "SELECT * FROM staff WHERE email = ?";  // Assuming you have a column 'email' in 'staff' table
            PreparedStatement pstm = conn.prepareStatement(sql);
            pstm.setString(1, email);
            ResultSet rs = pstm.executeQuery();
            if (rs.next()) {
                exists = true;
                user_Type = "lecture";
            } else {
                user_Type = "student";
            }
            pstm.close();
        } catch (SQLException ex) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
        }
        return exists;
    }

    
    
// Fetch all students
public ArrayList<User> getAllStudents() {
    try {
        ensureConnection();
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Connection error in getAllStudents", e);
        return new ArrayList<>();
    }
    
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
        LOGGER.log(Level.SEVERE, "Error fetching students: " + ex.getMessage(), ex);
    } finally {
        try {
            if (rs != null) rs.close();
            if (pstm != null) pstm.close();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error closing resources: " + e.getMessage(), e);
        }
    }

    return list;
}



// Fetch all lecturers
public ArrayList<User> getAllLecturers() {
    try {
        ensureConnection();
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Connection error in getAllLecturers", e);
        return new ArrayList<>();
    }
    
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
        LOGGER.log(Level.SEVERE, "Error fetching lecturers: " + ex.getMessage(), ex);
    } finally {
        try {
            if (rs != null) rs.close();
            if (pstm != null) pstm.close();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error closing resources: " + e.getMessage(), e);
        }
    }

    return list;
}



    
     public String getUserType(String userId){
        try {
            ensureConnection();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Connection error in getUserType", e);
            return "error";
        }
        
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
            LOGGER.log(Level.SEVERE, ex.getMessage(), ex);
            str= "error";
        }
        return str;
    }
     
    public int getUserId(String userName){
        try {
            ensureConnection();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Connection error in getUserId", e);
            return 0;
        }
        
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
            LOGGER.log(Level.SEVERE, ex.getMessage(), ex);
            
        }
        return str;
    }

    public User getUserByUsername(String username) {
        try {
            ensureConnection();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Connection error in getUserByUsername", e);
            return null;
        }
        
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
        try {
            ensureConnection();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Connection error in getUserByEmail", e);
            return null;
        }
        
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
        try {
            ensureConnection();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Connection error in getUserDetails", e);
            return null;
        }
        
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
    try {
        ensureConnection();
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Connection error in addNewStaff", e);
        return;
    }
    
    // Check if email already exists in staff table
    String checkSql = "SELECT COUNT(*) as count FROM staff WHERE email = ?";
    try (PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
        checkStmt.setString(1, email);
        try (ResultSet rs = checkStmt.executeQuery()) {
            if (rs.next() && rs.getInt("count") > 0) {
                LOGGER.warning("Staff email already exists: " + email);
                // Email already exists, you might want to throw an exception or return false
                return;
            }
        }
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Error checking existing staff email", e);
        return;
    }
    
    // Check if staff number already exists
    checkSql = "SELECT COUNT(*) as count FROM staff WHERE staffNum = ?";
    try (PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
        checkStmt.setString(1, staffNum);
        try (ResultSet rs = checkStmt.executeQuery()) {
            if (rs.next() && rs.getInt("count") > 0) {
                LOGGER.warning("Staff number already exists: " + staffNum);
                return;
            }
        }
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Error checking existing staff number", e);
        return;
    }
    
    String sql = "INSERT INTO staff (staffNum, email, fullNames, course_name) VALUES (?, ?, ?, ?)";
    try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
        pstmt.setString(1, staffNum);
        pstmt.setString(2, email);
        pstmt.setString(3, fullNames);
        pstmt.setString(4, course_name);
        pstmt.executeUpdate();
        LOGGER.info("Staff added successfully: " + email + " - " + fullNames);
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Error adding new staff", e);
        e.printStackTrace();
    }
}

// Helper method to check if email exists in staff table (for frontend validation)
public boolean isEmailInStaffTable(String email) {
    try {
        ensureConnection();
        String sql = "SELECT COUNT(*) as count FROM staff WHERE email = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, email);
            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next() && rs.getInt("count") > 0;
            }
        }
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Error checking staff email", e);
        return false;
    }
}

// Helper method to check if email exists in users table
public boolean isEmailRegistered(String email) {
    try {
        ensureConnection();
        String sql = "SELECT COUNT(*) as count FROM users WHERE email = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, email);
            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next() && rs.getInt("count") > 0;
            }
        }
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Error checking registered email", e);
        return false;
    }
}

// Helper method to check if username exists
public boolean isUsernameTaken(String username) {
    try {
        ensureConnection();
        String sql = "SELECT COUNT(*) as count FROM users WHERE user_name = ?";
        try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, username);
            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next() && rs.getInt("count") > 0;
            }
        }
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Error checking username", e);
        return false;
    }
}


    public boolean loginValidate(String userName, String userPass) throws SQLException {
        try {
            ensureConnection();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Connection error in loginValidate", e);
            return false;
        }
        
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
        try {
            ensureConnection();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Connection error in updateUser", e);
            return false;
        }
        
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

    public int getExamId(String courseName) {
        try {
            ensureConnection();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Connection error in getExamId", e);
            return 0;
        }
        
        PreparedStatement ps = null;
        ResultSet rs = null;
        int examId = 0;

        try {
            String sql = "SELECT exam_id FROM exams WHERE cname = ? AND status = 'Active' ORDER BY exam_id DESC LIMIT 1";
            ps = conn.prepareStatement(sql);
            ps.setString(1, courseName);
            rs = ps.executeQuery();

            if (rs.next()) {
                examId = rs.getInt("exam_id");
            }

        } catch (SQLException ex) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, "getExamId failed for course: " + courseName, ex);
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
            } catch (SQLException ex) {
                Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, "Failed to close resources in getExamId", ex);
            }
        }

        return examId;
    }

    // In DatabaseClass.java
    public ArrayList<String> getActiveCourseNames() {
        try {
            ensureConnection();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Connection error in getActiveCourseNames", e);
            return new ArrayList<>();
        }
        
        ArrayList<String> courseNames = new ArrayList<>();
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            String sql = "SELECT DISTINCT course_name FROM courses WHERE is_active = 1 ORDER BY course_name";
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();

            while(rs.next()){
                courseNames.add(rs.getString("course_name"));
            }
        } catch (SQLException ex) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, "getActiveCourseNames failed", ex);
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
            } catch (SQLException ex) {
                Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, "Failed to close resources in getActiveCourseNames", ex);
            }
        }

        return courseNames;
    }

public boolean isCourseActive(String courseName) {
    try {
        ensureConnection();
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Connection error in isCourseActive", e);
        return false;
    }
    
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        // SIMPLIFIED: Just check is_active column in courses table
        String sql = "SELECT is_active FROM courses WHERE course_name = ?";
        ps = conn.prepareStatement(sql);
        ps.setString(1, courseName);
        rs = ps.executeQuery();

        if (rs.next()) {
            int isActive = rs.getInt("is_active");
            return isActive == 1;
        }
        
        return false; // Course not found

    } catch (SQLException ex) {
        Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, "isCourseActive failed for course: " + courseName, ex);
        return false;
    } finally {
        try {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
        } catch (SQLException ex) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, "Failed to close resources in isCourseActive", ex);
        }
    }
}
    
public int updateStudent(int uId, String fName, String lName, String uName, String email, String pass,
        String contact, String city, String address, String userType) {
    try {
        ensureConnection();
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Connection error in updateStudent", e);
        return 0;
    }
    
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
    try {
        ensureConnection();
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Connection error in updateLecturer", e);
        return 0;
    }
    
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


public boolean updateCourse(String originalCourseName, String courseName, int tMarks, String time, String examDate) {
    try {
        ensureConnection();
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Connection error in updateCourse", e);
        return false;
    }
    
    PreparedStatement pstm = null;
    PreparedStatement pstmQuestions = null;
    PreparedStatement pstmExams = null;
    
    try {
        conn.setAutoCommit(false);
        
        // 1. Update the course in courses table
        String sqlCourse = "UPDATE courses SET course_name=?, total_marks=?, time=?, exam_date=? WHERE course_name=?";
        pstm = conn.prepareStatement(sqlCourse);
        pstm.setString(1, courseName);
        pstm.setInt(2, tMarks);
        pstm.setString(3, time);
        pstm.setString(4, examDate);
        pstm.setString(5, originalCourseName);
        
        int rowsAffected = pstm.executeUpdate();
        
        // 2. Update course_name in questions table if it changed
        if (!originalCourseName.equals(courseName)) {
            String sqlQuestions = "UPDATE questions SET course_name=? WHERE course_name=?";
            pstmQuestions = conn.prepareStatement(sqlQuestions);
            pstmQuestions.setString(1, courseName);
            pstmQuestions.setString(2, originalCourseName);
            pstmQuestions.executeUpdate();
        }
        
        // 3. Update course_name in exams table if it changed
        if (!originalCourseName.equals(courseName)) {
            String sqlExams = "UPDATE exams SET course_name=? WHERE course_name=?";
            pstmExams = conn.prepareStatement(sqlExams);
            pstmExams.setString(1, courseName);
            pstmExams.setString(2, originalCourseName);
            pstmExams.executeUpdate();
        }
        
        conn.commit();
        return rowsAffected > 0;
        
    } catch (SQLException ex) {
        try {
            if (conn != null) conn.rollback();
        } catch (SQLException rollbackEx) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, "Rollback failed", rollbackEx);
        }
        Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
        return false;
    } finally {
        try {
            if (pstm != null) pstm.close();
            if (pstmQuestions != null) pstmQuestions.close();
            if (pstmExams != null) pstmExams.close();
            conn.setAutoCommit(true);
        } catch (SQLException e) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, e);
        }
    }
}

public ArrayList<String> getAllCourseNames() {
    try {
        ensureConnection();
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Connection error in getAllCourseNames", e);
        return new ArrayList<>();
    }
    
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
    try {
        ensureConnection();
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Connection error in getAllCourses", e);
        return new ArrayList();
    }
    
    ArrayList list = new ArrayList();
    try {
        String sql = "SELECT course_name, total_marks, time, exam_date, is_active FROM courses";
        PreparedStatement pstm = conn.prepareStatement(sql);
        ResultSet rs = pstm.executeQuery();

        while (rs.next()) {
            list.add(rs.getString("course_name")); 
            list.add(rs.getInt("total_marks"));    
            list.add(rs.getString("time"));        
            list.add(rs.getDate("exam_date"));     
            list.add(rs.getBoolean("is_active"));   
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
        ensureConnection();
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Connection error in addNewCourse", e);
        return false;
    }
    
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
            ensureConnection();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Connection error in delCourse", e);
            return;
        }
        
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
    addNewQuestionReturnId(questionText, opt1, opt2, opt3, opt4, correctAnswer, courseName, questionType, null);
}

public void addNewQuestion(String questionText, String opt1, String opt2, String opt3, String opt4, String correctAnswer, String courseName, String questionType, String imagePath) {
    addNewQuestionReturnId(questionText, opt1, opt2, opt3, opt4, correctAnswer, courseName, questionType, imagePath);
}

public int addNewQuestionReturnId(String questionText, String opt1, String opt2, String opt3, String opt4, String correctAnswer, String courseName, String questionType, String imagePath) {
    return addNewQuestionReturnId(questionText, opt1, opt2, opt3, opt4, correctAnswer, courseName, questionType, imagePath, null);
}

public int addNewQuestionReturnId(String questionText, String opt1, String opt2, String opt3, String opt4, String correctAnswer, String courseName, String questionType, String imagePath, String extraData) {
    try {
        ensureConnection();
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Connection error in addNewQuestionReturnId", e);
        return -1;
    }
     
    PreparedStatement pstm = null;
    ResultSet rsKeys = null;
    try {
        String sql;
        int marks = 1; // Default marks

        // Set marks based on question type rubric
        if ("MultipleSelect".equalsIgnoreCase(questionType)) {
            marks = 2; // 2 marks for MultipleSelect (1 mark per correct selection)
        } else if ("TrueFalse".equalsIgnoreCase(questionType)) {
            marks = 1; // 1 mark for True/False
        } else if ("MCQ".equalsIgnoreCase(questionType)) {
            marks = 1; // 1 mark for MCQ
        } else if ("FillInTheBlank".equalsIgnoreCase(questionType) || "FillInTheWord".equalsIgnoreCase(questionType)) {
            marks = 1; // 1 mark for Fill in the missing word
        } else {
            marks = 1; // Default 1 mark for other types
        }

        // Handle different question types
        if ("DRAG_AND_DROP".equalsIgnoreCase(questionType) || "REARRANGE".equalsIgnoreCase(questionType) || "RE_ARRANGE".equalsIgnoreCase(questionType)) {
            // For drag-and-drop or rearrange questions, insert empty strings for opt fields since they're required
            sql = "INSERT INTO questions (question, opt1, opt2, opt3, opt4, correct, course_name, question_type, image_path, marks, extra_data) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            pstm = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            pstm.setString(1, questionText);
            pstm.setString(2, ""); // opt1 - empty
            pstm.setString(3, ""); // opt2 - empty
            pstm.setString(4, ""); // opt3 - empty
            pstm.setString(5, ""); // opt4 - empty
            pstm.setString(6, ""); // correct - empty
            pstm.setString(7, courseName);
            pstm.setString(8, questionType);
            pstm.setString(9, imagePath);
            pstm.setInt(10, marks);
            pstm.setString(11, extraData);
        } else if ("TrueFalse".equalsIgnoreCase(questionType)) {
            sql = "INSERT INTO questions (question, opt1, opt2, correct, course_name, question_type, image_path, marks, extra_data) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
            pstm = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            pstm.setString(1, questionText);
            pstm.setString(2, "True");  // Hardcoded options for True/False
            pstm.setString(3, "False");
            pstm.setString(4, correctAnswer);
            pstm.setString(5, courseName);
            pstm.setString(6, questionType);
            pstm.setString(7, imagePath);
            pstm.setInt(8, marks);
            pstm.setString(9, extraData);
        } else {
            // Otherwise, handle multiple-choice questions
            sql = "INSERT INTO questions (question, opt1, opt2, opt3, opt4, correct, course_name, question_type, image_path, marks, extra_data) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            pstm = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            pstm.setString(1, questionText);
            pstm.setString(2, opt1);
            pstm.setString(3, opt2);
            pstm.setString(4, opt3);
            pstm.setString(5, opt4);
            pstm.setString(6, correctAnswer);
            pstm.setString(7, courseName);
            pstm.setString(8, questionType);
            pstm.setString(9, imagePath);
            pstm.setInt(10, marks);
            pstm.setString(11, extraData);
        }

        // Execute the update
        pstm.executeUpdate();
        rsKeys = pstm.getGeneratedKeys();
        if (rsKeys != null && rsKeys.next()) {
            return rsKeys.getInt(1);
        }
        return -1;
    } catch (SQLException ex) {
        LOGGER.log(Level.SEVERE, "Error inserting question: " + ex.getMessage(), ex);
        return -1;
    } finally {
        try { if (rsKeys != null) rsKeys.close(); } catch (SQLException e) { LOGGER.log(Level.SEVERE, "Error closing generated keys", e); }
        try { if (pstm != null) pstm.close(); } catch (SQLException e) { LOGGER.log(Level.SEVERE, "Error closing statement", e); }
    }
}  
    
    // Method to properly insert drag-and-drop data using relational tables
    public void addDragDropData(int questionId, java.util.List<String> dragItems, 
                                java.util.List<String> dropTargets, java.util.List<String> correctTargets) {
        LOGGER.log(Level.INFO, "addDragDropData called for question ID: {0}", questionId);
        
        Connection conn = null;
        PreparedStatement pstmDrag = null;
        PreparedStatement pstmTarget = null;
        
        try {
            conn = getConnection();
            
            // First, insert drop targets and get their IDs
            java.util.Map<String, Integer> targetLabelToId = new java.util.HashMap<>();
            String sqlTarget = "INSERT INTO drop_targets (question_id, target_label, target_order) VALUES (?, ?, ?)";
            pstmTarget = conn.prepareStatement(sqlTarget, Statement.RETURN_GENERATED_KEYS);
            
            for (int i = 0; i < dropTargets.size(); i++) {
                pstmTarget.setInt(1, questionId);
                String targetLabel = dropTargets.get(i) != null ? dropTargets.get(i).trim() : "";
                pstmTarget.setString(2, targetLabel);
                pstmTarget.setInt(3, i + 1);
                int rowsAffected = pstmTarget.executeUpdate();
                LOGGER.log(Level.INFO, "Drop target insert rows affected: {0}", rowsAffected);
                
                ResultSet rs = pstmTarget.getGeneratedKeys();
                if (rs.next()) {
                    int targetId = rs.getInt(1);
                    targetLabelToId.put(targetLabel, targetId);
                    LOGGER.log(Level.INFO, "Generated target ID: {0} for label: {1}", new Object[]{targetId, targetLabel});
                }
                rs.close();
            }
            
            // Then insert drag items with correct target mappings
            String sqlDrag = "INSERT INTO drag_items (question_id, item_text, correct_target_id, item_order) VALUES (?, ?, ?, ?)";
            pstmDrag = conn.prepareStatement(sqlDrag);
            
            for (int i = 0; i < dragItems.size(); i++) {
                pstmDrag.setInt(1, questionId);
                pstmDrag.setString(2, dragItems.get(i));
                
                // Map the correct target if available
                if (i < correctTargets.size() && correctTargets.get(i) != null && !correctTargets.get(i).trim().isEmpty()) {
                    String correctTargetLabel = correctTargets.get(i).trim();
                    Integer correctTargetId = targetLabelToId.get(correctTargetLabel);
                    if (correctTargetId != null) {
                        pstmDrag.setInt(3, correctTargetId);
                        LOGGER.log(Level.INFO, "Mapping drag item ''{0}'' to target label ''{1}'' (ID: {2})", new Object[]{dragItems.get(i), correctTargetLabel, correctTargetId});
                    } else {
                        pstmDrag.setNull(3, Types.INTEGER);
                    }
                } else {
                    pstmDrag.setNull(3, Types.INTEGER);
                }
                
                pstmDrag.setInt(4, i + 1);
                int rowsAffected = pstmDrag.executeUpdate();
                LOGGER.log(Level.INFO, "Drag item insert rows affected: {0}", rowsAffected);
            }
            
            LOGGER.log(Level.INFO, "Drag-drop data saved successfully for question ID: {0}", questionId);
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error inserting drag-drop data: " + e.getMessage(), e);
            throw new RuntimeException("Failed to save drag-drop data: " + e.getMessage(), e);
        } finally {
            try {
                if (pstmDrag != null) pstmDrag.close();
                if (pstmTarget != null) pstmTarget.close();
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "Error closing resources", e);
            }
        }
    }

    public void clearDragDropQuestionData(int questionId) {
        Connection conn = null;
        PreparedStatement pstm = null;
        try {
            conn = getConnection();

            // drag_items references drop_targets via correct_target_id, so delete drag_items first.
            pstm = conn.prepareStatement("DELETE FROM drag_items WHERE question_id = ?");
            pstm.setInt(1, questionId);
            int deletedDragItems = pstm.executeUpdate();
            LOGGER.log(Level.INFO, "Cleared drag_items for questionId={0}, rows={1}", new Object[]{questionId, deletedDragItems});
            pstm.close();
            pstm = null;

            pstm = conn.prepareStatement("DELETE FROM drop_targets WHERE question_id = ?");
            pstm.setInt(1, questionId);
            int deletedTargets = pstm.executeUpdate();
            LOGGER.log(Level.INFO, "Cleared drop_targets for questionId={0}, rows={1}", new Object[]{questionId, deletedTargets});
            pstm.close();
            pstm = null;

            pstm = conn.prepareStatement("DELETE FROM rearrange_items WHERE question_id = ?");
            pstm.setInt(1, questionId);
            int deletedRearrange = pstm.executeUpdate();
            LOGGER.log(Level.INFO, "Cleared rearrange_items for questionId={0}, rows={1}", new Object[]{questionId, deletedRearrange});
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error clearing drag-drop data for questionId=" + questionId + ": " + e.getMessage(), e);
        } finally {
            try { if (pstm != null) pstm.close(); } catch (SQLException e) { LOGGER.log(Level.SEVERE, "Error closing statement", e); }
        }
    }

// Get drag items for a question
public java.util.List<java.util.Map<String, Object>> getDragItemsByQuestionId(int questionId) {
    java.util.List<java.util.Map<String, Object>> dragItems = new java.util.ArrayList<>();
    Connection conn = null;
    PreparedStatement pstm = null;
    ResultSet rs = null;
    
    try {
        conn = getConnection();
        String sql = "SELECT id, item_text, correct_target_id, item_order FROM drag_items WHERE question_id = ? ORDER BY item_order";
        pstm = conn.prepareStatement(sql);
        pstm.setInt(1, questionId);
        rs = pstm.executeQuery();
        
        while (rs.next()) {
            java.util.Map<String, Object> item = new java.util.HashMap<>();
            item.put("id", rs.getInt("id"));
            item.put("text", rs.getString("item_text"));
            item.put("correct_target_id", rs.getObject("correct_target_id"));
            item.put("order", rs.getInt("item_order"));
            dragItems.add(item);
        }
        
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Error getting drag items", e);
    } finally {
        try {
            if (rs != null) rs.close();
            if (pstm != null) pstm.close();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error closing resources", e);
        }
    }
    
    return dragItems;
}

// Get drop targets for a question
public java.util.List<java.util.Map<String, Object>> getDropTargetsByQuestionId(int questionId) {
    java.util.List<java.util.Map<String, Object>> dropTargets = new java.util.ArrayList<>();
    Connection conn = null;
    PreparedStatement pstm = null;
    ResultSet rs = null;
    
    try {
        conn = getConnection();
        String sql = "SELECT id, target_label, target_order FROM drop_targets WHERE question_id = ? ORDER BY target_order";
        pstm = conn.prepareStatement(sql);
        pstm.setInt(1, questionId);
        rs = pstm.executeQuery();
        
        while (rs.next()) {
            java.util.Map<String, Object> target = new java.util.HashMap<>();
            target.put("id", rs.getInt("id"));
            target.put("label", rs.getString("target_label"));
            target.put("order", rs.getInt("target_order"));
            dropTargets.add(target);
        }
        
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Error getting drop targets", e);
    } finally {
        try {
            if (rs != null) rs.close();
            if (pstm != null) pstm.close();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error closing resources", e);
        }
    }
    
    return dropTargets;
}

// Wrapper method to convert Map list to DragItem list (for backward compatibility)
public ArrayList<DragItem> getDragItemsByQuestionIdOld(int questionId) {
    ArrayList<DragItem> dragItems = new ArrayList<>();
    java.util.List<java.util.Map<String, Object>> mapList = getDragItemsByQuestionId(questionId);
    
    for (java.util.Map<String, Object> map : mapList) {
        DragItem item = new DragItem();
        item.setId((Integer) map.get("id"));
        item.setItemText((String) map.get("text"));
        item.setCorrectTargetId((Integer) map.get("correct_target_id"));
        item.setItemOrder((Integer) map.get("order"));
        dragItems.add(item);
    }
    
    return dragItems;
}

// Wrapper method to convert Map list to DropTarget list (for backward compatibility)
public ArrayList<DropTarget> getDropTargetsByQuestionIdOld(int questionId) {
    ArrayList<DropTarget> dropTargets = new ArrayList<>();
    java.util.List<java.util.Map<String, Object>> mapList = getDropTargetsByQuestionId(questionId);
    
    for (java.util.Map<String, Object> map : mapList) {
        DropTarget target = new DropTarget();
        target.setId((Integer) map.get("id"));
        target.setTargetLabel((String) map.get("label"));
        target.setTargetOrder((Integer) map.get("order"));
        dropTargets.add(target);
    }
    
    return dropTargets;
}

// Check if a question exists in the questions table
public boolean questionExists(int questionId) {
    try {
        ensureConnection();
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Connection error in questionExists", e);
        return false;
    }
    
    try {
        String sql = "SELECT COUNT(*) FROM questions WHERE question_id = ?";
        PreparedStatement pstm = conn.prepareStatement(sql);
        pstm.setInt(1, questionId);
        ResultSet rs = pstm.executeQuery();
        
        boolean exists = false;
        if (rs.next()) {
            exists = rs.getInt(1) > 0;
        }
        
        rs.close();
        pstm.close();
        return exists;
        
    } catch (SQLException ex) {
        LOGGER.log(Level.SEVERE, "Error checking if question exists: " + ex.getMessage(), ex);
        Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
        return false;
    }
}

// Get the last inserted question ID
public int getLastInsertedQuestionId() {
    Connection conn = null;
    Statement stmt = null;
    ResultSet rs = null;
    
    try {
        conn = getConnection();
        stmt = conn.createStatement();
        rs = stmt.executeQuery("SELECT LAST_INSERT_ID()");
        
        if (rs.next()) {
            int lastId = rs.getInt(1);
            LOGGER.log(Level.INFO, "Last inserted question ID: {0}", lastId);
            return lastId;
        }
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Error getting last inserted question ID: " + e.getMessage(), e);
    } finally {
        try {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error closing resources", e);
        }
    }
    
    return -1;
}


    
public Questions getQuestionById(int questionId) {
    try {
        ensureConnection();
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Connection error in getQuestionById", e);
        return null;
    }
    
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
            question.setCourseName(rs.getString("course_name"));
            question.setQuestionType(rs.getString("question_type"));
            question.setImagePath(rs.getString("image_path"));
            
            // Populate advanced fields
            try {
                question.setExtraData(rs.getString("extra_data"));
                question.setDragItemsJson(rs.getString("drag_items"));
                question.setDropTargetsJson(rs.getString("drop_targets"));
                question.setCorrectTargetsJson(rs.getString("drag_correct_targets"));
                question.setTotalMarks(rs.getInt("marks"));
                
                if (("DRAG_AND_DROP".equalsIgnoreCase(question.getQuestionType()) || "RE_ARRANGE".equalsIgnoreCase(question.getQuestionType()))) {
                    question.setDragItems(getDragItemsByQuestionIdOld(question.getQuestionId()));
                    question.setDropTargets(getDropTargetsByQuestionIdOld(question.getQuestionId()));
                } else if ("REARRANGE".equalsIgnoreCase(question.getQuestionType())) {
                    question.setRearrangeItems(getRearrangeItems(question.getQuestionId()));
                    // Fallback JSON for UI
                    question.setRearrangeItemsJson(question.getDragItemsJson());
                }
            } catch (SQLException sqle) {
                // Columns might not exist yet
            }
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
    try {
        ensureConnection();
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Connection error in updateQuestion", e);
        return false;
    }
    
    String sql = "UPDATE questions SET question=?, opt1=?, opt2=?, opt3=?, opt4=?, correct=?, course_name=?, question_type=?, image_path=?, extra_data=? WHERE question_id=?";
    try (PreparedStatement pstm = conn.prepareStatement(sql)) {
        pstm.setString(1, question.getQuestion());
        pstm.setString(2, question.getOpt1());
        pstm.setString(3, question.getOpt2());
        pstm.setString(4, question.getOpt3());
        pstm.setString(5, question.getOpt4());
        pstm.setString(6, question.getCorrect());
        pstm.setString(7, question.getCourseName());
        pstm.setString(8, question.getQuestionType());
        pstm.setString(9, question.getImagePath());
        pstm.setString(10, question.getExtraData());
        pstm.setInt(11, question.getQuestionId());

        int rowsAffected = pstm.executeUpdate();
        return rowsAffected > 0;
    } catch (SQLException e) {
        e.printStackTrace();
        return false;
    }
}

 
    
public void delQuestion(int qId) {
    try {
        ensureConnection();
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Connection error in delQuestion", e);
        return;
    }
    
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

/**
 * Force delete a question by ID, ensuring all related data is removed
 */
public boolean forceDeleteQuestion(int questionId) {
    Connection conn = null;
    PreparedStatement pstmt = null;
    boolean success = false;
    
    try {
        conn = getConnection();
        conn.setAutoCommit(false);
        
        // 1. Delete from drag_drop_answers first (if table exists)
        try {
            String sql1 = "DELETE FROM drag_drop_answers WHERE question_id = ?";
            pstmt = conn.prepareStatement(sql1);
            pstmt.setInt(1, questionId);
            pstmt.executeUpdate();
            pstmt.close();
        } catch (SQLException e) {
            // Table might not exist, continue
        }
        
        // 2. Delete from drag_items
        try {
            String sql2 = "DELETE FROM drag_items WHERE question_id = ?";
            pstmt = conn.prepareStatement(sql2);
            pstmt.setInt(1, questionId);
            pstmt.executeUpdate();
            pstmt.close();
        } catch (SQLException e) {
            LOGGER.warning("Error deleting drag_items: " + e.getMessage());
        }
        
        // 3. Delete from drop_targets
        try {
            String sql3 = "DELETE FROM drop_targets WHERE question_id = ?";
            pstmt = conn.prepareStatement(sql3);
            pstmt.setInt(1, questionId);
            pstmt.executeUpdate();
            pstmt.close();
        } catch (SQLException e) {
            LOGGER.warning("Error deleting drop_targets: " + e.getMessage());
        }
        
        // 4. Delete from answers (by question text)
        String getQuestionSql = "SELECT question FROM questions WHERE question_id = ?";
        pstmt = conn.prepareStatement(getQuestionSql);
        pstmt.setInt(1, questionId);
        ResultSet rs = pstmt.executeQuery();
        
        if (rs.next()) {
            String questionText = rs.getString("question");
            rs.close();
            pstmt.close();
            
            if (questionText != null) {
                String deleteAnswersSql = "DELETE FROM answers WHERE question = ?";
                pstmt = conn.prepareStatement(deleteAnswersSql);
                pstmt.setString(1, questionText);
                pstmt.executeUpdate();
                pstmt.close();
            }
        }
        
        // 5. Finally delete the question itself
        String deleteQuestionSql = "DELETE FROM questions WHERE question_id = ?";
        pstmt = conn.prepareStatement(deleteQuestionSql);
        pstmt.setInt(1, questionId);
        int rowsAffected = pstmt.executeUpdate();
        
        success = rowsAffected > 0;
        conn.commit();
        
        LOGGER.info("Force delete question " + questionId + ": " + success);
        
    } catch (SQLException e) {
        try {
            if (conn != null) conn.rollback();
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Rollback failed", ex);
        }
        LOGGER.log(Level.SEVERE, "Error force deleting question", e);
    } finally {
        try {
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.setAutoCommit(true);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error closing resources", e);
        }
    }
    
    return success;
}

public boolean deleteQuestion(int questionId) {
    LOGGER.info("deleteQuestion called with ID: " + questionId);
    
    boolean autoCommit = true;
    try {
        ensureConnection();
        autoCommit = conn.getAutoCommit();
        conn.setAutoCommit(false);
        LOGGER.info("Database connection established, auto-commit disabled");
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Connection error in deleteQuestion", e);
        return false;
    }
    
    PreparedStatement pstmt = null;
    PreparedStatement pstmtAnswers = null;
    PreparedStatement pstmtDragItems = null;
    PreparedStatement pstmtDropTargets = null;
    
    try {
        // STEP 1: Get the question text
        String getQuestionSql = "SELECT question FROM questions WHERE question_id = ?";
        pstmt = conn.prepareStatement(getQuestionSql);
        pstmt.setInt(1, questionId);
        ResultSet rs = pstmt.executeQuery();
        
        String questionText = null;
        if (rs.next()) {
            questionText = rs.getString("question");
        }
        rs.close();
        pstmt.close();
        
        // STEP 2: Delete from answers table (by question text)
        if (questionText != null) {
            String deleteAnswersSql = "DELETE FROM answers WHERE question = ?";
            pstmtAnswers = conn.prepareStatement(deleteAnswersSql);
            pstmtAnswers.setString(1, questionText);
            int answersDeleted = pstmtAnswers.executeUpdate();
            pstmtAnswers.close();
            
            if (answersDeleted > 0) {
                LOGGER.info("Deleted " + answersDeleted + " answer record(s) related to question ID: " + questionId);
            }
        }
        
        // STEP 3: Delete from drag_drop_answers (if table exists)
        try {
            String deleteDragDropAnswersSql = "DELETE FROM drag_drop_answers WHERE question_id = ?";
            pstmtDragItems = conn.prepareStatement(deleteDragDropAnswersSql);
            pstmtDragItems.setInt(1, questionId);
            pstmtDragItems.executeUpdate();
            pstmtDragItems.close();
        } catch (SQLException e) {
            // Table might not exist, ignore
        }
        
        // STEP 4: Delete from drag_items
        try {
            String deleteDragItemsSql = "DELETE FROM drag_items WHERE question_id = ?";
            pstmtDragItems = conn.prepareStatement(deleteDragItemsSql);
            pstmtDragItems.setInt(1, questionId);
            pstmtDragItems.executeUpdate();
            pstmtDragItems.close();
        } catch (SQLException e) {
            LOGGER.warning("Error deleting drag_items: " + e.getMessage());
        }
        
        // STEP 5: Delete from drop_targets
        try {
            String deleteDropTargetsSql = "DELETE FROM drop_targets WHERE question_id = ?";
            pstmtDropTargets = conn.prepareStatement(deleteDropTargetsSql);
            pstmtDropTargets.setInt(1, questionId);
            pstmtDropTargets.executeUpdate();
            pstmtDropTargets.close();
        } catch (SQLException e) {
            LOGGER.warning("Error deleting drop_targets: " + e.getMessage());
        }
        
        // STEP 6: Delete the question itself
        String deleteQuestionSql = "DELETE FROM questions WHERE question_id = ?";
        pstmt = conn.prepareStatement(deleteQuestionSql);
        pstmt.setInt(1, questionId);
        
        int rowsAffected = pstmt.executeUpdate();
        LOGGER.info("Deleted " + rowsAffected + " question record(s) with ID: " + questionId);
        
        // Commit the transaction
        conn.commit();
        LOGGER.info("Transaction committed successfully");
        
        return rowsAffected > 0;
        
    } catch (SQLException ex) {
        LOGGER.log(Level.SEVERE, "SQLException in deleteQuestion: " + ex.getMessage(), ex);
        try {
            conn.rollback();
            LOGGER.log(Level.SEVERE, "Transaction rolled back due to error deleting question ID: " + questionId, ex);
        } catch (SQLException rollbackEx) {
            LOGGER.log(Level.SEVERE, "Rollback failed", rollbackEx);
        }
        return false;
    } finally {
        try {
            if (pstmt != null) pstmt.close();
            if (pstmtAnswers != null) pstmtAnswers.close();
            if (pstmtDragItems != null) pstmtDragItems.close();
            if (pstmtDropTargets != null) pstmtDropTargets.close();
            conn.setAutoCommit(autoCommit);
            LOGGER.info("Connection auto-commit restored to: " + autoCommit);
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error closing resources", ex);
        }
    }
}


public void deleteUserCascade(int userId) {
    try {
        ensureConnection();
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Connection error in deleteUserCascade", e);
        return;
    }
    
    PreparedStatement pstmt = null;
    ResultSet rs = null;
    
    try {
        conn.setAutoCommit(false);

        String userType = getUserType(String.valueOf(userId));
        LOGGER.log(Level.INFO, "Deleting user ID: {0}, Type: {1}", new Object[]{userId, userType});

        if ("student".equalsIgnoreCase(userType)) {
            // Step 1: Get all exam_ids for the student
            ArrayList<Integer> examIds = new ArrayList<>();
            String selectExamsSql = "SELECT exam_id FROM exams WHERE std_id = ?";
            try (PreparedStatement pstmtExams = conn.prepareStatement(selectExamsSql)) {
                pstmtExams.setInt(1, userId);
                try (ResultSet rsExams = pstmtExams.executeQuery()) {
                    while (rsExams.next()) {
                        examIds.add(rsExams.getInt("exam_id"));
                    }
                }
            }

            // Step 2: Delete from answers table for each exam_id
            if (!examIds.isEmpty()) {
                String deleteAnswersSql = "DELETE FROM answers WHERE exam_id = ?";
                try (PreparedStatement pstmtAnswers = conn.prepareStatement(deleteAnswersSql)) {
                    for (int examId : examIds) {
                        pstmtAnswers.setInt(1, examId);
                        pstmtAnswers.executeUpdate();
                    }
                }
            }

            // Step 3: Delete from exams table
            String deleteExamsSql = "DELETE FROM exams WHERE std_id = ?";
            try (PreparedStatement pstmtExams = conn.prepareStatement(deleteExamsSql)) {
                pstmtExams.setInt(1, userId);
                pstmtExams.executeUpdate();
            }

            // Step 4: Delete from students table
            delStudent(userId);

        } else if ("lecture".equalsIgnoreCase(userType)) {
            // For a lecturer, we need to handle their course associations
            
            // Step 1: Get the lecturer's course information for logging
            String getLecturerInfoSql = "SELECT course_name FROM lectures WHERE user_id = ?";
            try (PreparedStatement pstmtInfo = conn.prepareStatement(getLecturerInfoSql)) {
                pstmtInfo.setInt(1, userId);
                try (ResultSet rsInfo = pstmtInfo.executeQuery()) {
                    if (rsInfo.next()) {
                        String courseName = rsInfo.getString("course_name");
                        LOGGER.log(Level.INFO, "Deleting lecturer for course: {0}", courseName);
                    }
                }
            }

            // Step 2: Check if this lecturer is the only one assigned to their course(s)
            String checkCourseAssignmentsSql = 
                "SELECT course_name FROM lectures WHERE user_id != ? AND course_name IN " +
                "(SELECT course_name FROM lectures WHERE user_id = ?)";
            boolean hasMultipleLecturers = false;
            try (PreparedStatement pstmtCheck = conn.prepareStatement(checkCourseAssignmentsSql)) {
                pstmtCheck.setInt(1, userId);
                pstmtCheck.setInt(2, userId);
                try (ResultSet rsCheck = pstmtCheck.executeQuery()) {
                    if (rsCheck.next()) {
                        hasMultipleLecturers = true;
                        LOGGER.log(Level.INFO, "Other lecturers teach the same course(s)");
                    }
                }
            }

            // Step 3: Delete from lectures table
            delLecture(userId);

            // Step 4: Optionally remove course assignments if no other lecturers
            if (!hasMultipleLecturers) {
                LOGGER.log(Level.INFO, "No other lecturers for this course - course remains active");
            }

        } else if ("admin".equalsIgnoreCase(userType)) {
            // For admin users, we might want to prevent deletion or handle differently
            LOGGER.log(Level.WARNING, "Warning: Attempting to delete admin user ID: {0}", userId);
            // Option: throw an exception or log a warning
            // throw new SQLException("Cannot delete admin users");
        }

        // Step 5: Finally, delete from the main users table for all user types
        int deletedFromUsers = deleteUser(userId);
        LOGGER.log(Level.INFO, "Deleted {0} row(s) from users table", deletedFromUsers);

        conn.commit();
        LOGGER.log(Level.INFO, "User deletion completed successfully for ID: {0}", userId);
        
    } catch (SQLException ex) {
        System.err.println("Error deleting user cascade for ID: " + userId);
        ex.printStackTrace();
        try {
            if (conn != null) {
                conn.rollback();
                LOGGER.log(Level.WARNING, "Transaction rolled back due to error");
            }
        } catch (SQLException rollbackEx) {
            System.err.println("Rollback failed: " + rollbackEx.getMessage());
            rollbackEx.printStackTrace();
        }
        throw new RuntimeException("Failed to delete user: " + ex.getMessage(), ex);
    } finally {
        // Clean up resources
        try {
            if (rs != null) rs.close();
            if (pstmt != null) pstmt.close();
            if (conn != null) conn.setAutoCommit(true);
        } catch (SQLException e) {
            System.err.println("Error cleaning up resources: " + e.getMessage());
            e.printStackTrace();
        }
    }
}

// Helper method to delete user from users table
public int deleteUser(int userId) {
    try {
        ensureConnection();
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Connection error in deleteUser", e);
        return 0;
    }
    
    String sql = "DELETE FROM users WHERE user_id = ?";
    try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
        pstmt.setInt(1, userId);
        int rowsAffected = pstmt.executeUpdate();
        return rowsAffected;
    } catch (SQLException ex) {
        Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
        return 0;
    }
}

public void deleteCourseCascade(String courseName) {
    try {
        ensureConnection();
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Connection error in deleteCourseCascade", e);
        return;
    }
    
    PreparedStatement pstmAnswers = null;
    PreparedStatement pstmExams = null;
    PreparedStatement pstmQuestions = null;
    PreparedStatement pstmCourse = null;
    
    try {
        conn.setAutoCommit(false);
        
        // 1. First get all exam IDs for this course
        ArrayList<Integer> examIds = new ArrayList<>();
        String getExamIdsSql = "SELECT exam_id FROM exams WHERE course_name = ?";
        pstmExams = conn.prepareStatement(getExamIdsSql);
        pstmExams.setString(1, courseName);
        ResultSet rs = pstmExams.executeQuery();
        while (rs.next()) {
            examIds.add(rs.getInt("exam_id"));
        }
        rs.close();
        
        // 2. Delete answers for each exam
        if (!examIds.isEmpty()) {
            String deleteAnswersSql = "DELETE FROM answers WHERE exam_id = ?";
            pstmAnswers = conn.prepareStatement(deleteAnswersSql);
            for (int examId : examIds) {
                pstmAnswers.setInt(1, examId);
                pstmAnswers.executeUpdate();
            }
        }
        
        // 3. Delete exams for this course
        String deleteExamsSql = "DELETE FROM exams WHERE course_name = ?";
        pstmExams = conn.prepareStatement(deleteExamsSql);
        pstmExams.setString(1, courseName);
        pstmExams.executeUpdate();
        
        // 4. Delete questions for this course
        String deleteQuestionsSql = "DELETE FROM questions WHERE course_name = ?";
        pstmQuestions = conn.prepareStatement(deleteQuestionsSql);
        pstmQuestions.setString(1, courseName);
        pstmQuestions.executeUpdate();
        
        // 5. Finally delete the course
        String deleteCourseSql = "DELETE FROM courses WHERE course_name = ?";
        pstmCourse = conn.prepareStatement(deleteCourseSql);
        pstmCourse.setString(1, courseName);
        pstmCourse.executeUpdate();
        
        conn.commit();
    } catch (SQLException ex) {
        try {
            conn.rollback();
        } catch (SQLException rollbackEx) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, "Rollback failed", rollbackEx);
        }
        Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
    } finally {
        try {
            if (pstmAnswers != null) pstmAnswers.close();
            if (pstmExams != null) pstmExams.close();
            if (pstmQuestions != null) pstmQuestions.close();
            if (pstmCourse != null) pstmCourse.close();
            conn.setAutoCommit(true);
        } catch (SQLException e) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, e);
        }
    }
}




    public void delStudent(int uid){
        try {
            ensureConnection();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Connection error in delStudent", e);
            return;
        }
        
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
            ensureConnection();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Connection error in delLecture", e);
            return;
        }
        
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
    try {
        ensureConnection();
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Connection error in deleteLecturer", e);
        return;
    }
    
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


    
public void addQuestion(String cName, String question, String opt1, String opt2, String opt3, String opt4, String correct, String questionType, String imagePath) {
    try {
        ensureConnection();
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Connection error in addQuestion", e);
        return;
    }
    
    try {
        String sql;
        PreparedStatement pstm;

        // If the question type is True/False, only use two options (True/False)
        if (questionType.equals("TrueFalse")) {
            sql = "INSERT INTO questions (question, opt1, opt2, correct, course_name, question_type, image_path) VALUES (?, ?, ?, ?, ?, ?, ?)";
            pstm = conn.prepareStatement(sql);
            pstm.setString(1, question);
            pstm.setString(2, "True");  // True as the first option
            pstm.setString(3, "False"); // False as the second option
            pstm.setString(4, correct); // Correct answer should be "True" or "False"
            pstm.setString(5, cName); // Set the course name
            pstm.setString(6, questionType);
            pstm.setString(7, imagePath); // Set the image path
        } else {
            // Multiple Choice Question logic
            sql = "INSERT INTO questions (question, opt1, opt2, opt3, opt4, correct, course_name, question_type, image_path) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
            pstm = conn.prepareStatement(sql);
            pstm.setString(1, question);
            pstm.setString(2, opt1);
            pstm.setString(3, opt2);
            pstm.setString(4, opt3);
            pstm.setString(5, opt4);
            pstm.setString(6, correct);
            pstm.setString(7, cName); // Set the course name
            pstm.setString(8, questionType);
            pstm.setString(9, imagePath); // Set the image path
        }

        // Execute the update
        pstm.executeUpdate();
        pstm.close();
        LOGGER.log(Level.INFO, "Question inserted successfully: {0}", question);

    } catch (SQLException ex) {
        LOGGER.log(Level.SEVERE, "Error inserting question: " + ex.getMessage(), ex);
        Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
    }
}



    
    
public ArrayList getQuestions(String courseName, int questions) {
    try {
        ensureConnection();
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Connection error in getQuestions", e);
        return new ArrayList();
    }
    
    ArrayList list = new ArrayList();
    PreparedStatement pstm = null;
    ResultSet rs = null;
    
    try {
        // Use LOWER and TRIM to make the course name search case-insensitive and whitespace-tolerant
        String sql = "SELECT * FROM questions WHERE LOWER(TRIM(course_name)) = LOWER(TRIM(?)) ORDER BY RAND() LIMIT ?";
        pstm = conn.prepareStatement(sql);
        pstm.setString(1, courseName);
        pstm.setInt(2, questions);
        rs = pstm.executeQuery();
        
        Questions question;
        while (rs.next()) {
            question = new Questions(
                rs.getInt("question_id"),
                rs.getString("question"),
                rs.getString("opt1"),
                rs.getString("opt2"),
                rs.getString("opt3"),
                rs.getString("opt4"),
                rs.getString("correct"),
                rs.getString("course_name"),
                rs.getString("question_type"),
                rs.getString("image_path")
            );
            
            // Populate advanced fields from current row
            try {
                question.setExtraData(rs.getString("extra_data"));
                question.setDragItemsJson(rs.getString("drag_items"));
                question.setDropTargetsJson(rs.getString("drop_targets"));
                question.setCorrectTargetsJson(rs.getString("drag_correct_targets"));
                question.setTotalMarks(rs.getInt("marks"));
            } catch (SQLException sqle) {
                // Columns might not exist yet
            }
            
            list.add(question);
        }
    } catch (SQLException ex) {
        Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, "Error in getQuestions", ex);
    } finally {
        try {
            if (rs != null) rs.close();
            if (pstm != null) pstm.close();
        } catch (SQLException e) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, "Failed to close resources in getQuestions", e);
        }
    }

    // Now populate nested relational data AFTER closing the main ResultSet
    for (Object obj : list) {
        Questions q = (Questions) obj;
            if ("DRAG_AND_DROP".equalsIgnoreCase(q.getQuestionType()) || "RE_ARRANGE".equalsIgnoreCase(q.getQuestionType())) {
            q.setDragItems(getDragItemsByQuestionIdOld(q.getQuestionId()));
            q.setDropTargets(getDropTargetsByQuestionIdOld(q.getQuestionId()));
        } else if ("REARRANGE".equalsIgnoreCase(q.getQuestionType())) {
            q.setRearrangeItems(getRearrangeItems(q.getQuestionId()));
            // Also populate rearrangeItemsJson for fallback in UI
            q.setRearrangeItemsJson(q.getDragItemsJson());
        }
    }
    return list;
}
    
    public int startExam(String rawName, int sId) throws SQLException {
        try {
            ensureConnection();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Connection error in startExam", e);
            throw new SQLException("Database connection failed: " + e.getMessage());
        }
        
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
            pstm.setString(7, "incomplete");       // Set initial status
            pstm.setNull(8, Types.VARCHAR);         // result_status is NULL initially

            pstm.executeUpdate();

            try (ResultSet keys = pstm.getGeneratedKeys()) {
                if (keys.next()) {
                    examId = keys.getInt(1);
                    logExamStart(sId, examId, cName);
                }
            }
        }
        return examId;
    }

    public void logExamStart(int studentId, int examId, String courseName) {
        try {
            ensureConnection();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Connection error in logExamStart", e);
            return;
        }
        
        try {
            String sql = "INSERT INTO exam_register(student_id, exam_id, course_name, exam_date, start_time) VALUES (?, ?, ?, ?, ?)";
            PreparedStatement pstm = conn.prepareStatement(sql);
            pstm.setInt(1, studentId);
            pstm.setInt(2, examId);
            pstm.setString(3, courseName);
            pstm.setDate(4, java.sql.Date.valueOf(LocalDate.now()));
            pstm.setTime(5, java.sql.Time.valueOf(LocalTime.now()));
            pstm.executeUpdate();
            pstm.close();
        } catch (SQLException ex) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
    
    public int getLastExamId(){
        try {
            ensureConnection();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Connection error in getLastExamId", e);
            return 0;
        }
        
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
        try {
            ensureConnection();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Connection error in getStartTime", e);
            return "";
        }
        
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
        try {
            ensureConnection();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Connection error in getCourseTimeByName", e);
            return null;
        }
        
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
        try {
            ensureConnection();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Connection error in getTotalMarksByName", e);
            return 0;
        }
        
        int marks=0;
        try{
            PreparedStatement pstm=conn.prepareStatement("Select total_marks from courses where course_name=?");
            pstm.setString(1,cName);
            ResultSet rs=pstm.executeQuery();
            while(rs.next()){
                marks=rs.getInt(1);
            }
            pstm.close();
        }catch(Exception e){
             e.printStackTrace();
        }
        
        return marks;
    }
    
public ArrayList getAllQuestions(String courseName) {
    try {
        ensureConnection();
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Connection error in getAllQuestions", e);
        return new ArrayList();
    }
    
    ArrayList list = new ArrayList();
    PreparedStatement pstm = null;
    ResultSet rs = null;
    
    try {
        // Use LOWER and TRIM for a case-insensitive and whitespace-tolerant search
        String sql = "SELECT * FROM questions WHERE LOWER(TRIM(course_name)) = LOWER(TRIM(?))";
        pstm = conn.prepareStatement(sql);
        pstm.setString(1, courseName);
        rs = pstm.executeQuery();
        
        Questions question;
        while (rs.next()) {
            question = new Questions(
                rs.getInt("question_id"),
                rs.getString("question"),
                rs.getString("opt1"),
                rs.getString("opt2"),
                rs.getString("opt3"),
                rs.getString("opt4"),
                rs.getString("correct"),
                rs.getString("course_name"),
                rs.getString("question_type"),
                rs.getString("image_path")
            );
            
            // Populate advanced fields from current row
            try {
                question.setExtraData(rs.getString("extra_data"));
                question.setDragItemsJson(rs.getString("drag_items"));
                question.setDropTargetsJson(rs.getString("drop_targets"));
                question.setCorrectTargetsJson(rs.getString("drag_correct_targets"));
                question.setTotalMarks(rs.getInt("marks"));
            } catch (SQLException sqle) {
                // Columns might not exist yet
            }
            
            list.add(question);
        }
    } catch (SQLException ex) {
        Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, "Error in getAllQuestions", ex);
    } finally {
        try {
            if (rs != null) rs.close();
            if (pstm != null) pstm.close();
        } catch (SQLException e) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, "Failed to close resources in getAllQuestions", e);
        }
    }

    // Now populate nested relational data AFTER closing the main ResultSet
    for (Object obj : list) {
        Questions q = (Questions) obj;
        if ("DRAG_AND_DROP".equalsIgnoreCase(q.getQuestionType()) || "RE_ARRANGE".equalsIgnoreCase(q.getQuestionType())) {
            q.setDragItems(getDragItemsByQuestionIdOld(q.getQuestionId()));
            q.setDropTargets(getDropTargetsByQuestionIdOld(q.getQuestionId()));
        } else if ("REARRANGE".equalsIgnoreCase(q.getQuestionType())) {
            q.setRearrangeItems(getRearrangeItems(q.getQuestionId()));
            // Also populate rearrangeItemsJson for fallback in UI
            q.setRearrangeItemsJson(q.getDragItemsJson());
        }
    }
    return list;
}

// Enhanced getAllQuestions method with search, filters, and sorting
public ArrayList getAllQuestions(String courseName, String searchTerm, String questionTypeFilter, String sortBy) {
    try {
        ensureConnection();
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Connection error in getAllQuestions", e);
        return new ArrayList();
    }
    
    ArrayList list = new ArrayList();
    PreparedStatement pstm = null;
    ResultSet rs = null;
    
    try {
        // Build dynamic SQL query
        StringBuilder sql = new StringBuilder("SELECT * FROM questions WHERE LOWER(TRIM(course_name)) = LOWER(TRIM(?))");
        
        // Add search condition if provided
        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            sql.append(" AND (LOWER(question) LIKE LOWER(?) OR LOWER(opt1) LIKE LOWER(?) OR LOWER(opt2) LIKE LOWER(?) OR LOWER(opt3) LIKE LOWER(?) OR LOWER(opt4) LIKE LOWER(?))");
        }
        
        // Add question type filter if provided
        if (questionTypeFilter != null && !questionTypeFilter.trim().isEmpty() && !"all".equalsIgnoreCase(questionTypeFilter)) {
            sql.append(" AND question_type = ?");
        }
        
        // Add sorting
        if (sortBy == null || sortBy.isEmpty() || "desc".equalsIgnoreCase(sortBy)) {
            sql.append(" ORDER BY question_id DESC"); // Descending order (newest first)
        } else {
            sql.append(" ORDER BY question_id ASC"); // Ascending order (oldest first)
        }
        
        pstm = conn.prepareStatement(sql.toString());
        
        // Set parameters
        int paramIndex = 1;
        pstm.setString(paramIndex++, courseName);
        
        if (searchTerm != null && !searchTerm.trim().isEmpty()) {
            String searchPattern = "%" + searchTerm.trim() + "%";
            pstm.setString(paramIndex++, searchPattern);
            pstm.setString(paramIndex++, searchPattern);
            pstm.setString(paramIndex++, searchPattern);
            pstm.setString(paramIndex++, searchPattern);
            pstm.setString(paramIndex++, searchPattern);
        }
        
        if (questionTypeFilter != null && !questionTypeFilter.trim().isEmpty() && !"all".equalsIgnoreCase(questionTypeFilter)) {
            pstm.setString(paramIndex++, questionTypeFilter);
        }
        
        rs = pstm.executeQuery();
        
        Questions question;
        while (rs.next()) {
            question = new Questions(
                rs.getInt("question_id"),
                rs.getString("question"),
                rs.getString("opt1"),
                rs.getString("opt2"),
                rs.getString("opt3"),
                rs.getString("opt4"),
                rs.getString("correct"),
                rs.getString("course_name"),
                rs.getString("question_type"),
                rs.getString("image_path")
            );
            
            // Populate advanced fields from current row
            try {
                question.setExtraData(rs.getString("extra_data"));
                question.setDragItemsJson(rs.getString("drag_items"));
                question.setDropTargetsJson(rs.getString("drop_targets"));
                question.setCorrectTargetsJson(rs.getString("drag_correct_targets"));
                question.setTotalMarks(rs.getInt("marks"));
            } catch (SQLException sqle) {
                // Columns might not exist yet
            }
            
            list.add(question);
        }
    } catch (SQLException ex) {
        Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, "Error in getAllQuestions", ex);
    } finally {
        try {
            if (rs != null) rs.close();
            if (pstm != null) pstm.close();
        } catch (SQLException e) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, "Failed to close resources in getAllQuestions", e);
        }
    }

    // Now populate nested relational data AFTER closing the main ResultSet
    for (Object obj : list) {
        Questions q = (Questions) obj;
        if ("DRAG_AND_DROP".equalsIgnoreCase(q.getQuestionType()) || "RE_ARRANGE".equalsIgnoreCase(q.getQuestionType())) {
            q.setDragItems(getDragItemsByQuestionIdOld(q.getQuestionId()));
            q.setDropTargets(getDropTargetsByQuestionIdOld(q.getQuestionId()));
        } else if ("REARRANGE".equalsIgnoreCase(q.getQuestionType())) {
            q.setRearrangeItems(getRearrangeItems(q.getQuestionId()));
            // Also populate rearrangeItemsJson for fallback in UI
            q.setRearrangeItemsJson(q.getDragItemsJson());
        }
    }
    return list;
}
    
    public ArrayList getAllAnswersByExamId(int examId){
        try {
            ensureConnection();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Connection error in getAllAnswersByExamId", e);
            return new ArrayList();
        }
        
        ArrayList list=new ArrayList();
        try {
            
            // Fixed: Group by question_id ONLY to collapse duplicate rows.
            // We use MAX() for other columns to ensure SQL compatibility while picking representative values.
            String sql = "SELECT MAX(question) as question, MAX(answer) as answer, MAX(correct_answer) as correct_answer, " +
                        "CASE " +
                        "    WHEN SUM(CASE WHEN status = 'correct' THEN 1 ELSE 0 END) > 0 THEN 'correct' " +
                        "    WHEN SUM(CASE WHEN status LIKE 'partial:%' THEN 1 ELSE 0 END) > 0 THEN MAX(status) " +
                        "    ELSE 'incorrect' " +
                        "END as status, " +
                        "question_id " +
                        "FROM answers " +
                        "WHERE exam_id = ? " +
                        "GROUP BY question_id " +
                        "ORDER BY question_id";
            
            PreparedStatement pstm=conn.prepareStatement(sql);
            pstm.setInt(1,examId);
            ResultSet rs=pstm.executeQuery();
            Answers a;
            while(rs.next()){
               a = new Answers(
                       rs.getString("question"),
                       rs.getString("answer"),
                       rs.getString("correct_answer"),
                       rs.getString("status"),
                       0, // score (default)
                       rs.getInt("question_id") // question_id for image support
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
        try {
            ensureConnection();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Connection error in getRemainingTime", e);
            return 0;
        }
        
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
        return time;
    }
    
    
public void insertAnswer(int eId, int qid, String question, String ans) {
    try {
        ensureConnection();
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Connection error in insertAnswer", e);
        return;
    }
    
    PreparedStatement pstmCheck = null;
    PreparedStatement pstm = null;
    ResultSet rs = null;
    try {
        String correct = getCorrectAnswer(qid);
        String status = getAnswerStatus(ans, correct);
        String userAnswerForDb = (ans != null && !ans.trim().isEmpty()) ? ans.trim() : "N/A";

        // First, check if an answer already exists for this exam and question
        String checkSql = "SELECT answer_id FROM answers WHERE exam_id = ? AND question_id = ?";
        pstmCheck = conn.prepareStatement(checkSql);
        pstmCheck.setInt(1, eId);
        pstmCheck.setInt(2, qid);
        rs = pstmCheck.executeQuery();

        if (rs.next()) {
            // Update existing answer
            int answerId = rs.getInt("answer_id");
            String updateSql = "UPDATE answers SET question = ?, answer = ?, correct_answer = ?, status = ? WHERE answer_id = ?";
            pstm = conn.prepareStatement(updateSql);
            pstm.setString(1, question);
            pstm.setString(2, userAnswerForDb);
            pstm.setString(3, correct);
            pstm.setString(4, status);
            pstm.setInt(5, answerId);
        } else {
            // Insert new answer
            String insertSql = "INSERT INTO answers (exam_id, question_id, question, answer, correct_answer, status) VALUES (?, ?, ?, ?, ?, ?)";
            pstm = conn.prepareStatement(insertSql);
            pstm.setInt(1, eId);
            pstm.setInt(2, qid);
            pstm.setString(3, question);
            pstm.setString(4, userAnswerForDb);
            pstm.setString(5, correct);
            pstm.setString(6, status);
        }

        pstm.executeUpdate();
        
    } catch (SQLException ex) {
        Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
    } finally {
        try {
            if (rs != null) rs.close();
            if (pstmCheck != null) pstmCheck.close();
            if (pstm != null) pstm.close();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to close resources in insertAnswer", e);
        }
    }
}


private String getCorrectAnswer(int qid) {
    try {
        ensureConnection();
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Connection error in getCorrectAnswer", e);
        return "";
    }
    
    String ans = ""; // Default to empty string
    PreparedStatement pstm = null;
    ResultSet rs = null;
    
    try {
        // First, get the correct answer from the questions table
        pstm = conn.prepareStatement("SELECT correct, question_type, drag_items FROM questions WHERE question_id=?");
        pstm.setInt(1, qid);
        rs = pstm.executeQuery();
        
        if (rs.next()) {
            String result = rs.getString("correct");
            String questionType = rs.getString("question_type");
            String dragItemsJson = rs.getString("drag_items");
            
            // For Drag and Drop or Rearrange, return the correct answer in JSON format
            if ("DRAG_AND_DROP".equalsIgnoreCase(questionType) || "REARRANGE".equalsIgnoreCase(questionType) || "RE_ARRANGE".equalsIgnoreCase(questionType)) {
                // Special handling for REARRANGE (singular) - it uses a JSON array of IDs
                if ("REARRANGE".equalsIgnoreCase(questionType)) {
                    try {
                        ArrayList<RearrangeItem> items = getRearrangeItems(qid);
                        if (items != null && !items.isEmpty()) {
                            org.json.JSONArray correctArr = new org.json.JSONArray();
                            for (RearrangeItem item : items) {
                                correctArr.put(item.getId());
                            }
                            return correctArr.toString();
                        } else if (dragItemsJson != null && dragItemsJson.startsWith("[")) {
                            // Fallback to JSON indices if relational table is empty
                            org.json.JSONArray itemsArr = new org.json.JSONArray(dragItemsJson);
                            org.json.JSONArray correctArr = new org.json.JSONArray();
                            for (int i = 0; i < itemsArr.length(); i++) {
                                correctArr.put(i);
                            }
                            return correctArr.toString();
                        }
                    } catch (Exception e) {
                        LOGGER.log(Level.WARNING, "Error building rearrange correct answer for Q" + qid + ": " + e.getMessage());
                    }
                }

                org.json.JSONObject correctJson = new org.json.JSONObject();
                try {
                    ArrayList<DragItem> dragItems = getDragItemsByQuestionIdOld(qid);
                    if (dragItems != null && !dragItems.isEmpty()) {
                        for (DragItem di : dragItems) {
                            if (di.getCorrectTargetId() != null && di.getCorrectTargetId() > 0) {
                                // Use target_ format for consistency
                                correctJson.put("target_" + di.getCorrectTargetId(), "item_" + di.getId());
                            }
                        }
                    }
                    
                    // Fallback to JSON columns if relational data is empty
                    if (correctJson.length() == 0) {
                        String sql2 = "SELECT drag_correct_targets FROM questions WHERE question_id = ?";
                        try (PreparedStatement pstm2 = conn.prepareStatement(sql2)) {
                            pstm2.setInt(1, qid);
                            try (ResultSet rs2 = pstm2.executeQuery()) {
                                if (rs2.next()) {
                                    String jsonStr = rs2.getString("drag_correct_targets");
                                    if (jsonStr != null && !jsonStr.trim().isEmpty()) {
                                        // Robust parsing: handles both object format and array format
                                        if (jsonStr.startsWith("{")) {
                                            correctJson = new org.json.JSONObject(jsonStr);
                                        } else if (jsonStr.startsWith("[")) {
                                            // If it's an array of labels, we might not be able to map to IDs easily here
                                            // but at least we don't throw an error. 
                                            // Relational data should be the source of truth anyway.
                                            LOGGER.warning("drag_correct_targets is an array for Q" + qid + ". Relational data missing.");
                                        }
                                    }
                                }
                            }
                        }
                    }
                } catch (Exception e) {
                    LOGGER.log(Level.WARNING, "Error building drag drop correct targets JSON for Q" + qid + ": " + e.getMessage());
                }
                
                // Ensure we return at least empty JSON object string if nothing else found
                return correctJson.length() > 0 ? correctJson.toString() : "{}";
            }
            
            // Handle null from DB and trim whitespace
            if (result != null) {
                ans = result.trim();
            }
            
            // For True/False questions, normalize the answer to standard format
            if ("TrueFalse".equalsIgnoreCase(questionType)) {
                if (ans != null && !ans.isEmpty()) {
                    // Convert variations to standard True/False format
                    String lowerAns = ans.toLowerCase();
                    if (lowerAns.contains("true") || lowerAns.equals("1") || lowerAns.equals("yes")) {
                        ans = "True";
                    } else if (lowerAns.contains("false") || lowerAns.equals("0") || lowerAns.equals("no")) {
                        ans = "False";
                    }
                }
            } else {
                // For other question types, ensure we have a proper answer
                if (ans == null) {
                    ans = "";
                }
            }
        }
    } catch (SQLException ex) {
        Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
    } finally {
        try {
            if (rs != null) rs.close();
            if (pstm != null) pstm.close();
        } catch (SQLException e) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, "Failed to close resources in getCorrectAnswer", e);
        }
    }
    
    return ans;
}


// New method to delete multiple questions in a single transaction
public int deleteQuestions(int[] questionIds) {
    if (questionIds == null || questionIds.length == 0) {
        return 0; // No questions to delete
    }
    
    boolean autoCommit = true;
    try {
        ensureConnection();
        autoCommit = conn.getAutoCommit();
        conn.setAutoCommit(false);
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Connection error in deleteQuestions", e);
        return 0;
    }
    
    PreparedStatement pstmt = null;
    PreparedStatement pstmtAnswers = null;
    
    try {
        // First, get question texts to potentially clean up related answers
        // We'll use a batch approach for better performance
        StringBuilder questionIdsQuery = new StringBuilder();
        for (int i = 0; i < questionIds.length; i++) {
            questionIdsQuery.append("?");
            if (i < questionIds.length - 1) {
                questionIdsQuery.append(",");
            }
        }
        
        String getQuestionsSql = "SELECT question_id, question FROM questions WHERE question_id IN (" + questionIdsQuery.toString() + ")";
        pstmt = conn.prepareStatement(getQuestionsSql);
        
        // Set the parameters for question IDs
        for (int i = 0; i < questionIds.length; i++) {
            pstmt.setInt(i + 1, questionIds[i]);
        }
        
        ResultSet rs = pstmt.executeQuery();
        
        // Collect question texts for answer deletion
        Map<String, Integer> questionTextMap = new HashMap<>();
        while (rs.next()) {
            String questionText = rs.getString("question");
            if (questionText != null) {
                questionTextMap.put(questionText, rs.getInt("question_id"));
            }
        }
        rs.close();
        pstmt.close();
        
        // Delete related answers based on question texts
        if (!questionTextMap.isEmpty()) {
            StringBuilder questionTextsQuery = new StringBuilder();
            for (int i = 0; i < questionTextMap.size(); i++) {
                questionTextsQuery.append("?");
                if (i < questionTextMap.size() - 1) {
                    questionTextsQuery.append(",");
                }
            }
            
            String deleteAnswersSql = "DELETE FROM answers WHERE question IN (" + questionTextsQuery.toString() + ")";
            pstmtAnswers = conn.prepareStatement(deleteAnswersSql);
            
            int paramIndex = 1;
            for (String questionText : questionTextMap.keySet()) {
                pstmtAnswers.setString(paramIndex++, questionText);
            }
            
            int answersDeleted = pstmtAnswers.executeUpdate();
            pstmtAnswers.close();
            
            if (answersDeleted > 0) {
                LOGGER.info("Deleted " + answersDeleted + " answer record(s) related to questions");
            }
        }
        
        // Now delete the questions themselves
        String deleteQuestionsSql = "DELETE FROM questions WHERE question_id IN (" + questionIdsQuery.toString() + ")";
        pstmt = conn.prepareStatement(deleteQuestionsSql);
        
        // Set the parameters for question IDs
        for (int i = 0; i < questionIds.length; i++) {
            pstmt.setInt(i + 1, questionIds[i]);
        }
        
        // Execute the statement and get number of affected rows
        int rowsAffected = pstmt.executeUpdate();
        pstmt.close();
        
        LOGGER.info("Deleted " + rowsAffected + " question record(s) in bulk");
        
        // Commit the transaction
        conn.commit();
        
        return rowsAffected;
    } catch (SQLException ex) {
        try {
            conn.rollback();
            LOGGER.log(Level.SEVERE, "Transaction rolled back due to error deleting questions", ex);
        } catch (SQLException rollbackEx) {
            LOGGER.log(Level.SEVERE, "Rollback failed", rollbackEx);
        }
        LOGGER.log(Level.SEVERE, "Error deleting questions", ex);
        return 0;
    } finally {
        try {
            if (pstmt != null) pstmt.close();
            if (pstmtAnswers != null) pstmtAnswers.close();
            conn.setAutoCommit(autoCommit); // Restore original autocommit setting
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Error closing resources", e);
        }
    }
}


private String getAnswerStatus(String ans, String correct) {
    // 1. Normalize inputs: handle nulls and trim whitespace
    String userAnswer = (ans != null) ? ans.trim() : "";
    String correctAnswer = (correct != null) ? correct.trim() : "";

    // 2. An unanswered question is always incorrect
    if (userAnswer.isEmpty() || userAnswer.equals("N/A")) {
        return "incorrect";
    }

    // 3. Compare based on question type (drag-drop, rearrange, multi-select or single)
    if (userAnswer.startsWith("{") && correctAnswer.startsWith("{")) {
        try {
            org.json.JSONObject userObj = new org.json.JSONObject(userAnswer);
            org.json.JSONObject correctObj = new org.json.JSONObject(correctAnswer);
            
            // Count correct matches
            int correctMatches = 0;
            int totalMatches = correctObj.length();
            
            java.util.Iterator<String> keys = correctObj.keys();
            while (keys.hasNext()) {
                String key = keys.next();
                if (userObj.has(key) && userObj.get(key).equals(correctObj.get(key))) {
                    correctMatches++;
                }
            }
            
            // Determine status and include marks for partial scoring
            if (correctMatches == totalMatches && totalMatches > 0) {
                return "correct";
            } else if (correctMatches > 0) {
                return "partial:" + (float)correctMatches;
            } else {
                return "incorrect";
            }
        } catch (Exception e) {
            return "incorrect";
        }
    }
    
    // Handle REARRANGE JSON arrays
    if (userAnswer.startsWith("[") && correctAnswer.startsWith("[")) {
        try {
            org.json.JSONArray userArr = new org.json.JSONArray(userAnswer);
            org.json.JSONArray correctArr = new org.json.JSONArray(correctAnswer);

            int correctCount = 0;
            int totalCount = correctArr.length();

            for (int i = 0; i < totalCount && i < userArr.length(); i++) {
                if (userArr.get(i).equals(correctArr.get(i))) {
                    correctCount++;
                }
            }

            if (correctCount == totalCount && totalCount > 0) {
                return "correct";
            } else if (correctCount > 0) {
                // Calculate partial marks (assuming 1 mark per correct position by default)
                return "partial:" + (float)correctCount;
            } else {
                return "incorrect";
            }
        } catch (Exception e) {
            return "incorrect";
        }
    }

    if (correctAnswer.contains("|")) {
        // Normalize multi-select answers and support partial marks
        String[] ansParts = userAnswer.split("\\|");
        Set<String> userSet = new HashSet<>();
        for (String p : ansParts) {
            if (!p.trim().isEmpty()) userSet.add(p.trim().toLowerCase());
        }
        
        String[] correctParts = correctAnswer.split("\\|");
        Set<String> correctSet = new HashSet<>();
        for (String p : correctParts) {
            if (!p.trim().isEmpty()) correctSet.add(p.trim().toLowerCase());
        }
        
        int matchCount = 0;
        for (String u : userSet) {
            if (correctSet.contains(u)) {
                matchCount++;
            }
        }
        
        if (matchCount == correctSet.size() && userSet.size() == correctSet.size()) {
            return "correct";
        } else if (matchCount > 0) {
            // Return partial status with the score (1 mark per correct selection)
            return "partial:" + (float)matchCount;
        } else {
            return "incorrect";
        }
    } else {
        // Simple case-insensitive comparison for single answers
        return userAnswer.equalsIgnoreCase(correctAnswer) ? "correct" : "incorrect";
    }
}


public boolean courseExists(String courseName) {
    try {
        ensureConnection();
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Connection error in courseExists", e);
        return false;
    }
    
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
    try {
        ensureConnection();
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Connection error in getResultsFromExams", e);
        return new ArrayList<>();
    }
    
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

    public boolean hasQuestions(String courseName) {
        try {
            ensureConnection();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Connection error in hasQuestions", e);
            return false;
        }
        
        String sql = "SELECT 1 FROM questions WHERE course_name = ? LIMIT 1";
        try (PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, courseName);
            try (ResultSet rs = ps.executeQuery()) {
                return rs.next();
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "hasQuestions failed for course: " + courseName, e);
            return false;
        }
    }

public int getExamDuration(String courseName) {
    try {
        ensureConnection();
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Connection error in getExamDuration", e);
        return 120; // Default 2 hours in minutes
    }
    
    int duration = 120; // Default 2 hours in minutes
    try {
        String sql = "SELECT time FROM courses WHERE course_name = ?";
        PreparedStatement pstm = conn.prepareStatement(sql);
        pstm.setString(1, courseName);
        ResultSet rs = pstm.executeQuery();
        if (rs.next()) {
            String timeStr = rs.getString("time");
            
            // Handle different time formats
            if (timeStr != null && !timeStr.trim().isEmpty()) {
                timeStr = timeStr.trim();
                
                // Case 1: Already in minutes (just a number)
                try {
                    // Try to parse as just minutes
                    duration = Integer.parseInt(timeStr);
                    LOGGER.log(Level.INFO, "Parsed as minutes: {0} for course: {1}", new Object[]{duration, courseName});
                } catch (NumberFormatException e1) {
                    // Case 2: Try to parse as "hh:mm" format
                    if (timeStr.contains(":")) {
                        String[] parts = timeStr.split(":");
                        int hours = 0;
                        int minutes = 0;
                        
                        try {
                            hours = Integer.parseInt(parts[0].trim());
                            minutes = Integer.parseInt(parts[1].trim());
                            duration = (hours * 60) + minutes;
                            LOGGER.log(Level.INFO, "Parsed as hh:mm: {0} minutes for course: {1}", new Object[]{duration, courseName});
                        } catch (NumberFormatException e2) {
                            LOGGER.log(Level.WARNING, "Error parsing time format: {0}", timeStr);
                        }
                    } else {
                        // Case 3: Try to parse as decimal hours (e.g., "1.5" = 1.5 hours)
                        try {
                            double decimalHours = Double.parseDouble(timeStr);
                            duration = (int) Math.round(decimalHours * 60);
                            LOGGER.log(Level.INFO, "Parsed as decimal hours: {0} minutes for course: {1}", new Object[]{duration, courseName});
                        } catch (NumberFormatException e3) {
                            LOGGER.log(Level.WARNING, "Could not parse time format: {0}", timeStr);
                        }
                    }
                }
            }
        }
        rs.close();
        pstm.close();
    } catch (SQLException ex) {
        LOGGER.log(Level.SEVERE, "Error getting exam duration: " + ex.getMessage(), ex);
    }
    return duration;
}

// Method to get an Exam by Exam ID
public Exams getResultByExamId(int examId) {
    try {
        ensureConnection();
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Connection error in getResultByExamId", e);
        return null;
    }
    
    Exams exam = null;
    PreparedStatement pstm = null;
    ResultSet rs = null;

    try {
        String query = "SELECT u.first_name, u.last_name, u.user_name, u.email, " +
                       "e.exam_id, e.std_id, e.course_name, e.total_marks, e.obt_marks, " +
                       "e.date, e.start_time, e.end_time, e.exam_time, e.status, e.result_status " +
                       "FROM exams e " +
                       "INNER JOIN users u ON e.std_id = u.user_id " +
                       "WHERE e.exam_id = ?";

        pstm = conn.prepareStatement(query);
        pstm.setInt(1, examId);
        rs = pstm.executeQuery();

        if (rs.next()) {
            String formattedDate = rs.getDate("date") != null ? rs.getDate("date").toString() : null;
            
            // Get marks - THESE ARE THE ACTUAL VALUES FROM DATABASE
            int obtMarks = rs.getInt("obt_marks");
            int totalMarks = rs.getInt("total_marks");
            
            // Get result_status directly from database
            String resultStatus = rs.getString("result_status");
            
            // Calculate percentage for logging/debug
            double percentage = 0;
            if (totalMarks > 0) {
                percentage = (obtMarks * 100.0) / totalMarks;
            }
            
            // Log the actual values for debugging
            LOGGER.info("Exam ID " + examId + " - Marks: " + obtMarks + "/" + totalMarks + 
                       " (" + String.format("%.1f", percentage) + "%) - Status: " + resultStatus);
            
            exam = new Exams(
                rs.getString("first_name"), 
                rs.getString("last_name"), 
                rs.getString("user_name"),
                rs.getString("email"),
                rs.getInt("exam_id"),
                rs.getString("std_id"),
                rs.getString("course_name"),
                totalMarks,
                obtMarks,
                formattedDate,
                rs.getString("start_time"),
                rs.getString("end_time"),
                rs.getString("exam_time"),
                resultStatus != null ? resultStatus : (percentage >= 45.0 ? "Pass" : "Fail")
            );
        }
    } catch (SQLException ex) {
        ex.printStackTrace();
    } finally {
        closeResources(pstm, rs);
    }
    return exam;
}


    public void deleteExamResults(String[] examIds) {
        try {
            ensureConnection();
            conn.setAutoCommit(false);
            String deleteAnswersSql = "DELETE FROM answers WHERE exam_id = ?";
            String deleteExamSql = "DELETE FROM exams WHERE exam_id = ?";
            try (PreparedStatement psAnswers = conn.prepareStatement(deleteAnswersSql);
                 PreparedStatement psExams = conn.prepareStatement(deleteExamSql)) {
                for (String examIdStr : examIds) {
                    int examId = Integer.parseInt(examIdStr);
                    psAnswers.setInt(1, examId);
                    psAnswers.addBatch();
                    psExams.setInt(1, examId);
                    psExams.addBatch();
                }
                psAnswers.executeBatch();
                psExams.executeBatch();
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                LOGGER.log(Level.SEVERE, "Error bulk deleting exam results", e);
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Connection error in deleteExamResults", e);
        }
    }
    
    
public boolean deleteExamRecord(int examId, int studentId) throws SQLException {
    try {
        ensureConnection();
        
        // First, check if the record exists
        String checkSql = "SELECT COUNT(*) FROM exams e " +
                         "JOIN answers a ON e.exam_id = a.exam_id " +
                         "WHERE e.exam_id = ? AND a.student_id = ?";
        
        try (PreparedStatement checkStmt = conn.prepareStatement(checkSql)) {
            checkStmt.setInt(1, examId);
            checkStmt.setInt(2, studentId);
            
            ResultSet rs = checkStmt.executeQuery();
            if (rs.next() && rs.getInt(1) == 0) {
                // Record doesn't exist
                return false;
            }
        }
        
        // Start transaction
        conn.setAutoCommit(false);
        
        try {
            // Delete from answers table first (foreign key constraint)
            String deleteAnswersSql = "DELETE FROM answers WHERE exam_id = ? AND student_id = ?";
            try (PreparedStatement psAnswers = conn.prepareStatement(deleteAnswersSql)) {
                psAnswers.setInt(1, examId);
                psAnswers.setInt(2, studentId);
                psAnswers.executeUpdate();
            }
            
            // Check if this was the last student for this exam
            String countStudentsSql = "SELECT COUNT(*) FROM answers WHERE exam_id = ?";
            try (PreparedStatement countStmt = conn.prepareStatement(countStudentsSql)) {
                countStmt.setInt(1, examId);
                ResultSet rs = countStmt.executeQuery();
                
                if (rs.next() && rs.getInt(1) == 0) {
                    // No more students for this exam, delete the exam itself
                    String deleteExamSql = "DELETE FROM exams WHERE exam_id = ?";
                    try (PreparedStatement psExams = conn.prepareStatement(deleteExamSql)) {
                        psExams.setInt(1, examId);
                        psExams.executeUpdate();
                    }
                }
            }
            
            conn.commit();
            return true;
            
        } catch (SQLException e) {
            conn.rollback();
            LOGGER.log(Level.SEVERE, "Error deleting exam record for examId: " + 
                      examId + ", studentId: " + studentId, e);
            throw e; // Re-throw to handle in calling code
        } finally {
            conn.setAutoCommit(true);
        }
        
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Connection error in deleteExamRecord", e);
        throw e;
    }
}

public boolean deleteExamResult(int examId) {
    try {
        ensureConnection();
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Connection error in deleteExamResult", e);
        return false;
    }
    
    PreparedStatement psExam = null;
    PreparedStatement psAnswers = null;
    Connection conn = null;
    boolean success = false;
    
    try {
        conn = getConnection();
        conn.setAutoCommit(false); // Start transaction
        
        // First, get exam details for logging/confirmation (optional)
        String examDetailsSql = "SELECT e.*, s.name as student_name, c.cname as course_name " +
                                "FROM exams e " +
                                "JOIN students s ON e.stu_id = s.stu_id " +
                                "JOIN courses c ON e.course_id = c.course_id " +
                                "WHERE e.exam_id = ?";
        
        // 1. Delete answers associated with this exam
        String deleteAnswersSql = "DELETE FROM answers WHERE exam_id = ?";
        psAnswers = conn.prepareStatement(deleteAnswersSql);
        psAnswers.setInt(1, examId);
        int answersDeleted = psAnswers.executeUpdate();
        
        // 2. Delete the exam itself
        String deleteExamSql = "DELETE FROM exams WHERE exam_id = ?";
        psExam = conn.prepareStatement(deleteExamSql);
        psExam.setInt(1, examId);
        int examDeleted = psExam.executeUpdate();
        
        conn.commit(); // Commit transaction
        success = (examDeleted > 0);
        
        // Log the deletion
        if (success) {
            LOGGER.log(Level.INFO, "Successfully deleted exam result ID: {0} and {1} related answers", new Object[]{examId, answersDeleted});
        }
        
    } catch (SQLException ex) {
        try {
            if (conn != null) {
                conn.rollback(); // Rollback on error
            }
        } catch (SQLException rollbackEx) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, "Rollback failed", rollbackEx);
        }
        Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, "deleteExamResult failed for exam ID: " + examId, ex);
        success = false;
    } finally {
        try {
            if (psAnswers != null) psAnswers.close();
            if (psExam != null) psExam.close();
            if (conn != null) {
                conn.setAutoCommit(true);
            }
        } catch (SQLException ex) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, "Failed to close resources", ex);
        }
    }
    
    return success;
}

// Optional: Method to get exam details before deletion (for confirmation)
public Map<String, String> getExamDetails(int examId) {
    try {
        ensureConnection();
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Connection error in getExamDetails", e);
        return new HashMap<>();
    }
    
    PreparedStatement ps = null;
    ResultSet rs = null;
    Map<String, String> details = new HashMap<>();
    
    try {
        String sql = "SELECT e.exam_id, e.obt_marks, e.total_marks, e.result_status, " +
                     "s.name as student_name, s.email, s.stu_id, " +
                     "c.cname as course_name, e.exam_date " +
                     "FROM exams e " +
                     "JOIN students s ON e.stu_id = s.stu_id " +
                     "JOIN courses c ON e.course_id = c.course_id " +
                     "WHERE e.exam_id = ?";
        
        ps = getConnection().prepareStatement(sql);
        ps.setInt(1, examId);
        rs = ps.executeQuery();
        
        if (rs.next()) {
            details.put("exam_id", String.valueOf(rs.getInt("exam_id")));
            details.put("student_name", rs.getString("student_name"));
            details.put("student_id", rs.getString("stu_id"));
            details.put("email", rs.getString("email"));
            details.put("course_name", rs.getString("course_name"));
            details.put("obt_marks", String.valueOf(rs.getInt("obt_marks")));
            details.put("total_marks", String.valueOf(rs.getInt("total_marks")));
            details.put("result_status", rs.getString("result_status"));
            details.put("exam_date", rs.getString("exam_date"));
        }
        
    } catch (SQLException ex) {
        Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, "getExamDetails failed", ex);
    } finally {
        try {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
        } catch (SQLException ex) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, "Failed to close resources", ex);
        }
    }
    
    return details;
}

// Add this method to DatabaseClass.java to get ALL exam results (for admin)
public ArrayList<Exams> getAllExamResults() {
    try {
        ensureConnection();
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Connection error in getAllExamResults", e);
        return new ArrayList<>();
    }
    
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

public String generateDeviceIdentifier() {
    // Generate a simple identifier without request info
    String timestamp = String.valueOf(System.currentTimeMillis());
    String random = String.valueOf((int)(Math.random() * 10000));
    
    return "device_" + timestamp.substring(timestamp.length() - 8) + "_" + random;
}



// Method to get all exams with results
public ArrayList<Exams> getAllExamsWithResults() {
    try {
        ensureConnection();
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Connection error in getAllExamsWithResults", e);
        return new ArrayList<>();
    }
    
    ArrayList<Exams> exams = new ArrayList<>();
    PreparedStatement ps = null;
    ResultSet rs = null;

    try {
        String query = "SELECT u.first_name, u.last_name, u.user_name, u.email, " +
                       "e.exam_id, e.std_id, e.course_name, e.total_marks, e.obt_marks, " +
                       "e.date, e.start_time, e.end_time, e.exam_time, e.status, e.result_status " +
                       "FROM exams e " +
                       "INNER JOIN users u ON e.std_id = u.user_id";

        ps = conn.prepareStatement(query);
        rs = ps.executeQuery();

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
                resultStatus
            );
            exams.add(exam);
        }
    } catch (SQLException e) {
        Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, "Error fetching exams with results", e);
    } finally {
        try {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
        } catch (SQLException ex) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, "Failed to close resources", ex);
        }
    }

    return exams;
}

public float[] getRawMarks(int examId) {
    try {
        ensureConnection();
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Connection error in getRawMarks", e);
        return new float[]{0, 0};
    }

    float totalPossibleMarks = 0;
    float totalObtainedMarks = 0;

    try {
        // Get all answers for this exam - COLLAPSE DUPLICATES: Group ONLY by question_id
        // This ensures each question is counted exactly once towards total possible marks.
        String sql = "SELECT " +
                    "CASE " +
                    "    WHEN SUM(CASE WHEN a.status = 'correct' THEN 1 ELSE 0 END) > 0 THEN 'correct' " +
                    "    WHEN SUM(CASE WHEN a.status LIKE 'partial:%' THEN 1 ELSE 0 END) > 0 THEN MAX(a.status) " +
                    "    ELSE 'incorrect' " +
                    "END as status, " +
                    "q.question_type, q.question_id, q.marks " +
                    "FROM answers a " +
                    "JOIN questions q ON a.question_id = q.question_id " +
                    "WHERE a.exam_id = ? " +
                    "GROUP BY q.question_id, q.question_type, q.marks";
        PreparedStatement pstm = conn.prepareStatement(sql);
        pstm.setInt(1, examId);
        ResultSet rs = pstm.executeQuery();

        while (rs.next()) {
            String status = rs.getString("status");
            String questionType = rs.getString("question_type");
            int qid = rs.getInt("question_id");
            int qMarks = rs.getInt("marks");
            
            // Default weight if marks not set
            float questionWeight = qMarks > 0 ? qMarks : 1.0f;
            totalPossibleMarks += questionWeight;
            
            // Unified marking logic: use status from answers table for ALL question types.
            // This ensures consistency between results summary and question details.
            if ("correct".equals(status)) {
                totalObtainedMarks += questionWeight;
            } else if (status != null && status.startsWith("partial:")) {
                try {
                    // Extract marks from status string (e.g. "partial:1.5")
                    float partialObtained = Float.parseFloat(status.substring(8));
                    totalObtainedMarks += partialObtained;
                } catch (NumberFormatException e) {
                    LOGGER.log(Level.WARNING, "Error parsing partial marks from status: " + status, e);
                }
            }

            LOGGER.log(Level.INFO, "Question Q{0} ({1}): obtained {2}/{3} (status: {4})",
                      new Object[]{qid, questionType,
                      ("correct".equals(status) ? questionWeight : (status != null && status.startsWith("partial:") ? status.substring(8) : "0")),
                      questionWeight, status});
        }
        rs.close();
        pstm.close();
        
        return new float[]{totalObtainedMarks, totalPossibleMarks};
        
    } catch (SQLException ex) {
        Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
        return new float[]{0, 0};
    }
}

public void calculateResult(int eid, int tMarks, String endTime, int size) {
    try {
        ensureConnection();
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Connection error in calculateResult", e);
        return;
    }
    
    try {
        // First, calculate raw obtained and total possible marks
        float[] marks = getRawMarks(eid);
        float obtRaw = marks[0];
        float totalRaw = marks[1];
        
        // If totalRaw is 0 (should not happen in real exams), fallback to the passed tMarks
        if (totalRaw == 0) totalRaw = tMarks;
        
        // Calculate percentage based on raw marks
        float percentage = 0;
        if (totalRaw > 0) {
            percentage = (obtRaw / totalRaw) * 100;
        }
        
        // Determine result status based on percentage (45% passing threshold)
        String resultStatus = (percentage >= 45.0) ? "Pass" : "Fail";
        
        // Round for DB storage (since schema is INT)
        int obtRounded = Math.round(obtRaw);
        int totalRounded = Math.round(totalRaw);

        // CRITICAL: Log the actual values being saved
        LOGGER.info("=== SAVING EXAM RESULTS (UNSCALED) ===");
        LOGGER.info("Exam ID: " + eid);
        LOGGER.info("Raw Obtained: " + obtRaw);
        LOGGER.info("Raw Total: " + totalRaw);
        LOGGER.info("Saved Obtained: " + obtRounded);
        LOGGER.info("Saved Total: " + totalRounded);
        LOGGER.info("Percentage: " + String.format("%.1f", percentage) + "%");
        LOGGER.info("Result Status: " + resultStatus);
        LOGGER.info("===========================");
        
        // Update exams table with unscaled obt_marks, total_marks, end_time, and status
        String sql = "UPDATE exams SET obt_marks=?, total_marks=?, end_time=?, status='completed', result_status=? WHERE exam_id=?";
        PreparedStatement pstm = conn.prepareStatement(sql);
        pstm.setInt(1, obtRounded);
        pstm.setInt(2, totalRounded);
        pstm.setString(3, endTime);
        pstm.setString(4, resultStatus);
        pstm.setInt(5, eid);
        
        int rowsUpdated = pstm.executeUpdate();
        LOGGER.info("Rows updated: " + rowsUpdated);
        
        pstm.close();
        
        // Verify the update worked
        String verifySql = "SELECT obt_marks, result_status FROM exams WHERE exam_id = ?";
        PreparedStatement verifyStmt = conn.prepareStatement(verifySql);
        verifyStmt.setInt(1, eid);
        ResultSet verifyRs = verifyStmt.executeQuery();
        if (verifyRs.next()) {
            LOGGER.info("VERIFIED - Exam " + eid + ": obt_marks=" + verifyRs.getInt("obt_marks") + 
                       ", result_status=" + verifyRs.getString("result_status"));
        }
        verifyRs.close();
        verifyStmt.close();

        logExamCompletion(eid);
        
    } catch (SQLException ex) {
        LOGGER.log(Level.SEVERE, "ERROR in calculateResult: " + ex.getMessage(), ex);
    }
}

public void logExamCompletion(int examId) {
    try {
        ensureConnection();
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Connection error in logExamCompletion", e);
        return;
    }
    
    try {
        String sql = "UPDATE exam_register SET end_time = ? WHERE exam_id = ?";
        PreparedStatement pstm = conn.prepareStatement(sql);
        pstm.setTime(1, java.sql.Time.valueOf(LocalTime.now()));
        pstm.setInt(2, examId);
        pstm.executeUpdate();
        pstm.close();
    } catch (SQLException ex) {
        Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
    }
}

    public void toggleCourseStatus(String cName) {
        try {
            ensureConnection();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Connection error in toggleCourseStatus", e);
            return;
        }
        
        try {
            String sql = "UPDATE courses SET is_active = !is_active WHERE course_name=?";
            PreparedStatement pstm = conn.prepareStatement(sql);
            pstm.setString(1, cName);
            pstm.executeUpdate();
            pstm.close();
        } catch (SQLException ex) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
        }
    }

// Add these methods to your DatabaseClass

public boolean registerExamStart(int studentId, int examId, String courseName) 
    throws SQLException {
    
    try {
        ensureConnection();
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Connection error in registerExamStart", e);
        return false;
    }
    
    if (studentId <= 0 || examId <= 0 || courseName == null || courseName.trim().isEmpty()) {
        return false;
    }
    
    String sql = "INSERT INTO exam_register " +
                 "(student_id, exam_id, course_name, exam_date, start_time) " +
                 "VALUES (?, ?, ?, CURDATE(), CURTIME()) " +
                 "ON DUPLICATE KEY UPDATE " +
                 "    start_time = CURTIME()";
    
    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setInt(1, studentId);
        ps.setInt(2, examId);
        ps.setString(3, courseName.trim());
        
        return ps.executeUpdate() > 0;
    }
}

public boolean registerExamCompletion(int studentId, int examId, String endTime) 
    throws SQLException {
    
    try {
        ensureConnection();
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Connection error in registerExamCompletion", e);
        return false;
    }
    
    if (studentId <= 0 || examId <= 0 || endTime == null || endTime.trim().isEmpty()) {
        return false;
    }
    
    String sql = "UPDATE exam_register " +
                 "SET end_time = ? " +
                 "WHERE student_id = ? " +
                 "  AND exam_id = ? " +
                 "  AND exam_date = CURDATE() " +
                 "  AND end_time IS NULL " +
                 "  AND start_time IS NOT NULL";
    
    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setString(1, endTime.trim());
        ps.setInt(2, studentId);
        ps.setInt(3, examId);
        
        return ps.executeUpdate() > 0;
    }
}

// Removed getDeviceIdentifier method due to HttpServletRequest dependency
// This method was causing compilation errors

// Add a method to get the register for a specific exam
public ResultSet getExamRegister(int examId) throws SQLException {
    try {
        ensureConnection();
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Connection error in getExamRegister", e);
        throw e;
    }
    
    String sql = "SELECT er.*, u.first_name, u.last_name, u.email, u.contact_no " +
                 "FROM exam_register er " +
                 "JOIN users u ON er.student_id = u.user_id " +
                 "WHERE er.exam_id = ? " +
                 "ORDER BY er.start_time DESC";
    
    PreparedStatement ps = conn.prepareStatement(sql);
    ps.setInt(1, examId);
    return ps.executeQuery();
}

public boolean registerExamCompletion(int studentId, int examId, LocalTime endTime) 
    throws SQLException {
    
    try {
        ensureConnection();
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Connection error in registerExamCompletion (LocalTime)", e);
        return false;
    }
    
    // Validate inputs
    if (studentId <= 0) {
        throw new IllegalArgumentException("Invalid student ID");
    }
    if (examId <= 0) {
        throw new IllegalArgumentException("Invalid exam ID");
    }
    if (endTime == null) {
        throw new IllegalArgumentException("End time cannot be null");
    }
    
    // Regular string concatenation for Java 8
    String sql = "UPDATE exam_register " +
                 "SET end_time = ? " +
                 "WHERE student_id = ? " +
                 "  AND exam_id = ? " +
                 "  AND exam_date = CURDATE() " +
                 "  AND end_time IS NULL " +
                 "  AND start_time IS NOT NULL";
    
    try (PreparedStatement ps = conn.prepareStatement(sql)) {
        ps.setString(1, endTime.toString());
        ps.setString(2, endTime.toString()); // For duration calculation
        ps.setInt(3, studentId);
        ps.setInt(4, examId);
        
        int updated = ps.executeUpdate();
        
        if (updated == 0) {
            // Log the issue but don't throw - this might be intentional (already completed)
            LOGGER.warning("No active exam session found for student " + studentId 
                + " and exam " + examId + " today. Might already be completed.");
            return false;
        }
        
        return true;
    }
}

/* Add this method in your DatabaseClass */

public String getLastCourseName() {
    try {
        ensureConnection();
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Connection error in getLastCourseName", e);
        return null;
    }
    
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

// Add to DatabaseClass.java

// Get filtered exam register
// Get filtered exam register - IMPROVED VERSION
// UPDATED: Get filtered exam register with all new filters
public ResultSet getFilteredExamRegister(int examId, int studentId, String firstName, 
                                         String lastName, String courseName, String examDate) throws SQLException {
    try {
        ensureConnection();
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Connection error in getFilteredExamRegister", e);
        throw e;
    }
    
    StringBuilder sql = new StringBuilder();
    sql.append("SELECT ");
    sql.append("    er.register_id, ");
    sql.append("    er.student_id, ");
    sql.append("    er.exam_id, ");
    sql.append("    er.course_name, ");
    sql.append("    er.exam_date, ");
    sql.append("    er.start_time, ");
    sql.append("    er.end_time, ");
    sql.append("    u.first_name, ");
    sql.append("    u.last_name, ");
    sql.append("    u.email ");
    sql.append("FROM exam_register er ");
    sql.append("LEFT JOIN users u ON er.student_id = u.user_id ");
    sql.append("WHERE 1=1 ");
    
    ArrayList<Object> params = new ArrayList<>();
    
    if (examId > 0) {
        sql.append("AND er.exam_id = ? ");
        params.add(examId);
    }
    
    if (studentId > 0) {
        sql.append("AND er.student_id = ? ");
        params.add(studentId);
    }
    
    if (firstName != null && !firstName.trim().isEmpty()) {
        sql.append("AND LOWER(u.first_name) LIKE ? ");
        params.add("%" + firstName.trim().toLowerCase() + "%");
    }
    
    if (lastName != null && !lastName.trim().isEmpty()) {
        sql.append("AND LOWER(u.last_name) LIKE ? ");
        params.add("%" + lastName.trim().toLowerCase() + "%");
    }
    
    if (courseName != null && !courseName.trim().isEmpty()) {
        sql.append("AND er.course_name = ? ");
        params.add(courseName.trim());
    }
    
    if (examDate != null && !examDate.trim().isEmpty()) {
        sql.append("AND er.exam_date = ? ");
        params.add(java.sql.Date.valueOf(examDate));
    }
    
    sql.append("ORDER BY er.exam_date DESC, er.start_time DESC");
    
    PreparedStatement ps = conn.prepareStatement(sql.toString(), 
        ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
    
    for (int i = 0; i < params.size(); i++) {
        ps.setObject(i + 1, params.get(i));
    }
    
    return ps.executeQuery();
}

// Get all exam register
public ResultSet getAllExamRegister() throws SQLException {
    try {
        ensureConnection();
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Connection error in getAllExamRegister", e);
        throw e;
    }
    
    String sql = "SELECT er.*, u.first_name, u.last_name, u.email, u.contact_no " +
                 "FROM exam_register er " +
                 "JOIN users u ON er.student_id = u.user_id " +
                 "ORDER BY er.exam_date DESC, er.start_time DESC";
    
    PreparedStatement ps = conn.prepareStatement(sql, 
        ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_READ_ONLY);
    
    return ps.executeQuery();
}

// Get exam register statistics
public ResultSet getExamRegisterStatistics(int examId, String courseName, String examDate) throws SQLException {
    try {
        ensureConnection();
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Connection error in getExamRegisterStatistics", e);
        throw e;
    }
    
    StringBuilder sql = new StringBuilder();
    sql.append("SELECT ");
    sql.append("    COUNT(*) as total_students, ");
    sql.append("    SUM(CASE WHEN end_time IS NOT NULL THEN 1 ELSE 0 END) as completed, ");
    sql.append("    SUM(CASE WHEN end_time IS NULL THEN 1 ELSE 0 END) as Incomplete, ");
    sql.append("    AVG(CASE WHEN duration_seconds > 0 THEN duration_seconds ELSE NULL END) as avg_duration ");
    sql.append("FROM exam_register er ");
    sql.append("WHERE 1=1 ");
    
    ArrayList<Object> params = new ArrayList<>();
    
    if (examId > 0) {
        sql.append("AND er.exam_id = ? ");
        params.add(examId);
    }
    
    if (courseName != null && !courseName.trim().isEmpty()) {
        sql.append("AND er.course_name = ? ");
        params.add(courseName.trim());
    }
    
    if (examDate != null && !examDate.trim().isEmpty()) {
        sql.append("AND er.exam_date = ? ");
        params.add(java.sql.Date.valueOf(examDate));
    }
    
    PreparedStatement ps = conn.prepareStatement(sql.toString());
    
    for (int i = 0; i < params.size(); i++) {
        ps.setObject(i + 1, params.get(i));
    }
    
    return ps.executeQuery();
}

// NEW METHOD: Get courses from exam register
public ArrayList<String> getExamRegisterCourses() {
    try {
        ensureConnection();
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Connection error in getExamRegisterCourses", e);
        return new ArrayList<>();
    }
    
    ArrayList<String> courses = new ArrayList<>();
    try {
        // Get DISTINCT courses from exam_register table
        String sql = "SELECT DISTINCT course_name FROM exam_register WHERE course_name IS NOT NULL AND course_name != '' ORDER BY course_name";
        PreparedStatement ps = conn.prepareStatement(sql);
        ResultSet rs = ps.executeQuery();
        
        while (rs.next()) {
            String courseName = rs.getString("course_name");
            if (courseName != null && !courseName.trim().isEmpty()) {
                courses.add(courseName.trim());
            }
        }
        
        rs.close();
        ps.close();
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return courses;
}


// Get course list for dropdown
public ArrayList<String> getCourseList() {
    try {
        ensureConnection();
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Connection error in getCourseList", e);
        return new ArrayList<>();
    }
    
    ArrayList<String> courses = new ArrayList<>();
    try {
        String sql = "SELECT DISTINCT course_name FROM courses WHERE course_status = 'Active' ORDER BY course_name";
        PreparedStatement ps = conn.prepareStatement(sql);
        ResultSet rs = ps.executeQuery();
        
        while (rs.next()) {
            String courseName = rs.getString("course_name");
            if (courseName != null && !courseName.trim().isEmpty()) {
                courses.add(courseName.trim());
            }
        }
        
        rs.close();
        ps.close();
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return courses;
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

    public boolean markAttendance(int studentId, String studentName) {
        try {
            ensureConnection();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Connection error in markAttendance", e);
            return false;
        }
        
        try {
            String sql = "INSERT INTO daily_register(student_id, student_name, registration_date, registration_time) VALUES (?, ?, CURDATE(), CURTIME())";
            PreparedStatement pstm = conn.prepareStatement(sql);
            pstm.setInt(1, studentId);
            pstm.setString(2, studentName);
            int rows = pstm.executeUpdate();
            pstm.close();
            return rows > 0;
        } catch (SQLException ex) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
            return false;
        }
    }
    
    public PreparedStatement getPreparedStatement(String sql) throws SQLException {
        try {
            ensureConnection();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Connection error in getPreparedStatement", e);
            throw e;
        }
        
        return conn.prepareStatement(sql);
    }

    public ArrayList<Map<String, String>> getAttendanceByStudentId(int studentId) {
        try {
            ensureConnection();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Connection error in getAttendanceByStudentId", e);
            return new ArrayList<>();
        }
        
        ArrayList<Map<String, String>> attendanceList = new ArrayList<>();
        try {
            String sql = "SELECT * FROM daily_register WHERE student_id = ? ORDER BY registration_date DESC, registration_time DESC";
            PreparedStatement pstm = conn.prepareStatement(sql);
            pstm.setInt(1, studentId);
            ResultSet rs = pstm.executeQuery();
            while (rs.next()) {
                Map<String, String> attendance = new HashMap<>();
                attendance.put("register_id", rs.getString("register_id"));
                attendance.put("student_id", rs.getString("student_id"));
                attendance.put("student_name", rs.getString("student_name"));
                attendance.put("registration_date", rs.getString("registration_date"));
                attendance.put("registration_time", rs.getString("registration_time"));
                attendanceList.add(attendance);
            }
            rs.close();
            pstm.close();
        } catch (SQLException ex) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
        }
        return attendanceList;
    }

    public ArrayList<Map<String, String>> getFilteredDailyRegister(String studentNameFilter, String dateFilter) {
        try {
            ensureConnection();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Connection error in getFilteredDailyRegister", e);
            return new ArrayList<>();
        }
        
        ArrayList<Map<String, String>> registerList = new ArrayList<>();
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            StringBuilder query = new StringBuilder("SELECT * FROM daily_register WHERE 1=1 ");
            ArrayList<Object> params = new ArrayList<>();

            if (studentNameFilter != null && !studentNameFilter.trim().isEmpty()) {
                query.append("AND student_name LIKE ? ");
                params.add("%" + studentNameFilter.trim() + "%");
            }

            if (dateFilter != null && !dateFilter.trim().isEmpty()) {
                query.append("AND registration_date = ? ");
                params.add(java.sql.Date.valueOf(dateFilter));
            }

            query.append("ORDER BY registration_date DESC, registration_time DESC");

            pstmt = conn.prepareStatement(query.toString());

            for (int i = 0; i < params.size(); i++) {
                pstmt.setObject(i + 1, params.get(i));
            }

            rs = pstmt.executeQuery();

            while (rs.next()) {
                Map<String, String> record = new HashMap<>();
                record.put("register_id", rs.getString("register_id"));
                record.put("student_id", rs.getString("student_id"));
                record.put("student_name", rs.getString("student_name"));
                record.put("registration_date", rs.getString("registration_date"));
                record.put("registration_time", rs.getString("registration_time"));
                registerList.add(record);
            }

        } catch (SQLException ex) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, "Error in getFilteredDailyRegister", ex);
        } finally {
            closeResources(pstmt, rs);
        }

        return registerList;
    }
    
    public void deleteExamRegisterRecords(String[] registerIds) {
        try {
            ensureConnection();
            conn.setAutoCommit(false);
            String deleteSql = "DELETE FROM exam_register WHERE register_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(deleteSql)) {
                for (String registerId : registerIds) {
                    ps.setInt(1, Integer.parseInt(registerId));
                    ps.addBatch();
                }
                ps.executeBatch();
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                LOGGER.log(Level.SEVERE, "Error bulk deleting exam register records", e);
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Connection error in deleteExamRegisterRecords", e);
        }
    }

    public void deleteDailyRegisterRecords(String[] registerIds) {
        try {
            ensureConnection();
            conn.setAutoCommit(false);
            String deleteSql = "DELETE FROM daily_register WHERE register_id = ?";
            try (PreparedStatement ps = conn.prepareStatement(deleteSql)) {
                for (String registerId : registerIds) {
                    ps.setInt(1, Integer.parseInt(registerId));
                    ps.addBatch();
                }
                ps.executeBatch();
                conn.commit();
            } catch (SQLException e) {
                conn.rollback();
                LOGGER.log(Level.SEVERE, "Error bulk deleting daily register records", e);
            } finally {
                conn.setAutoCommit(true);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Connection error in deleteDailyRegisterRecords", e);
        }
    }

    public int getDaysLateCount(int studentId) {
        int lateDays = 0;
        try {
            ensureConnection();
            String sql = "SELECT COUNT(*) FROM daily_register WHERE student_id = ? AND registration_time > '10:00:00'";
            PreparedStatement pstm = conn.prepareStatement(sql);
            pstm.setInt(1, studentId);
            ResultSet rs = pstm.executeQuery();
            if (rs.next()) {
                lateDays = rs.getInt(1);
            }
            rs.close();
            pstm.close();
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error in getDaysLateCount", ex);
        }
        return lateDays;
    }

    public int getDaysPresentCount(int studentId) {
    int presentDays = 0;
    try {
        ensureConnection();
        String sql = "SELECT COUNT(*) FROM daily_register WHERE student_id = ?";
        PreparedStatement pstm = conn.prepareStatement(sql);
        pstm.setInt(1, studentId);
        ResultSet rs = pstm.executeQuery();
        if (rs.next()) {
            presentDays = rs.getInt(1);
        }
        rs.close();
        pstm.close();
    } catch (SQLException ex) {
        LOGGER.log(Level.SEVERE, "Error in getDaysPresentCount", ex);
    }
    return presentDays;
}

    public int getDaysAbsentCount(int studentId) {
        int absentDays = 0;
        try {
            ensureConnection();
            String firstDateSql = "SELECT MIN(registration_date) as first_date FROM daily_register WHERE student_id = ?";
            PreparedStatement pstm = conn.prepareStatement(firstDateSql);
            pstm.setInt(1, studentId);
            ResultSet rs = pstm.executeQuery();

            if (rs.next()) {
                java.sql.Date firstDate = rs.getDate("first_date");

                if (firstDate != null) {
                    LocalDate startDate = firstDate.toLocalDate();
                    LocalDate endDate = startDate.plusMonths(3);

                    String presentDaysSql = "SELECT COUNT(*) as present_days FROM daily_register WHERE student_id = ? AND registration_date >= ? AND registration_date < ?";
                    PreparedStatement pstm2 = conn.prepareStatement(presentDaysSql);
                    pstm2.setInt(1, studentId);
                    pstm2.setDate(2, java.sql.Date.valueOf(startDate));
                    pstm2.setDate(3, java.sql.Date.valueOf(endDate));
                    ResultSet rs2 = pstm2.executeQuery();

                    int presentDays = 0;
                    if (rs2.next()) {
                        presentDays = rs2.getInt("present_days");
                    }

                    long weekdays = 0;
                    for (LocalDate date = startDate; date.isBefore(endDate); date = date.plusDays(1)) {
                        if (date.getDayOfWeek() != DayOfWeek.SATURDAY && date.getDayOfWeek() != DayOfWeek.SUNDAY) {
                            weekdays++;
                        }
                    }
                    absentDays = (int) weekdays - presentDays;
                    rs2.close();
                    pstm2.close();
                }
            }
            rs.close();
            pstm.close();
        } catch (SQLException ex) {
            LOGGER.log(Level.SEVERE, "Error in getDaysAbsentCount", ex);
        }
        return absentDays < 0 ? 0 : absentDays;
    }
    

 public String getAttendanceCalendarData(int studentId) {
    Connection conn = null;
    PreparedStatement pstm = null;
    ResultSet rs = null;
    
    StringBuilder json = new StringBuilder("[");
    try {
        conn = getConnection(); // Use getConnection() instead of ensureConnection()
        
        // 1. Define the 3-month period based on the current date
        LocalDate today = LocalDate.now();
        LocalDate startDate = today.minusMonths(2).withDayOfMonth(1);
        LocalDate endDate = today.plusMonths(1).withDayOfMonth(today.plusMonths(1).lengthOfMonth());
        
        LOGGER.log(Level.FINE, "Calendar Period: {0} to {1}", new Object[]{startDate, endDate});

        // 2. Fetch all attendance records within this 3-month period
        String attendanceSql = "SELECT DATE(registration_date) as reg_date, TIME(registration_time) as reg_time " +
                              "FROM daily_register WHERE student_id = ? " +
                              "AND DATE(registration_date) BETWEEN ? AND ? " +
                              "ORDER BY registration_date";
        
        pstm = conn.prepareStatement(attendanceSql);
        pstm.setInt(1, studentId);
        pstm.setDate(2, java.sql.Date.valueOf(startDate));
        pstm.setDate(3, java.sql.Date.valueOf(endDate));
        
        rs = pstm.executeQuery();

        Map<LocalDate, LocalTime> attendanceMap = new HashMap<>();
        while (rs.next()) {
            try {
                Date sqlDate = rs.getDate("reg_date");
                Time sqlTime = rs.getTime("reg_time");
                
                if (sqlDate != null && sqlTime != null) {
                    attendanceMap.put(
                        sqlDate.toLocalDate(),
                        sqlTime.toLocalTime()
                    );
                }
            } catch (Exception e) {
                LOGGER.log(Level.WARNING, "Error processing record: " + e.getMessage(), e);
            }
        }
        
        LOGGER.log(Level.FINE, "Found {0} attendance records", attendanceMap.size());

        // 3. Generate JSON for each day in the 3-month period
        boolean first = true;
        LocalDate currentDate = startDate;
        
        while (!currentDate.isAfter(endDate)) {
            if (!first) {
                json.append(",");
            }
            first = false;

            String eventClass = "future"; // Default for future dates
            
            // Check if date is in the past or today
            if (currentDate.isBefore(today) || currentDate.isEqual(today)) {
                // Check if attendance was recorded
                if (attendanceMap.containsKey(currentDate)) {
                    LocalTime time = attendanceMap.get(currentDate);
                    if (time.isAfter(LocalTime.of(10, 0))) {
                        eventClass = "late";
                    } else {
                        eventClass = "present";
                    }
                } else {
                    // No attendance recorded
                    if (currentDate.getDayOfWeek() != DayOfWeek.SATURDAY && 
                        currentDate.getDayOfWeek() != DayOfWeek.SUNDAY) {
                        // Weekday with no attendance = absent
                        eventClass = "absent";
                    } else {
                        // Weekend
                        eventClass = "weekend";
                    }
                }
            } else if (currentDate.getDayOfWeek() == DayOfWeek.SATURDAY || 
                      currentDate.getDayOfWeek() == DayOfWeek.SUNDAY) {
                // Future weekend
                eventClass = "weekend";
            }

            // Format the date properly
            String dateStr = currentDate.toString();
            
            json.append("{")
                .append("\"date\":\"").append(dateStr).append("\",")
                .append("\"class\":\"").append(eventClass).append("\"")
                .append("}");
            
            // Debug output for first few days
            if (currentDate.getDayOfMonth() <= 3) {
                LOGGER.log(Level.FINE, "Day {0}: {1}", new Object[]{dateStr, eventClass});
            }
            
            currentDate = currentDate.plusDays(1);
        }

    } catch (SQLException ex) {
        LOGGER.log(Level.SEVERE, "Error in getAttendanceCalendarData", ex);
        return "[]"; 
    } catch (Exception ex) {
        LOGGER.log(Level.SEVERE, "Unexpected error in getAttendanceCalendarData", ex);
        return "[]";
    } finally {
        // Close all resources properly
        try { if (rs != null) rs.close(); } catch (SQLException e) {}
        try { if (pstm != null) pstm.close(); } catch (SQLException e) {}
    }
    
    json.append("]");
    
    String result = json.toString();
    // System.out.println("Generated JSON length: " + result.length()); // Debug
    // System.out.println("First 200 chars of JSON: " + result.substring(0, Math.min(result.length(), 200))); // Debug
    
    return result;
}

 
  // In DatabaseClass
public boolean checkUsernameExists(String username) {
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    try {
        conn = getConnection();
        // FIXED: Only check user_name column (with underscore)
        String sql = "SELECT COUNT(*) FROM users WHERE user_name = ?";
        ps = conn.prepareStatement(sql);
        ps.setString(1, username);
        rs = ps.executeQuery();
        if (rs.next()) {
            return rs.getInt(1) > 0;
        }
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Error checking username existence", e);
    } finally {
        try {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error closing resources", e);
        }
    }
    return false;
}

public boolean checkEmailExists(String email) {
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    try {
        conn = getConnection();
        String sql = "SELECT COUNT(*) FROM users WHERE email = ?";
        ps = conn.prepareStatement(sql);
        ps.setString(1, email);
        rs = ps.executeQuery();
        if (rs.next()) {
            return rs.getInt(1) > 0;
        }
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Error checking email existence", e);
    } finally {
        try {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error closing resources", e);
        }
    }
    return false;
}

public boolean checkContactNoExists(String contactNo) {
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    try {
        conn = getConnection();
        String sql = "SELECT COUNT(*) FROM users WHERE contact_no = ?";
        ps = conn.prepareStatement(sql);
        ps.setString(1, contactNo);
        rs = ps.executeQuery();
        if (rs.next()) {
            return rs.getInt(1) > 0;
        }
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Error checking contact number existence", e);
    } finally {
        try {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error closing resources", e);
        }
    }
    return false;
}

public boolean checkStaffEmailExists(String email) {
    Connection conn = null;
    PreparedStatement ps = null;
    ResultSet rs = null;
    
    try {
        conn = getConnection();
        String sql = "SELECT COUNT(*) FROM staff WHERE email = ?";
        ps = conn.prepareStatement(sql);
        ps.setString(1, email);
        rs = ps.executeQuery();
        if (rs.next()) {
            return rs.getInt(1) > 0;
        }
    } catch (SQLException e) {
        LOGGER.log(Level.SEVERE, "Error checking staff email existence", e);
    } finally {
        try {
            if (rs != null) rs.close();
            if (ps != null) ps.close();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error closing resources", e);
        }
    }
    return false;
}

 public boolean checkUserExists(String username) {
        try {
            ensureConnection();
            String sql = "SELECT COUNT(*) FROM users WHERE username = ?";
            try (PreparedStatement ps = conn.prepareStatement(sql)) {
                ps.setString(1, username);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    return rs.getInt(1) > 0;
                }
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error checking user existence", e);
        }
        return false;
    }

    // ==================== FORGOT PASSWORD METHODS ====================
    
    /**
     * Stores a verification code for password reset in the verification_codes table.
     * @param email The user's email address
     * @param code The 8-character verification code
     * @param userType The type of user (student, lecture, admin)
     * @return true if code was stored successfully, false otherwise
     */
    public boolean storeVerificationCode(String email, String code, String userType) {
        Connection conn = null;
        PreparedStatement ps = null;
        
        try {
            conn = getConnection();
            
            // First, delete any existing codes for this email
            String deleteSql = "DELETE FROM verification_codes WHERE email = ?";
            try (PreparedStatement deletePs = conn.prepareStatement(deleteSql)) {
                deletePs.setString(1, email);
                deletePs.executeUpdate();
            }
            
            // Insert new verification code
            String sql = "INSERT INTO verification_codes (email, code, user_type) VALUES (?, ?, ?)";
            ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            ps.setString(2, code);
            ps.setString(3, userType);
            
            int rowsAffected = ps.executeUpdate();
            return rowsAffected > 0;
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error storing verification code for: " + email, e);
            return false;
        } finally {
            try {
                if (ps != null) ps.close();
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "Error closing resources", e);
            }
        }
    }
    
    /**
     * Verifies if the provided code matches the stored code for the email.
     * Also checks if the code has not expired (within 1 hour).
     * @param email The user's email address
     * @param code The verification code to verify
     * @return true if code is valid and not expired, false otherwise
     */
    public boolean verifyResetCode(String email, String code) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            
            // Check if code exists and is not expired (within 1 hour)
            String sql = "SELECT code, created_at FROM verification_codes " +
                        "WHERE email = ? AND code = ? " +
                        "AND created_at >= DATE_SUB(NOW(), INTERVAL 1 HOUR)";
            
            ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            ps.setString(2, code.toUpperCase());
            
            rs = ps.executeQuery();
            return rs.next(); // Returns true if a valid, non-expired code was found
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error verifying reset code for: " + email, e);
            return false;
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "Error closing resources", e);
            }
        }
    }
    
    /**
     * Updates the user's password after successful verification.
     * @param email The user's email address
     * @param newPassword The new hashed password
     * @param code The verification code (for additional security check)
     * @return true if password was updated successfully, false otherwise
     */
    public boolean updatePasswordByEmail(String email, String newPassword, String code) {
        Connection conn = null;
        PreparedStatement psVerify = null;
        PreparedStatement psUpdate = null;
        PreparedStatement psDelete = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            conn.setAutoCommit(false); // Start transaction
            
            // 1. Verify the code one more time
            String verifySql = "SELECT id FROM verification_codes " +
                              "WHERE email = ? AND code = ? " +
                              "AND created_at >= DATE_SUB(NOW(), INTERVAL 1 HOUR)";
            psVerify = conn.prepareStatement(verifySql);
            psVerify.setString(1, email);
            psVerify.setString(2, code.toUpperCase());
            rs = psVerify.executeQuery();
            
            if (!rs.next()) {
                conn.rollback();
                LOGGER.warning("Invalid or expired code for password reset: " + email);
                return false;
            }
            
            // 2. Update the password in users table
            String updateSql = "UPDATE users SET password = ? WHERE email = ?";
            psUpdate = conn.prepareStatement(updateSql);
            psUpdate.setString(1, newPassword);
            psUpdate.setString(2, email);
            
            int rowsUpdated = psUpdate.executeUpdate();
            
            if (rowsUpdated == 0) {
                conn.rollback();
                LOGGER.warning("No user found with email: " + email);
                return false;
            }
            
            // 3. Delete the used verification code
            String deleteSql = "DELETE FROM verification_codes WHERE email = ?";
            psDelete = conn.prepareStatement(deleteSql);
            psDelete.setString(1, email);
            psDelete.executeUpdate();
            
            // 4. Commit transaction
            conn.commit();
            LOGGER.info("Password reset successful for: " + email);
            return true;
            
        } catch (SQLException e) {
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {
                LOGGER.log(Level.SEVERE, "Error rolling back transaction", ex);
            }
            LOGGER.log(Level.SEVERE, "Error updating password for: " + email, e);
            return false;
        } finally {
            try {
                if (rs != null) rs.close();
                if (psVerify != null) psVerify.close();
                if (psUpdate != null) psUpdate.close();
                if (psDelete != null) psDelete.close();
                if (conn != null) {
                    conn.setAutoCommit(true); // Reset auto-commit
                }
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "Error closing resources", e);
            }
        }
    }
    
    /**
     * Gets the user type for a given email address.
     * Used to determine user type when sending verification codes.
     * @param email The user's email address
     * @return The user type (student, lecture, admin) or null if not found
     */
    public String getUserTypeByEmail(String email) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            String sql = "SELECT user_type FROM users WHERE email = ?";
            ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                return rs.getString("user_type");
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting user type for email: " + email, e);
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "Error closing resources", e);
            }
        }
        return null;
    }
    
    /**
     * Gets the first name of a user by email for personalized emails.
     * @param email The user's email address
     * @return The user's first name or "User" if not found
     */
    public String getFirstNameByEmail(String email) {
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            String sql = "SELECT first_name FROM users WHERE email = ?";
            ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            rs = ps.executeQuery();
            
            if (rs.next()) {
                String firstName = rs.getString("first_name");
                return (firstName != null && !firstName.isEmpty()) ? firstName : "User";
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting first name for email: " + email, e);
        } finally {
            try {
                if (rs != null) rs.close();
                if (ps != null) ps.close();
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "Error closing resources", e);
            }
        }
        return "User";
    }
    
    /**
     * Deletes a verification code from the database after it has been successfully used.
     * This prevents code reuse and maintains database cleanliness.
     * @param email The email address associated with the code
     * @param code The verification code to delete
     * @return true if deletion was successful, false otherwise
     */
    public boolean deleteVerificationCode(String email, String code) {
        Connection conn = null;
        PreparedStatement ps = null;
        
        try {
            conn = getConnection();
            String sql = "DELETE FROM verification_codes WHERE email = ? AND code = ?";
            ps = conn.prepareStatement(sql);
            ps.setString(1, email);
            ps.setString(2, code);
            
            int rowsAffected = ps.executeUpdate();
            
            if (rowsAffected > 0) {
                LOGGER.info("Verification code deleted for email: " + email);
                return true;
            } else {
                LOGGER.warning("No verification code found to delete for email: " + email);
                return false;
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error deleting verification code for: " + email, e);
            return false;
        } finally {
            try {
                if (ps != null) ps.close();
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "Error closing resources", e);
            }
        }
    }
 

public boolean addNewUser(String fName, String lName, String uName, String email, String pass,
                       String contact, String city, String address, String userTypeParam) {
    try {
        // Call your existing void method
        this.addNewUserVoid(fName, lName, uName, email, pass, contact, city, address, userTypeParam);
        return true; // Success if no exception
    } catch (RuntimeException e) {
        // Log the error
        LOGGER.log(Level.SEVERE, "Error in addNewUser", e);
        return false; // Failure
    }
}


    /**
     * Get the total count of questions in the system
     * @return total number of questions
     **/
    public int getTotalQuestionsCount() {
        try {
            ensureConnection();
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Connection error in getTotalQuestionsCount", e);
            return 0;
        }
        
        int totalQuestions = 0;
        try {
            String sql = "SELECT COUNT(*) as total FROM questions";
            PreparedStatement pstmt = conn.prepareStatement(sql);
            ResultSet rs = pstmt.executeQuery();
            
            if (rs.next()) {
                totalQuestions = rs.getInt("total");
            }
            
            rs.close();
            pstmt.close();
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return totalQuestions;
    }

// Keep your original method but rename it
public void addNewUserVoid(String fName, String lName, String uName, String email, String pass,
                       String contact, String city, String address, String userTypeParam) {
    Connection localConn = null;
    PreparedStatement pstmUsers = null;
    PreparedStatement pstmInsert = null;
    ResultSet rsUserId = null;
    
    try {
        // Get a fresh connection
        localConn = getConnection();
        localConn.setAutoCommit(false);
        
        // FIRST: Check if email already exists in users table
        String checkSql = "SELECT COUNT(*) as count FROM users WHERE email = ?";
        try (PreparedStatement checkStmt = localConn.prepareStatement(checkSql)) {
            checkStmt.setString(1, email);
            try (ResultSet rs = checkStmt.executeQuery()) {
                if (rs.next() && rs.getInt("count") > 0) {
                    LOGGER.warning("User email already exists: " + email);
                    throw new RuntimeException("Email already registered: " + email);
                }
            }
        }
        
        // SECOND: Check if username already exists
        checkSql = "SELECT COUNT(*) as count FROM users WHERE user_name = ?";
        try (PreparedStatement checkStmt = localConn.prepareStatement(checkSql)) {
            checkStmt.setString(1, uName);
            try (ResultSet rs = checkStmt.executeQuery()) {
                if (rs.next() && rs.getInt("count") > 0) {
                    LOGGER.warning("Username already exists: " + uName);
                    throw new RuntimeException("Username already exists: " + uName);
                }
            }
        }
        
        // THIRD: Determine user type and check authorization
        String userType = "student";
        if (userTypeParam != null && !userTypeParam.isEmpty()) {
            userType = userTypeParam.toLowerCase();
        }
        
        String courseName = "";
        if ("lecture".equals(userType) || "admin".equals(userType)) {
            // Check if email exists in staff table for authorization
            checkSql = "SELECT staffNum, fullNames, course_name FROM staff WHERE email = ?";
            try (PreparedStatement checkStmt = localConn.prepareStatement(checkSql)) {
                checkStmt.setString(1, email);
                try (ResultSet rs = checkStmt.executeQuery()) {
                    if (!rs.next()) {
                        LOGGER.warning("Unauthorized " + userType + " registration attempt for email: " + email);
                        throw new RuntimeException("Unauthorized registration: Email not in staff table");
                    }
                    // Get course name for lecturers
                    if ("lecture".equals(userType)) {
                        courseName = rs.getString("course_name");
                        if (courseName == null) {
                            courseName = "";
                        }
                    }
                }
            }
        }
        
        // Insert into users table
        String sqlUsers = "INSERT INTO users (first_name, last_name, user_name, email, password, user_type, contact_no, city, address) " +
                          "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        pstmUsers = localConn.prepareStatement(sqlUsers, Statement.RETURN_GENERATED_KEYS);
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

        // Get the generated user_id
        rsUserId = pstmUsers.getGeneratedKeys();
        if (!rsUserId.next()) {
            throw new SQLException("Failed to retrieve generated user_id for " + email);
        }
        int userId = rsUserId.getInt(1);

        // Insert into appropriate table based on user type
        if ("student".equals(userType)) {
            String sqlInsert = "INSERT INTO students (user_id, first_name, last_name, user_name, email, password, user_type, contact_no, city, address) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            pstmInsert = localConn.prepareStatement(sqlInsert);
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
            pstmInsert.executeUpdate();
            
        } else if ("lecture".equals(userType)) {
            // Insert into lectures table with course name
            String sqlInsert = "INSERT INTO lectures (user_id, first_name, last_name, user_name, email, password, user_type, contact_no, city, address, course_name) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            pstmInsert = localConn.prepareStatement(sqlInsert);
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
            pstmInsert.setString(11, courseName);
            pstmInsert.executeUpdate();
            
        } else if ("admin".equals(userType)) {
            // Check if admin table exists, otherwise skip
            try {
                String sqlInsert = "INSERT INTO admin (user_id, first_name, last_name, user_name, email, password, user_type, contact_no, city, address) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
                pstmInsert = localConn.prepareStatement(sqlInsert);
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
                pstmInsert.executeUpdate();
            } catch (SQLException e) {
                // If admin table doesn't exist, just log it and continue
                LOGGER.info("Admin table doesn't exist or user already inserted, skipping admin table insert");
            }
        }

        localConn.commit();
        LOGGER.info("User registered successfully: " + email + " (" + userType + ") with ID: " + userId);
        
    } catch (SQLException | RuntimeException ex) {
        try {
            if (localConn != null) {
                localConn.rollback();
            }
        } catch (SQLException rollbackEx) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, "Rollback failed", rollbackEx);
        }
        
        if (ex instanceof RuntimeException) {
            throw (RuntimeException) ex;
        } else {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, "Error in addNewUserVoid", ex);
            throw new RuntimeException("Registration failed: " + ex.getMessage(), ex);
        }
    } finally {
        // Close resources properly
        try {
            if (rsUserId != null) rsUserId.close();
            if (pstmUsers != null) pstmUsers.close();
            if (pstmInsert != null) pstmInsert.close();
            if (localConn != null) {
                localConn.setAutoCommit(true);
                localConn.close(); // Close the local connection
            }
        } catch (SQLException e) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, "Error closing resources", e);
        }
    }
    }
    
    // ==================== DRAG AND DROP QUESTION METHODS ====================
    
    /**
     * Creates a new drag-and-drop question with its items and targets
     */
    public int createDragDropQuestion(String questionText, String courseName, int totalMarks, 
                                   ArrayList<DragItem> dragItems, ArrayList<DropTarget> dropTargets) {
        Connection conn = null;
        PreparedStatement pstmQuestion = null;
        PreparedStatement pstmDragItem = null;
        PreparedStatement pstmDropTarget = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            
            // Insert the question
            String sqlQuestion = "INSERT INTO questions (question, course_name, question_type, total_marks, opt1, opt2, opt3, opt4, correct) VALUES (?, ?, 'DRAG_AND_DROP', ?, '', '', '', '', '')";
            pstmQuestion = conn.prepareStatement(sqlQuestion, Statement.RETURN_GENERATED_KEYS);
            pstmQuestion.setString(1, questionText);
            pstmQuestion.setString(2, courseName);
            pstmQuestion.setInt(3, totalMarks);
            pstmQuestion.executeUpdate();
            
            // Get the generated question ID
            int questionId = 0;
            rs = pstmQuestion.getGeneratedKeys();
            if (rs.next()) {
                questionId = rs.getInt(1);
            }
            
            // Insert drag items
            String sqlDragItem = "INSERT INTO drag_items (question_id, item_text, correct_target_id, item_order) VALUES (?, ?, ?, ?)";
            pstmDragItem = conn.prepareStatement(sqlDragItem);
            
            for (DragItem item : dragItems) {
                pstmDragItem.setInt(1, questionId);
                pstmDragItem.setString(2, item.getItemText());
                if (item.getCorrectTargetId() != null) {
                    pstmDragItem.setInt(3, item.getCorrectTargetId());
                } else {
                    pstmDragItem.setNull(3, Types.INTEGER);
                }
                pstmDragItem.setInt(4, item.getItemOrder());
                pstmDragItem.addBatch();
            }
            pstmDragItem.executeBatch();
            
            // Insert drop targets
            String sqlDropTarget = "INSERT INTO drop_targets (question_id, target_label, target_order) VALUES (?, ?, ?)";
            pstmDropTarget = conn.prepareStatement(sqlDropTarget);
            
            for (DropTarget target : dropTargets) {
                pstmDropTarget.setInt(1, questionId);
                pstmDropTarget.setString(2, target.getTargetLabel());
                pstmDropTarget.setInt(3, target.getTargetOrder());
                pstmDropTarget.addBatch();
            }
            pstmDropTarget.executeBatch();
            
            conn.commit();
            LOGGER.info("Drag-drop question created successfully with ID: " + questionId);
            return questionId;
            
        } catch (SQLException e) {
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException rollbackEx) {
                LOGGER.log(Level.SEVERE, "Rollback failed", rollbackEx);
            }
            LOGGER.log(Level.SEVERE, "Error creating drag-drop question", e);
            throw new RuntimeException("Failed to create drag-drop question: " + e.getMessage(), e);
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmQuestion != null) pstmQuestion.close();
                if (pstmDragItem != null) pstmDragItem.close();
                if (pstmDropTarget != null) pstmDropTarget.close();
                if (conn != null) {
                    conn.setAutoCommit(true);
                }
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "Error closing resources", e);
            }
        }
    }
    
    /**
     * Gets a complete drag-drop question with all items and targets
     */
    public Questions getDragDropQuestionById(int questionId) {
        Questions question = getQuestionById(questionId);
        if (question != null && ("DRAG_AND_DROP".equals(question.getQuestionType()) || "RE_ARRANGE".equals(question.getQuestionType()))) {
            question.setDragItems(getDragItemsByQuestionIdOld(questionId));
            question.setDropTargets(getDropTargetsByQuestionIdOld(questionId));
        }
        return question;
    }
    
    /**
     * Adds a rearrange question to the database
     */
    public int addRearrangeQuestion(String courseName, String question, String imagePath, 
                                ArrayList<String> items, ArrayList<Integer> correctOrder, int marks) {
        int questionId = -1;
        try {
            // Insert into questions table
            String sql = "INSERT INTO questions (question, opt1, opt2, opt3, opt4, correct, course_name, question_type, image_path, marks) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            pstmt.setString(1, question);
            pstmt.setString(2, ""); // opt1 - empty for rearrange
            pstmt.setString(3, ""); // opt2 - empty for rearrange
            pstmt.setString(4, ""); // opt3 - empty for rearrange
            pstmt.setString(5, ""); // opt4 - empty for rearrange
            pstmt.setString(6, ""); // correct - empty for rearrange
            pstmt.setString(7, courseName);
            pstmt.setString(8, "REARRANGE");
            pstmt.setString(9, imagePath);
            pstmt.setInt(10, marks);
            pstmt.executeUpdate();
            
            ResultSet rs = pstmt.getGeneratedKeys();
            if (rs.next()) {
                questionId = rs.getInt(1);
            }
            
            // Insert rearrange items
            String itemSql = "INSERT INTO rearrange_items (question_id, item_text, correct_position) VALUES (?, ?, ?)";
            PreparedStatement itemStmt = conn.prepareStatement(itemSql);
            
            for (int i = 0; i < items.size(); i++) {
                itemStmt.setInt(1, questionId);
                itemStmt.setString(2, items.get(i));
                itemStmt.setInt(3, correctOrder.get(i));
                itemStmt.addBatch();
            }
            itemStmt.executeBatch();
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return questionId;
    }
    
    /**
     * Gets rearrange items for a question
     */
    public ArrayList<RearrangeItem> getRearrangeItems(int questionId) {
        ArrayList<RearrangeItem> items = new ArrayList<>();
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            // Order by correct_position to ensure items are returned in the intended sequence
            String sql = "SELECT * FROM rearrange_items WHERE question_id = ? ORDER BY correct_position ASC";
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, questionId);
            rs = pstmt.executeQuery();
            
            while (rs.next()) {
                RearrangeItem item = new RearrangeItem();
                item.setId(rs.getInt("id"));
                item.setItemText(rs.getString("item_text"));
                item.setCorrectPosition(rs.getInt("correct_position"));
                items.add(item);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting rearrange items", e);
        } finally {
            try { if (rs != null) rs.close(); } catch (SQLException e) {}
            try { if (pstmt != null) pstmt.close(); } catch (SQLException e) {}
        }
        return items;
    }

    public void addRearrangeData(int questionId, java.util.List<String> items) {
        PreparedStatement pstm = null;
        try {
            ensureConnection();
            String sql = "INSERT INTO rearrange_items (question_id, item_text, correct_position, item_order) VALUES (?, ?, ?, ?)";
            pstm = conn.prepareStatement(sql);
            for (int i = 0; i < items.size(); i++) {
                pstm.setInt(1, questionId);
                pstm.setString(2, items.get(i));
                pstm.setInt(3, i + 1); // 1-based position
                pstm.setInt(4, i + 1); // 1-based order
                pstm.addBatch();
            }
            pstm.executeBatch();
            LOGGER.log(Level.INFO, "Added {0} rearrange items for questionId={1}", new Object[]{items.size(), questionId});
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error adding rearrange data: " + e.getMessage(), e);
        } finally {
            try { if (pstm != null) pstm.close(); } catch (SQLException e) {}
        }
    }

    public void clearRearrangeData(int questionId) {
        PreparedStatement pstm = null;
        try {
            ensureConnection();
            String sql = "DELETE FROM rearrange_items WHERE question_id = ?";
            pstm = conn.prepareStatement(sql);
            pstm.setInt(1, questionId);
            int deleted = pstm.executeUpdate();
            LOGGER.log(Level.INFO, "Cleared rearrange items for questionId={0}, rows={1}", new Object[]{questionId, deleted});
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error clearing rearrange data for questionId=" + questionId + ": " + e.getMessage(), e);
        } finally {
            try { if (pstm != null) pstm.close(); } catch (SQLException e) {}
        }
    }

    public void updateRearrangeQuestionJson(int questionId, String itemsJson, Integer totalMarks) {
        PreparedStatement pstm = null;
        try {
            ensureConnection();
            // Store rearrange items in the drag_items column for consistency with other interactive types
            String sql = "UPDATE questions SET drag_items=?, marks=? WHERE question_id=?";
            pstm = conn.prepareStatement(sql);
            pstm.setString(1, itemsJson);
            if (totalMarks != null) {
                pstm.setBigDecimal(2, new BigDecimal(totalMarks));
            } else {
                // Default to number of items
                int count = 1;
                try {
                    org.json.JSONArray arr = new org.json.JSONArray(itemsJson);
                    count = Math.max(1, arr.length());
                } catch (Exception e) {}
                pstm.setBigDecimal(2, new BigDecimal(count));
            }
            pstm.setInt(3, questionId);
            pstm.executeUpdate();
            LOGGER.log(Level.INFO, "Updated rearrange question JSON for questionId={0}", questionId);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error updating rearrange question JSON", e);
        } finally {
            try { if (pstm != null) pstm.close(); } catch (SQLException e) {}
        }
    }
    
    /**
     * Gets a complete rearrange question with all items
     */
    public Questions getRearrangeQuestionById(int questionId) {
        Questions question = getQuestionById(questionId);
        if (question != null && "REARRANGE".equals(question.getQuestionType())) {
            question.setRearrangeItems(getRearrangeItems(questionId));
        }
        return question;
    }
    
    /**
     * Submits drag-drop answers and calculates marks
     * 1 mark per correct match, divided proportionally from total marks
     */
    public float submitDragDropAnswers(int examId, int questionId, String studentId, 
                                      Map<Integer, Integer> selectedMatches) {
        Connection conn = null;
        PreparedStatement pstmDelete = null;
        PreparedStatement pstmInsert = null;
        PreparedStatement pstmCheck = null;
        ResultSet rs = null;
        float totalMarks = 0;
        
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            
            // Get the question's total marks
            Questions question = getQuestionById(questionId);
            if (question == null) {
                throw new RuntimeException("Question not found: " + questionId);
            }
            
            // Get drag items to check correct answers
            ArrayList<DragItem> dragItems = getDragItemsByQuestionIdOld(questionId);
            if (dragItems == null || dragItems.isEmpty()) {
                throw new RuntimeException("No drag items found for question: " + questionId);
            }
            
            // Calculate marks per match (equal distribution based on correct mappings only)
            int correctMappingsCount = 0;
            
            // Try to get correct targets from question's JSON field as primary source
            java.util.Map<Integer, Integer> jsonCorrectTargets = new java.util.HashMap<>();
            String correctTargetsJson = question.getCorrectTargetsJson();
            LOGGER.info("Q" + questionId + ": JSON field value = '" + correctTargetsJson + "'");
            if (correctTargetsJson != null && !correctTargetsJson.isEmpty()) {
                try {
                    org.json.JSONObject jsonObj = new org.json.JSONObject(correctTargetsJson);
                    java.util.Iterator<String> keys = jsonObj.keys();
                    while (keys.hasNext()) {
                        String key = keys.next();
                        // Format: "target_X" : "item_Y" - need to extract IDs
                        if (key.startsWith("target_")) {
                            int targetId = Integer.parseInt(key.substring(7));
                            String value = jsonObj.getString(key);
                            if (value.startsWith("item_")) {
                                int itemId = Integer.parseInt(value.substring(5));
                                jsonCorrectTargets.put(itemId, targetId);
                                LOGGER.info("Q" + questionId + ": Parsed from JSON -> item " + itemId + " should go to target " + targetId);
                            }
                        }
                    }
                    LOGGER.info("Q" + questionId + ": Loaded " + jsonCorrectTargets.size() + " correct targets from JSON");
                } catch (Exception e) {
                    LOGGER.warning("Error parsing correct targets JSON for Q" + questionId + ": " + e.getMessage());
                }
            } else {
                LOGGER.warning("Q" + questionId + ": drag_correct_targets JSON field is empty or null!");
            }
            
            for (DragItem item : dragItems) {
                // Check both database column and JSON field
                if (item.getCorrectTargetId() != null && item.getCorrectTargetId() > 0) {
                    correctMappingsCount++;
                } else if (jsonCorrectTargets.containsKey(item.getId())) {
                    // Use JSON as fallback
                    correctMappingsCount++;
                }
            }

            float marksPerCorrectMatch = 0;
            if (correctMappingsCount > 0) {
                marksPerCorrectMatch = (float) question.getTotalMarks() / correctMappingsCount;
                LOGGER.info("Q" + questionId + ": Distributed " + question.getTotalMarks() + " marks across " + correctMappingsCount + " mappings (" + marksPerCorrectMatch + " each)");
            } else if (dragItems.size() > 0) {
                // Fallback to total items if no correct mappings defined (unlikely for well-defined questions)
                marksPerCorrectMatch = (float) question.getTotalMarks() / dragItems.size();
                LOGGER.warning("Q" + questionId + ": No correct mappings found! Falling back to " + dragItems.size() + " items for marks distribution (" + marksPerCorrectMatch + " each)");
            } else {
                LOGGER.severe("Q" + questionId + ": No items found for this question!");
            }
            
            // Delete any existing answers for this question
            String deleteSql = "DELETE FROM drag_drop_answers WHERE exam_id = ? AND question_id = ? AND student_id = ?";
            pstmDelete = conn.prepareStatement(deleteSql);
            pstmDelete.setInt(1, examId);
            pstmDelete.setInt(2, questionId);
            pstmDelete.setString(3, studentId);
            pstmDelete.executeUpdate();
            pstmDelete.close();
            
            // Insert new answers - FIXED: Removed extra '?' placeholder
            String insertSql = "INSERT INTO drag_drop_answers (exam_id, question_id, student_id, drag_item_id, drop_target_id, is_correct, marks_obtained) VALUES (?, ?, ?, ?, ?, ?, ?)";
            pstmInsert = conn.prepareStatement(insertSql);
            
            int correctCount = 0;
            for (DragItem item : dragItems) {
                Integer selectedTargetId = selectedMatches.get(item.getId());
                boolean isCorrect = false;
                
                // Check if correct_target_id exists and matches selected target
                // Also try JSON fallback
                LOGGER.info("Q" + questionId + ": Checking item.id=" + item.getId() + 
                           " (text: '" + item.getItemText() + "'), selectedTargetId=" + selectedTargetId +
                           ", db_correctTargetId=" + item.getCorrectTargetId() +
                           ", json_correctTargetId=" + jsonCorrectTargets.get(item.getId()));
                
                if (selectedTargetId != null) {
                    if (item.getCorrectTargetId() != null && item.getCorrectTargetId() > 0) {
                        // Primary: use database column
                        isCorrect = item.getCorrectTargetId().equals(selectedTargetId);
                    } else if (jsonCorrectTargets.containsKey(item.getId())) {
                        // Fallback: use JSON field
                        Integer jsonTargetId = jsonCorrectTargets.get(item.getId());
                        if (jsonTargetId != null) {
                            isCorrect = jsonTargetId.equals(selectedTargetId);
                        }
                    }
                }
                
                LOGGER.info("Q" + questionId + ": isCorrect = " + isCorrect);
                
                float marksObtained = isCorrect ? marksPerCorrectMatch : 0;
                
                pstmInsert.setInt(1, examId);
                pstmInsert.setInt(2, questionId);
                pstmInsert.setString(3, studentId);
                pstmInsert.setInt(4, item.getId());
                
                if (selectedTargetId != null) {
                    pstmInsert.setInt(5, selectedTargetId);
                } else {
                    pstmInsert.setNull(5, Types.INTEGER);
                }
                
                pstmInsert.setInt(6, isCorrect ? 1 : 0);
                // Use setFloat instead of setBigDecimal for marks_obtained
                pstmInsert.setFloat(7, marksObtained);
                pstmInsert.addBatch();
                
                totalMarks += marksObtained;
                if (isCorrect) correctCount++;
            }
            
            pstmInsert.executeBatch();
            conn.commit();
            
            LOGGER.info("Drag-drop answers submitted for exam: " + examId + 
                        ", question: " + questionId + 
                        ", student: " + studentId + 
                        ", correct: " + correctCount + "/" + dragItems.size() +
                        ", marks: " + totalMarks + "/" + question.getTotalMarks());
            
        } catch (SQLException e) {
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException rollbackEx) {
                LOGGER.log(Level.SEVERE, "Rollback failed", rollbackEx);
            }
            LOGGER.log(Level.SEVERE, "Error submitting drag-drop answers", e);
            throw new RuntimeException("Failed to submit drag-drop answers: " + e.getMessage(), e);
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmDelete != null) pstmDelete.close();
                if (pstmInsert != null) pstmInsert.close();
                if (conn != null) {
                    conn.setAutoCommit(true);
                }
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "Error closing resources", e);
            }
        }
        
        return totalMarks;
    }
    
    /**
     * Gets student's drag-drop answers for a question
     */
    public ArrayList<DragDropAnswer> getStudentDragDropAnswers(int examId, int questionId, String studentId) {
        ArrayList<DragDropAnswer> answers = new ArrayList<>();
        Connection conn = null;
        PreparedStatement pstm = null;
        ResultSet rs = null;
        
        try {
            conn = getConnection();
            String sql = "SELECT id, exam_id, question_id, student_id, drag_item_id, drop_target_id, is_correct, marks_obtained FROM drag_drop_answers WHERE exam_id = ? AND question_id = ? AND student_id = ?";
            pstm = conn.prepareStatement(sql);
            pstm.setInt(1, examId);
            pstm.setInt(2, questionId);
            pstm.setString(3, studentId);
            rs = pstm.executeQuery();
            
            while (rs.next()) {
                DragDropAnswer answer = new DragDropAnswer();
                answer.setId(rs.getInt("id"));
                answer.setExamId(rs.getInt("exam_id"));
                answer.setQuestionId(rs.getInt("question_id"));
                answer.setStudentId(rs.getString("student_id"));
                answer.setDragItemId(rs.getInt("drag_item_id"));
                answer.setDropTargetId(rs.getInt("drop_target_id"));
                answer.setCorrect(rs.getBoolean("is_correct"));
                answer.setMarksObtained(rs.getFloat("marks_obtained"));
                answers.add(answer);
            }
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error getting drag-drop answers", e);
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstm != null) pstm.close();
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "Error closing resources", e);
            }
        }
        
        return answers;
    }
    
    /**
     * Submit rearrange answers and calculate marks
     * 1 mark per correctly positioned item, divided proportionally from total marks
     */
    public float submitRearrangeAnswer(int examId, int questionId, String studentId, ArrayList<Integer> studentOrder) {
        Connection conn = null;
        PreparedStatement pstmDelete = null;
        PreparedStatement pstmInsert = null;
        PreparedStatement pstmSelect = null;
        ResultSet rs = null;
        float totalMarks = 0;
        
        try {
            conn = getConnection();
            conn.setAutoCommit(false);
            
            // Get the question's total marks and correct rearrange items
            Questions question = getQuestionById(questionId);
            if (question == null) {
                throw new RuntimeException("Question not found: " + questionId);
            }
            
            ArrayList<RearrangeItem> correctItems = getRearrangeItems(questionId);
            if (correctItems == null || correctItems.isEmpty()) {
                // Fallback to JSON
                String itemsJson = question.getDragItemsJson();
                if (itemsJson != null && itemsJson.startsWith("[")) {
                    JSONArray arr = new JSONArray(itemsJson);
                    correctItems = new ArrayList<>();
                    for (int i = 0; i < arr.length(); i++) {
                        RearrangeItem ri = new RearrangeItem();
                        ri.setId(i); // Use index as virtual ID
                        ri.setItemText(arr.getString(i));
                        ri.setCorrectPosition(i + 1);
                        correctItems.add(ri);
                    }
                }
            }

            if (correctItems == null || correctItems.isEmpty()) {
                throw new RuntimeException("No rearrange items found for question: " + questionId);
            }
            
            // Calculate marks per correct position (equal distribution)
            float marksPerCorrectPosition = 0;
            if (correctItems.size() > 0) {
                marksPerCorrectPosition = (float) question.getTotalMarks() / correctItems.size();
            }
            
            // Delete any existing answers for this question
            String deleteSql = "DELETE FROM rearrange_answers WHERE exam_id = ? AND question_id = ? AND student_id = ?";
            pstmDelete = conn.prepareStatement(deleteSql);
            pstmDelete.setInt(1, examId);
            pstmDelete.setInt(2, questionId);
            pstmDelete.setString(3, studentId);
            pstmDelete.executeUpdate();
            pstmDelete.close();
            
            // Insert new answers
            String insertSql = "INSERT INTO rearrange_answers (exam_id, question_id, student_id, item_id, student_position, is_correct, marks_obtained) VALUES (?, ?, ?, ?, ?, ?, ?)";
            pstmInsert = conn.prepareStatement(insertSql);
            
            int correctCount = 0;
            
            // Compare student's order with correct order
            for (int i = 0; i < correctItems.size() && i < studentOrder.size(); i++) {
                RearrangeItem correctItem = correctItems.get(i);
                int studentSelectedItemId = studentOrder.get(i);
                
                // Check if the student placed the correct item in this position
                boolean isCorrect = (correctItem.getId() == studentSelectedItemId);
                float marksObtained = isCorrect ? marksPerCorrectPosition : 0;
                
                pstmInsert.setInt(1, examId);
                pstmInsert.setInt(2, questionId);
                pstmInsert.setString(3, studentId);
                pstmInsert.setInt(4, correctItem.getId());
                pstmInsert.setInt(5, i + 1); // Position in student's arrangement
                pstmInsert.setInt(6, isCorrect ? 1 : 0);
                pstmInsert.setFloat(7, marksObtained);
                pstmInsert.addBatch();
                
                totalMarks += marksObtained;
                if (isCorrect) correctCount++;
            }
            
            // Handle case where student provided fewer items than expected
            for (int i = studentOrder.size(); i < correctItems.size(); i++) {
                RearrangeItem correctItem = correctItems.get(i);
                
                pstmInsert.setInt(1, examId);
                pstmInsert.setInt(2, questionId);
                pstmInsert.setString(3, studentId);
                pstmInsert.setInt(4, correctItem.getId());
                pstmInsert.setNull(5, java.sql.Types.INTEGER); // No position given by student
                pstmInsert.setInt(6, 0); // Incorrect
                pstmInsert.setFloat(7, 0); // No marks
                pstmInsert.addBatch();
            }
            
            pstmInsert.executeBatch();
            conn.commit();
            
            LOGGER.info("Rearrange answers submitted for exam: " + examId + 
                        ", question: " + questionId + 
                        ", student: " + studentId + 
                        ", correct: " + correctCount + "/" + correctItems.size() +
                        ", marks: " + totalMarks + "/" + question.getTotalMarks());
            
        } catch (SQLException e) {
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException rollbackEx) {
                LOGGER.log(Level.SEVERE, "Rollback failed", rollbackEx);
            }
            LOGGER.log(Level.SEVERE, "Error submitting rearrange answers", e);
            throw new RuntimeException("Failed to submit rearrange answers: " + e.getMessage(), e);
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmDelete != null) pstmDelete.close();
                if (pstmInsert != null) pstmInsert.close();
                if (conn != null) {
                    conn.setAutoCommit(true);
                }
            } catch (SQLException e) {
                LOGGER.log(Level.SEVERE, "Error closing resources", e);
            }
        }
        
        return totalMarks;
    }
}
    