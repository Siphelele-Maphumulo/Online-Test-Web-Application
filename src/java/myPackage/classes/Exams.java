package myPackage.classes;

public class Exams {
    private String fullName;  // Combined first and last name
    private int examId;
    private String stdId;
    private String cName;  // Course name
    private int tMarks;    // Total marks
    private int obtMarks;  // Obtained marks
    private String date;   // Exam date
    private String startTime;
    private String endTime;
    private String examTime;  // Exam duration
    private String status;

    // Constructor with full name and other fields
    public Exams(String firstName, String lastName, int examId, String stdId, String courseName, int totalMarks,
                 int obtainedMarks, String date, String startTime, String endTime, String examTime, String status) {
        this.fullName = firstName + " " + lastName;  // Combine first and last names
        this.examId = examId;
        this.stdId = stdId;
        this.cName = courseName;
        this.tMarks = totalMarks;
        this.obtMarks = obtainedMarks;
        this.date = date;
        this.startTime = startTime;
        this.endTime = endTime;
        this.examTime = examTime;
        this.status = status;
    }

    // Getter for fullName
    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    // Getters and setters for other fields
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

    public String getcName() {
        return cName;
    }

    public void setcName(String cName) {
        this.cName = cName;
    }

    public int gettMarks() {
        return tMarks;
    }

    public void settMarks(int tMarks) {
        this.tMarks = tMarks;
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

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
