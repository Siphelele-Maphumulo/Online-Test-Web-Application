package myPackage.classes;

public class Answers {
    private String question;
    private String answer;
    private String correctAnswer;
    private String status;
    private int score; // Add this field

    // Default constructor
    public Answers() {
    }

    // Existing constructor (keep this for backward compatibility)
    public Answers(String question, String answer, String correctAnswer, String status) {
        this.question = question;
        this.answer = answer;
        this.correctAnswer = correctAnswer;
        this.status = status;
        this.score = 0; // Default score
    }

    // New constructor with score
    public Answers(String question, String answer, String correctAnswer, String status, int score) {
        this.question = question;
        this.answer = answer;
        this.correctAnswer = correctAnswer;
        this.status = status;
        this.score = score;
    }

    // Getters and setters
    public String getQuestion() {
        return question;
    }

    public void setQuestion(String question) {
        this.question = question;
    }

    public String getAnswer() {
        return answer;
    }

    public void setAnswer(String answer) {
        this.answer = answer;
    }

    public String getCorrectAnswer() {
        return correctAnswer;
    }

    public void setCorrectAnswer(String correctAnswer) {
        this.correctAnswer = correctAnswer;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public int getScore() {
        return score;
    }

    public void setScore(int score) {
        this.score = score;
    }
}