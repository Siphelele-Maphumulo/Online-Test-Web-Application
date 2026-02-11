package myPackage.classes;

public class DragDropItem {
    private int itemId;
    private int questionId;
    private String itemText;
    private String itemValue;
    private int itemOrder;
    
    // Default constructor
    public DragDropItem() {
    }
    
    // Constructor with parameters
    public DragDropItem(int itemId, int questionId, String itemText, String itemValue, int itemOrder) {
        this.itemId = itemId;
        this.questionId = questionId;
        this.itemText = itemText;
        this.itemValue = itemValue;
        this.itemOrder = itemOrder;
    }
    
    // Getters and Setters
    public int getItemId() {
        return itemId;
    }
    
    public void setItemId(int itemId) {
        this.itemId = itemId;
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
    
    public String getItemValue() {
        return itemValue;
    }
    
    public void setItemValue(String itemValue) {
        this.itemValue = itemValue;
    }
    
    public int getItemOrder() {
        return itemOrder;
    }
    
    public void setItemOrder(int itemOrder) {
        this.itemOrder = itemOrder;
    }
    
    @Override
    public String toString() {
        return "DragDropItem{" +
                "itemId=" + itemId +
                ", questionId=" + questionId +
                ", itemText='" + itemText + '\'' +
                ", itemValue='" + itemValue + '\'' +
                ", itemOrder=" + itemOrder +
                '}';
    }
}