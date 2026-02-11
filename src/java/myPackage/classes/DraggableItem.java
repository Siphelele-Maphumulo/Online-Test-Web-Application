package myPackage.classes;

public class DraggableItem {
    private int itemId;
    private int questionId;
    private String itemText;
    private String itemValue;

    public DraggableItem() {
    }

    public DraggableItem(int itemId, int questionId, String itemText, String itemValue) {
        this.itemId = itemId;
        this.questionId = questionId;
        this.itemText = itemText;
        this.itemValue = itemValue;
    }

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
}
