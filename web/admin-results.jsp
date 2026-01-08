<%@page import="myPackage.classes.Answers"%>
<%@page import="myPackage.classes.Exams"%>
<%@page import="myPackage.classes.Questions"%>
<%@page import="java.util.ArrayList"%>
<jsp:useBean id="pDAO" class="myPackage.DatabaseClass" scope="page"/>

<style>
  /* Enhanced Results Page Styles */
  .results-wrapper {
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
  
  .stats-badge {
    background: linear-gradient(135deg, #e3e3e3, #09294D);
    color: white;
    padding: 8px 20px;
    border-radius: 25px;
    font-weight: 700;
    font-size: 1.1rem;
    box-shadow: 0 4px 12px rgba(216, 160, 46, 0.3);
  }
  
  .mut-logo {
    max-height: 150px;
  }
  
  .results-card {
    background: #fff;
    border: 1px solid rgba(0,0,0,.06);
    border-radius: 20px;
    box-shadow: 0 8px 32px rgba(0,0,0,.08);
    padding: 0;
    margin-bottom: 32px;
    overflow: hidden;
    transition: transform 0.3s ease, box-shadow 0.3s ease;
  }
  
  .results-card:hover {
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
  
  /* Search Styles */
  .search-container {
    position: relative;
    margin-bottom: 24px;
  }
  
  .search-input {
    width: 100%;
    padding: 16px 52px 16px 20px;
    border: 2px solid #e9ecef;
    border-radius: 12px;
    font-size: 1rem;
    transition: all 0.3s ease;
    background: #fcfcfd;
    font-weight: 500;
    box-shadow: 0 4px 12px rgba(0,0,0,.06);
  }
  
  .search-input:focus {
    outline: none;
    border-color: #09294D;
    background: white;
    box-shadow: 0 0 0 4px rgba(9, 41, 77, 0.1);
  }
  
  .search-icon {
    position: absolute;
    right: 20px;
    top: 50%;
    transform: translateY(-50%);
    color: #6c757d;
    font-size: 1.1rem;
  }
  
  /* Table Styles */
  .results-table {
    width: 100%;
    border-collapse: collapse;
    background: #fff;
  }
  
  .results-table thead th {
    background: #f8f9fa;
    color: #09294D;
    padding: 20px 16px;
    font-weight: 700;
    text-align: center;
    border-bottom: 2px solid #e9ecef;
    font-size: 1rem;
    cursor: pointer;
    transition: all 0.3s ease;
    position: relative;
  }
  
  .results-table thead th:hover {
    background: #e9ecef;
  }
  
  .results-table tbody td {
    padding: 20px 16px;
    border-bottom: 1px solid #f0f0f0;
    vertical-align: middle;
    color: #333;
    font-weight: 500;
    text-align: center;
  }
  
  .results-table tbody tr {
    transition: all 0.3s ease;
  }
  
  .results-table tbody tr:hover {
    background: #f8f9fa;
    transform: scale(1.01);
  }
  
  /* Status Badges */
  .status-badge {
    padding: 8px 16px;
    border-radius: 20px;
    font-weight: 700;
    font-size: 0.9rem;
    display: inline-block;
    min-width: 80px;
  }
  
  .status-pass {
    background: linear-gradient(135deg, #28a745, #20c997);
    color: white;
    box-shadow: 0 4px 12px rgba(40, 167, 69, 0.3);
  }
  
  .status-fail {
    background: linear-gradient(135deg, #dc3545, #c82333);
    color: white;
    box-shadow: 0 4px 12px rgba(220, 53, 69, 0.3);
  }
  
  .status-terminated {
    background: linear-gradient(135deg, #ffc107, #fd7e14);
    color: white;
    box-shadow: 0 4px 12px rgba(255, 193, 7, 0.3);
  }
  
  /* Percentage Badge */
  .percentage-badge {
    background: linear-gradient(135deg, #17a2b8, #6f42c1);
    color: white;
    padding: 8px 16px;
    border-radius: 20px;
    font-weight: 700;
    font-size: 0.9rem;
    display: inline-block;
    min-width: 60px;
    box-shadow: 0 4px 12px rgba(23, 162, 184, 0.3);
  }
  
  /* Action Button */
  .action-btn {
    background: linear-gradient(135deg, #e3e3e3, #09294D);
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
    box-shadow: 0 4px 12px rgba(9, 41, 77, 0.3);
  }
  
  .action-btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(9, 41, 77, 0.4);
    color: white;
    text-decoration: none;
  }
  
  /* Details Table Styles */
  .details-table {
    width: 100%;
    border-collapse: collapse;
    background: #fff;
    margin-top: 0;
  }
  
  .details-table tr {
    border-bottom: 1px solid #f0f0f0;
    transition: all 0.3s ease;
  }
  
  .details-table tr:hover {
    background: #f8f9fa;
  }
  
  .details-table td {
    padding: 20px 16px;
    vertical-align: top;
    color: #333;
    font-weight: 500;
  }
  
  .question-number {
    background: linear-gradient(135deg, #09294D, #1a3d6d);
    color: white;
    width: 40px;
    height: 40px;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-weight: 700;
    font-size: 1rem;
    margin: 0 auto;
  }
  
  .question-text {
    font-weight: 600;
    color: #09294D;
    font-size: 1.1rem;
    line-height: 1.5;
  }
  
  .answer-text {
    color: #333;
    font-weight: 500;
    line-height: 1.5;
  }
  
  .correct-answer {
    color: #28a745;
    font-weight: 600;
  }
  
  .incorrect-answer {
    color: #dc3545;
    font-weight: 600;
  }
  
  .status-correct {
    color: #28a745;
    font-weight: 700;
    text-transform: uppercase;
  }
  
  .status-incorrect {
    color: #dc3545;
    font-weight: 700;
    text-transform: uppercase;
  }
  
  /* Back Button */
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
  
  /* Sort Indicator */
  .sort-indicator {
    margin-left: 8px;
    display: inline-block;
    transition: transform 0.3s ease;
  }
  
  .rotate .sort-indicator {
    transform: rotate(180deg);
  }
  
  /* No Results Message */
  .no-results {
    text-align: center;
    padding: 60px 40px;
    color: #6c757d;
    font-style: italic;
    font-size: 1.1rem;
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
    
    .results-table {
      display: block;
      overflow-x: auto;
    }
    
    .details-table {
      display: block;
      overflow-x: auto;
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
    
    .results-table thead th,
    .results-table tbody td {
      padding: 16px 12px;
      font-size: 0.9rem;
    }
    
    .action-btn {
      padding: 8px 16px;
      font-size: 0.8rem;
    }
  }
</style>

<div class="results-wrapper">
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
        <a href="adm-page.jsp?pgprt=3">
          <i class="fas fa-question-circle"></i>
          <h2>Questions</h2>
        </a>
        <a class="active" href="adm-page.jsp?pgprt=5">
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
    <div class="results-panel">
      <!-- Page Header -->
      <div class="page-header">
        <div class="page-title">
          <i class="fas fa-chart-bar"></i>
          Student Results
        </div>
        <div class="stats-badge">
          <i class="fas fa-graduation-cap"></i>
          Performance Analytics
        </div>
      </div>

      <!-- Search Section -->
      <div class="search-container">
        <input type="text" id="searchBox" class="search-input" placeholder="Search by Student ID, Name, or Course..." onkeyup="filterTable()">
        <i class="fas fa-search search-icon"></i>
      </div>

      <!-- Results Card -->
      <div class="results-card">
        <div class="card-header">
          <span><i class="fas fa-list"></i> All Student Results</span>
          <div class="stats-badge" style="background: linear-gradient(135deg, #28a745, #20c997);">
            <i class="fas fa-database"></i>
            <% 
              ArrayList<Exams> list = pDAO.getResultsFromExams();
              int totalResults = list.size();
            %>
            <%= totalResults %> Results
          </div>
        </div>
        
        <%
          if (request.getParameter("eid") == null) {
        %>
        <div style="overflow-x: auto;">
          <table class="results-table">
            <thead>
              <tr>
                <th onclick="toggleSort(this, 'name')">
                  Name & Surname
                  <i class="fas fa-sort sort-indicator"></i>
                </th>
                <th onclick="toggleSort(this, 'studentId')">
                  Student ID
                  <i class="fas fa-sort sort-indicator"></i>
                </th>
                <th onclick="toggleSort(this, 'email')">
                  Email
                  <i class="fas fa-sort sort-indicator"></i>
                </th>
                <th onclick="toggleSort(this, 'date')">
                  Date
                  <i class="fas fa-sort sort-indicator"></i>
                </th>
                <th onclick="toggleSort(this, 'course')">
                  Course
                  <i class="fas fa-sort sort-indicator"></i>
                </th>
                <th onclick="toggleSort(this, 'time')">
                  Time
                  <i class="fas fa-sort sort-indicator"></i>
                </th>
                <th onclick="toggleSort(this, 'marks')">
                  Marks
                  <i class="fas fa-sort sort-indicator"></i>
                </th>
                <th onclick="toggleSort(this, 'status')">
                  Status
                  <i class="fas fa-sort sort-indicator"></i>
                </th>
                <th onclick="toggleSort(this, 'percentage')">
                  %
                  <i class="fas fa-sort sort-indicator"></i>
                </th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody id="resultsTableBody">
              <% 
                if (list.isEmpty()) {
              %>
                <tr>
                  <td colspan="10" class="no-results">
                    <i class="fas fa-inbox" style="font-size: 3rem; margin-bottom: 16px; display: block; opacity: 0.5;"></i>
                    No results available. Students need to complete exams to see results here.
                  </td>
                </tr>
              <%
                } else {
                  for (int i = 0; i < list.size(); i++) {
                    Exams e = list.get(i);
                    double percentage = 0;
                    if (e.gettMarks() > 0) {
                      percentage = (double) e.getObtMarks() / e.gettMarks() * 100;
                    }
              %>
              <tr>
                <td class="student-name"><%= e.getFullName() %></td>
                <td class="student-id"><%= e.getUserName() %></td>
                <td class="student-email"><%= e.getEmail() %></td>
                <td class="exam-date"><%= e.getDate() %></td>
                <td class="course-name"><%= e.getcName() %></td>
                <td class="exam-time"><%= e.getStartTime() + " - " + e.getEndTime() %></td>
                <td class="exam-marks"><%= e.getObtMarks() %> / <%= e.gettMarks() %></td>
                <td>
                  <% 
                    if (e.getStatus() != null) {
                      if (e.getStatus().equals("Pass")) { 
                  %>
                    <span class="status-badge status-pass">
                      <i class="fas fa-check-circle"></i>
                      <%= e.getStatus() %>
                    </span>
                  <% } else { %>
                    <span class="status-badge status-fail">
                      <i class="fas fa-times-circle"></i>
                      <%= e.getStatus() %>
                    </span>
                  <% } 
                    } else { %>
                    <span class="status-badge status-terminated">
                      <i class="fas fa-exclamation-triangle"></i>
                      Terminated
                    </span>
                  <% } %>
                </td>
                <td>
                  <span class="percentage-badge">
                    <%= String.format("%.0f", percentage) %>%
                  </span>
                </td>
                <td>
                  <a href="adm-page.jsp?pgprt=5&eid=<%= e.getExamId() %>" class="action-btn">
                    <i class="fas fa-eye"></i>
                    Details
                  </a>
                </td>
              </tr>
              <% 
                  }
                } 
              %>
            </tbody>
          </table>
        </div>
        <%
          } else {
        %>
        <!-- Details View -->
        <div style="padding: 24px;">
          <a href="adm-page.jsp?pgprt=5" class="back-btn">
            <i class="fas fa-arrow-left"></i>
            Back to All Results
          </a>
          
          <div class="card-header" style="margin-bottom: 24px; border-radius: 12px;">
            <span><i class="fas fa-file-alt"></i> Exam Result Details</span>
            <i class="fas fa-clipboard-check" style="opacity: 0.8;"></i>
          </div>
          
          <table class="details-table">
            <%
              ArrayList<Answers> answersList = pDAO.getAllAnswersByExamId(
                Integer.parseInt(request.getParameter("eid"))
              );
              for (int i = 0; i < answersList.size(); i++) {
                Answers a = answersList.get(i);
            %>
            <tr>
              <td style="width: 60px; text-align: center;">
                <div class="question-number">
                  <%= i + 1 %>
                </div>
              </td>
              <td colspan="2">
                <div class="question-text">
                  <%= a.getQuestion() %>
                </div>
              </td>
              <td style="width: 100px; text-align: center;">
                <% if (a.getStatus().equals("correct")) { %>
                  <span class="status-correct">
                    <i class="fas fa-check"></i>
                    <%= a.getStatus() %>
                  </span>
                <% } else { %>
                  <span class="status-incorrect">
                    <i class="fas fa-times"></i>
                    <%= a.getStatus() %>
                  </span>
                <% } %>
              </td>
            </tr>
            <tr>
              <td></td>
              <td style="width: 50%;">
                <div class="answer-text">
                  <strong>Your Answer:</strong> 
                  <span class="<%= a.getStatus().equals("correct") ? "correct-answer" : "incorrect-answer" %>">
                    <%= a.getAnswer() %>
                  </span>
                </div>
              </td>
              <td style="width: 50%;">
                <div class="answer-text">
                  <strong>Correct Answer:</strong> 
                  <span class="correct-answer">
                    <%= a.getCorrectAns() %>
                  </span>
                </div>
              </td>
              <td></td>
            </tr>
            <% } %>
          </table>
        </div>
        <%
          }
        %>
      </div>
    </div>
  </div>
</div>

<!-- Font Awesome for Icons -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

<script>
  let currentSort = {
    column: null,
    direction: 'asc'
  };

  function toggleSort(header, column) {
    const table = document.querySelector('.results-table');
    const tbody = document.getElementById('resultsTableBody');
    const rows = Array.from(tbody.rows);
    const indicator = header.querySelector('.sort-indicator');
    
    // Remove rotate class from all indicators
    document.querySelectorAll('.sort-indicator').forEach(ind => {
      ind.classList.remove('rotate');
    });
    
    // Toggle direction if clicking the same column
    if (currentSort.column === column) {
      currentSort.direction = currentSort.direction === 'asc' ? 'desc' : 'asc';
    } else {
      currentSort.column = column;
      currentSort.direction = 'asc';
    }
    
    // Add rotate class for descending sort
    if (currentSort.direction === 'desc') {
      indicator.classList.add('rotate');
    }
    
    // Sort rows
    rows.sort((a, b) => {
      const cellA = a.querySelector(`.${column}`).textContent.trim();
      const cellB = b.querySelector(`.${column}`).textContent.trim();
      
      if (column === 'marks' || column === 'percentage') {
        const numA = parseFloat(cellA.replace(/[^\d.]/g, ''));
        const numB = parseFloat(cellB.replace(/[^\d.]/g, ''));
        return currentSort.direction === 'asc' ? numA - numB : numB - numA;
      } else {
        return currentSort.direction === 'asc' 
          ? cellA.localeCompare(cellB)
          : cellB.localeCompare(cellA);
      }
    });
    
    // Reappend sorted rows
    rows.forEach(row => tbody.appendChild(row));
  }

  function filterTable() {
    const input = document.getElementById('searchBox');
    const filter = input.value.toLowerCase();
    const tableBody = document.getElementById('resultsTableBody');
    const rows = tableBody.getElementsByTagName('tr');

    for (let i = 0; i < rows.length; i++) {
      const cells = rows[i].getElementsByTagName('td');
      let showRow = false;
      
      if (cells.length > 0) {
        // Search in student ID, name, email, and course
        const studentId = cells[1].textContent.toLowerCase();
        const studentName = cells[0].textContent.toLowerCase();
        const studentEmail = cells[2].textContent.toLowerCase();
        const courseName = cells[4].textContent.toLowerCase();
        
        if (studentId.includes(filter) || studentName.includes(filter) || 
            studentEmail.includes(filter) || courseName.includes(filter)) {
          showRow = true;
        }
      }
      
      rows[i].style.display = showRow ? "" : "none";
    }
  }

  // Initialize page
  window.onload = function() {
    // Add any initialization code here if needed
  };
</script>