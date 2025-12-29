package myPackage.classes;

public class Courses {
    
    private String cName;       // Course name
    private int tMarks;         // Total marks
    private String time;        // Exam duration or time
    private String examDate;    // Exam date

    // Constructors

    // Constructor with examDate and time
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

    // Constructor with only course name and total marks
    public Courses(String cName, int tMarks) {
        this.cName = cName;
        this.tMarks = tMarks;
    }

    // Default constructor
    public Courses() {}

    // Getters and Setters

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

    public String getTime() {
        return time;
    }

    public void setTime(String time) {
        this.time = time;
    }

    public String getExamDate() {
        return examDate;
    }

    public void setExamDate(String examDate) {
        this.examDate = examDate;
    }  
}
