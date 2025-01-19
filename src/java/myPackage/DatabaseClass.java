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
import myPackage.classes.Result;

public class DatabaseClass {
    private Connection conn;

    public DatabaseClass() throws ClassNotFoundException, SQLException {
        establishConnection();
    }

    private void establishConnection() throws ClassNotFoundException, SQLException {
        Class.forName("com.mysql.cj.jdbc.Driver"); // Updated to MySQL Connector/J 8.x
        conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/exam_system", "root", "");
    }

    String user_Type = "";
    public boolean checkLecturerByEmail(String email) {
        System.out.println("Here");
        boolean exists = false;
        try {
            String sql = "SELECT * FROM lectures WHERE email = ?";  // Assuming you have a column 'email' in 'lectures' table
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


    
    public ArrayList getAllUsers(){
        ArrayList list=new ArrayList();
        User user=null;
        PreparedStatement pstm;
        try {
            pstm = conn.prepareStatement("Select * from users");
            ResultSet rs=pstm.executeQuery();
            while(rs.next()){
                user =new User(rs.getInt(1),rs.getString(2),
                        rs.getString(3),rs.getString(4),rs.getString(5),rs.getString(6),rs.getString(7),rs.getString(8),rs.getString(9),rs.getString(10));
            list.add(user);
            }
        } catch (SQLException ex) {
            System.out.println(ex.getMessage());
            
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
     
     public User getUserDetails(String userId){
         User userDetails=null;
         
         try {
            String sql="SELECT * from users where user_id=?";
            PreparedStatement pstm=conn.prepareStatement(sql);
            pstm.setString(1, userId);
            ResultSet rs=pstm.executeQuery();
            while(rs.next()){
                userDetails=new User(rs.getInt(1),rs.getString(2),rs.getString(3),rs.getString(4)
                                        ,rs.getString(5),rs.getString(6),rs.getString(7),rs.getString(8)
                                            ,rs.getString(9),rs.getString(10));
            }
            pstm.close();
        } catch (SQLException ex) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
        }
         return userDetails;
     }
    
    public void addNewStudent(String fName, String lName, String uName, String email, String pass,
            String contact, String city, String address) {
        try {
            String sql = "INSERT into users(first_name, last_name, user_name, email, password, user_type, contact_no, city, address) "
                    + "Values(?,?,?,?,?,?,?,?,?)";
            
            PreparedStatement pstm = conn.prepareStatement(sql);
            pstm.setString(1, fName);
            pstm.setString(2, lName);
            pstm.setString(3, uName);
            pstm.setString(4, email);
            pstm.setString(5, pass);
            pstm.setString(6, user_Type);
            pstm.setString(7, contact);
            pstm.setString(8, city);
            pstm.setString(9, address);
            pstm.executeUpdate();
        } catch (SQLException ex) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
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
    
    public void updateStudent(int uId,String fName,String lName,String uName,String email,String pass,
            String contact,String city,String address,String userType){
        try {
            String sql="Update users"
                    + " set first_name=? , last_name=? , user_name=? , email=? , password=? , user_type=? , contact_no=? , city=? , address=? "
                    + " where user_id=?";
            
            PreparedStatement pstm=conn.prepareStatement(sql);
            pstm.setString(1,fName );
            pstm.setString(2,lName );
            pstm.setString(3,uName );
            pstm.setString(4,email );
            pstm.setString(5,pass );
            pstm.setString(6,userType );
            pstm.setString(7,contact );
            pstm.setString(8,city );
            pstm.setString(9,address );
            pstm.setInt(10,uId);
            pstm.executeUpdate();
        } catch (SQLException ex) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
    
public ArrayList<String> getAllCourseNames() {
    ArrayList<String> courseNames = new ArrayList<>();
    try {
        String query = "SELECT course_name FROM courses";
        PreparedStatement pstmt = conn.prepareStatement(query);
        ResultSet rs = pstmt.executeQuery();
        
        while (rs.next()) {
            courseNames.add(rs.getString("course_name"));
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    return courseNames;
}


    

public ArrayList getAllCourses() {
    ArrayList list = new ArrayList();
    try {
        String sql = "SELECT course_name, total_marks, exam_date FROM courses";
        PreparedStatement pstm = conn.prepareStatement(sql);
        ResultSet rs = pstm.executeQuery();
        while (rs.next()) {
            list.add(rs.getString(1));  // course_name
            list.add(rs.getInt(2));     // total_marks
            list.add(rs.getDate(3));    // exam_date
        }
        pstm.close();
    } catch (SQLException ex) {
        Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
    }
    return list;
}

    
public void addNewCourse(String courseName, int tMarks, String time, String examDate) {
    try {
        String sql = "INSERT INTO courses(course_name, total_marks, time, exam_date) VALUES (?, ?, ?, ?)";
        PreparedStatement pstm = conn.prepareStatement(sql);
        pstm.setString(1, courseName);
        pstm.setInt(2, tMarks);
        pstm.setString(3, time);
        pstm.setString(4, examDate); // Set the exam date
        
        pstm.executeUpdate();
        pstm.close();
    } catch (SQLException ex) {
        Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
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
    public void delQuestion(int qId){
        try {
            String sql="DELETE from questions where question_id=?";
            PreparedStatement pstm=conn.prepareStatement(sql);
            pstm.setInt(1,qId);
            pstm.executeUpdate();
            pstm.close();
        } catch (SQLException ex) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
        }
    }
    public void delUser(int uid){
        try {
            String sql="DELETE from users where user_id=?";
            PreparedStatement pstm=conn.prepareStatement(sql);
            pstm.setInt(1,uid);
            pstm.executeUpdate();
            pstm.close();
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
    
    public int startExam(String cName, int sId) {
        int examId = 0;
        try {
            String sql = "INSERT INTO exams(course_name, date, start_time, exam_time, std_id, total_marks) " +
                         "VALUES (?, ?, ?, ?, ?, ?)";
            PreparedStatement pstm = conn.prepareStatement(sql);
            pstm.setString(1, cName);
            pstm.setString(2, LocalDate.now().toString()); // Ensure consistent date format
            pstm.setString(3, LocalTime.now().toString());
            pstm.setString(4, getCourseTimeByName(cName));
            pstm.setInt(5, sId);
            pstm.setInt(6, getTotalMarksByName(cName));
            pstm.executeUpdate();
            pstm.close();
            examId = getLastExamId();
        } catch (SQLException ex) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
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



    // Method to get all results from the exams table
    public ArrayList<Exams> getResultsFromExams() {
        ArrayList<Exams> list = new ArrayList<>();
        try {
            String query = "SELECT u.first_name, u.last_name, e.exam_id, e.std_id, e.course_name, " +
                           "e.total_marks, e.obt_marks, e.date, e.start_time, e.end_time, e.exam_time, e.status " +
                           "FROM exams e " +
                           "JOIN users u ON e.std_id = u.user_id " +
                           "ORDER BY e.date DESC";
            PreparedStatement pstm = conn.prepareStatement(query);
            ResultSet rs = pstm.executeQuery();

            while (rs.next()) {
                String formattedDate = rs.getDate("date") != null ? rs.getDate("date").toString() : null;

                Exams exam = new Exams(
                    rs.getString("first_name"),
                    rs.getString("last_name"),
                    rs.getInt("exam_id"),
                    rs.getString("std_id"),
                    rs.getString("course_name"),
                    rs.getInt("total_marks"),
                    rs.getInt("obt_marks"),
                    formattedDate,
                    rs.getString("start_time"),
                    rs.getString("end_time"),
                    rs.getString("exam_time"),
                    rs.getString("status")
                );
                list.add(exam);
            }
        } catch (SQLException ex) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }


// Method to get results for a specific student by student ID
    public ArrayList<Exams> getResultsFromExams(int stdId) {
        ArrayList<Exams> list = new ArrayList<>();
        try {
            String query = "SELECT u.first_name, u.last_name, e.exam_id, e.std_id, e.course_name, " +
                           "e.total_marks, e.obt_marks, e.date, e.start_time, e.end_time, e.exam_time, e.status " +
                           "FROM exams e " +
                           "JOIN users u ON e.std_id = u.user_id " +
                           "WHERE e.std_id = ? " +
                           "ORDER BY e.date DESC";
            PreparedStatement pstm = conn.prepareStatement(query);
            pstm.setInt(1, stdId);
            ResultSet rs = pstm.executeQuery();

            while (rs.next()) {
                String formattedDate = rs.getDate("date") != null ? rs.getDate("date").toString() : null;

                Exams exam = new Exams(
                    rs.getString("first_name"),
                    rs.getString("last_name"),
                    rs.getInt("exam_id"),
                    rs.getString("std_id"),
                    rs.getString("course_name"),
                    rs.getInt("total_marks"),
                    rs.getInt("obt_marks"),
                    formattedDate,
                    rs.getString("start_time"),
                    rs.getString("end_time"),
                    rs.getString("exam_time"),
                    rs.getString("status")
                );
                list.add(exam);
            }
        } catch (SQLException ex) {
            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
        }
        return list;
    }


// Method to get an Exam by Exam ID
public Exams getResultByExamId(int examId) {
    Exams exam = null;
    PreparedStatement pstm = null;
    ResultSet rs = null;

    try {
        String query = "SELECT u.first_name, u.last_name, " +
                       "e.exam_id, e.std_id, e.course_name, e.total_marks, e.obt_marks, " +
                       "e.date, e.start_time, e.end_time, e.exam_time, e.status " +
                       "FROM exams e " +
                       "INNER JOIN users u ON e.std_id = u.user_id " +
                       "WHERE e.exam_id = ?";

        pstm = conn.prepareStatement(query);
        pstm.setInt(1, examId);
        rs = pstm.executeQuery();

        if (rs.next()) {
            String formattedDate = rs.getDate("date") != null ? rs.getDate("date").toString() : null;
            exam = new Exams(
                rs.getString("first_name"), 
                rs.getString("last_name"), 
                rs.getInt("exam_id"),
                rs.getString("std_id"),
                rs.getString("course_name"),
                rs.getInt("total_marks"),
                rs.getInt("obt_marks"),
                formattedDate,
                rs.getString("start_time"),
                rs.getString("end_time"),
                rs.getString("exam_time"),
                rs.getString("status")
            );
        }
    } catch (SQLException ex) {
        ex.printStackTrace();
    } finally {
        closeResources(pstm, rs);
    }
    return exam;
}

// Method to get all exams with results
public ArrayList<Exams> getAllExamsWithResults() {
    ArrayList<Exams> exams = new ArrayList<>();

    String query = "SELECT u.first_name, u.last_name, " +
                   "e.exam_id, e.std_id, e.course_name, e.total_marks, e.obt_marks, " +
                   "e.date, e.start_time, e.end_time, e.exam_time, e.status " +
                   "FROM exams e " +
                   "INNER JOIN users u ON e.std_id = u.user_id";

    try (PreparedStatement ps = conn.prepareStatement(query);
         ResultSet rs = ps.executeQuery()) {

        while (rs.next()) {
            String formattedDate = rs.getDate("date") != null 
                                    ? new SimpleDateFormat("yyyy-MM-dd").format(rs.getDate("date")) 
                                    : null;

            Exams exam = new Exams(
                rs.getString("first_name"),
                rs.getString("last_name"),
                rs.getInt("exam_id"),
                rs.getString("std_id"),
                rs.getString("course_name"),
                rs.getInt("total_marks"),
                rs.getInt("obt_marks"),
                formattedDate,
                rs.getString("start_time"),
                rs.getString("end_time"),
                rs.getString("exam_time"),
                rs.getString("status")
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

        while (rs.next()) {
            correctAnswersCount = rs.getInt(1);
        }
    } catch (SQLException ex) {
        Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
    }

    // Calculate marks per question
    float marksPerQuestion = (float) tMarks / size;
    float obtainedMarks = correctAnswersCount * marksPerQuestion;

    return Math.round(obtainedMarks);
}

    
//    public Exams getResultByExamId(int examId){
//        Exams exam=null;
//        try {
//            PreparedStatement pstm=conn.prepareStatement("select * from exams where exam_id=?");
//            pstm.setInt(1, examId);
//            ResultSet rs=pstm.executeQuery();
//            while(rs.next()){
//                exam=new Exams(                
//                rs.getString(1), // firstName (assuming it is in column 11)
//                rs.getString(2),  // lastName (assuming it is in column 12) 
//                rs.getInt(3),  // examId
//                rs.getString(4), // stdId
//                rs.getString(5), // cName
//                rs.getString(6), // tMarks
//                rs.getString(7), // obtMarks
//                rs.getString(8), // date
//                getFormatedTime(rs.getString(9)), // startTime
//                getFormatedTime(rs.getString(10)), // endTime
//                rs.getString(11), // examTime
//                rs.getString(12) // status)
//                );
//                
//            }
//        } catch (SQLException ex) {
//            Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
//        }
//        return exam;
//        
//    }
//    
 public void calculateResult(int eid, int tMarks, String endTime, int size) {
    try {
        String sql = "UPDATE exams SET obt_marks=?, end_time=?, status=? WHERE exam_id=?";
        PreparedStatement pstm = conn.prepareStatement(sql);
        int obt = getObtMarks(eid, tMarks, size);
        pstm.setInt(1, obt);
        pstm.setString(2, endTime);
        float percent = ((obt * 100) / tMarks);
        if (percent >= 45.0) {
            pstm.setString(3, "Pass");
        } else {
            pstm.setString(3, "Fail");
        }
        pstm.setInt(4, eid);
        pstm.executeUpdate();
    } catch (SQLException ex) {
        Logger.getLogger(DatabaseClass.class.getName()).log(Level.SEVERE, null, ex);
    }
}  



  // Method to get all exams with results and include user details


 

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