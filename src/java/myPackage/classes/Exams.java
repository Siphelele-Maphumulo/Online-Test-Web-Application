package myPackage.classes;

public class Exams {
    private String cName;
    private String status;
    private int totalMarks;
    private String examDate;
    private int examId;
    private String stdId;
    private int obtMarks;
    private String date;
    private String startTime;
    private String endTime;
    private String examTime;
    
    // Constructors
    public Exams() {
        // Default constructor
    }
    
    public Exams(String firstName, String lastName, String userName, String email,
                int examId, String stdId, String courseName, int totalMarks, int obtMarks,
                String date, String startTime, String endTime, String examTime, String resultStatus) {
        // Constructor for results
        this.examId = examId;
        this.stdId = stdId;
        this.cName = courseName;
        this.totalMarks = totalMarks;
        this.obtMarks = obtMarks;
        this.date = date;
        this.startTime = startTime;
        this.endTime = endTime;
        this.examTime = examTime;
        this.status = resultStatus;
    }
    
    // Getters and Setters
    public String getcName() {
        return cName;
    }
    
    public void setcName(String cName) {
        this.cName = cName;
    }
    
    // Convenience method for getCourseName()
    public String getCourseName() {
        return getcName();
    }
    
    public void setCourseName(String courseName) {
        setcName(courseName);
    }
    
    public String getStatus() {
        return status;
    }
    
    public void setStatus(String status) {
        this.status = status;
    }
    
    public int getTotalMarks() {
        return totalMarks;
    }
    
    public void setTotalMarks(int totalMarks) {
        this.totalMarks = totalMarks;
    }
    
    public String getExamDate() {
        return examDate;
    }
    
    public void setExamDate(String examDate) {
        this.examDate = examDate;
    }
    
    public int getExamId() {
        return examId;
    }
    
    public void setExamId(int examId) {
        this.examId = examId;
    }
    
    public String getStdId() {
        return stdId;
    }
    
    public void setStdId(String stdId) {
        this.stdId = stdId;
    }
    
    public int getObtMarks() {
        return obtMarks;
    }
    
    public void setObtMarks(int obtMarks) {
        this.obtMarks = obtMarks;
    }
    
    public String getDate() {
        return date;
    }
    
    public void setDate(String date) {
        this.date = date;
    }
    
    public String getStartTime() {
        return startTime;
    }
    
    public void setStartTime(String startTime) {
        this.startTime = startTime;
    }
    
    public String getEndTime() {
        return endTime;
    }
    
    public void setEndTime(String endTime) {
        this.endTime = endTime;
    }
    
    public String getExamTime() {
        return examTime;
    }
    
    public void setExamTime(String examTime) {
        this.examTime = examTime;
    }
    
    // Additional getters if needed (for reflection in JSP)
    public String getFirstName() {
        // This might not be stored in Exams class - adjust based on your needs
        return "";
    }
    
    public String getLastName() {
        // This might not be stored in Exams class - adjust based on your needs
        return "";
    }
    
    public String getUserName() {
        // This might not be stored in Exams class - adjust based on your needs
        return "";
    }
    
    public String getEmail() {
        // This might not be stored in Exams class - adjust based on your needs
        return "";
    }
}