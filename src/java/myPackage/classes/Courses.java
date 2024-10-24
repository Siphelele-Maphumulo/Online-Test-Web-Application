package myPackage.classes;

public class Courses {
    
   private String cName;
   private int tMarks;
   private String time;
   private String examDate;  // New field for storing the exam date

    // Constructor with examDate
    public Courses(String cName, int tMarks, String time, String examDate) {
        this.cName = cName;
        this.tMarks = tMarks;
        this.time = time;
        this.examDate = examDate;
    }

    // Constructor without examDate
    public Courses(String cName, int tMarks, String time) {
        this.cName = cName;
        this.tMarks = tMarks;
        this.time = time;
    }

    // Another constructor that doesn't require time or examDate
    public Courses(String cName, int tMarks) {
        this.cName = cName;
        this.tMarks = tMarks;
    }

    public Courses() {
    }

    // Getter and setter for course name
    public String getcName() {
        return cName;
    }

    public void setcName(String cName) {
        this.cName = cName;
    }

    // Getter and setter for total marks
    public int gettMarks() {
        return tMarks;
    }

    public void settMarks(int tMarks) {
        this.tMarks = tMarks;
    }

    // Getter and setter for time
    public String getTime() {
        return time;
    }

    public void setTime(String time) {
        this.time = time;
    }

    // Getter and setter for examDate
    public String getExamDate() {
        return examDate;
    }

    public void setExamDate(String examDate) {
        this.examDate = examDate;
    }  
}
