<%@page import="java.util.ArrayList"%>
<%@page import="myPackage.classes.Questions"%>
<%@page import="myPackage.classes.Exams"%>
<jsp:useBean id="pDAO" class="myPackage.DatabaseClass" scope="page"/>
<%!
// Helper method to extract and format code snippets with basic syntax highlighting
private String[] extractQuestionAndCode(String text) {
    if (text == null) return new String[]{"", ""};
    
    String questionText = text;
    String codeSnippet = "";
    
    // Extract code block if present (between ```)
    if (text.contains("```")) {
        // Extract code between triple backticks
        int start = text.indexOf("```");
        int end = text.lastIndexOf("```");
        if (start != -1 && end != -1 && start != end) {
            codeSnippet = text.substring(start + 3, end).trim();
            questionText = text.substring(0, start).trim();
        }
    }
    
    // If no code blocks found but contains code patterns, treat the whole text as code
    if (codeSnippet.isEmpty() && (text.contains("def ") || text.contains("function ") || 
        text.contains("public ") || text.contains("class ") || text.contains("print(") || 
        text.contains("console.") || text.contains("<?php") || text.contains("import ") || 
        text.contains("int ") || text.contains("String ") || text.contains("printf(") || 
        text.contains("cout "))) {
        codeSnippet = text;
        questionText = "What is the output/result of this code?";
    }
    
    return new String[]{questionText, codeSnippet};
}

// Helper method to format code snippets with basic syntax highlighting

%>

<style>
  /* Enhanced Student Exam Page Styles */
  .exam-wrapper {
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
  
  /* Exam Header Styles */
  .exam-header {
    background: #fff;
    border: 1px solid rgba(0,0,0,.06);
    box-shadow: 0 8px 24px rgba(0,0,0,.08);
    border-radius: 20px;
    padding: 24px 32px;
    margin-bottom: 24px;
    display: flex;
    justify-content: space-between;
    align-items: center;
    position: sticky;
    top: 0;
    z-index: 50;
  }
  
  .timer-container {
    display: flex;
    flex-direction: column;
    align-items: flex-end;
    gap: 16px;
  }
  
  .badge-time {
    font-weight: 700;
    font-size: 1.1rem;
    background: linear-gradient(135deg, #dc3545, #c82333);
    color: white;
    padding: 10px 20px;
    border-radius: 25px;
    min-width: 100px;
    text-align: center;
    border: none;
    box-shadow: 0 4px 12px rgba(220, 53, 69, 0.3);
  }
  
  .badge-time.warning {
    background: linear-gradient(135deg, #ffc107, #fd7e14);
    color: #000;
  }
  
  .badge-time.expired {
    background: linear-gradient(135deg, #6c757d, #495057);
    color: white;
  }
  
  .progress-container {
    min-width: 280px;
  }
  
  .progress-label {
    display: flex;
    justify-content: space-between;
    margin-bottom: 8px;
    font-size: 0.9rem;
    font-weight: 600;
    color: #09294D;
  }
  
  .progress {
    height: 12px;
    border-radius: 10px;
    background: #f1f3f4;
    overflow: hidden;
  }
  
  .progress-bar {
    border-radius: 10px;
    background: linear-gradient(90deg, #28a745, #20c997);
    transition: width 0.3s ease;
    height: 100%;
  }
  
  /* Question Card Styles */
  .question-card {
    background: #fff;
    border: 1px solid rgba(0,0,0,.06);
    border-radius: 20px;
    box-shadow: 0 8px 32px rgba(0,0,0,.08);
    padding: 32px;
    margin-bottom: 24px;
    transition: transform 0.3s ease, box-shadow 0.3s ease;
  }
  
  .question-card:hover {
    transform: translateY(-4px);
    box-shadow: 0 12px 40px rgba(0,0,0,.12);
  }
  
  .question-header {
    display: flex;
    align-items: flex-start;
    margin-bottom: 24px;
    gap: 20px;
  }
  
  .question-label {
    display: inline-flex;
    width: 50px;
    height: 50px;
    align-items: center;
    justify-content: center;
    background: linear-gradient(135deg, #09294D, #1a3d6d);
    color: #fff;
    border-radius: 14px;
    font-weight: 800;
    font-size: 1.2rem;
    flex-shrink: 0;
    box-shadow: 0 4px 12px rgba(9, 41, 77, 0.3);
  }
  
  .question-text {
    font-weight: 600;
    color: #09294D;
    margin: 0;
    font-size: 1.2rem;
    line-height: 1.6;
    flex: 1;
    white-space: pre-wrap;
    word-wrap: break-word;
  }
  
  .answers {
    margin-top: 20px;
  }
  
  .form-check {
    padding: 18px 20px;
    border: 2px solid #e9ecef;
    border-radius: 14px;
    margin-bottom: 12px;
    background: #fcfcfd;
    transition: all 0.3s ease;
    cursor: pointer;
  }
  
  .form-check:hover {
    background: #f7f9ff;
    border-color: #09294D;
    transform: translateX(8px);
  }
  
  .form-check.selected {
    background: #e7f3ff;
    border-color: #007bff;
    box-shadow: 0 4px 12px rgba(0, 123, 255, 0.1);
  }
  
  .form-check-input {
    width: 20px;
    height: 20px;
    margin-top: 2px;
    cursor: pointer;
  }
  
  .form-check-input:checked {
    background-color: #09294D;
    border-color: #09294D;
  }
  
  .form-check-label {
    font-weight: 500;
    color: #333;
    margin-left: 16px;
    cursor: pointer;
    line-height: 1.5;
    font-size: 1.05rem;
    white-space: pre-wrap;
    word-wrap: break-word;
  }
  
  /* Multi-select specific styles */
  .multi-select-note {
    background: #e7f3ff;
    padding: 12px 16px;
    border-radius: 10px;
    margin-bottom: 16px;
    border-left: 4px solid #007bff;
    display: flex;
    align-items: center;
    gap: 10px;
    font-weight: 600;
    color: #09294D;
  }
  
  /* Code snippet styles */
  .code-snippet {
    background: #2d2d2d;
    color: #f8f8f2;
    border: 1px solid #444;
    border-radius: 8px;
    padding: 20px;
    margin: 16px 0;
    font-family: 'Courier New', monospace;
    font-size: 14px;
    line-height: 1.5;
    white-space: pre-wrap;
    overflow-x: auto;
    position: relative;
  }
  
  .code-snippet::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    right: 0;
    height: 4px;
    background: linear-gradient(90deg, #007bff, #28a745);
    border-radius: 8px 8px 0 0;
  }
  
  .code-header {
    color: #adb5bd;
    font-size: 12px;
    margin-bottom: 12px;
    display: flex;
    align-items: center;
    gap: 8px;
    border-bottom: 1px solid #444;
    padding-bottom: 8px;
  }
  
  .code-question-indicator {
    background: linear-gradient(135deg, #007bff, #0056b3);
    color: white;
    padding: 10px 16px;
    border-radius: 8px;
    margin-bottom: 16px;
    border-left: 4px solid #0056b3;
    display: flex;
    align-items: center;
    gap: 10px;
    font-weight: 600;
  }
  
  /* Syntax highlighting classes */
  .code-keyword { color: #ff79c6; font-weight: bold; }
  .code-function { color: #50fa7b; }
  .code-string { color: #f1fa8c; }
  .code-number { color: #bd93f9; }
  .code-comment { color: #6272a4; font-style: italic; }
  .code-operator { color: #ff79c6; }
  
  /* Submit Bar Styles */
  .submit-bar {
    position: fixed;
    bottom: 0;
    left: 280px;
    right: 0;
    padding: 16px 32px;
    background: linear-gradient(180deg, rgba(246,247,251,0), #f6f7fb 40%, #f6f7fb);
    z-index: 60;
  }
  
  .submit-inner {
    background: #fff;
    border: 1px solid rgba(0,0,0,.06);
    box-shadow: 0 10px 24px rgba(0,0,0,.08);
    border-radius: 20px;
    padding: 24px 32px;
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
  
  .submit-btn {
    background: linear-gradient(135deg, #D8A02E, #09294D);
    border: none;
    border-radius: 14px;
    padding: 16px 32px;
    font-size: 1.2rem;
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
  
  .submit-btn:hover {
    transform: translateY(-3px);
    box-shadow: 0 8px 25px rgba(9, 41, 77, 0.4);
  }
  
  .submit-btn:disabled {
    background: #6c757d;
    transform: none;
    box-shadow: none;
    cursor: not-allowed;
  }
  
  .note {
    color: #6c757d;
    font-size: 1rem;
    max-width: 600px;
    font-weight: 500;
  }
  
  /* Course Selection Styles */
  .course-card {
    background: #fff;
    border: 1px solid rgba(0,0,0,.06);
    border-radius: 20px;
    box-shadow: 0 8px 32px rgba(0,0,0,.08);
    padding: 40px;
    margin-bottom: 32px;
    max-width: 600px;
    margin-left: auto;
    margin-right: auto;
  }
  
  .form-label {
    font-weight: 700;
    color: #09294D;
    margin-bottom: 16px;
    font-size: 1.2rem;
    display: flex;
    align-items: center;
    gap: 12px;
  }
  
  .form-select {
    width: 100%;
    padding: 16px 20px;
    border: 2px solid #e9ecef;
    border-radius: 12px;
    font-size: 1.1rem;
    transition: all 0.3s ease;
    background: #fcfcfd;
    font-weight: 500;
    margin-bottom: 24px;
  }
  
  .form-select:focus {
    outline: none;
    border-color: #09294D;
    background: white;
    box-shadow: 0 0 0 4px rgba(9, 41, 77, 0.1);
  }
  
  .start-exam-btn {
    background: linear-gradient(135deg, #28a745, #20c997);
    border: none;
    border-radius: 14px;
    padding: 18px 40px;
    font-size: 1.2rem;
    font-weight: 700;
    color: white;
    cursor: pointer;
    transition: all 0.3s ease;
    width: 100%;
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 12px;
    box-shadow: 0 6px 20px rgba(40, 167, 69, 0.3);
  }
  
  .start-exam-btn:hover {
    transform: translateY(-3px);
    box-shadow: 0 8px 25px rgba(40, 167, 69, 0.4);
  }
  
  /* Result Display Styles */
  .result-card {
    background: #fff;
    border: 1px solid rgba(0,0,0,.06);
    border-radius: 20px;
    box-shadow: 0 8px 32px rgba(0,0,0,.08);
    padding: 40px;
    margin-bottom: 32px;
    max-width: 800px;
    margin-left: auto;
    margin-right: auto;
  }
  
  .result-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    gap: 24px;
    margin-top: 24px;
  }
  
  .result-item {
    background: #f8f9fa;
    padding: 24px;
    border-radius: 16px;
    border-left: 4px solid #D8A02E;
    transition: transform 0.3s ease;
  }
  
  .result-item:hover {
    transform: translateY(-4px);
  }
  
  .result-item strong {
    color: #09294D;
    display: block;
    margin-bottom: 12px;
    font-size: 1rem;
    font-weight: 700;
  }
  
  .result-value {
    color: #333;
    font-size: 1.3rem;
    font-weight: 700;
  }
  
  .status-pass {
    color: #28a745;
  }
  
  .status-fail {
    color: #dc3545;
  }
  
  .percentage-badge {
    background: linear-gradient(135deg, #17a2b8, #6f42c1);
    color: white;
    padding: 8px 20px;
    border-radius: 20px;
    font-weight: 700;
    display: inline-block;
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
    
    .submit-bar {
      left: 240px;
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
      padding-bottom: 160px;
    }
    
    .submit-bar {
      left: 0;
      padding: 16px 20px;
    }
    
    .page-header, .exam-header {
      flex-direction: column;
      gap: 16px;
      text-align: center;
    }
    
    .timer-container {
      align-items: center;
      width: 100%;
    }
    
    .progress-container {
      min-width: 100%;
    }
    
    .submit-inner {
      flex-direction: column;
      gap: 20px;
      text-align: center;
    }
    
    .submit-btn {
      width: 100%;
    }
    
    .question-header {
      flex-direction: column;
      gap: 16px;
      align-items: flex-start;
    }
    
    .result-grid {
      grid-template-columns: 1fr;
    }
  }
  
  @media (max-width: 480px) {
    .content-area {
      padding: 16px;
      padding-bottom: 180px;
    }
    
    .question-card, .course-card, .result-card {
      padding: 24px 20px;
    }
    
    .form-check {
      padding: 16px 18px;
    }
    
    .submit-inner {
      padding: 20px 24px;
    }
    
    .badge-time {
      min-width: 80px;
      font-size: 1rem;
    }
  }
</style>

<div class="exam-wrapper">
  <!-- SIDEBAR - KEPT YOUR EXACT LAYOUT -->
  <div class="sidebar">
    <div class="sidebar-background">
      <div style="text-align: center; margin: 20px 0 40px 0;">
        <img src="IMG/mut.png" alt="MUT Logo" class="mut-logo">
      </div>
      <div class="left-menu">
        <a href="std-page.jsp?pgprt=0"><i class="fas fa-user"></i><h2>Profile</h2></a>
        <a class="active" href="std-page.jsp?pgprt=1"><i class="fas fa-file-alt"></i><h2>Exams</h2></a>
        <a href="std-page.jsp?pgprt=2"><i class="fas fa-chart-line"></i><h2>Results</h2></a>
      </div>
    </div>
  </div>

  <div class="content-area">
  <% if ("1".equals(String.valueOf(session.getAttribute("examStarted")))) { %>

    <!-- Header -->
    <div class="exam-header">
      <div>
        <div class="page-title">
          <i class="fas fa-file-alt"></i>
          <%= request.getParameter("coursename") != null ? request.getParameter("coursename") : "Selected Course" %> Exam
        </div>
        <div class="note"><i class="fas fa-info-circle"></i>
          Answer all questions carefully. Your work is auto-submitted when time runs out.
        </div>
      </div>

      <div class="timer-container">
        <span class="badge-time" id="remainingTime">--:--</span>
        <div class="progress-container">
          <div class="progress-label">
            <span>Progress</span><span id="progressLabel">0%</span>
          </div>
          <div class="progress"><div class="progress-bar" id="progressBar" style="width:0%"></div></div>
        </div>
      </div>
    </div>

    <%
      ArrayList<Questions> questionsList = pDAO.getQuestions(request.getParameter("coursename"), 20);
      int totalQ = questionsList.size();
    %>

    <form id="myform" action="controller.jsp" method="post">
      <input type="hidden" name="page" value="exams">
      <input type="hidden" name="operation" value="submitted">
      <input type="hidden" name="size" value="<%= totalQ %>">
      <input type="hidden" name="totalmarks" value="<%= pDAO.getTotalMarksByName(request.getParameter("coursename")) %>">

      <% for (int i = 0; i < totalQ; i++) {
           Questions q = questionsList.get(i);

           // Declare isMultiTwo variable with proper scope
           boolean isMultiTwo = false;
           try {
             // Check if question contains "select two" or similar phrases
             String questionText = q.getQuestion() != null ? q.getQuestion().toLowerCase() : "";
             isMultiTwo = questionText.contains("select two") || 
                         questionText.contains("choose two") || 
                         questionText.contains("pick two") ||
                         questionText.contains("multiple answers") ||
                         questionText.contains("two options");
           } catch(Exception e) {
             isMultiTwo = false;
           }

           // Collect options in a small array-like list
           java.util.List<String> opts = new java.util.ArrayList<String>();
           if (q.getOpt1()!=null && !q.getOpt1().trim().isEmpty()) opts.add(q.getOpt1());
           if (q.getOpt2()!=null && !q.getOpt2().trim().isEmpty()) opts.add(q.getOpt2());
           if (q.getOpt3()!=null && !q.getOpt3().trim().isEmpty()) opts.add(q.getOpt3());
           if (q.getOpt4()!=null && !q.getOpt4().trim().isEmpty()) opts.add(q.getOpt4());
      %>

        <div class="question-card" data-qindex="<%= i %>">
          <div class="question-header">
            <div class="question-label"><%= i + 1 %></div>
            <div class="question-content">
              <% 
                // Check if this is a code question by looking for code patterns
                String questionText = q.getQuestion();
                boolean isCodeQuestion = questionText.contains("def ") || questionText.contains("function ") || 
                                        questionText.contains("public ") || questionText.contains("class ") ||
                                        questionText.contains("print(") || questionText.contains("console.") ||
                                        questionText.contains("<?php") || questionText.contains("import ") ||
                                        questionText.contains("int ") || questionText.contains("String ") ||
                                        questionText.contains("printf(") || questionText.contains("cout ");

                if (isCodeQuestion) {
              %>
                <div class="code-question-indicator">
                  <i class="fas fa-code"></i> 
                  <strong>Code Analysis Question</strong>
                </div>
              <% } %>
              <p class="question-text">
                <%=questionText.replace("```", "") %>
              </p>

              <% if (isCodeQuestion) { %>
              <% } %>
            </div>
          </div>

          <div class="answers" data-max-select="<%= isMultiTwo ? "2" : "1" %>">
            <% if (isMultiTwo) { %>
              <div class="multi-select-note">
                <i class="fas fa-check-double"></i> 
                <strong>Choose up to 2 answers</strong>
              </div>
            <% } %>

            <% for (int oi = 0; oi < opts.size(); oi++) {
                 String optVal = opts.get(oi);
                 String inputId = "q"+i+"o"+(oi+1);
            %>
              <div class="form-check">
                <input
                  class="form-check-input answer-input <%= isMultiTwo ? "multi" : "single" %>"
                  type="<%= isMultiTwo ? "checkbox" : "radio" %>"
                  id="<%= inputId %>"
                  name="<%= isMultiTwo ? ("ans"+i+"_"+oi) : ("ans"+i) %>"
                  value="<%= optVal %>"
                  data-qindex="<%= i %>"
                >
                <label class="form-check-label" for="<%= inputId %>"><%= optVal %></label>
              </div>
            <% } %>

            <% if (isMultiTwo) { %>
              <input type="hidden" id="ans<%= i %>-hidden" name="ans<%= i %>" value="">
            <% } %>
          </div>

          <!-- Hidden fields for controller -->
          <input type="hidden" name="question<%= i %>" value="<%= q.getQuestion() %>">
          <input type="hidden" name="qid<%= i %>" value="<%= q.getQuestionId() %>">
          <input type="hidden" name="qtype<%= i %>" value="<%= isMultiTwo ? "multi2" : "single" %>">
        </div>

      <% } // end for %>

      <!-- Submit bar -->
      <div class="submit-bar">
        <div class="submit-inner">
          <div class="note">
            <i class="fas fa-exclamation-triangle"></i>
            <strong>Important:</strong> Review all answers before submitting. Unanswered questions are marked incorrect.
          </div>
          <button type="button" id="submitBtn" class="submit-btn">
            <i class="fas fa-paper-plane"></i> Submit Exam
          </button>
        </div>
      </div>
    </form>

    <!-- Scripts: timer, selection limit (2), progress, submit -->
    <script>
      // --- Timer ---
      (function(){
        var time = <%= pDAO.getRemainingTime(Integer.parseInt(session.getAttribute("examId").toString())) %>;
        var sec = 60, timerEl = document.getElementById('remainingTime');
        var formEl = document.getElementById('myform');
        var tick = setInterval(function(){
          sec--; if (sec===0){ sec=60; time--; }
          if (time < 0){ 
            clearInterval(tick); 
            timerEl.textContent="00:00";
            timerEl.className='badge-time expired'; 
            window.onbeforeunload=null; 
            
            // Update all multi-select hidden fields before auto-submit
            document.querySelectorAll('.answers[data-max-select="2"]').forEach(function(box){
              var qindex = box.closest('.question-card').getAttribute('data-qindex');
              updateHiddenForMulti(qindex);
            });
            
            formEl.submit(); 
            return; 
          }
          var mm = String(Math.max(time,0)).padStart(2,'0');
          var ss = String(Math.max(sec,0)).padStart(2,'0');
          timerEl.textContent = mm+":"+ss;
          timerEl.className = 'badge-time ' + (time<5 ? 'warning' : '');
        }, 1000);
      })();

      // --- Helpers to gather per-question selections & update hidden for multi ---
      function updateHiddenForMulti(qindex){
        var box = document.querySelector('.question-card[data-qindex="'+qindex+'"] .answers');
        if(!box) return;
        var selectedValues = [];
        box.querySelectorAll('input.multi:checked').forEach(function(checkbox){
          selectedValues.push(checkbox.value);
        });
        var hidden = document.getElementById('ans'+qindex+'-hidden');
        if(hidden) hidden.value = selectedValues.join('|');
      }

      // --- Enforce "up to 2" for multi-select questions + UI highlight ---
      var dirty = false;
      document.addEventListener('change', function(e){
        if(!(e.target.classList && e.target.classList.contains('answer-input'))) return;

        var wrapper = e.target.closest('.answers');
        if(!wrapper) return;

        // Handle max select for multi (2)
        var maxSel = parseInt(wrapper.getAttribute('data-max-select') || '1', 10);
        if (e.target.classList.contains('multi')) {
          var checkedBoxes = wrapper.querySelectorAll('input.multi:checked');
          if (checkedBoxes.length > maxSel) {
            e.target.checked = false; // revert last click
            alert('You can only select up to ' + maxSel + ' options for this question.');
            return;
          }
          var qindex = e.target.getAttribute('data-qindex');
          updateHiddenForMulti(qindex);
        }

        // Update selected highlight
        document.querySelectorAll('.form-check').forEach(function(c){ c.classList.remove('selected'); });
        document.querySelectorAll('.answer-input:checked').forEach(function(inp){
          var fc = inp.closest('.form-check'); 
          if(fc) fc.classList.add('selected');
        });

        // Refresh progress
        updateProgress();
        dirty = true;
      });

      // --- Progress (counts single if 1 selected, multi if >=1 selected) ---
      function updateProgress(){
        var cards = document.querySelectorAll('.question-card');
        var answered = 0;
        cards.forEach(function(card){
          var box = card.querySelector('.answers');
          if(!box) return;
          var maxSel = parseInt(box.getAttribute('data-max-select')||'1',10);
          if (maxSel === 1) {
            if (box.querySelector('input.single:checked')) answered++;
          } else {
            if (box.querySelectorAll('input.multi:checked').length >= 1) answered++;
          }
        });
        var total = cards.length;
        var pct = total ? Math.round((answered/total)*100) : 0;
        document.getElementById('progressBar').style.width = pct + '%';
        document.getElementById('progressLabel').textContent = pct + '%';
      }
      
      // Initialize progress on load
      updateProgress();

      // --- Leave protection + submit ---
      window.onbeforeunload = function(){ 
        if(dirty) return "You have unsaved answers. Are you sure you want to leave?";
      };

      document.getElementById('submitBtn').addEventListener('click', function(){
        // ensure hidden values for all multi questions are up to date
        document.querySelectorAll('.answers[data-max-select="2"]').forEach(function(box){
          var qindex = box.closest('.question-card').getAttribute('data-qindex');
          updateHiddenForMulti(qindex);
        });

        var totalQuestions = <%= totalQ %>;
        var answeredQuestions = 0;
        
        // Count properly answered questions
        document.querySelectorAll('.question-card').forEach(function(card){
          var box = card.querySelector('.answers');
          if(!box) return;
          var maxSel = parseInt(box.getAttribute('data-max-select')||'1',10);
          if (maxSel === 1) {
            if (box.querySelector('input.single:checked')) answeredQuestions++;
          } else {
            if (box.querySelectorAll('input.multi:checked').length >= 1) answeredQuestions++;
          }
        });
        
        if (answeredQuestions < totalQuestions) {
          if(!confirm("You have answered " + answeredQuestions + " out of " + totalQuestions + " questions. Submit anyway?")) return;
        }
        
        if(confirm("Final confirmation: Submit your exam now?")) {
          window.onbeforeunload = null;
          var btn = document.getElementById('submitBtn');
          btn.disabled = true; 
          btn.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Submitting...';
          document.getElementById('myform').submit();
        }
      });
    </script>

  <% } else if ("1".equals(request.getParameter("showresult"))) {
       Exams result = pDAO.getResultByExamId(Integer.parseInt(request.getParameter("eid")));
  %>
    <!-- RESULTS -->
    <div class="page-header">
      <div class="page-title"><i class="fas fa-chart-line"></i> Exam Result</div>
      <div class="stats-badge"><i class="fas fa-graduation-cap"></i> <%= result.getStatus() %></div>
    </div>

    <div class="result-card">
      <div class="result-grid">
        <div class="result-item"><strong><i class="fas fa-calendar-alt"></i> Exam Date</strong><div class="result-value"><%= result.getDate() %></div></div>
        <div class="result-item"><strong><i class="fas fa-book"></i> Course Name</strong><div class="result-value"><%= result.getcName() %></div></div>
        <div class="result-item"><strong><i class="fas fa-clock"></i> Start Time</strong><div class="result-value"><%= result.getStartTime() %></div></div>
        <div class="result-item"><strong><i class="fas fa-clock"></i> End Time</strong><div class="result-value"><%= result.getEndTime() %></div></div>
        <div class="result-item"><strong><i class="fas fa-star"></i> Obtained Marks</strong><div class="result-value"><%= result.getObtMarks() %></div></div>
        <div class="result-item"><strong><i class="fas fa-star-half-alt"></i> Total Marks</strong><div class="result-value"><%= result.gettMarks() %></div></div>
        <div class="result-item">
          <strong><i class="fas fa-flag"></i> Result Status</strong>
          <div class="result-value <%= result.getStatus().equalsIgnoreCase("Pass") ? "status-pass" : "status-fail" %>">
            <i class="fas <%= result.getStatus().equalsIgnoreCase("Pass") ? "fa-check-circle" : "fa-times-circle" %>"></i>
            <%= result.getStatus() %>
          </div>
        </div>
        <div class="result-item">
          <strong><i class="fas fa-chart-pie"></i> Percentage</strong>
          <div class="result-value">
            <%
              double percentage = 0;
              if (result.gettMarks() > 0) percentage = (double) result.getObtMarks() / result.gettMarks() * 100;
            %>
            <span class="percentage-badge"><%= String.format("%.1f", percentage) %>%</span>
          </div>
        </div>
      </div>
    </div>

  <% } else { %>
    <!-- COURSE PICKER -->
    <div class="page-header">
      <div class="page-title"><i class="fas fa-pencil-alt"></i> Start New Exam</div>
      <div class="stats-badge"><i class="fas fa-play-circle"></i> Ready to Start</div>
    </div>

    <div class="course-card">
      <form action="controller.jsp" method="post">
        <input type="hidden" name="page" value="exams">
        <input type="hidden" name="operation" value="startexam">
        <label class="form-label"><i class="fas fa-book"></i> Select Course</label>
        <select name="coursename" class="form-select" required>
          <option value="">Choose a course...</option>
          <%
            ArrayList<String> courseList = pDAO.getAllCourseNames();
            for (String course : courseList) {
          %>
            <option value="<%= course %>"><%= course %></option>
          <% } %>
        </select>
        <button type="submit" class="start-exam-btn"><i class="fas fa-play"></i> Start Exam</button>
      </form>
    </div>
  <% } %>
  </div>
</div>

<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">