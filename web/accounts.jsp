<%@page import="myPackage.classes.User"%>
<%@page import="java.util.ArrayList"%>
<jsp:useBean id="pDAO" class="myPackage.DatabaseClass" scope="page"/>

<style>
  /* Enhanced Student Accounts Page Styles */
  .accounts-wrapper {
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
    max-height: 150px;
  }
  
  .accounts-card {
    background: #fff;
    border: 1px solid rgba(0,0,0,.06);
    border-radius: 20px;
    box-shadow: 0 8px 32px rgba(0,0,0,.08);
    padding: 0;
    margin-bottom: 32px;
    overflow: hidden;
    transition: transform 0.3s ease, box-shadow 0.3s ease;
  }
  
  .accounts-card:hover {
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
  
  /* Search and Actions Bar */
  .actions-bar {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 24px 32px;
    background: #f8f9fa;
    border-bottom: 1px solid #e9ecef;
  }
  
  .search-container {
    position: relative;
    flex: 1;
    max-width: 400px;
  }
  
  .search-input {
    width: 100%;
    padding: 14px 52px 14px 20px;
    border: 2px solid #e9ecef;
    border-radius: 12px;
    font-size: 1rem;
    transition: all 0.3s ease;
    background: #fff;
    font-weight: 500;
    box-shadow: 0 4px 12px rgba(0,0,0,.06);
  }
  
  .search-input:focus {
    outline: none;
    border-color: #09294D;
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
  
  .add-student-btn {
    background: linear-gradient(135deg, #28a745, #20c997);
    color: white;
    border: none;
    border-radius: 12px;
    padding: 14px 28px;
    font-size: 1rem;
    font-weight: 700;
    cursor: pointer;
    transition: all 0.3s ease;
    text-decoration: none;
    display: inline-flex;
    align-items: center;
    gap: 10px;
    box-shadow: 0 6px 20px rgba(40, 167, 69, 0.3);
  }
  
  .add-student-btn:hover {
    transform: translateY(-3px);
    box-shadow: 0 8px 25px rgba(40, 167, 69, 0.4);
    color: white;
    text-decoration: none;
  }
  
  /* Table Styles */
  .accounts-table {
    width: 100%;
    border-collapse: collapse;
    background: #fff;
  }
  
  .accounts-table thead th {
    background: #f8f9fa;
    color: #09294D;
    padding: 20px 16px;
    font-weight: 700;
    text-align: left;
    border-bottom: 2px solid #e9ecef;
    font-size: 1rem;
  }
  
  .accounts-table tbody td {
    padding: 20px 16px;
    border-bottom: 1px solid #f0f0f0;
    vertical-align: middle;
    color: #333;
    font-weight: 500;
  }
  
  .accounts-table tbody tr {
    transition: all 0.3s ease;
  }
  
  .accounts-table tbody tr:hover {
    background: #f8f9fa;
    transform: scale(1.01);
  }
  
  .student-name {
    font-weight: 700;
    color: #09294D;
    font-size: 1.1rem;
    display: flex;
    align-items: center;
    gap: 12px;
  }
  
  .student-avatar {
    width: 40px;
    height: 40px;
    background: linear-gradient(135deg, #D8A02E, #09294D);
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-weight: 700;
    font-size: 1rem;
  }
  
  .student-number {
    background: linear-gradient(135deg, #17a2b8, #6f42c1);
    color: white;
    padding: 6px 12px;
    border-radius: 20px;
    font-weight: 600;
    font-size: 0.9rem;
    display: inline-block;
  }
  
  .contact-info {
    color: #6c757d;
    font-size: 0.95rem;
  }
  
  .location-info {
    color: #6c757d;
    font-size: 0.95rem;
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
  
  .no-students {
    text-align: center;
    padding: 60px 40px;
    color: #6c757d;
    font-style: italic;
    font-size: 1.1rem;
  }
  
  .students-count {
    display: flex;
    align-items: center;
    gap: 8px;
    background: #f8f9fa;
    padding: 8px 16px;
    border-radius: 20px;
    font-weight: 600;
    color: #09294D;
  }
  
  /* User Role Badge */
  .user-role {
    display: inline-block;
    background: linear-gradient(135deg, #D8A02E, #e6b450);
    color: white;
    padding: 4px 12px;
    border-radius: 15px;
    font-weight: 600;
    font-size: 0.8rem;
    margin-left: 8px;
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
    
    .actions-bar {
      flex-direction: column;
      gap: 16px;
      align-items: stretch;
    }
    
    .search-container {
      max-width: 100%;
    }
    
    .accounts-table {
      display: block;
      overflow-x: auto;
    }
    
    .add-student-btn {
      width: 100%;
      justify-content: center;
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
    
    .actions-bar {
      padding: 20px 24px;
    }
    
    .accounts-table thead th,
    .accounts-table tbody td {
      padding: 16px 12px;
      font-size: 0.9rem;
    }
    
    .student-name {
      flex-direction: column;
      align-items: flex-start;
      gap: 8px;
    }
    
    .delete-btn {
      padding: 8px 16px;
      font-size: 0.8rem;
    }
  }
</style>

<div class="accounts-wrapper">
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
        <a href="adm-page.jsp?pgprt=5">
          <i class="fas fa-chart-bar"></i>
          <h2>Students Results</h2>
        </a>
        <a class="active" href="adm-page.jsp?pgprt=1">
          <i class="fas fa-user-graduate"></i>
          <h2>Student Accounts</h2>
        </a>
        <a href="adm-page.jsp?pgprt=6">
          <i class="fas fa-chalkboard-teacher"></i>
          <h2>Lecture Accounts</h2>
        </a>
      </div>
    </div>
  </div>

  <!-- CONTENT AREA -->
  <div class="content-area">
    <div class="accounts-panel">
      <!-- Page Header -->
      <div class="page-header">
        <div class="page-title">
          <i class="fas fa-user-graduate"></i>
          Student Accounts Management
        </div>
        <div class="stats-badge">
          <%
            User currentUser = pDAO.getUserDetails(session.getAttribute("userId").toString());
            ArrayList<User> studentList = pDAO.getAllStudents();
            int studentCount = 0;
            for (User user : studentList) {
              if (user.getUserId() != Integer.parseInt(session.getAttribute("userId").toString())) {
                if (currentUser.getType().equalsIgnoreCase("lecture") && user.getType().equalsIgnoreCase("student") ||
                    currentUser.getType().equalsIgnoreCase("admin")) {
                  studentCount++;
                }
              }
            }
          %>
          <i class="fas fa-users"></i>
          <%= studentCount %> Students
        </div>
      </div>

      <!-- Student Accounts Card -->
      <div class="accounts-card">
        <div class="card-header">
          <span><i class="fas fa-list"></i> All Registered Students</span>
          <div class="students-count">
            <i class="fas fa-layer-group"></i>
            Total: <%= studentCount %>
          </div>
        </div>
        
        <!-- Search and Actions Bar -->
        <div class="actions-bar">
          <a href="signup.jsp?from=account" class="add-student-btn">
            <i class="fas fa-plus-circle"></i>
            Add New Student
          </a>
          
          <div class="search-container">
            <input type="text" id="studentSearch" class="search-input" placeholder="Search by Student No, Name, or Email...">
            <i class="fas fa-search search-icon"></i>
          </div>
        </div>
        
        <div style="overflow-x: auto;">
          <table class="accounts-table">
            <thead>
              <tr>
                <th>Student</th>
                <th>Student Number</th>
                <th>Email</th>
                <th>Contact</th>
                <th>Location</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody id="studentTableBody">
              <%
                boolean hasStudents = false;
                for (User user : studentList) {
                  if (user.getUserId() != Integer.parseInt(session.getAttribute("userId").toString())) {
                    if (currentUser.getType().equalsIgnoreCase("lecture") && user.getType().equalsIgnoreCase("student") ||
                        currentUser.getType().equalsIgnoreCase("admin")) {
                      hasStudents = true;
                      String initials = user.getFirstName().substring(0, 1) + user.getLastName().substring(0, 1);
              %>
              <tr>
                <td>
                  <div class="student-name">
                    <div class="student-avatar">
                      <%= initials %>
                    </div>
                    <div>
                      <%= user.getFirstName() + " " + user.getLastName() %>
                      <span class="user-role">Student</span>
                    </div>
                  </div>
                </td>
                <td>
                  <span class="student-number">
                    <i class="fas fa-id-card"></i>
                    <%= user.getUserName() %>
                  </span>
                </td>
                <td class="contact-info">
                  <i class="fas fa-envelope" style="color: #D8A02E; margin-right: 8px;"></i>
                  <%= user.getEmail() %>
                </td>
                <td class="contact-info">
                  <i class="fas fa-phone" style="color: #28a745; margin-right: 8px;"></i>
                  <%= user.getContact() %>
                </td>
                <td class="location-info">
                  <i class="fas fa-map-marker-alt" style="color: #17a2b8; margin-right: 8px;"></i>
                  <%= user.getCity() %>, <%= user.getAddress() %>
                </td>
                <td>
                  <a href="controller.jsp?page=accounts&operation=del&uid=<%= user.getUserId() %>" 
                     onclick="return confirm('Are you sure you want to delete student \"<%= user.getFirstName() %> <%= user.getLastName() %>\"? This action cannot be undone.');" 
                     class="delete-btn">
                     <i class="fas fa-trash"></i>
                     Delete
                  </a>
                </td>
              </tr>
              <%
                    }
                  }
                }
                
                if (!hasStudents) {
              %>
                <tr>
                  <td colspan="6" class="no-students">
                    <i class="fas fa-user-graduate" style="font-size: 3rem; margin-bottom: 16px; display: block; opacity: 0.5;"></i>
                    No students registered yet. Add your first student to get started.
                  </td>
                </tr>
              <%
                }
              %>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</div>

<!-- Font Awesome for Icons -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">

<script>
  // Function to filter students
  document.getElementById('studentSearch').onkeyup = function() {
    var input = this.value.toLowerCase();
    var table = document.getElementById("studentTableBody");
    var rows = table.getElementsByTagName("tr");
    
    for (var i = 0; i < rows.length; i++) {
      var cells = rows[i].getElementsByTagName("td");
      var match = false;
      
      if (cells.length > 0) {
        // Search in student number, name, and email
        const studentNumber = cells[1].textContent.toLowerCase();
        const studentName = cells[0].textContent.toLowerCase();
        const email = cells[2].textContent.toLowerCase();
        
        if (studentNumber.includes(input) || studentName.includes(input) || email.includes(input)) {
          match = true;
        }
        
        rows[i].style.display = match ? "" : "none";
      }
    }
  };

  // Add loading animation
  window.onload = function() {
    const tableBody = document.getElementById('studentTableBody');
    const rows = tableBody.getElementsByTagName('tr');
    
    // Add animation delay for each row
    Array.from(rows).forEach((row, index) => {
      if (row.style.display !== 'none') {
        row.style.animationDelay = `${index * 0.1}s`;
        row.classList.add('fade-in');
      }
    });
  };
</script>