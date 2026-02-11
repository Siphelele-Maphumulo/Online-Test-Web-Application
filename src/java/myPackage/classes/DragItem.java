package myPackage.classes;

public class DragItem {
    private int id;
    private int questionId;
    private String itemText;
    private Integer correctTargetId;
    private int itemOrder;
    
    public DragItem() {
    }
    
    public DragItem(int id, int questionId, String itemText, Integer correctTargetId, int itemOrder) {
        this.id = id;
        this.questionId = questionId;
        this.itemText = itemText;
        this.correctTargetId = correctTargetId;
        this.itemOrder = itemOrder;
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
    
    public String getItemText() {
        return itemText;
    }
    
    public void setItemText(String itemText) {
        this.itemText = itemText;
    }
    
    public Integer getCorrectTargetId() {
        return correctTargetId;
    }
    
    public void setCorrectTargetId(Integer correctTargetId) {
        this.correctTargetId = correctTargetId;
    }
    
    public int getItemOrder() {
        return itemOrder;
    }
    
    public void setItemOrder(int itemOrder) {
        this.itemOrder = itemOrder;
    }
}
