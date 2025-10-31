<%@page import="myPackage.classes.Questions"%>
<%@page import="java.util.ArrayList"%>
<jsp:useBean id="pDAO" class="myPackage.DatabaseClass" scope="page"/>

<style>
  /* Enhanced Questions List Page Styles */
  .questions-wrapper {
    display: flex;
    min-height: 100vh;
    background: #f6f7fb;
  }
  
  .sidebar {
    width: 180px;
    background: #F3F3F3;
    position: fixed;
    left: 0;
    top: 0;
    height: 100vh;
    z-index: 100;
    border-right: 1px solid rgba(0,0,0,.08);
  }
  
  .sidebar-background {
    height: 100%;
    padding: 32px 24px;
  }
  
  .left-menu a {
    display: flex;
    align-items: center;
    padding: 14px 16px;
    border-radius: 12px;
    color: #09294D;
    text-decoration: none;
    margin-bottom: 8px;
    font-weight: 600;
    transition: all 0.3s ease;
    border: 2px solid transparent;
  }
  
  .left-menu a:hover {
    background: #ffffff;
    border-color: #D8A02E;
    transform: translateX(8px);
    box-shadow: 0 4px 12px rgba(0,0,0,.08);
  }
  
  .left-menu a.active {
    background: linear-gradient(135deg, #09294D, #1a3d6d);
    color: white;
    border-color: #D8A02E;
    box-shadow: 0 6px 20px rgba(9, 41, 77, 0.3);
  }
  
  .content-area {
    flex: 1;
    padding: 32px;
    margin-left: 280px;
    min-height: 100vh;
    background: #f6f7fb;
  }
  
  .page-header {
    background: #fff;
    border: 1px solid rgba(0,0,0,.06);
    box-shadow: 0 8px 24px rgba(0,0,0,.08);
    border-radius: 20px;
    padding: 24px 32px;
    margin-bottom: 32px;
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
  
  .page-title {
    font-size: 1.75rem;
    font-weight: 800;
    margin: 0;
    color: #09294D;
    display: flex;
    align-items: center;
    gap: 16px;
  }
  
  .page-title i {
    color: #D8A02E;
    font-size: 2rem;
  }
  
  .stats-badge {
    background: linear-gradient(135deg, #D8A02E, #09294D);
    color: white;
    padding: 8px 20px;
    border-radius: 25px;
    font-weight: 700;
    font-size: 1.1rem;
    box-shadow: 0 4px 12px rgba(216, 160, 46, 0.3);
  }
  
  .mut-logo {
    max-height: 80px;
  }
  
  .questions-container {
    max-width: 1000px;
    margin: 0 auto;
  }
  
  .course-header {
    background: linear-gradient(135deg, #D8A02E, #09294D);
    color: white;
    padding: 20px 24px;
    border-radius: 16px 16px 0 0;
    margin-bottom: 0;
    font-size: 1.375rem;
    font-weight: 700;
    display: flex;
    align-items: center;
    justify-content: space-between;
  }
  
  .course-header i {
    font-size: 1.5rem;
  }
  
  .questions-count {
    display: flex;
    align-items: center;
    gap: 8px;
    background: rgba(255,255,255,0.2);
    padding: 6px 16px;
    border-radius: 20px;
    font-weight: 600;
    font-size: 0.9rem;
  }
  
  .question-card {
    background: #fff;
    border: 1px solid rgba(0,0,0,.06);
    border-radius: 16px;
    box-shadow: 0 4px 16px rgba(0,0,0,.08);
    padding: 0;
    margin-bottom: 24px;
    overflow: hidden;
    transition: transform 0.3s ease, box-shadow 0.3s ease;
  }
  
  .question-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 8px 32px rgba(0,0,0,.12);
  }
  
  .question-header {
    background: #f8f9fa;
    padding: 20px 24px;
    border-bottom: 1px solid #e9ecef;
    display: flex;
    align-items: center;
    justify-content: space-between;
  }
  
  .question-number {
    display: flex;
    align-items: center;
    gap: 12px;
  }
  
  .question-badge {
    width: 36px;
    height: 36px;
    background: linear-gradient(135deg, #09294D, #1a3d6d);
    color: white;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: 700;
    font-size: 1rem;
  }
  
  .question-text {
    font-weight: 600;
    color: #09294D;
    font-size: 1.1rem;
    margin: 0;
    line-height: 1.5;
  }
  
  .question-actions {
    display: flex;
    gap: 12px;
  }
  
  .question-content {
    padding: 24px;
  }
  
  .options-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 16px;
    margin-bottom: 20px;
  }
  
  .option-item {
    background: #f8f9fa;
    border: 2px solid #e9ecef;
    border-radius: 12px;
    padding: 16px;
    transition: all 0.3s ease;
  }
  
  .option-item:hover {
    background: #f0f0f0;
    transform: translateY(-2px);
  }
  
  .option-correct {
    border-color: #28a745;
    background: #f8fff9;
    position: relative;
  }
  
  .option-correct::after {
    content: "? Correct Answer";
    position: absolute;
    top: -10px;
    right: 12px;
    background: #28a745;
    color: white;
    padding: 4px 12px;
    border-radius: 20px;
    font-size: 0.8rem;
    font-weight: 600;
  }
  
  .option-label {
    font-weight: 600;
    color: #6c757d;
    margin-bottom: 8px;
    display: block;
  }
  
  .option-text {
    color: #333;
    font-weight: 500;
    line-height: 1.4;
  }
  
  .delete-btn {
    background: linear-gradient(135deg, #dc3545, #c82333);
    color: white;
    border: none;
    border-radius: 10px;
    padding: 10px 20px;
    font-size: 0.9rem;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s ease;
    text-decoration: none;
    display: inline-flex;
    align-items: center;
    gap: 8px;
    box-shadow: 0 4px 12px rgba(220, 53, 69, 0.3);
  }
  
  .delete-btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(220, 53, 69, 0.4);
    color: white;
    text-decoration: none;
  }
  
  .edit-btn {
    background: linear-gradient(135deg, #17a2b8, #6f42c1);
    color: white;
    border: none;
    border-radius: 10px;
    padding: 10px 20px;
    font-size: 0.9rem;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s ease;
    text-decoration: none;
    display: inline-flex;
    align-items: center;
    gap: 8px;
    box-shadow: 0 4px 12px rgba(23, 162, 184, 0.3);
  }
  
  .edit-btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(23, 162, 184, 0.4);
    color: white;
    text-decoration: none;
  }
  
  .no-questions {
    text-align: center;
    padding: 60px 40px;
    color: #6c757d;
    font-style: italic;
    font-size: 1.1rem;
    background: #fff;
    border-radius: 16px;
    border: 1px solid rgba(0,0,0,.06);
    box-shadow: 0 4px 16px rgba(0,0,0,.08);
  }
  
  .back-btn {
    background: linear-gradient(135deg, #6c757d, #495057);
    color: white;
    border: none;
    border-radius: 12px;
    padding: 14px 28px;
    font-size: 1rem;
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s ease;
    text-decoration: none;
    display: inline-flex;
    align-items: center;
    gap: 10px;
    margin-bottom: 24px;
  }
  
  .back-btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(108, 117, 125, 0.4);
    color: white;
    text-decoration: none;
  }
  
  /* Responsive Design */
  @media (max-width: 1024px) {
    .sidebar {
      width: 240px;
    }
    
    .content-area {
      margin-left: 240px;
      padding: 24px;
    }
  }
  
  @media (max-width: 768px) {
    .sidebar {
      position: relative;
      width: 100%;
      height: auto;
    }
    
    .content-area {
      margin-left: 0;
      padding: 20px;
    }
    
    .page-header {
      flex-direction: column;
      gap: 16px;
      text-align: center;
    }
    
    .options-grid {
      grid-template-columns: 1fr;
    }
    
    .question-header {
      flex-direction: column;
      gap: 16px;
      align-items: flex-start;
    }
    
    .question-actions {
      width: 100%;
      justify-content: space-between;
    }
  }
  
  @media (max-width: 480px) {
    .content-area {
      padding: 16px;
    }
    
    .course-header {
      padding: 16px 20px;
      flex-direction: column;
      gap: 12px;
      text-align: center;
    }
    
    .question-content {
      padding: 20px;
    }
    
    .delete-btn, .edit-btn {
      padding: 8px 16px;
      font-size: 0.8rem;
    }
  }
</style>

<div class="questions-wrapper">
  <!-- SIDEBAR -->
  <div class="sidebar">
    <div class="sidebar-background">
      <div style="text-align: center; margin: 20px 0 40px 0;">
        <img src="IMG/mut.png" alt="MUT Logo" class="mut-logo">
      </div>
      <div class="left-menu">
        <a href="adm-page.jsp?pgprt=0">
          <i class="fas fa-user"></i>
          <h2>Profile</h2>
        </a>
        <a href="adm-page.jsp?pgprt=2">
          <i class="fas fa-book"></i>
          <h2>Courses</h2>
        </a>
        <a class="active" href="adm-page.jsp?pgprt=3">
          <i class="fas fa-question-circle"></i>
          <h2>Questions</h2>
        </a>
        <a href="adm-page.jsp?pgprt=5">
          <i class="fas fa-chart-bar"></i>
          <h2>Students Results</h2>
        </a>
        <a href="adm-page.jsp?pgprt=1">
          <i class="fas fa-users"></i>
          <h2>Accounts</h2>
        </a>
      </div>
    </div>
  </div>

  <!-- CONTENT AREA -->
  <div class="content-area">
    <div class="questions-container">
      <!-- Page Header -->
      <div class="page-header">
        <div class="page-title">
          <i class="fas fa-question-circle"></i>
          Course Questions
        </div>
        <div class="stats-badge">
          <%
            if (request.getParameter("coursename") != null) {
              ArrayList list = pDAO.getAllQuestions(request.getParameter("coursename"));
          %>
          <i class="fas fa-list-ol"></i>
          <%= list.size() %> Questions
          <%
            }
          %>
        </div>
      </div>

      <!-- Back Button -->
      <a href="adm-page.jsp?pgprt=3" class="back-btn">
        <i class="fas fa-arrow-left"></i>
        Back to Questions Management
      </a>

      <%
        if (request.getParameter("coursename") != null) {
          ArrayList list = pDAO.getAllQuestions(request.getParameter("coursename"));
          String courseName = request.getParameter("coursename");
      %>
      
      <!-- Course Header -->
      <div class="course-header">
        <div>
          <i class="fas fa-book"></i>
          <%= courseName %> - Questions
        </div>
        <div class="questions-count">
          <i class="fas fa-layer-group"></i>
          Total: <%= list.size() %> Questions
        </div>
      </div>

      <%
          if (list.isEmpty()) {
      %>
        <div class="no-questions">
          <i class="fas fa-inbox" style="font-size: 3rem; margin-bottom: 16px; display: block; opacity: 0.5;"></i>
          No questions found for <%= courseName %>.
          <br>
          <small>Add questions to this course to see them listed here.</small>
        </div>
      <%
          } else {
            for (int i = 0; i < list.size(); i++) {
              Questions question = (Questions) list.get(i);
              String questionId = String.valueOf(question.getQuestionId());
              String questionNumber = String.valueOf(i + 1);
              String questionText = question.getQuestion();
              String opt1 = question.getOpt1();
              String opt2 = question.getOpt2();
              String opt3 = question.getOpt3();
              String opt4 = question.getOpt4();
              String correct = question.getCorrect();
              
              // Check if this is a multiple select question (contains pipe separator)
              boolean isMultipleSelect = correct != null && correct.contains("|");
              String[] correctAnswers = null;
              if (isMultipleSelect) {
                  correctAnswers = correct.split("\\|");
              }
      %>
      
      <!-- Question Card -->
      <div class="question-card">
        <div class="question-header">
          <div class="question-number">
            <div class="question-badge">
              <%= questionNumber %>
            </div>
            <div class="question-text">
              <%= questionText %>
              <% if (isMultipleSelect) { %>
                <div style="margin-top: 8px;">
                  <span class="question-type-badge" style="background: #17a2b8; color: white; padding: 2px 8px; border-radius: 12px; font-size: 0.8rem;">
                    <i class="fas fa-check-double"></i> Multiple Select (Choose Two)
                  </span>
                </div>
              <% } %>
            </div>
          </div>
          <div class="question-actions">
            <a href="edit_question.jsp?qid=<%= question.getQuestionId() %>" class="edit-btn">
              <i class="fas fa-edit"></i>
              Edit
            </a>
            <a href="controller.jsp?page=questions&operation=del&qid=<%= question.getQuestionId() %>" 
               onclick="return confirm('Are you sure you want to delete this question? This action cannot be undone.');" 
               class="delete-btn">
              <i class="fas fa-trash"></i>
              Delete
            </a>
          </div>
        </div>
        
        <div class="question-content">
          <div class="options-grid">
            <!-- Option A -->
            <div class="option-item <%= isMultipleSelect ? 
                  (containsAnswer(correctAnswers, opt1) ? "option-correct" : "") : 
                  (correct.equals(opt1) ? "option-correct" : "") %>">
              <span class="option-label">Option A</span>
              <div class="option-text"><%= opt1 %></div>
              <% if (isMultipleSelect && containsAnswer(correctAnswers, opt1)) { %>
                <div class="correct-indicator">
                  <i class="fas fa-check"></i> Correct Answer
                </div>
              <% } %>
            </div>
            
            <!-- Option B -->
            <div class="option-item <%= isMultipleSelect ? 
                  (containsAnswer(correctAnswers, opt2) ? "option-correct" : "") : 
                  (correct.equals(opt2) ? "option-correct" : "") %>">
              <span class="option-label">Option B</span>
              <div class="option-text"><%= opt2 %></div>
              <% if (isMultipleSelect && containsAnswer(correctAnswers, opt2)) { %>
                <div class="correct-indicator">
                  <i class="fas fa-check"></i> Correct Answer
                </div>
              <% } %>
            </div>
            
            <!-- Option C -->
            <% if (opt3 != null && !opt3.isEmpty()) { %>
            <div class="option-item <%= isMultipleSelect ? 
                  (containsAnswer(correctAnswers, opt3) ? "option-correct" : "") : 
                  (correct.equals(opt3) ? "option-correct" : "") %>">
              <span class="option-label">Option C</span>
              <div class="option-text"><%= opt3 %></div>
              <% if (isMultipleSelect && containsAnswer(correctAnswers, opt3)) { %>
                <div class="correct-indicator">
                  <i class="fas fa-check"></i> Correct Answer
                </div>
              <% } %>
            </div>
            <% } %>
            
            <!-- Option D -->
            <% if (opt4 != null && !opt4.isEmpty()) { %>
            <div class="option-item <%= isMultipleSelect ? 
                  (containsAnswer(correctAnswers, opt4) ? "option-correct" : "") : 
                  (correct.equals(opt4) ? "option-correct" : "") %>">
              <span class="option-label">Option D</span>
              <div class="option-text"><%= opt4 %></div>
              <% if (isMultipleSelect && containsAnswer(correctAnswers, opt4)) { %>
                <div class="correct-indicator">
                  <i class="fas fa-check"></i> Correct Answer
                </div>
              <% } %>
            </div>
            <% } %>
          </div>
          
          <div style="text-align: center; margin-top: 16px;">
            <small style="color: #6c757d;">
              <i class="fas fa-info-circle"></i> 
              Question ID: <strong><%= questionId %></strong> | 
              <% if (isMultipleSelect) { %>
                <span style="color: #17a2b8;"><strong>Multiple Correct Answers</strong> - Both highlighted answers must be selected</span>
              <% } else { %>
                Correct answer is highlighted in green
              <% } %>
            </small>
          </div>
        </div>
      </div>
      <%
            }
          }
        } else {
      %>
        <div class="no-questions">
          <i class="fas fa-exclamation-circle" style="font-size: 3rem; margin-bottom: 16px; display: block; opacity: 0.5;"></i>
          Please select a course to view questions.
          <br>
          <small>Go back to Questions Management and select a course.</small>
        </div>
      <%
        }
      %>
    </div>
  </div>
</div>

<!-- Font Awesome for Icons -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

<script>
  // Add animation to question cards
  document.addEventListener('DOMContentLoaded', function() {
    const questionCards = document.querySelectorAll('.question-card');
    questionCards.forEach((card, index) => {
      card.style.animationDelay = `${index * 0.1}s`;
      card.classList.add('fade-in-up');
    });
  });
</script>

<%!
// Helper method to check if an array contains a specific answer
private boolean containsAnswer(String[] correctAnswers, String option) {
    if (correctAnswers == null || option == null) return false;
    for (String correctAnswer : correctAnswers) {
        if (correctAnswer.trim().equals(option.trim())) {
            return true;
        }
    }
    return false;
}
%>