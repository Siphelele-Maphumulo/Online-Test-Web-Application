<%@page import="myPackage.classes.Answers"%>
<%@page import="myPackage.classes.Exams"%>
<%@page import="myPackage.classes.Questions"%>
<%@page import="java.util.ArrayList"%>
<jsp:useBean id="pDAO" class="myPackage.DatabaseClass" scope="page"/>

<style>
  /* Layout */
  .exam-wrapper {
    display: flex;
    min-height: 100vh;
    background: #f6f7fb;
  }
  
  .sidebar {
    width: 200px;
    background: #F3F3F3;
    position: fixed;
    left: 0;
    top: 0;
    height: 100vh;
    z-index: 100;
  }
  
  .sidebar-background {
    height: 100%;
    padding: 24px;
  }
  
  .left-menu a {
    display: block;
    padding: 10px 12px;
    border-radius: 10px;
    color: #000;
    text-decoration: none;
    margin-bottom: 8px;
    font-weight: 600;
    transition: background-color 0.3s ease;
  }
  
  .left-menu a:hover {
    background: #e8e8e8;
  }
  
  .left-menu a.active {
    background: #e2e2e2;
  }
  
  .content-area {
    flex: 1;
    padding: 24px 24px 80px 24px;
    position: relative;
    margin-left: 260px; /* Match sidebar width */
    min-height: 100vh;
  }
  
  .exam-header {
    position: sticky;
    top: 0;
    z-index: 50;
    background: #fff;
    border: 1px solid rgba(0,0,0,.06);
    box-shadow: 0 8px 20px rgba(0,0,0,.06);
    border-radius: 16px;
    padding: 16px 20px;
    margin-bottom: 20px;
    display: flex;
    align-items: center;
    gap: 12px;
  }
  
  .exam-title {
    font-size: 1.25rem;
    font-weight: 800;
    margin: 0;
    color: #09294D;
  }
  
  .badge-time {
    font-weight: 700;
    font-size: 1rem;
  }
  
  .mut-logo {
    max-height: 150px;
  }
  
  .exam-card {
    background: #fff;
    border: 1px solid rgba(0,0,0,.08);
    border-radius: 16px;
    box-shadow: 0 10px 24px rgba(0,0,0,.06);
    padding: 0; /* Remove padding from card to let content control spacing */
    margin-bottom: 16px;
    overflow: hidden; /* Ensure content stays within rounded corners */
  }
  
  .question-label {
    display: inline-flex;
    width: 36px;
    height: 36px;
    align-items: center;
    justify-content: center;
    background: #09294D;
    color: #fff;
    border-radius: 10px;
    font-weight: 800;
    margin-right: 10px;
  }
  
  .question-text {
    font-weight: 600;
    color: #222;
    margin: 0;
  }
  
  .answers {
    margin-top: 10px;
  }
  
  .answers .form-check {
    padding: 10px 12px;
    border: 1px solid #e9ecef;
    border-radius: 10px;
    margin-bottom: 8px;
    background: #fcfcfd;
  }
  
  .answers .form-check:hover {
    background: #f7f9ff;
  }
  
  .progress {
    height: 10px;
    border-radius: 999px;
  }
  
  .submit-bar {
    position: fixed;
    bottom: 0;
    left: 260px;
    right: 0;
    padding: 12px 20px;
    background: linear-gradient(180deg, rgba(246,247,251,0), #f6f7fb 40%, #f6f7fb);
    z-index: 60;
  }
  
  .submit-inner {
    background: #fff;
    border: 1px solid rgba(0,0,0,.06);
    box-shadow: 0 10px 24px rgba(0,0,0,.08);
    border-radius: 14px;
    padding: 12px;
    display: flex;
    justify-content: space-between;
    align-items: center;
  }
  
  .submit-btn {
    min-width: 200px;
  }
  
  .note {
    color: #6c757d;
    font-size: .9rem;
  }
  
  /* Profile specific styles */
  .profile-panel {
    float: left;
    max-width: 600px;
    width: 100%;
  }
  
  .title {
    background-color: #e3e3e3;
    color: white;
    padding: 12px 16px;
    font-weight: 700;
    font-size: 1.25rem;
    margin: 0; /* Remove margin to stick to top */
  }
  
  .profile {
    background: #fff;
    border-radius: 16px;
    padding: 24px;
    box-shadow: 0 4px 12px rgba(0,0,0,.08);
    border: 1px solid rgba(0,0,0,.06);
  }
  
  .profile h2 {
    margin: 0;
    line-height: 1.8;
  }
  
  .tag {
    display: inline-block;
    padding: 4px 12px;
    border-radius: 8px;
    color: white;
    font-weight: 600;
    margin-right: 8px;
    min-width: 120px;
    text-align: center;
  }
  
  .val {
    font-weight: 500;
    color: #333;
  }
  
  .form-button {
    background-color: #d3d3d3;
    border: none;
    border-radius: 12px;
    padding: 10px 20px;
    font-size: 16px;
    color: #000;
    cursor: pointer;
    text-decoration: none;
    display: inline-block;
    transition: background-color 0.3s ease;
  }
  
  .form-button:hover {
    background-color: #c0c0c0;
  }
  
  /* Form styles */
  .central-div {
    background: #fff;
    border-radius: 16px;
    padding: 24px;
    box-shadow: 0 4px 12px rgba(0,0,0,.08);
    border: 1px solid rgba(0,0,0,.06);
    max-width: 600px;
  }
  
  .form-style-6 table {
    width: 100%;
    border-collapse: collapse;
  }
  
  .form-style-6 td {
    padding: 12px 8px;
    vertical-align: top;
  }
  
  .form-style-6 label {
    font-weight: 600;
    color: #333;
  }
  
  .form-style-6 input.text {
    width: 100%;
    padding: 10px 12px;
    border: 1px solid #ddd;
    border-radius: 8px;
    font-size: 14px;
    transition: border-color 0.3s ease;
  }
  
  .form-style-6 input.text:focus {
    outline: none;
    border-color: #09294D;
    box-shadow: 0 0 0 2px rgba(9, 41, 77, 0.1);
  }
  
  /* Results Page Specific Styles */
.results-panel {
    float: left;
    max-width: 900px;
    width: 100%;
}

/* Table Styles */
#rounded-corner, #gradient-style {
    width: 100%;
    border-collapse: collapse;
    background: #fff;
    margin: 0; /* Remove margin to stick directly under title */
    border-radius: 0 0 16px 16px; /* Only round bottom corners */
}

#rounded-corner thead th, #gradient-style thead th {
    background: #09294D;
    color: white;
    padding: 16px 12px;
    font-weight: 600;
    text-align: center;
    border: none;
    cursor: pointer;
    transition: background-color 0.3s ease;
    position: relative;
}

#rounded-corner thead th:hover, #gradient-style thead th:hover {
    background: #e3e3e3;
}

#rounded-corner tbody td, #gradient-style tbody td {
    padding: 14px 12px;
    border-bottom: 1px solid #e9ecef;
    text-align: center;
    vertical-align: middle;
}

#rounded-corner tbody tr:hover, #gradient-style tbody tr:hover {
    background: #f8f9fa;
}

/* Status badges */
.status-pass {
    background: #00cc33 !important;
    color: white;
    padding: 6px 12px;
    border-radius: 20px;
    font-weight: 600;
}

.status-fail {
    background: #ff3333 !important;
    color: white;
    padding: 6px 12px;
    border-radius: 20px;
    font-weight: 600;
}

.status-terminated {
    background: #ffa500 !important;
    color: white;
    padding: 6px 12px;
    border-radius: 20px;
    font-weight: 600;
}

/* Search box */
.search-container {
    position: absolute;
    top: 16px;
    right: 20px;
    z-index: 10;
}

.search-input {
    padding: 10px 16px;
    border: 1px solid #ddd;
    border-radius: 10px;
    font-size: 14px;
    min-width: 200px;
    background: white;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    transition: border-color 0.3s ease;
}

.search-input:focus {
    outline: none;
    border-color: #09294D;
    box-shadow: 0 0 0 2px rgba(9, 41, 77, 0.1);
}

/* Action links */
.action-link {
    color: #09294D;
    text-decoration: none;
    font-weight: 600;
    padding: 6px 12px;
    border-radius: 8px;
    transition: background-color 0.3s ease;
}

.action-link:hover {
    background: #f0f0f0;
    text-decoration: underline;
}

/* Back button */
.back-button {
    background-color: #d3d3d3;
    border: none;
    border-radius: 12px;
    padding: 12px 24px;
    font-size: 16px;
    color: #000;
    cursor: pointer;
    transition: background-color 0.3s ease;
    text-decoration: none;
    display: inline-block;
}

.back-button:hover {
    background-color: #c0c0c0;
}

/* Details table specific */
#gradient-style tr:nth-child(odd) {
    background: #f8f9fa;
}

#gradient-style tr:nth-child(even) {
    background: #fff;
}

/* Sort indicator */
.sort-indicator {
    margin-left: 8px;
    display: inline-block;
    transition: transform 0.3s ease;
}

.rotate .sort-indicator {
    transform: rotate(180deg);
}

/* Header container for title and search */
.results-header {
    position: relative;
    background-color: #e3e3e3;
    color: white;
    padding: 12px 16px;
    border-radius: 16px 16px 0 0;
    margin: 0;
}

.results-title {
    font-weight: 700;
    font-size: 1.25rem;
    margin: 0;
    display: inline-block;
}

/* No results message */
.no-results {
    text-align: center;
    padding: 40px;
    color: #6c757d;
    font-style: italic;
}

/* Responsive design */
@media (max-width: 992px) {
    .sidebar {
        position: relative;
        width: 100%;
        height: auto;
    }
    
    .content-area {
        margin-left: 0;
        padding-bottom: 120px;
    }
    
    .submit-bar {
        left: 0;
    }
    
    .profile-panel {
        max-width: 100%;
        float: none;
    }
    
    .results-panel {
        max-width: 100%;
        float: none;
    }
}

@media (max-width: 768px) {
    .content-area {
        padding: 16px;
    }
    
    .exam-header {
        flex-direction: column;
        align-items: flex-start;
        gap: 8px;
    }
    
    .profile h2 {
        font-size: 1.1rem;
    }
    
    .tag {
        min-width: 100px;
        font-size: 0.9rem;
    }
    
    .search-container {
        position: relative;
        top: 0;
        right: 0;
        padding: 10px 0;
        width: 100%;
    }
    
    .search-input {
        width: 100%;
        min-width: auto;
    }
    
    #rounded-corner, #gradient-style {
        display: block;
        overflow-x: auto;
    }
}
</style>

<!-- SIDEBAR -->
<div class="sidebar">
    <div class="sidebar-background" style="background-color:#F3F3F3; color:black">
        <!-- Logo on the left -->
        <div style="flex: 1;">
            <img src="IMG/mut.png" alt="MUT Logo" style="max-height: 120px;">
        </div>

        <div class="left-menu">
            <a href="adm-page.jsp?pgprt=0"><h2 style="color:black">Profile</h2></a>
            <a href="adm-page.jsp?pgprt=2"><h2 style="color:black">Courses</h2></a>
            <a href="adm-page.jsp?pgprt=3"><h2 style="color:black">Questions</h2></a>
            <a href="adm-page.jsp?pgprt=1"><h2 style="color:black">Accounts</h2></a>
            <a class="active" href="adm-page.jsp?pgprt=5"><h2 style="color:black">Students Results</h2></a>
        </div>
    </div>
</div>

<!-- CONTENT AREA -->
<div class="content-area">
    <div class="panel" style="float: left; max-width: 900px">

        <% if (request.getParameter("eid") == null) { %>
            <div class="title" style="background-color: #e3e3e3">All Results</div>
            <table id="rounded-corner">
                <thead>
                    <tr>
                        <th scope="col" class="rounded-company">Date</th>
                        <th scope="col" class="rounded-q1">Course</th>
                        <th scope="col" class="rounded-q2">Time</th>
                        <th scope="col" class="rounded-q2">Marks</th> <!-- New column for Marks -->
                        <th scope="col" class="rounded-q3">Status</th>
                        <th scope="col" class="rounded-q4">Action</th>
                    </tr>
                </thead>
                <tbody>
                    <% 
                        // Now calling without student ID to get results for all students
                        ArrayList<Exams> list = pDAO.getResultsFromExams();
                        for (int i = 0; i < list.size(); i++) {
                            Exams e = list.get(i);
                    %>
                    <tr>
                        <td><%= e.getFullName() %></td>
                        <td><%= e.getDate() %></td> <!-- Displaying the exam date -->
                        <td><%= e.getcName() %></td> <!-- Displaying the course name -->
                        <td><%= e.getStartTime() + " - " + e.getEndTime() %></td> <!-- Displaying the time -->
                        <td><%= e.getObtMarks() %> / <%= e.gettMarks() %></td> <!-- Displaying marks obtained and total marks -->
                        <% if (e.getStatus() != null) {
                            if (e.getStatus().equals("Pass")) { %>
                                <td style="background: #00cc33; color:white"><%= e.getStatus() %></td>
                            <% } else { %>
                                <td style="background: #ff3333; color:white"><%= e.getStatus() %></td>
                            <% } 
                        } else { %>
                            <td style="background: bisque;">Terminated</td>
                        <% } %>
                        <td><a href="std-page.jsp?pgprt=2&eid=<%= e.getExamId() %>">Details</a></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        <% } else { %>
            <div class="title">Result Details</div>
            <table id="gradient-style">
                <%
                    ArrayList<Answers> list = pDAO.getAllAnswersByExamId(
                        Integer.parseInt(request.getParameter("eid"))
                    );
                    for (int i = 0; i < list.size(); i++) {
                        Answers a = list.get(i);
                %>
                <tr>
                    <td rowspan="2"><%= i + 1 %>)</td>
                    <td colspan="2"><%= a.getQuestion() %></td>
                    <td rowspan="2">
                        <% if (a.getStatus().equals("correct")) { %>
                            <span style="color: green;"><%= a.getStatus() %></span>
                        <% } else { %>
                            <span style="color: red;"><%= a.getStatus() %></span>
                        <% } %>
                    </td>
                </tr>
                <tr>
                    <td><%="Your Ans: " + a.getAnswer() %></td>
                    <td><%="Correct Ans: " + a.getCorrectAns() %></td>
                </tr>
                <tr>
                    <td colspan="3" style="background: white"></td>
                <% } %>
            </table>
        <% } %>
    </div>
</div>
