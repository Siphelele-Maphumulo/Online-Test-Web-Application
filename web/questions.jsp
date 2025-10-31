<%@page import="java.util.ArrayList"%>
<%@page import="myPackage.DatabaseClass"%>
<jsp:useBean id="pDAO" class="myPackage.DatabaseClass" scope="page"/>

<style>
  /* Enhanced Questions Page Styles */
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
  
  .question-card {
    background: #fff;
    border: 1px solid rgba(0,0,0,.06);
    border-radius: 20px;
    box-shadow: 0 8px 32px rgba(0,0,0,.08);
    padding: 0;
    margin-bottom: 32px;
    overflow: hidden;
    transition: transform 0.3s ease, box-shadow 0.3s ease;
  }
  
  .question-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 12px 40px rgba(0,0,0,.12);
  }
  
  .card-header {
    background: linear-gradient(135deg, #D8A02E, #09294D);
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
  
  .question-form {
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
    grid-template-columns: repeat(4, 1fr);
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
  
  .form-actions {
    display: flex;
    justify-content: center;
    gap: 16px;
    padding-top: 24px;
    border-top: 1px solid #f0f0f0;
  }
  
  .submit-btn {
    background: linear-gradient(135deg, #D8A02E, #09294D);
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
    box-shadow: 0 6px 20px rgba(9, 41, 77, 0.3);
  }
  
  .submit-btn:hover {
    transform: translateY(-3px);
    box-shadow: 0 8px 25px rgba(9, 41, 77, 0.4);
  }
  
  .show-btn {
    background: linear-gradient(135deg, #28a745, #20c997);
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
    box-shadow: 0 6px 20px rgba(40, 167, 69, 0.3);
  }
  
  .show-btn:hover {
    transform: translateY(-3px);
    box-shadow: 0 8px 25px rgba(40, 167, 69, 0.4);
  }
  
  .reset-btn {
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
  }
  
  .reset-btn:hover {
    transform: translateY(-3px);
    box-shadow: 0 8px 25px rgba(108, 117, 125, 0.4);
  }
  
  .question-input {
    width: 100%;
    padding: 16px 20px;
    border: 2px solid #e9ecef;
    border-radius: 12px;
    font-size: 1rem;
    transition: all 0.3s ease;
    background: #fcfcfd;
    font-weight: 500;
    margin-bottom: 16px;
  }
  
  .question-input:focus {
    outline: none;
    border-color: #09294D;
    background: white;
    box-shadow: 0 0 0 4px rgba(9, 41, 77, 0.1);
    transform: translateY(-2px);
  }
  
  .form-row {
    display: flex;
    gap: 16px;
    margin-bottom: 16px;
  }
  
  .form-row .form-group {
    flex: 1;
  }
  
  .hidden {
    display: none;
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
    
    .form-actions {
      flex-direction: column;
    }
    
    .submit-btn, .show-btn, .reset-btn {
      width: 100%;
    }
    
    .form-row {
      flex-direction: column;
      gap: 16px;
    }
  }
  
  @media (max-width: 480px) {
    .content-area {
      padding: 16px;
    }
    
    .card-header {
      padding: 20px 24px;
      flex-direction: column;
      gap: 12px;
      text-align: center;
    }
    
    .question-form {
      padding: 24px 20px;
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
    <div class="questions-panel">
      <!-- Page Header -->
      <div class="page-header">
        <div class="page-title">
          <i class="fas fa-question-circle"></i>
          Question Management
        </div>
        <div class="stats-badge">
          <i class="fas fa-database"></i>
          Manage Questions
        </div>
      </div>

      <!-- Display success/error messages -->
      <% 
        String message = (String) session.getAttribute("message");
        if (message != null) {
      %>
        <div class="alert alert-success" style="background: #d4edda; color: #155724; padding: 12px; border-radius: 5px; margin-bottom: 20px; border: 1px solid #c3e6cb;">
          <i class="fas fa-check-circle"></i> <%= message %>
        </div>
      <%
          session.removeAttribute("message");
        }
      %>

      <!-- Show Questions Panel -->
      <div class="question-card">
        <div class="card-header">
          <span><i class="fas fa-list"></i> Show All Questions</span>
          <i class="fas fa-search" style="opacity: 0.8;"></i>
        </div>
        <div class="question-form">
          <form action="adm-page.jsp">
            <div class="form-grid">
              <div class="form-group">
                <label class="form-label">
                  <i class="fas fa-book" style="color: #D8A02E;"></i>
                  Select Course
                </label>
                <select name="coursename" class="form-select" id="courseSelectShowAll" required>
                  <% 
                  ArrayList<String> courseNames = pDAO.getAllCourseNames(); 
                  String lastCourseName = pDAO.getLastCourseName();
                  
                  if (courseNames.isEmpty()) {
                  %>
                    <option value="">No courses available</option>
                  <%
                  } else {
                    for (String course : courseNames) {
                      boolean isSelected = (lastCourseName != null && lastCourseName.equals(course)) || 
                                         (lastCourseName == null && course.equals(courseNames.get(0)));
                  %>
                  <option value="<%=course%>" <%=isSelected ? "selected" : ""%>><%=course%></option>
                  <% 
                    }
                  } 
                  %>
                </select>
              </div>
            </div>
            
            <input type="hidden" name="pgprt" value="4">
            
            <div class="form-actions">
              <button type="submit" class="show-btn" <%=courseNames.isEmpty() ? "disabled" : ""%>>
                <i class="fas fa-eye"></i>
                Show Questions
              </button>
            </div>
          </form>
        </div>
      </div>

      <!-- Add New Question Panel -->
      <div class="question-card">
        <div class="card-header">
          <span><i class="fas fa-plus-circle"></i> Add New Question</span>
          <i class="fas fa-edit" style="opacity: 0.8;"></i>
        </div>
        <div class="question-form">
          <form action="controller.jsp" method="POST" id="questionForm">
            <div class="form-grid">
              <div class="form-group">
                <label class="form-label">
                  <i class="fas fa-book" style="color: #D8A02E;"></i>
                  Select Course
                </label>
                <select name="coursename" class="form-select" id="courseSelectAddNew" required>
                  <% 
                  ArrayList<String> allCourseNames = pDAO.getAllCourseNames();
                  if (allCourseNames.isEmpty()) {
                  %>
                    <option value="">No courses available. Please add courses first.</option>
                  <%
                  } else {
                  %>
                    <option value="">Select Course</option>
                  <%
                    for (String course : allCourseNames) {
                      boolean isSelected = (lastCourseName != null && lastCourseName.equals(course)) || 
                                         (lastCourseName == null && course.equals(allCourseNames.get(0)));
                  %>
                  <option value="<%=course%>" <%=isSelected ? "selected" : ""%>><%=course%></option>
                  <% 
                    }
                  } 
                  %>
                </select>
                <% if (allCourseNames.isEmpty()) { %>
                <small style="color: #dc3545; font-size: 12px;">
                  <i class="fas fa-exclamation-triangle"></i> 
                  You need to add courses first before adding questions.
                </small>
                <% } %>
              </div>
              
              <div class="form-group">
                <label class="form-label">
                  <i class="fas fa-question" style="color: #17a2b8;"></i>
                  Question Type
                </label>
                    <select name="questionType" id="questionType" class="form-select" onchange="toggleOptions()">
                      <option value="MCQ">Multiple Choice (Single Answer)</option>
                      <option value="MultipleSelect">Multiple Select (Choose Two)</option>
                      <option value="TrueFalse">True/False</option>
                      <option value="Code">Code Snippet</option> <!-- Add this line -->
                    </select>
              </div>
            </div>

            <div class="form-group">
              <label class="form-label">
                <i class="fas fa-pencil-alt" style="color: #28a745;"></i>
                Your Question
              </label>
              <textarea name="question" class="question-input" placeholder="Type your question here" required rows="3"></textarea>
            </div>

            <div id="mcqOptions">
              <div class="form-group">
                <label class="form-label">
                  <i class="fas fa-list-ol" style="color: #D8A02E;"></i>
                  Options
                </label>
                <div class="options-grid">
                  <input type="text" name="opt1" class="option-input" placeholder="First Option" id="opt1" required>
                  <input type="text" name="opt2" class="option-input" placeholder="Second Option" id="opt2" required>
                  <input type="text" name="opt3" class="option-input" placeholder="Third Option" id="opt3">
                  <input type="text" name="opt4" class="option-input" placeholder="Fourth Option" id="opt4">
                </div>
              </div>
            </div>

            <div class="form-group">
              <label class="form-label">
                <i class="fas fa-check-circle" style="color: #28a745;"></i>
                Correct Answer
              </label>
              
              <!-- Single Answer Input (for MCQ and True/False) -->
              <div id="correctAnswerContainer">
                <input type="text" id="correctAnswer" name="correct" class="form-input" placeholder="Enter correct answer" required>
                <small id="correctAnswerHint" class="form-hint">Enter the correct answer (must match one of the options exactly)</small>
              </div>
              
              <!-- Multiple Answer Selection (for MultipleSelect) -->
              <div id="multipleCorrectContainer" style="display: none;">
                <div class="options-grid">
                  <div class="form-check">
                    <input type="checkbox" id="correctOpt1" name="correctOpt1" value="" class="correct-checkbox">
                    <label for="correctOpt1" class="form-check-label">Option 1</label>
                  </div>
                  <div class="form-check">
                    <input type="checkbox" id="correctOpt2" name="correctOpt2" value="" class="correct-checkbox">
                    <label for="correctOpt2" class="form-check-label">Option 2</label>
                  </div>
                  <div class="form-check">
                    <input type="checkbox" id="correctOpt3" name="correctOpt3" value="" class="correct-checkbox">
                    <label for="correctOpt3" class="form-check-label">Option 3</label>
                  </div>
                  <div class="form-check">
                    <input type="checkbox" id="correctOpt4" name="correctOpt4" value="" class="correct-checkbox">
                    <label for="correctOpt4" class="form-check-label">Option 4</label>
                  </div>
                </div>
                <!-- Hidden field that will store the combined correct answers -->
                <input type="hidden" id="multipleCorrectAnswer" name="correctMultiple">
                <small id="multipleCorrectHint" class="form-hint">Select exactly 2 correct answers</small>
              </div>
            </div>

            <input type="hidden" name="page" value="questions">
            <input type="hidden" name="operation" value="addnew">
            
            <div class="form-actions">
              <button type="reset" class="reset-btn" onclick="resetQuestionForm()">
                <i class="fas fa-redo"></i>
                Reset Form
              </button>
              <button type="submit" class="submit-btn" id="submitBtn">
                <i class="fas fa-plus"></i>
                Add Question
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- Font Awesome for Icons -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

<script>
    function toggleOptions() {
      var questionType = document.getElementById("questionType").value;
      var mcqOptions = document.getElementById("mcqOptions");
      var correctAnswerContainer = document.getElementById("correctAnswerContainer");
      var multipleCorrectContainer = document.getElementById("multipleCorrectContainer");
      var correctAnswer = document.getElementById("correctAnswer");
      var correctAnswerHint = document.getElementById("correctAnswerHint");
      var multipleCorrectHint = document.getElementById("multipleCorrectHint");

      if (questionType === "TrueFalse") {
        mcqOptions.style.display = "none"; 
        correctAnswerContainer.style.display = "block";
        multipleCorrectContainer.style.display = "none";
        correctAnswer.value = ""; 
        correctAnswer.placeholder = "Enter 'True' or 'False'"; 
        correctAnswerHint.textContent = "Enter 'True' or 'False'";
        correctAnswer.required = true;

        // Clear MCQ options but set required for True/False
        document.getElementById('opt1').value = '';
        document.getElementById('opt2').value = '';
        document.getElementById('opt3').value = '';
        document.getElementById('opt4').value = '';
        document.getElementById('opt1').required = false;
        document.getElementById('opt2').required = false;

      } else if (questionType === "MultipleSelect") {
        mcqOptions.style.display = "block"; 
        correctAnswerContainer.style.display = "none";
        multipleCorrectContainer.style.display = "block";
        multipleCorrectHint.textContent = "Select exactly 2 correct answers";
        correctAnswer.required = false;

        // Set required for first two options
        document.getElementById('opt1').required = true;
        document.getElementById('opt2').required = true;
        document.getElementById('opt3').required = false;
        document.getElementById('opt4').required = false;

        // Update checkbox labels with current option values
        updateCorrectOptionLabels();
      } else if (questionType === "Code") {
        // Code question type
        mcqOptions.style.display = "block"; 
        correctAnswerContainer.style.display = "block";
        multipleCorrectContainer.style.display = "none";
        correctAnswer.placeholder = "Expected output or answer"; 
        correctAnswerHint.textContent = "Enter the expected output or correct answer for the code snippet";
        correctAnswer.required = true;

        // Set required for first two options
        document.getElementById('opt1').required = true;
        document.getElementById('opt2').required = true;
        document.getElementById('opt3').required = false;
        document.getElementById('opt4').required = false;

        // Update option placeholders for code questions
        document.getElementById('opt1').placeholder = "Option 1 (output interpretation)";
        document.getElementById('opt2').placeholder = "Option 2 (output interpretation)";
        document.getElementById('opt3').placeholder = "Option 3 (output interpretation)";
        document.getElementById('opt4').placeholder = "Option 4 (output interpretation)";
      } else {
        // Multiple Choice (Single Answer) - default
        mcqOptions.style.display = "block"; 
        correctAnswerContainer.style.display = "block";
        multipleCorrectContainer.style.display = "none";
        correctAnswer.placeholder = "Correct Answer"; 
        correctAnswerHint.textContent = "Enter the correct answer (must match one of the options exactly)";
        correctAnswer.required = true;

        // Set required for first two options
        document.getElementById('opt1').required = true;
        document.getElementById('opt2').required = true;
        document.getElementById('opt3').required = false;
        document.getElementById('opt4').required = false;

        // Reset option placeholders to default
        document.getElementById('opt1').placeholder = "First Option";
        document.getElementById('opt2').placeholder = "Second Option";
        document.getElementById('opt3').placeholder = "Third Option";
        document.getElementById('opt4').placeholder = "Fourth Option";
      }

      // Enable/disable submit button based on form validity
      updateSubmitButton();
    }

  function updateCorrectOptionLabels() {
    var opt1 = document.getElementById('opt1').value || 'Option 1';
    var opt2 = document.getElementById('opt2').value || 'Option 2';
    var opt3 = document.getElementById('opt3').value || 'Option 3';
    var opt4 = document.getElementById('opt4').value || 'Option 4';
    
    document.querySelector('label[for="correctOpt1"]').textContent = opt1;
    document.querySelector('label[for="correctOpt2"]').textContent = opt2;
    document.querySelector('label[for="correctOpt3"]').textContent = opt3;
    document.querySelector('label[for="correctOpt4"]').textContent = opt4;
    
    // Update checkbox values
    document.getElementById('correctOpt1').value = opt1;
    document.getElementById('correctOpt2').value = opt2;
    document.getElementById('correctOpt3').value = opt3;
    document.getElementById('correctOpt4').value = opt4;
  }

  function updateMultipleCorrectAnswer() {
    var selectedOptions = [];
    document.querySelectorAll('.correct-checkbox:checked').forEach(function(checkbox) {
      if (checkbox.value && checkbox.value.trim() !== '') {
        selectedOptions.push(checkbox.value);
      }
    });
    document.getElementById('multipleCorrectAnswer').value = selectedOptions.join('|');
  }

  function updateSubmitButton() {
    var submitBtn = document.getElementById('submitBtn');
    var form = document.getElementById('questionForm');
    
    // Check if form is valid
    var isValid = form.checkValidity();
    submitBtn.disabled = !isValid;
    
    // Additional validation for MultipleSelect
    var questionType = document.getElementById("questionType").value;
    if (questionType === "MultipleSelect") {
      var selectedCount = document.querySelectorAll('.correct-checkbox:checked').length;
      if (selectedCount !== 2) {
        submitBtn.disabled = true;
      }
    }
  }

function resetQuestionForm() {
  // Reset form and reinitialize the options
  document.getElementById('questionForm').reset();
  
  // Reset option placeholders to default
  document.getElementById('opt1').placeholder = "First Option";
  document.getElementById('opt2').placeholder = "Second Option";
  document.getElementById('opt3').placeholder = "Third Option";
  document.getElementById('opt4').placeholder = "Fourth Option";
  
  toggleOptions();
}

function validateQuestionForm() {
  var questionType = document.getElementById("questionType").value;
  var isValid = true;
  
  if (questionType === "TrueFalse") {
    var correctAnswer = document.getElementById("correctAnswer").value.trim();
    if (correctAnswer !== "True" && correctAnswer !== "False") {
      alert("For True/False questions, correct answer must be either 'True' or 'False'");
      isValid = false;
    }
  } else if (questionType === "MultipleSelect") {
    var selectedCount = document.querySelectorAll('.correct-checkbox:checked').length;
    if (selectedCount !== 2) {
      alert("For Multiple Select questions, you must select exactly 2 correct answers.");
      isValid = false;
    } else {
      updateMultipleCorrectAnswer();
    }
  } else if (questionType === "Code") {
    // Code question validation - same as MCQ but with different messaging
    var correctAnswer = document.getElementById("correctAnswer").value.trim();
    var opt1 = document.getElementById('opt1').value.trim();
    var opt2 = document.getElementById('opt2').value.trim();
    var opt3 = document.getElementById('opt3').value.trim();
    var opt4 = document.getElementById('opt4').value.trim();
    
    if (correctAnswer !== opt1 && correctAnswer !== opt2 && 
        correctAnswer !== opt3 && correctAnswer !== opt4) {
      alert("Correct answer must match one of the provided options exactly. For code questions, this is typically the expected output.");
      isValid = false;
    }
  } else {
    // Multiple Choice validation - check if correct answer matches one of the options
    var correctAnswer = document.getElementById("correctAnswer").value.trim();
    var opt1 = document.getElementById('opt1').value.trim();
    var opt2 = document.getElementById('opt2').value.trim();
    var opt3 = document.getElementById('opt3').value.trim();
    var opt4 = document.getElementById('opt4').value.trim();
    
    if (correctAnswer !== opt1 && correctAnswer !== opt2 && 
        correctAnswer !== opt3 && correctAnswer !== opt4) {
      alert("Correct answer must match one of the provided options exactly.");
      isValid = false;
    }
  }
  
  return isValid;
}

  function syncCourseDropdowns() {
    const courseSelectAddNew = document.getElementById('courseSelectAddNew');
    const courseSelectShowAll = document.getElementById('courseSelectShowAll');

    // Sync from Add New to Show All
    courseSelectAddNew.addEventListener('change', function() {
      courseSelectShowAll.value = this.value;
    });

    // Sync from Show All to Add New
    courseSelectShowAll.addEventListener('change', function() {
      courseSelectAddNew.value = this.value;
    });
  }

  // Initialize everything when page loads
  window.onload = function() {
    toggleOptions(); 
    
    // Add event listeners for option changes to update labels
    document.getElementById('opt1').addEventListener('input', function() {
      updateCorrectOptionLabels();
      updateSubmitButton();
    });
    document.getElementById('opt2').addEventListener('input', function() {
      updateCorrectOptionLabels();
      updateSubmitButton();
    });
    document.getElementById('opt3').addEventListener('input', function() {
      updateCorrectOptionLabels();
      updateSubmitButton();
    });
    document.getElementById('opt4').addEventListener('input', function() {
      updateCorrectOptionLabels();
      updateSubmitButton();
    });
    
    // Add event listeners for correct answer checkboxes
    document.querySelectorAll('.correct-checkbox').forEach(function(checkbox) {
      checkbox.addEventListener('change', function() {
        var selectedCount = document.querySelectorAll('.correct-checkbox:checked').length;
        if (selectedCount > 2) {
          this.checked = false;
          alert("You can only select 2 correct answers for Multiple Select questions.");
        }
        updateMultipleCorrectAnswer();
        updateSubmitButton();
      });
    });
    
    // Add event listener for correct answer input
    document.getElementById('correctAnswer').addEventListener('input', updateSubmitButton);
    
    // Add event listener for course selection
    document.getElementById('courseSelectAddNew').addEventListener('change', updateSubmitButton);
    
    // Add form validation
    document.getElementById('questionForm').addEventListener('submit', function(e) {
      if (!validateQuestionForm()) {
        e.preventDefault();
        return false;
      }
    });
    
    // Real-time form validation
    document.getElementById('questionForm').addEventListener('input', updateSubmitButton);
    
    // Sync course dropdowns
    syncCourseDropdowns();
    
    // Initial button state
    updateSubmitButton();
  };
</script>