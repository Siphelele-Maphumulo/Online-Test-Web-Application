<%@page import="myPackage.classes.User"%>
<%@page import="java.util.ArrayList"%>
<jsp:useBean id="pDAO" class="myPackage.DatabaseClass" scope="page"/>

<style>
  /* Enhanced Profile Page Styles */
  .profile-wrapper {
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
  
  .profile-card {
    background: #fff;
    border: 1px solid rgba(0,0,0,.06);
    border-radius: 20px;
    box-shadow: 0 8px 32px rgba(0,0,0,.08);
    padding: 0;
    margin-bottom: 32px;
    overflow: hidden;
    transition: transform 0.3s ease, box-shadow 0.3s ease;
  }
  
  .profile-card:hover {
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
  
  .profile-content {
    padding: 32px;
  }
  
  .profile-header {
    display: flex;
    align-items: center;
    gap: 24px;
    margin-bottom: 32px;
    padding-bottom: 24px;
    border-bottom: 1px solid #f0f0f0;
  }
  
  .avatar {
    width: 100px;
    height: 100px;
    background: linear-gradient(135deg, #D8A02E, #09294D);
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    font-size: 2.5rem;
    font-weight: 700;
    box-shadow: 0 8px 20px rgba(9, 41, 77, 0.2);
  }
  
  .user-info h2 {
    margin: 0 0 8px 0;
    color: #09294D;
    font-size: 1.75rem;
    font-weight: 800;
  }
  
  .user-email {
    color: #6c757d;
    font-size: 1.1rem;
    margin: 0 0 12px 0;
  }
  
  .user-role {
    display: inline-block;
    background: linear-gradient(135deg, #D8A02E, #e6b450);
    color: white;
    padding: 8px 20px;
    border-radius: 20px;
    font-weight: 700;
    font-size: 0.9rem;
    box-shadow: 0 4px 12px rgba(216, 160, 46, 0.3);
  }
  
  .profile-info {
    display: grid;
    gap: 0;
  }
  
  .info-item {
    display: flex;
    align-items: center;
    padding: 20px 0;
    border-bottom: 1px solid #f0f0f0;
    transition: all 0.3s ease;
  }
  
  .info-item:hover {
    background: #f8f9fa;
    transform: translateX(8px);
    border-radius: 12px;
    padding-left: 16px;
  }
  
  .info-item:last-child {
    border-bottom: none;
  }
  
  .info-tag {
    background: linear-gradient(135deg, #09294D, #1a3d6d);
    color: white;
    padding: 12px 24px;
    border-radius: 12px;
    font-weight: 700;
    min-width: 160px;
    text-align: center;
    margin-right: 24px;
    flex-shrink: 0;
    box-shadow: 0 4px 12px rgba(9, 41, 77, 0.2);
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 8px;
  }
  
  .info-value {
    font-weight: 600;
    color: #333;
    font-size: 1.1rem;
    flex: 1;
  }
  
  .form-button {
    background: linear-gradient(135deg, #D8A02E, #09294D);
    border: none;
    border-radius: 12px;
    padding: 16px 32px;
    font-size: 1.1rem;
    font-weight: 700;
    color: white;
    cursor: pointer;
    transition: all 0.3s ease;
    text-decoration: none;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    gap: 12px;
    box-shadow: 0 6px 20px rgba(9, 41, 77, 0.3);
    min-width: 180px;
  }
  
  .form-button:hover {
    transform: translateY(-3px);
    box-shadow: 0 8px 25px rgba(9, 41, 77, 0.4);
    color: white;
    text-decoration: none;
  }
  
  .button-container {
    text-align: center;
    margin-top: 32px;
    padding-top: 24px;
    border-top: 1px solid #f0f0f0;
  }
  
  /* Edit form styles */
  .edit-form {
    padding: 32px;
  }
  
  .form-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
    gap: 24px;
    margin-bottom: 32px;
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
  
  .form-actions {
    display: flex;
    justify-content: center;
    gap: 16px;
    padding-top: 24px;
    border-top: 1px solid #f0f0f0;
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
  
  /* User type specific styles */
  .admin-badge {
    background: linear-gradient(135deg, #28a745, #20c997);
  }
  
  .lecturer-badge {
    background: linear-gradient(135deg, #17a2b8, #6f42c1);
  }
  
  .student-badge {
    background: linear-gradient(135deg, #D8A02E, #e6b450);
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
    
    .profile-header {
      flex-direction: column;
      text-align: center;
      gap: 16px;
    }
    
    .info-item {
      flex-direction: column;
      align-items: flex-start;
      gap: 12px;
    }
    
    .info-tag {
      min-width: auto;
      width: 100%;
      margin-right: 0;
    }
    
    .form-actions {
      flex-direction: column;
    }
    
    .form-button, .reset-btn {
      width: 100%;
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
    
    .profile-content, .edit-form {
      padding: 24px 20px;
    }
    
    .avatar {
      width: 80px;
      height: 80px;
      font-size: 2rem;
    }
  }
</style>

<%
    User user = pDAO.getUserDetails(session.getAttribute("userId").toString());
    String userInitials = user.getFirstName().substring(0, 1) + user.getLastName().substring(0, 1);
    String userRoleClass = "";
    
    if (user.getType().equalsIgnoreCase("admin")) {
        userRoleClass = "admin-badge";
    } else if (user.getType().equalsIgnoreCase("lecture")) {
        userRoleClass = "lecturer-badge";
    } else {
        userRoleClass = "student-badge";
    }

    // Check if the user is either an admin or a lecturer
    if (user.getType().equalsIgnoreCase("admin") || user.getType().equalsIgnoreCase("lecture")) {
%>
<div class="profile-wrapper">
  <!-- SIDEBAR -->
  <div class="sidebar">
    <div class="sidebar-background">
      <div style="text-align: center; margin: 20px 0 40px 0;">
        <img src="IMG/mut.png" alt="MUT Logo" class="mut-logo">
      </div>
      <div class="left-menu">
        <a class="active" href="adm-page.jsp?pgprt=0">
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
    <div class="profile-panel">
      <!-- Page Header -->
      <div class="page-header">
        <div class="page-title">
          <i class="fas fa-user-circle"></i>
          User Profile
        </div>
        <div class="stats-badge">
          <i class="fas fa-user-tag"></i>
          <%= user.getType().equalsIgnoreCase("admin") ? "Administrator" : 
              user.getType().equalsIgnoreCase("lecture") ? "Lecturer" : "Student" %>
        </div>
      </div>

      <!-- Profile Information Card -->
      <div class="profile-card">
        <div class="card-header">
          <span><i class="fas fa-id-card"></i> Profile Information</span>
          <i class="fas fa-user-edit" style="opacity: 0.8;"></i>
        </div>
        <%
          if (request.getParameter("pedt") == null) {
        %>
        <div class="profile-content">
          <!-- Profile Header with Avatar -->
          <div class="profile-header">
            <div class="avatar">
              <%= userInitials %>
            </div>
            <div class="user-info">
              <h2><%= user.getFirstName() + " " + user.getLastName() %></h2>
              <p class="user-email"><%= user.getEmail() %></p>
              <span class="user-role <%= userRoleClass %>">
                <i class="fas fa-user-shield"></i>
                <%= user.getType().equalsIgnoreCase("admin") ? "Administrator" : 
                    user.getType().equalsIgnoreCase("lecture") ? "Lecturer" : "Student" %>
              </span>
            </div>
          </div>

          <!-- Profile Details -->
          <div class="profile-info">
            <div class="info-item">
              <div class="info-tag">
                <i class="fas fa-user"></i>
                Full Name
              </div>
              <div class="info-value"><%= user.getFirstName() + " " + user.getLastName() %></div>
            </div>
            
            <div class="info-item">
              <div class="info-tag">
                <i class="fas fa-envelope"></i>
                Email Address
              </div>
              <div class="info-value"><%= user.getEmail() %></div>
            </div>
            
            <div class="info-item">
              <div class="info-tag">
                <i class="fas fa-phone"></i>
                Contact Number
              </div>
              <div class="info-value"><%= user.getContact() %></div>
            </div>
            
            <div class="info-item">
              <div class="info-tag">
                <i class="fas fa-city"></i>
                City
              </div>
              <div class="info-value"><%= user.getCity() %></div>
            </div>
            
            <div class="info-item">
              <div class="info-tag">
                <i class="fas fa-map-marker-alt"></i>
                Address
              </div>
              <div class="info-value"><%= user.getAddress() %></div>
            </div>
          </div>

          <!-- Edit Button -->
          <div class="button-container">
            <a href="adm-page.jsp?pgprt=0&pedt=1" class="form-button">
              <i class="fas fa-edit"></i>
              Edit Profile
            </a>
          </div>
        </div>
        <%
          } else {
        %>
        <!-- Edit Profile Form -->
        <div class="edit-form">
          <form action="controller.jsp" method="post">
            <input type="hidden" name="page" value="profile">
            <input type="hidden" name="utype" value="<%= user.getType() %>">
            
            <!-- Hidden fields for First Name, Last Name, Email, and Password -->
            <input type="hidden" name="fname" value="<%= user.getUserName() %>">
            <input type="hidden" name="fname" value="<%= user.getFirstName() %>">
            <input type="hidden" name="lname" value="<%= user.getLastName() %>">
            <input type="hidden" name="email" value="<%= user.getEmail() %>">
            <input type="hidden" name="pass" value="<%= user.getPassword() %>">

            <div class="form-grid">
              <div class="form-group">
                <label class="form-label">
                  <i class="fas fa-phone" style="color: #17a2b8;"></i>
                  Contact No
                </label>
                <input type="text" name="contactno" value="<%= user.getContact() %>" 
                       class="form-input" placeholder="Contact No" required>
              </div>
              
              <div class="form-group">
                <label class="form-label">
                  <i class="fas fa-city" style="color: #D8A02E;"></i>
                  City
                </label>
                <input type="text" name="city" value="<%= user.getCity() %>" 
                       class="form-input" placeholder="City" required>
              </div>
              
              <div class="form-group">
                <label class="form-label">
                  <i class="fas fa-map-marker-alt" style="color: #28a745;"></i>
                  Address
                </label>
                <input type="text" name="address" value="<%= user.getAddress() %>" 
                       class="form-input" placeholder="Address" required>
              </div>
            </div>
            
            <div class="form-actions">
              <button type="reset" class="reset-btn">
                <i class="fas fa-redo"></i>
                Reset Form
              </button>
              <button type="submit" class="form-button">
                <i class="fas fa-check"></i>
                Update Profile
              </button>
            </div>
          </form>
        </div>
        <%
          }
        %>
      </div>
    </div>
  </div>
</div>
<%
    } else {
%>
<div class="profile-wrapper">
  <!-- SIDEBAR -->
  <div class="sidebar">
    <div class="sidebar-background">
      <div style="text-align: center; margin: 20px 0 40px 0;">
        <img src="IMG/mut.png" alt="MUT Logo" class="mut-logo">
      </div>
      <div class="left-menu">
        <a class="active" href="std-page.jsp?pgprt=0">
          <i class="fas fa-user"></i>
          <h2>Profile</h2>
        </a>
        <a href="std-page.jsp?pgprt=1">
          <i class="fas fa-file-alt"></i>
          <h2>Exams</h2>
        </a>
        <a href="std-page.jsp?pgprt=2">
          <i class="fas fa-chart-line"></i>
          <h2>Results</h2>
        </a>
      </div>
    </div>
  </div>

  <!-- CONTENT AREA -->
  <div class="content-area">
    <div class="profile-panel">
      <!-- Page Header -->
      <div class="page-header">
        <div class="page-title">
          <i class="fas fa-user-circle"></i>
          Student Profile
        </div>
        <div class="stats-badge">
          <i class="fas fa-user-graduate"></i>
          Student Account
        </div>
      </div>

      <!-- Profile Information Card -->
      <div class="profile-card">
        <div class="card-header">
          <span><i class="fas fa-id-card"></i> Profile Information</span>
          <i class="fas fa-user-edit" style="opacity: 0.8;"></i>
        </div>
        <%
          if (request.getParameter("pedt") == null) {
        %>
        <div class="profile-content">
          <!-- Profile Header with Avatar -->
          <div class="profile-header">
            <div class="avatar">
              <%= userInitials %>
            </div>
            <div class="user-info">
              <h2><%= user.getFirstName() + " " + user.getLastName() %></h2>
              <p class="user-email"><%= user.getEmail() %></p>
              <span class="user-role student-badge">
                <i class="fas fa-user-graduate"></i>
                Student
              </span>
            </div>
          </div>

          <!-- Profile Details -->
          <div class="profile-info">
            <div class="info-item">
              <div class="info-tag">
                <i class="fas fa-user"></i>
                Full Name
              </div>
              <div class="info-value"><%= user.getFirstName() + " " + user.getLastName() %></div>
            </div>
            
            <div class="info-item">
              <div class="info-tag">
                <i class="fas fa-envelope"></i>
                Email Address
              </div>
              <div class="info-value"><%= user.getEmail() %></div>
            </div>
            
            <div class="info-item">
              <div class="info-tag">
                <i class="fas fa-phone"></i>
                Contact Number
              </div>
              <div class="info-value"><%= user.getContact() %></div>
            </div>
            
            <div class="info-item">
              <div class="info-tag">
                <i class="fas fa-city"></i>
                City
              </div>
              <div class="info-value"><%= user.getCity() %></div>
            </div>
            
            <div class="info-item">
              <div class="info-tag">
                <i class="fas fa-map-marker-alt"></i>
                Address
              </div>
              <div class="info-value"><%= user.getAddress() %></div>
            </div>
          </div>

          <!-- Edit Button -->
          <div class="button-container">
            <a href="std-page.jsp?pgprt=0&pedt=1" class="form-button">
              <i class="fas fa-edit"></i>
              Edit Profile
            </a>
          </div>
        </div>
        <%
          } else {
        %>
        <!-- Edit Profile Form -->
        <div class="edit-form">
          <form action="controller.jsp" method="post">
            <input type="hidden" name="page" value="profile">
            <input type="hidden" name="utype" value="<%= user.getType() %>">
            
            <!-- Hidden fields for First Name, Last Name, Email, and Password -->
            <input type="hidden" name="fname" value="<%= user.getUserName() %>">
            <input type="hidden" name="fname" value="<%= user.getFirstName() %>">
            <input type="hidden" name="lname" value="<%= user.getLastName() %>">
            <input type="hidden" name="email" value="<%= user.getEmail() %>">
            <input type="hidden" name="pass" value="<%= user.getPassword() %>">

            <div class="form-grid">
              <div class="form-group">
                <label class="form-label">
                  <i class="fas fa-phone" style="color: #17a2b8;"></i>
                  Contact No
                </label>
                <input type="text" name="contactno" value="<%= user.getContact() %>" 
                       class="form-input" placeholder="Contact No" required>
              </div>
              
              <div class="form-group">
                <label class="form-label">
                  <i class="fas fa-city" style="color: #D8A02E;"></i>
                  City
                </label>
                <input type="text" name="city" value="<%= user.getCity() %>" 
                       class="form-input" placeholder="City" required>
              </div>
              
              <div class="form-group">
                <label class="form-label">
                  <i class="fas fa-map-marker-alt" style="color: #28a745;"></i>
                  Address
                </label>
                <input type="text" name="address" value="<%= user.getAddress() %>" 
                       class="form-input" placeholder="Address" required>
              </div>
            </div>
            
            <div class="form-actions">
              <button type="reset" class="reset-btn">
                <i class="fas fa-redo"></i>
                Reset Form
              </button>
              <button type="submit" class="form-button">
                <i class="fas fa-check"></i>
                Update Profile
              </button>
            </div>
          </form>
        </div>
        <%
          }
        %>
      </div>
    </div>
  </div>
</div>
<%
    }
%>

<!-- Font Awesome for Icons -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css">