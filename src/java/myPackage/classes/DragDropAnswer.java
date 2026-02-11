package myPackage.classes;

public class DragDropAnswer {
    private int id;
    private int examId;
    private int questionId;
    private String studentId;
    private int dragItemId;
    private int dropTargetId;
    private boolean isCorrect;
    private float marksObtained;
    
    public DragDropAnswer() {
    }
    
    public DragDropAnswer(int examId, int questionId, String studentId, int dragItemId, int dropTargetId) {
        this.examId = examId;
        this.questionId = questionId;
        this.studentId = studentId;
        this.dragItemId = dragItemId;
        this.dropTargetId = dropTargetId;
    }
    
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public int getExamId() {
        return examId;
    }
    
    public void setExamId(int examId) {
        this.examId = examId;
    }
    
    public int getQuestionId() {
        return questionId;
    }
    
    public void setQuestionId(int questionId) {
        this.questionId = questionId;
    }
    
    public String getStudentId() {
        return studentId;
    }
    
    public void setStudentId(String studentId) {
        this.studentId = studentId;
    }
    
    public int getDragItemId() {
        return dragItemId;
    }
    
    public void setDragItemId(int dragItemId) {
        this.dragItemId = dragItemId;
    }
    
    public int getDropTargetId() {
        return dropTargetId;
    }
    
    public void setDropTargetId(int dropTargetId) {
        this.dropTargetId = dropTargetId;
    }
    
    public boolean isCorrect() {
        return isCorrect;
    }
    
    public void setCorrect(boolean correct) {
        isCorrect = correct;
    }
    
    public float getMarksObtained() {
        return marksObtained;
    }
    
    public void setMarksObtained(float marksObtained) {
        this.marksObtained = marksObtained;
    }
}
