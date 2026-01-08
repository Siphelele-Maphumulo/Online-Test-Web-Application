<%@page import="java.util.ArrayList"%>
<%@page import="myPackage.DatabaseClass"%>
<%@page import="myPackage.classes.Questions"%>
<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    DatabaseClass pDAO = new DatabaseClass();
    int questionId = Integer.parseInt(request.getParameter("qid"));
    Questions questionToEdit = null;
    String questionType = "MCQ"; // Default type

    // Retrieve question details for the given questionId
    try {
        String sql = "SELECT * FROM questions WHERE question_id=?";
        PreparedStatement pstm = pDAO.conn.prepareStatement(sql);
        pstm.setInt(1, questionId);
        ResultSet rs = pstm.executeQuery();
        if (rs.next()) {
            questionToEdit = new Questions(
                rs.getInt("question_id"),
                rs.getString("question"),
                rs.getString("opt1"),
                rs.getString("opt2"),
                rs.getString("opt3"),
                rs.getString("opt4"),
                rs.getString("correct"),
                rs.getString("course_name")
            );
            // Get question type if it exists in the database
            try {
                questionType = rs.getString("question_type");
                if (questionType == null) questionType = "MCQ";
            } catch (SQLException e) {
                questionType = "MCQ";
            }
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
    
    // Parse multiple correct answers if it's a MultipleSelect question
    String[] correctAnswers = null;
    if (questionType.equals("MultipleSelect") && questionToEdit != null) {
        correctAnswers = questionToEdit.getCorrect().split("\\|");
    }
%>

<style>
  /* Enhanced Edit Question Page Styles */
  .edit-question-wrapper {
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
    border-color: #e3e3e3;
    transform: translateX(8px);
    box-shadow: 0 4px 12px rgba(0,0,0,.08);
  }
  
  .left-menu a.active {
    background: linear-gradient(135deg, #09294D, #1a3d6d);
    color: white;
    border-color: #e3e3e3;
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
    color: #e3e3e3;
    font-size: 2rem;
  }
  
  .question-id-badge {
    background: linear-gradient(135deg, #17a2b8, #6f42c1);
    color: white;
    padding: 6px 16px;
    border-radius: 20px;
    font-weight: 600;
    font-size: 0.9rem;
    display: inline-flex;
    align-items: center;
    gap: 8px;
  }
  
  .mut-logo {
    max-height: 150px;
  }
  
  .edit-card {
    background: #fff;
    border: 1px solid rgba(0,0,0,.06);
    border-radius: 20px;
    box-shadow: 0 8px 32px rgba(0,0,0,.08);
    padding: 0;
    margin-bottom: 32px;
    overflow: hidden;
    transition: transform 0.3s ease, box-shadow 0.3s ease;
    max-width: 800px;
  }
  
  .edit-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 12px 40px rgba(0,0,0,.12);
  }
  
  .card-header {
    background: linear-gradient(135deg, #e3e3e3, #09294D);
    color: white;
    padding: 24px 32px;
    font-size: 1.375rem;
    font-weight: 700;
    display: flex;
    align-items: center;
    justify-content: space-between;
  }
  
  .card-header i {
    font-size: 1.5rem;
  }
  
  .edit-form {
    padding: 32px;
  }
  
  .form-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    gap: 24px;
    margin-bottom: 24px;
  }
  
  .form-group {
    display: flex;
    flex-direction: column;
  }
  
  .form-label {
    font-weight: 700;
    color: #09294D;
    font-size: 1rem;
    margin-bottom: 8px;
    display: flex;
    align-items: center;
    gap: 8px;
  }
  
  .form-input {
    width: 100%;
    padding: 16px 20px;
    border: 2px solid #e9ecef;
    border-radius: 12px;
    font-size: 1rem;
    transition: all 0.3s ease;
    background: #fcfcfd;
    font-weight: 500;
  }
  
  .form-input:focus {
    outline: none;
    border-color: #09294D;
    background: white;
    box-shadow: 0 0 0 4px rgba(9, 41, 77, 0.1);
    transform: translateY(-2px);
  }
  
  .form-select {
    width: 100%;
    padding: 16px 20px;
    border: 2px solid #e9ecef;
    border-radius: 12px;
    font-size: 1rem;
    transition: all 0.3s ease;
    background: #fcfcfd;
    font-weight: 500;
    appearance: none;
    background-image: url("data:image/svg+xml;charset=US-ASCII,<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 4 5'><path fill='%2309294D' d='M2 0L0 2h4zm0 5L0 3h4z'/></svg>");
    background-repeat: no-repeat;
    background-position: right 16px center;
    background-size: 12px;
  }
  
  .form-select:focus {
    outline: none;
    border-color: #09294D;
    background: white;
    box-shadow: 0 0 0 4px rgba(9, 41, 77, 0.1);
    transform: translateY(-2px);
  }
  
  .options-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 16px;
    margin: 16px 0;
  }
  
  .option-input {
    width: 100%;
    padding: 14px 16px;
    border: 2px solid #e9ecef;
    border-radius: 10px;
    font-size: 0.95rem;
    transition: all 0.3s ease;
    background: #fcfcfd;
  }
  
  .option-input:focus {
    outline: none;
    border-color: #09294D;
    background: white;
    box-shadow: 0 0 0 3px rgba(9, 41, 77, 0.1);
  }
  
  .correct-option-input {
    border-color: #28a745;
    background: #f8fff9;
  }
  
  .correct-option-input:focus {
    border-color: #28a745;
    box-shadow: 0 0 0 3px rgba(40, 167, 69, 0.1);
  }
  
  .form-actions {
    display: flex;
    justify-content: center;
    gap: 16px;
    padding-top: 24px;
    border-top: 1px solid #f0f0f0;
    margin-top: 24px;
  }
  
  .update-btn {
    background: linear-gradient(135deg, #e3e3e3, #09294D);
    border: none;
    border-radius: 12px;
    padding: 16px 32px;
    font-size: 1.1rem;
    font-weight: 700;
    color: white;
    cursor: pointer;
    transition: all 0.3s ease;
    min-width: 200px;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 12px;
    box-shadow: 0 6px 20px rgba(9, 41, 77, 0.3);
  }
  
  .update-btn:hover {
    transform: translateY(-3px);
    box-shadow: 0 8px 25px rgba(9, 41, 77, 0.4);
  }
  
  .cancel-btn {
    background: linear-gradient(135deg, #6c757d, #495057);
    border: none;
    border-radius: 12px;
    padding: 16px 32px;
    font-size: 1.1rem;
    font-weight: 700;
    color: white;
    cursor: pointer;
    transition: all 0.3s ease;
    min-width: 160px;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 12px;
    text-decoration: none;
  }
  
  .cancel-btn:hover {
    transform: translateY(-3px);
    box-shadow: 0 8px 25px rgba(108, 117, 125, 0.4);
    color: white;
    text-decoration: none;
  }
  
  .question-type-badge {
    display: inline-block;
    background: linear-gradient(135deg, #17a2b8, #6f42c1);
    color: white;
    padding: 6px 16px;
    border-radius: 20px;
    font-weight: 600;
    font-size: 0.9rem;
    margin-left: 12px;
  }
  
  .correct-options-container {
    display: none;
    margin-top: 16px;
  }
  
  .correct-options-grid {
    display: grid;
    grid-template-columns: repeat(2, 1fr);
    gap: 12px;
  }
  
  .correct-option-checkbox {
    display: flex;
    align-items: center;
    gap: 8px;
    padding: 12px 16px;
    border: 2px solid #e9ecef;
    border-radius: 8px;
    background: #fcfcfd;
    cursor: pointer;
    transition: all 0.3s ease;
  }
  
  .correct-option-checkbox:hover {
    border-color: #09294D;
  }
  
  .correct-option-checkbox.selected {
    border-color: #28a745;
    background: #f8fff9;
  }
  
  .correct-option-checkbox input[type="checkbox"] {
    margin: 0;
  }
  
  .form-hint {
    color: #6c757d;
    font-size: 0.875rem;
    margin-top: 8px;
    display: block;
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
    
    .form-grid {
      grid-template-columns: 1fr;
    }
    
    .options-grid {
      grid-template-columns: repeat(2, 1fr);
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
    
    .correct-options-grid {
      grid-template-columns: 1fr;
    }
    
    .form-actions {
      flex-direction: column;
    }
    
    .update-btn, .cancel-btn {
      width: 100%;
    }
  }
</style>

<div class="edit-question-wrapper">
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
    <!-- Page Header -->
    <div class="page-header">
      <div class="page-title">
        <i class="fas fa-edit"></i>
        Edit Question
        <span class="question-type-badge">
          <i class="fas fa-tag"></i>
          <%= questionType %>
        </span>
      </div>
      <div class="question-id-badge">
        <i class="fas fa-hashtag"></i>
        Question ID: <%= questionToEdit.getQuestionId() %>
      </div>
    </div>

    <!-- Edit Question Card -->
    <div class="edit-card">
      <div class="card-header">
        <span><i class="fas fa-pencil-alt"></i> Update Question Details</span>
        <i class="fas fa-question-circle" style="opacity: 0.8;"></i>
      </div>
      <div class="edit-form">
        <form action="controller.jsp" method="POST" id="editQuestionForm">
          <input type="hidden" name="page" value="questions">
          <input type="hidden" name="operation" value="edit">
          <input type="hidden" name="qid" value="<%= questionToEdit.getQuestionId() %>">
          <input type="hidden" name="questionType" id="questionType" value="<%= questionType %>">

          <div class="form-grid">
            <div class="form-group">
              <label class="form-label">
                <i class="fas fa-book" style="color: #e3e3e3;"></i>
                Select Course
              </label>
              <select name="coursename" class="form-select" id="courseSelect" required>
                <% 
                ArrayList<String> allCourseNames = pDAO.getAllCourseNames();
                String currentCourseName = questionToEdit.getCourseName();
                for (String course : allCourseNames) {
                %>
                <option value="<%=course%>" <%=currentCourseName.equals(course) ? "selected" : ""%>><%=course%></option>
                <% } %>
              </select>
            </div>

            <div class="form-group">
              <label class="form-label">
                <i class="fas fa-question" style="color: #17a2b8;"></i>
                Question Type
              </label>
              <select name="questionType" class="form-select" id="questionTypeSelect" onchange="toggleQuestionType()">
                <option value="MCQ" <%= questionType.equals("MCQ") ? "selected" : "" %>>Multiple Choice (Single Answer)</option>
                <option value="MultipleSelect" <%= questionType.equals("MultipleSelect") ? "selected" : "" %>>Multiple Select (Choose Two)</option>
                <option value="TrueFalse" <%= questionType.equals("TrueFalse") ? "selected" : "" %>>True/False</option>
              </select>
            </div>
          </div>

          <div class="form-group">
            <label class="form-label">
              <i class="fas fa-pencil-alt" style="color: #28a745;"></i>
              Question Text
            </label>
            <input type="text" name="question" class="form-input" value="<%= questionToEdit.getQuestion() %>" placeholder="Enter the question text..." required>
          </div>

          <div class="form-group" id="optionsContainer">
            <label class="form-label">
              <i class="fas fa-list-ol" style="color: #e3e3e3;"></i>
              Answer Options
            </label>
            <div class="options-grid">
              <input type="text" name="opt1" class="option-input" value="<%= questionToEdit.getOpt1() %>" placeholder="Option 1" required id="opt1">
              <input type="text" name="opt2" class="option-input" value="<%= questionToEdit.getOpt2() %>" placeholder="Option 2" required id="opt2">
              <input type="text" name="opt3" class="option-input" value="<%= questionToEdit.getOpt3() != null ? questionToEdit.getOpt3() : "" %>" placeholder="Option 3" id="opt3">
              <input type="text" name="opt4" class="option-input" value="<%= questionToEdit.getOpt4() != null ? questionToEdit.getOpt4() : "" %>" placeholder="Option 4" id="opt4">
            </div>
          </div>

          <!-- Single Correct Answer Input -->
          <div class="form-group" id="singleCorrectContainer">
            <label class="form-label">
              <i class="fas fa-check-circle" style="color: #28a745;"></i>
              Correct Answer
            </label>
            <input type="text" name="correct" class="form-input" value="<%= questionToEdit.getCorrect() %>" placeholder="Enter the correct answer..." id="correctAnswer">
            <small class="form-hint">
              <i class="fas fa-info-circle"></i> Must match exactly one of the options above
            </small>
          </div>

          <!-- Multiple Correct Answers Selection -->
          <div class="form-group" id="multipleCorrectContainer" style="display: none;">
            <label class="form-label">
              <i class="fas fa-check-double" style="color: #28a745;"></i>
              Select Correct Answers (Choose 2)
            </label>
            <div class="correct-options-grid" id="correctOptionsGrid">
              <label class="correct-option-checkbox" id="correctOpt1Label">
                <input type="checkbox" name="correctOpt1" value="<%= questionToEdit.getOpt1() %>" id="correctOpt1">
                <span><%= questionToEdit.getOpt1() %></span>
              </label>
              <label class="correct-option-checkbox" id="correctOpt2Label">
                <input type="checkbox" name="correctOpt2" value="<%= questionToEdit.getOpt2() %>" id="correctOpt2">
                <span><%= questionToEdit.getOpt2() %></span>
              </label>
              <label class="correct-option-checkbox" id="correctOpt3Label">
                <input type="checkbox" name="correctOpt3" value="<%= questionToEdit.getOpt3() != null ? questionToEdit.getOpt3() : "" %>" id="correctOpt3">
                <span><%= questionToEdit.getOpt3() != null ? questionToEdit.getOpt3() : "Option 3" %></span>
              </label>
              <label class="correct-option-checkbox" id="correctOpt4Label">
                <input type="checkbox" name="correctOpt4" value="<%= questionToEdit.getOpt4() != null ? questionToEdit.getOpt4() : "" %>" id="correctOpt4">
                <span><%= questionToEdit.getOpt4() != null ? questionToEdit.getOpt4() : "Option 4" %></span>
              </label>
            </div>
            <input type="hidden" name="correctMultiple" id="correctMultiple" value="">
            <small class="form-hint">
              <i class="fas fa-info-circle"></i> Select exactly 2 correct answers
            </small>
          </div>

          <div class="form-actions">
            <a href="adm-page.jsp?pgprt=3" class="cancel-btn">
              <i class="fas fa-times"></i>
              Cancel
            </a>
            <button type="submit" class="update-btn" id="updateBtn">
              <i class="fas fa-save"></i>
              Update Question
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</div>

<!-- Font Awesome for Icons -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

<script>
  // Initialize the page based on question type
  document.addEventListener('DOMContentLoaded', function() {
    toggleQuestionType();
    updateCorrectOptionLabels();
    
    // For MultipleSelect questions, pre-select the correct answers
    <% if (questionType.equals("MultipleSelect") && correctAnswers != null) { %>
      <%
      for (int i = 0; i < correctAnswers.length; i++) {
          String correctAnswer = correctAnswers[i].trim();
      %>
          if ('<%= correctAnswer %>' === '<%= questionToEdit.getOpt1() %>') {
              document.getElementById('correctOpt1').checked = true;
              document.getElementById('correctOpt1Label').classList.add('selected');
          } else if ('<%= correctAnswer %>' === '<%= questionToEdit.getOpt2() %>') {
              document.getElementById('correctOpt2').checked = true;
              document.getElementById('correctOpt2Label').classList.add('selected');
          } else if ('<%= correctAnswer %>' === '<%= questionToEdit.getOpt3() %>') {
              document.getElementById('correctOpt3').checked = true;
              document.getElementById('correctOpt3Label').classList.add('selected');
          } else if ('<%= correctAnswer %>' === '<%= questionToEdit.getOpt4() %>') {
              document.getElementById('correctOpt4').checked = true;
              document.getElementById('correctOpt4Label').classList.add('selected');
          }
      <%
      }
      %>
      updateMultipleCorrectAnswer();
    <% } %>
    
    // Add event listeners for option changes
    document.querySelectorAll('.option-input').forEach(input => {
        input.addEventListener('input', updateCorrectOptionLabels);
    });
    
    // Add event listeners for checkbox changes with limit enforcement
    document.querySelectorAll('.correct-option-checkbox input[type="checkbox"]').forEach(checkbox => {
        checkbox.addEventListener('change', function() {
            const label = this.parentElement;
            const questionType = document.getElementById('questionTypeSelect').value;
            
            if (questionType === 'MultipleSelect') {
                const checkedCount = document.querySelectorAll('.correct-option-checkbox input[type="checkbox"]:checked').length;
                
                if (this.checked && checkedCount > 2) {
                    // If trying to check more than 2, uncheck this one and show message
                    this.checked = false;
                    alert('You can only select exactly 2 correct answers for Multiple Select questions.');
                    return;
                }
            }
            
            if (this.checked) {
                label.classList.add('selected');
            } else {
                label.classList.remove('selected');
            }
            
            updateMultipleCorrectAnswer();
            validateForm();
        });
    });
    
    // Add event listener for correct answer input
    document.getElementById('correctAnswer').addEventListener('input', validateForm);
    
    // Initial form validation
    validateForm();
  });

  function toggleQuestionType() {
    const questionType = document.getElementById('questionTypeSelect').value;
    const singleCorrectContainer = document.getElementById('singleCorrectContainer');
    const multipleCorrectContainer = document.getElementById('multipleCorrectContainer');
    const optionsContainer = document.getElementById('optionsContainer');
    
    document.getElementById('questionType').value = questionType;
    
    if (questionType === 'MultipleSelect') {
      singleCorrectContainer.style.display = 'none';
      multipleCorrectContainer.style.display = 'block';
      optionsContainer.style.display = 'block';
      updateMultipleCorrectAnswer();
    } else if (questionType === 'TrueFalse') {
      singleCorrectContainer.style.display = 'block';
      multipleCorrectContainer.style.display = 'none';
      optionsContainer.style.display = 'none';
      // Set True/False options
      document.getElementById('opt1').value = 'True';
      document.getElementById('opt2').value = 'False';
      document.getElementById('opt3').value = '';
      document.getElementById('opt4').value = '';
    } else {
      singleCorrectContainer.style.display = 'block';
      multipleCorrectContainer.style.display = 'none';
      optionsContainer.style.display = 'block';
    }
    
    validateForm();
  }

  function updateCorrectOptionLabels() {
    const opt1 = document.getElementById('opt1').value || 'Option 1';
    const opt2 = document.getElementById('opt2').value || 'Option 2';
    const opt3 = document.getElementById('opt3').value || 'Option 3';
    const opt4 = document.getElementById('opt4').value || 'Option 4';
    
    // Update checkbox labels
    document.querySelector('#correctOpt1Label span').textContent = opt1;
    document.querySelector('#correctOpt2Label span').textContent = opt2;
    document.querySelector('#correctOpt3Label span').textContent = opt3;
    document.querySelector('#correctOpt4Label span').textContent = opt4;
    
    // Update checkbox values
    document.getElementById('correctOpt1').value = opt1;
    document.getElementById('correctOpt2').value = opt2;
    document.getElementById('correctOpt3').value = opt3;
    document.getElementById('correctOpt4').value = opt4;
    
    updateMultipleCorrectAnswer();
  }

  function updateMultipleCorrectAnswer() {
    const selectedOptions = [];
    document.querySelectorAll('.correct-option-checkbox input[type="checkbox"]:checked').forEach(checkbox => {
      if (checkbox.value && checkbox.value.trim() !== '') {
        selectedOptions.push(checkbox.value);
      }
    });
    document.getElementById('correctMultiple').value = selectedOptions.join('|');
  }

  function validateForm() {
    const questionType = document.getElementById('questionTypeSelect').value;
    const updateBtn = document.getElementById('updateBtn');
    let isValid = true;
    
    if (questionType === 'MultipleSelect') {
      const selectedCount = document.querySelectorAll('.correct-option-checkbox input[type="checkbox"]:checked').length;
      if (selectedCount !== 2) {
        isValid = false;
      }
    } else {
      const correctAnswer = document.getElementById('correctAnswer').value.trim();
      const options = [
        document.getElementById('opt1').value.trim(),
        document.getElementById('opt2').value.trim(),
        document.getElementById('opt3').value.trim(),
        document.getElementById('opt4').value.trim()
      ].filter(opt => opt !== '');
      
      if (correctAnswer === '' || !options.includes(correctAnswer)) {
        isValid = false;
      }
    }
    
    updateBtn.disabled = !isValid;
    return isValid;
  }

  // Form submission validation
  document.getElementById('editQuestionForm').addEventListener('submit', function(e) {
    const questionType = document.getElementById('questionTypeSelect').value;
    
    if (questionType === 'MultipleSelect') {
      const selectedCount = document.querySelectorAll('.correct-option-checkbox input[type="checkbox"]:checked').length;
      if (selectedCount !== 2) {
        e.preventDefault();
        alert('Error: For Multiple Select questions, you must select exactly 2 correct answers.');
        return false;
      }
      // Set the correct answer field to the multiple correct answers
      document.getElementById('correctAnswer').value = document.getElementById('correctMultiple').value;
    } else {
      const correctAnswer = document.getElementById('correctAnswer').value.trim();
      const options = [
        document.getElementById('opt1').value.trim(),
        document.getElementById('opt2').value.trim(),
        document.getElementById('opt3').value.trim(),
        document.getElementById('opt4').value.trim()
      ].filter(opt => opt !== '');
      
      if (!options.includes(correctAnswer)) {
        e.preventDefault();
        alert('Error: The correct answer must match one of the options provided.');
        return false;
      }
    }
    
    return true;
  });
</script>