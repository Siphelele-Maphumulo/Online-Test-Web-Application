<%@ page import="java.util.ArrayList" %>
<jsp:useBean id="pDAO" class="myPackage.DatabaseClass" scope="page" />

<style>
  /* Enhanced Courses Page Styles */
  .courses-wrapper {
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
  
  .exam-card {
    background: #fff;
    border: 1px solid rgba(0,0,0,.06);
    border-radius: 20px;
    box-shadow: 0 8px 32px rgba(0,0,0,.08);
    padding: 0;
    margin-bottom: 32px;
    overflow: hidden;
    transition: transform 0.3s ease, box-shadow 0.3s ease;
  }
  
  .exam-card:hover {
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
  
  .courses-panel {
    width: 100%;
    max-width: 1200px;
  }
  
  .courses-table {
    width: 100%;
    border-collapse: collapse;
    background: #fff;
  }
  
  .courses-table thead th {
    background: #f8f9fa;
    color: #09294D;
    padding: 20px 16px;
    font-weight: 700;
    text-align: left;
    border-bottom: 2px solid #e9ecef;
    font-size: 1rem;
  }
  
  .courses-table tbody td {
    padding: 20px 16px;
    border-bottom: 1px solid #f0f0f0;
    vertical-align: middle;
    color: #333;
    font-weight: 500;
  }
  
  .courses-table tbody tr {
    transition: all 0.3s ease;
  }
  
  .courses-table tbody tr:hover {
    background: #f8f9fa;
    transform: scale(1.01);
  }
  
  .course-name {
    font-weight: 700;
    color: #09294D;
    font-size: 1.1rem;
  }
  
  .course-marks {
    background: linear-gradient(135deg, #28a745, #20c997);
    color: white;
    padding: 6px 12px;
    border-radius: 20px;
    font-weight: 600;
    font-size: 0.9rem;
    display: inline-block;
  }
  
  .course-time {
    background: linear-gradient(135deg, #17a2b8, #6f42c1);
    color: white;
    padding: 6px 12px;
    border-radius: 20px;
    font-weight: 600;
    font-size: 0.9rem;
    display: inline-block;
  }
  
  .course-date {
    background: linear-gradient(135deg, #D8A02E, #e6b450);
    color: white;
    padding: 6px 12px;
    border-radius: 20px;
    font-weight: 600;
    font-size: 0.9rem;
    display: inline-block;
  }
  
  .delete-course-btn {
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
  
  .delete-course-btn:hover {
    transform: translateY(-2px);
    box-shadow: 0 6px 20px rgba(220, 53, 69, 0.4);
    color: white;
    text-decoration: none;
  }
  
  .add-course-form {
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
  
  .submit-course-btn {
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
  
  .submit-course-btn:hover {
    transform: translateY(-3px);
    box-shadow: 0 8px 25px rgba(9, 41, 77, 0.4);
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
  
  .no-courses {
    text-align: center;
    padding: 60px 40px;
    color: #6c757d;
    font-style: italic;
    font-size: 1.1rem;
  }
  
  .courses-count {
    display: flex;
    align-items: center;
    gap: 8px;
    background: #f8f9fa;
    padding: 8px 16px;
    border-radius: 20px;
    font-weight: 600;
    color: #09294D;
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
    
    .courses-table {
      display: block;
      overflow-x: auto;
    }
    
    .form-actions {
      flex-direction: column;
    }
    
    .submit-course-btn, .reset-btn {
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
    
    .add-course-form {
      padding: 24px 20px;
    }
  }
</style>

<div class="courses-wrapper">
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
        <a class="active" href="adm-page.jsp?pgprt=2">
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
    <div class="courses-panel">
      <!-- Page Header -->
      <div class="page-header">
        <div class="page-title">
          <i class="fas fa-book-open"></i>
          Course Management
        </div>
        <div class="stats-badge">
          <i class="fas fa-graduation-cap"></i>
        <%
            ArrayList list = pDAO.getAllCourses();
            // Fix: Since we're now storing 4 fields per course, divide by 4
            int courseCount = list.size() / 4;
        %>
          <%= courseCount %> Courses
        </div>
      </div>

      <!-- All Courses Panel -->
      <div class="exam-card">
        <div class="card-header">
          <span><i class="fas fa-list"></i> All Courses</span>
          <div class="courses-count">
            <i class="fas fa-layer-group"></i>
            Total: <%= courseCount %>
          </div>
        </div>
        <div style="overflow-x: auto;">
          <table class="courses-table">
            <thead>
              <tr>
                <th>Course Name</th>
                <th>Total Marks</th>
                <th>Duration</th>
                <th>Exam Date</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <%
              if (list.isEmpty()) {
              %>
                <tr>
                  <td colspan="5" class="no-courses">
                    <i class="fas fa-inbox" style="font-size: 3rem; margin-bottom: 16px; display: block; opacity: 0.5;"></i>
                    No courses available. Add your first course to get started.
                  </td>
                </tr>
              <%
              } else {
                for (int i = 0; i < list.size(); i += 4) {
                  if (i + 3 < list.size()) {
              %>
              <tr>
                <td>
                  <div class="course-name">
                    <i class="fas fa-book" style="color: #D8A02E; margin-right: 8px;"></i>
                    <%= list.get(i) %>
                  </div>
                </td>
                <td><span class="course-marks"><%= list.get(i + 1) %> Marks</span></td>
                <td><span class="course-time"><%= list.get(i + 2) %> mins</span></td>
                <td><span class="course-date"><%= list.get(i + 3) %></span></td>
                <td>
                  <a href="controller.jsp?page=courses&operation=del&cname=<%= list.get(i) %>"
                     onclick="return confirm('Are you sure you want to delete \"<%= list.get(i) %>\"? This action cannot be undone.');" 
                     class="delete-course-btn">
                     <i class="fas fa-trash"></i>
                     Delete
                  </a>
                </td>
              </tr>
              <%
                  }
                }
              }
              %>
            </tbody>
          </table>
        </div>
      </div>

      <!-- Add New Course Panel -->
      <div class="exam-card">
        <div class="card-header">
          <span><i class="fas fa-plus-circle"></i> Add New Course</span>
          <i class="fas fa-graduation-cap" style="opacity: 0.8;"></i>
        </div>
        <div class="add-course-form">
          <form action="controller.jsp" method="post">
            <div class="form-grid">
              <div class="form-group">
                <label class="form-label">
                  <i class="fas fa-book" style="color: #D8A02E;"></i>
                  Course Name
                </label>
                <input type="text" name="coursename" class="form-input" 
                       placeholder="Enter course name (e.g., Mathematics 101)" required>
              </div>
              
              <div class="form-group">
                <label class="form-label">
                  <i class="fas fa-chart-line" style="color: #28a745;"></i>
                  Total Marks
                </label>
                <input type="number" name="totalmarks" class="form-input" 
                       placeholder="Enter total marks" required min="1" max="1000">
              </div>
              
              <div class="form-group">
                <label class="form-label">
                  <i class="fas fa-clock" style="color: #17a2b8;"></i>
                  Exam Duration
                </label>
                <input type="number" name="time" class="form-input" 
                       placeholder="Duration in minutes" required min="1" max="480">
              </div>
              
              <div class="form-group">
                <label class="form-label">
                  <i class="fas fa-calendar-alt" style="color: #D8A02E;"></i>
                  Exam Date
                </label>
                <input type="date" name="examdate" class="form-input" required>
              </div>
            </div>
            
            <input type="hidden" name="page" value="courses">
            <input type="hidden" name="operation" value="addnew">
            
            <div class="form-actions">
              <button type="reset" class="reset-btn">
                <i class="fas fa-redo"></i>
                Reset Form
              </button>
              <button type="submit" class="submit-course-btn">
                <i class="fas fa-plus"></i>
                Add Course
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