package myPackage.classes;

public class User {
    private int userId;
    private String firstName;
    private String lastName;
    private String userName;
    private String email;
    private String password;
    private String type;  // Maps to "user_type" column
    private String contact;
    private String city;
    private String address;
    private String courseName; // Assigned course for lecturer (can be null for users)

    // Default constructor
    public User() {}

    // Constructor without courseName (for users table)
    public User(int userId, String firstName, String lastName, String userName,
                String email, String password, String user_type, String contact,
                String city, String address) {
        this.userId = userId;
        this.firstName = firstName;
        this.lastName = lastName;
        this.userName = userName;
        this.email = email;
        this.password = password;
        this.type = user_type;
        this.contact = contact;
        this.city = city;
        this.address = address;
        this.courseName = null; // default for users
    }

    // Full constructor with courseName (for lecturers table)
    public User(int userId, String firstName, String lastName, String userName,
                String email, String password, String user_type, String contact,
                String city, String address, String courseName) {
        this(userId, firstName, lastName, userName, email, password, user_type, contact, city, address);
        this.courseName = courseName;
    }

    // Getters and Setters
    public int getUserId() { return userId; }
    public void setUserId(int userId) { this.userId = userId; }

    public String getFirstName() { return firstName; }
    public void setFirstName(String firstName) { this.firstName = firstName; }

    public String getLastName() { return lastName; }
    public void setLastName(String lastName) { this.lastName = lastName; }

    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }
    public void setUserType(String type) { this.type = type; } // alias

    public String getContact() { return contact; }
    public void setContact(String contact) { this.contact = contact; }

    public String getCity() { return city; }
    public void setCity(String city) { this.city = city; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public String getCourseName() { return courseName; }
    public void setCourseName(String courseName) { this.courseName = courseName; }

    @Override
    public String toString() {
        return "User{" +
                "userId=" + userId +
                ", userName='" + userName + '\'' +
                ", type='" + type + '\'' +
                ", courseName='" + courseName + '\'' +
                '}';
    }
}
