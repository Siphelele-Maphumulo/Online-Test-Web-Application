package myPackage.classes;

public class Exams {
    
    private int examId;
    private String stdId;
    private String cName;
    private String tMarks;
    private String obtMarks;
    private String date;        // Exam date
    private String startTime;
    private String endTime;
    private String examTime;
    private String status;

    public Exams() {
    }

    // Constructor with exam date
    public Exams(int examId, String stdId, String cName, String tMarks, String obtMarks, String date, String startTime, String endTime, String examTime, String status) {
        this.examId = examId;
        this.stdId = stdId;
        this.cName = cName;
        this.tMarks = tMarks;
        this.obtMarks = obtMarks;
        this.date = date;
        this.startTime = startTime;
        this.endTime = endTime;
        this.examTime = examTime;
        this.status = status;
    }

    // Getters and Setters

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

    public String gettMarks() {
        return tMarks;
    }

    public void settMarks(String tMarks) {
        this.tMarks = tMarks;
    }

    public String getObtMarks() {
        return obtMarks;
    }

    public void setObtMarks(String obtMarks) {
        this.obtMarks = obtMarks;
    }

    public String getDate() {
        return date;   // Exam date
    }

    public void setDate(String date) {
        this.date = date;  // Set the exam date
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
