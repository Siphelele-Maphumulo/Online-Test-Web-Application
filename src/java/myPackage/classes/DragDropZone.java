package myPackage.classes;

public class DragDropZone {
    private int zoneId;
    private int questionId;
    private String zoneLabel;
    private int correctItemId;
    private int zoneOrder;
    
    // Default constructor
    public DragDropZone() {
    }
    
    // Constructor with parameters
    public DragDropZone(int zoneId, int questionId, String zoneLabel, int correctItemId, int zoneOrder) {
        this.zoneId = zoneId;
        this.questionId = questionId;
        this.zoneLabel = zoneLabel;
        this.correctItemId = correctItemId;
        this.zoneOrder = zoneOrder;
    }
    
    // Getters and Setters
    public int getZoneId() {
        return zoneId;
    }
    
    public void setZoneId(int zoneId) {
        this.zoneId = zoneId;
    }
    
    public int getQuestionId() {
        return questionId;
    }
    
    public void setQuestionId(int questionId) {
        this.questionId = questionId;
    }
    
    public String getZoneLabel() {
        return zoneLabel;
    }
    
    public void setZoneLabel(String zoneLabel) {
        this.zoneLabel = zoneLabel;
    }
    
    public int getCorrectItemId() {
        return correctItemId;
    }
    
    public void setCorrectItemId(int correctItemId) {
        this.correctItemId = correctItemId;
    }
    
    public int getZoneOrder() {
        return zoneOrder;
    }
    
    public void setZoneOrder(int zoneOrder) {
        this.zoneOrder = zoneOrder;
    }
    
    @Override
    public String toString() {
        return "DragDropZone{" +
                "zoneId=" + zoneId +
                ", questionId=" + questionId +
                ", zoneLabel='" + zoneLabel + '\'' +
                ", correctItemId=" + correctItemId +
                ", zoneOrder=" + zoneOrder +
                '}';
    }
}