package myPackage.classes;

public class DropTarget {
    private int id;
    private int questionId;
    private String targetLabel;
    private int targetOrder;
    
    public DropTarget() {
    }
    
    public DropTarget(int id, int questionId, String targetLabel, int targetOrder) {
        this.id = id;
        this.questionId = questionId;
        this.targetLabel = targetLabel;
        this.targetOrder = targetOrder;
    }
    
    public int getId() {
        return id;
    }
    
    public void setId(int id) {
        this.id = id;
    }
    
    public int getQuestionId() {
        return questionId;
    }
    
    public void setQuestionId(int questionId) {
        this.questionId = questionId;
    }
    
    public String getTargetLabel() {
        return targetLabel;
    }
    
    public void setTargetLabel(String targetLabel) {
        this.targetLabel = targetLabel;
    }
    
    public int getTargetOrder() {
        return targetOrder;
    }
    
    public void setTargetOrder(int targetOrder) {
        this.targetOrder = targetOrder;
    }
}
