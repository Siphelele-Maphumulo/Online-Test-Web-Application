package myPackage.classes;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class DragDropSubmission {
    private int submissionId;
    private int examId;
    private int questionId;
    private String studentId;
    private int droppedItemId;
    private int dropZoneId;
    private boolean isCorrect;
    private BigDecimal marksObtained;
    private Timestamp submittedAt;
    
    // Default constructor
    public DragDropSubmission() {
    }
    
    // Constructor with parameters
    public DragDropSubmission(int submissionId, int examId, int questionId, String studentId, 
                            int droppedItemId, int dropZoneId, boolean isCorrect, 
                            BigDecimal marksObtained, Timestamp submittedAt) {
        this.submissionId = submissionId;
        this.examId = examId;
        this.questionId = questionId;
        this.studentId = studentId;
        this.droppedItemId = droppedItemId;
        this.dropZoneId = dropZoneId;
        this.isCorrect = isCorrect;
        this.marksObtained = marksObtained;
        this.submittedAt = submittedAt;
    }
    
    // Getters and Setters
    public int getSubmissionId() {
        return submissionId;
    }
    
    public void setSubmissionId(int submissionId) {
        this.submissionId = submissionId;
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
    
    public int getDroppedItemId() {
        return droppedItemId;
    }
    
    public void setDroppedItemId(int droppedItemId) {
        this.droppedItemId = droppedItemId;
    }
    
    public int getDropZoneId() {
        return dropZoneId;
    }
    
    public void setDropZoneId(int dropZoneId) {
        this.dropZoneId = dropZoneId;
    }
    
    public boolean isCorrect() {
        return isCorrect;
    }
    
    public void setCorrect(boolean correct) {
        isCorrect = correct;
    }
    
    public BigDecimal getMarksObtained() {
        return marksObtained;
    }
    
    public void setMarksObtained(BigDecimal marksObtained) {
        this.marksObtained = marksObtained;
    }
    
    public Timestamp getSubmittedAt() {
        return submittedAt;
    }
    
    public void setSubmittedAt(Timestamp submittedAt) {
        this.submittedAt = submittedAt;
    }
    
    @Override
    public String toString() {
        return "DragDropSubmission{" +
                "submissionId=" + submissionId +
                ", examId=" + examId +
                ", questionId=" + questionId +
                ", studentId='" + studentId + '\'' +
                ", droppedItemId=" + droppedItemId +
                ", dropZoneId=" + dropZoneId +
                ", isCorrect=" + isCorrect +
                ", marksObtained=" + marksObtained +
                ", submittedAt=" + submittedAt +
                '}';
    }
}