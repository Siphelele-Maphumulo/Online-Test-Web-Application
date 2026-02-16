package myPackage.classes;

public class RearrangeItem {
    private int id;
    private String itemText;
    private int correctPosition;
    
    // Constructors
    public RearrangeItem() {}
    
    public RearrangeItem(int id, String itemText, int correctPosition) {
        this.id = id;
        this.itemText = itemText;
        this.correctPosition = correctPosition;
    }
    
    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }
    
    public String getItemText() { return itemText; }
    public void setItemText(String itemText) { this.itemText = itemText; }
    
    public int getCorrectPosition() { return correctPosition; }
    public void setCorrectPosition(int correctPosition) { this.correctPosition = correctPosition; }
}