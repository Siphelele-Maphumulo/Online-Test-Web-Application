<%@page import="myPackage.classes.Answers"%>
<%@page import="myPackage.classes.Exams"%>
<%@page import="myPackage.classes.Questions"%>
<%@page import="java.util.ArrayList"%>
<%--<jsp:useBean id="pDAO" class="myPackage.DatabaseClass" scope="page"/>--%>
 
<% 
myPackage.DatabaseClass pDAO = myPackage.DatabaseClass.getInstance();
%>

<style>
  /* Layout */
  .exam-wrapper {
    display: flex;
    min-height: 100vh;
    background: #f6f7fb;
  }
  
  .sidebar {
    width: 240px;
    background: #F3F3F3;
    position: fixed;
    left: 0;
    top: 0;
    height: 100vh;
    overflow-x:hidden;
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
    margin-left: 240px; /* Match sidebar width */
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
    padding: 12px 12px;
    margin-bottom: 20px;
    display: flex;
    align-items: center;
    gap: 8px;
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
    max-height: 80px;
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
  
  /* Results Page Specific Styles */
.results-panel {
    float: left;
    max-width: 900px;
    width: 100%;
}

/* Filter and Search Container */
.filter-container {
    background: #fff;
    border: 1px solid rgba(0,0,0,.08);
    border-radius: 12px;
    padding: 16px;
    margin-bottom: 20px;
    box-shadow: 0 4px 12px rgba(0,0,0,.06);
    display: flex;
    flex-wrap: wrap;
    gap: 16px;
    align-items: center;
}

.filter-group {
    display: flex;
    flex-direction: column;
    min-width: 200px;
}

.filter-label {
    font-weight: 600;
    color: #333;
    margin-bottom: 6px;
    font-size: 14px;
}

.filter-input {
    padding: 10px 12px;
    border: 1px solid #ddd;
    border-radius: 8px;
    font-size: 14px;
    background: white;
    transition: border-color 0.3s ease;
}

.filter-input:focus {
    outline: none;
    border-color: #09294D;
    box-shadow: 0 0 0 2px rgba(9, 41, 77, 0.1);
}

.filter-select {
    padding: 10px 12px;
    border: 1px solid #ddd;
    border-radius: 8px;
    font-size: 14px;
    background: white;
    cursor: pointer;
}

.filter-button {
    background: #09294D;
    color: white;
    border: none;
    border-radius: 8px;
    padding: 10px 20px;
    font-weight: 600;
    cursor: pointer;
    transition: background-color 0.3s ease;
}

.filter-button:hover {
    background: #e3e3e3;
}

.reset-button {
    background: #6c757d;
    color: white;
    border: none;
    border-radius: 8px;
    padding: 10px 20px;
    font-weight: 600;
    cursor: pointer;
    transition: background-color 0.3s ease;
}

.reset-button:hover {
    background: #495057;
}

/* Results Header */
.results-header {
    background-color: #e3e3e3;
    color: white;
    padding: 12px 16px;
    border-radius: 16px 16px 0 0;
    margin: 0;
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.results-title {
    font-weight: 700;
    font-size: 1.25rem;
    margin: 0;
}

.results-count {
    background: rgba(255, 255, 255, 0.2);
    padding: 4px 12px;
    border-radius: 20px;
    font-size: 0.9rem;
}

/* Table Styles */
#results-table {
    width: 100%;
    border-collapse: collapse;
    background: #fff;
    margin: 0;
    border-radius: 0 0 16px 16px;
    overflow: hidden;
}

#results-table thead th {
    background: #09294D;
    color: white;
    padding: 16px 12px;
    font-weight: 600;
    text-align: center;
    border: none;
    cursor: pointer;
    transition: background-color 0.3s ease;
    position: relative;
    user-select: none;
}

#results-table thead th:hover {
    background: #e3e3e3;
}

#results-table thead th.sort-asc:after {
    content: " ?";
    font-size: 12px;
}

#results-table thead th.sort-desc:after {
    content: " ?";
    font-size: 12px;
}

#results-table tbody td {
    padding: 14px 12px;
    border-bottom: 1px solid #e9ecef;
    text-align: center;
    vertical-align: middle;
}

#results-table tbody tr:hover {
    background: #f8f9fa;
}

/* Status badges */
.status-pass {
    background: #28a745 !important;
    color: white;
    padding: 6px 12px;
    border-radius: 20px;
    font-weight: 600;
    display: inline-block;
    min-width: 80px;
}

.status-fail {
    background: #dc3545 !important;
    color: white;
    padding: 6px 12px;
    border-radius: 20px;
    font-weight: 600;
    display: inline-block;
    min-width: 80px;
}

.status-terminated {
    background: #ffc107 !important;
    color: #09294D;
    padding: 6px 12px;
    border-radius: 20px;
    font-weight: 600;
    display: inline-block;
    min-width: 80px;
}

/* Search box */
.search-container {
    display: flex;
    gap: 8px;
}

.search-input {
    padding: 10px 16px;
    border: 1px solid #ddd;
    border-radius: 10px;
    font-size: 14px;
    min-width: 250px;
    background: white;
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
    display: inline-block;
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

/* No results message */
.no-results {
    text-align: center;
    padding: 40px;
    color: #6c757d;
    font-style: italic;
    background: #fff;
    border-radius: 0 0 16px 16px;
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
    
    .results-panel {
        max-width: 100%;
        float: none;
    }
    
    .filter-container {
        flex-direction: column;
        align-items: stretch;
    }
    
    .filter-group {
        min-width: 100%;
    }
    
    .search-input {
        min-width: auto;
        width: 100%;
    }
}

@media (max-width: 768px) {
    .content-area {
        padding: 16px;
    }
    
    .results-header {
        flex-direction: column;
        gap: 12px;
        align-items: flex-start;
    }
    
    .search-container {
        width: 100%;
    }
    
    #results-table {
        display: block;
        overflow-x: auto;
    }
    
    .filter-container {
        padding: 12px;
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
    <div class="results-panel">
        <% if (request.getParameter("eid") == null) { %>
            <!-- Filter and Search Section -->
            <div class="filter-container">
                <div class="filter-group">
                    <label class="filter-label">Search Student</label>
                    <input type="text" id="searchInput" class="filter-input" placeholder="Search by student name or email...">
                </div>
                
                <div class="filter-group">
                    <label class="filter-label">Course</label>
                    <select id="courseFilter" class="filter-select">
                        <option value="">All Courses</option>
                        <%
                            ArrayList<String> allCourses = pDAO.getAllCourseNames();
                            if (allCourses != null) {
                                for (String course : allCourses) {
                        %>
                        <option value="<%= course %>"><%= course %></option>
                        <%
                                }
                            }
                        %>
                    </select>
                </div>
                
                <div class="filter-group">
                    <label class="filter-label">Status</label>
                    <select id="statusFilter" class="filter-select">
                        <option value="">All Status</option>
                        <option value="Pass">Pass</option>
                        <option value="Fail">Fail</option>
                        <option value="Terminated">Terminated</option>
                    </select>
                </div>
                
                <div class="filter-group">
                    <label class="filter-label">Date Range</label>
                    <div style="display: flex; gap: 8px;">
                        <input type="date" id="dateFrom" class="filter-input" style="flex: 1;">
                        <span style="align-self: center;">to</span>
                        <input type="date" id="dateTo" class="filter-input" style="flex: 1;">
                    </div>
                </div>
                
                <button onclick="applyFilters()" class="filter-button">Apply Filters</button>
                <button onclick="resetFilters()" class="reset-button">Reset</button>
            </div>

            <!-- Results Header -->
            <div class="results-header">
                <div>
                    <div class="results-title">All Results</div>
                    <div class="results-count" id="resultsCount">Loading...</div>
                </div>
                <div class="search-container">
                    <input type="text" id="globalSearch" class="search-input" placeholder="Search in all columns...">
                    <button onclick="performGlobalSearch()" class="filter-button">Search</button>
                </div>
            </div>

            <!-- Results Table -->
            <table id="results-table">
                <thead>
                    <tr>
                        <th onclick="sortTable(0)">Student Name</th>
                        <th onclick="sortTable(1)">Date</th>
                        <th onclick="sortTable(2)">Course</th>
                        <th onclick="sortTable(3)">Time</th>
                        <th onclick="sortTable(4)">Marks</th>
                        <th onclick="sortTable(5)">Status</th>
                        <th>Action</th>
                    </tr>
                </thead>
                <tbody id="resultsBody">
                    <% 
                        // TEMPORARY WORKAROUND: You need to add a method in DatabaseClass that returns all results
                        // For now, I'll create a list using an alternative approach
                        ArrayList<Exams> list = new ArrayList<>();
                        
                        // Option 1: If you have access to all student IDs, you could loop through them
                        // Option 2: Modify the DatabaseClass to add a getAllResultsFromExams() method
                        // Option 3: Use a different method if available
                        
                        // For this example, let's assume you need to pass -1 or null to get all results
                        // Check what your actual method signature is
                        try {
                            // Try calling with null or -1 to see if it works
                            list = pDAO.getResultsFromExams(-1); // or pDAO.getAllResultsFromExams();
                        } catch(Exception e) {
                            // If the method doesn't exist, you'll need to add it to DatabaseClass
                    %>
                    <tr>
                        <td colspan="7" class="no-results" style="color: red;">
                            Error: Please add getAllResultsFromExams() method to DatabaseClass
                            <br>
                            <small>Current method requires a student ID parameter</small>
                        </td>
                    </tr>
                    <%
                        }
                        
                        if (list.isEmpty()) {
                    %>
                    <tr>
                        <td colspan="7" class="no-results">No results found</td>
                    </tr>
                    <%
                        } else {
                            for (int i = 0; i < list.size(); i++) {
                                Exams e = list.get(i);
                                String statusClass = "";
                                if (e.getStatus() != null) {
                                    if (e.getStatus().equals("Pass")) {
                                        statusClass = "status-pass";
                                    } else if (e.getStatus().equals("Fail")) {
                                        statusClass = "status-fail";
                                    }
                                } else {
                                    statusClass = "status-terminated";
                                }
                    %>
                    <tr class="result-row" 
                        data-student="<%= e.getFullName().toLowerCase() %> <%= e.getEmail().toLowerCase() %>"
                        data-course="<%= e.getcName() %>"
                        data-status="<%= e.getStatus() != null ? e.getStatus() : "Terminated" %>"
                        data-date="<%= e.getDate() %>">
                        <td><%= e.getFullName() %><br><small><%= e.getEmail() %></small></td>
                        <td><%= e.getDate() %></td>
                        <td><%= e.getcName() %></td>
                        <td><%= e.getStartTime() + " - " + e.getEndTime() %></td>
                        <td><strong><%= e.getObtMarks() %> / <%= e.gettMarks() %></strong></td>
                        <td><span class="<%= statusClass %>"><%= e.getStatus() != null ? e.getStatus() : "Terminated" %></span></td>
                        <td><a href="adm-page.jsp?pgprt=5&eid=<%= e.getExamId() %>" class="action-link">Details</a></td>
                    </tr>
                    <% 
                            }
                        }
                    %>
                </tbody>
            </table>
        <% } else { %>
            <!-- Result Details View -->
            <div style="margin-bottom: 20px;">
                <a href="adm-page.jsp?pgprt=5" class="back-button">? Back to All Results</a>
            </div>
            
            <div class="results-header">
                <div class="results-title">Result Details</div>
            </div>
            
            <table id="results-table">
                <thead>
                    <tr>
                        <th>#</th>
                        <th>Question</th>
                        <th>Your Answer</th>
                        <th>Correct Answer</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    <%
                        ArrayList<Answers> answersList = pDAO.getAllAnswersByExamId(
                            Integer.parseInt(request.getParameter("eid"))
                        );
                        if (answersList.isEmpty()) {
                    %>
                    <tr>
                        <td colspan="5" class="no-results">No answer details available</td>
                    </tr>
                    <%
                        } else {
                            for (int i = 0; i < answersList.size(); i++) {
                                Answers a = answersList.get(i);
                                String statusColor = a.getStatus().equals("correct") ? "green" : "red";
                    %>
                    <tr>
                        <td><%= i + 1 %></td>
                        <td><%= a.getQuestion() %></td>
                        <td><%= a.getAnswer() != null ? a.getAnswer() : "No Answer" %></td>
                        <td><%= a.getCorrectAnswer() != null ? a.getCorrectAnswer() : "N/A" %></td>
                        <td style="color: <%= statusColor %>; font-weight: 600;">
                            <%= a.getStatus().toUpperCase() %>
                        </td>
                    </tr>
                    <% 
                            }
                        }
                    %>
                </tbody>
            </table>
        <% } %>
    </div>
</div>

<script>
// Store original results for reset functionality
let originalResults = [];
let currentSortColumn = -1;
let sortDirection = 1; // 1 for ascending, -1 for descending

// Initialize when page loads
document.addEventListener('DOMContentLoaded', function() {
    // Store original results
    const rows = document.querySelectorAll('#resultsBody tr.result-row');
    originalResults = Array.from(rows).map(row => row.outerHTML);
    
    // Update results count
    updateResultsCount();
    
    // Add event listeners for real-time filtering
    document.getElementById('searchInput').addEventListener('input', applyFilters);
    document.getElementById('courseFilter').addEventListener('change', applyFilters);
    document.getElementById('statusFilter').addEventListener('change', applyFilters);
    document.getElementById('dateFrom').addEventListener('change', applyFilters);
    document.getElementById('dateTo').addEventListener('change', applyFilters);
    document.getElementById('globalSearch').addEventListener('input', function(e) {
        if (e.target.value.length >= 2 || e.target.value.length === 0) {
            applyFilters();
        }
    });
});

function updateResultsCount() {
    const visibleRows = document.querySelectorAll('#resultsBody tr.result-row:not([style*="display: none"])').length;
    const totalRows = originalResults.length;
    document.getElementById('resultsCount').textContent = `Showing ${visibleRows} of ${totalRows} results`;
}

function applyFilters() {
    const searchTerm = document.getElementById('searchInput').value.toLowerCase();
    const courseFilter = document.getElementById('courseFilter').value;
    const statusFilter = document.getElementById('statusFilter').value;
    const dateFrom = document.getElementById('dateFrom').value;
    const dateTo = document.getElementById('dateTo').value;
    const globalSearch = document.getElementById('globalSearch').value.toLowerCase();
    
    const rows = document.querySelectorAll('#resultsBody tr.result-row');
    
    rows.forEach(row => {
        let showRow = true;
        
        // Search filter (student name/email)
        if (searchTerm) {
            const studentData = row.getAttribute('data-student');
            if (!studentData.includes(searchTerm)) {
                showRow = false;
            }
        }
        
        // Course filter
        if (courseFilter && row.getAttribute('data-course') !== courseFilter) {
            showRow = false;
        }
        
        // Status filter
        if (statusFilter) {
            const rowStatus = row.getAttribute('data-status');
            if (statusFilter === 'Terminated' && rowStatus !== 'Terminated') {
                showRow = false;
            } else if (statusFilter !== 'Terminated' && rowStatus !== statusFilter) {
                showRow = false;
            }
        }
        
        // Date range filter
        if (dateFrom || dateTo) {
            const rowDate = new Date(row.getAttribute('data-date'));
            if (dateFrom) {
                const fromDate = new Date(dateFrom);
                if (rowDate < fromDate) showRow = false;
            }
            if (dateTo) {
                const toDate = new Date(dateTo);
                toDate.setHours(23, 59, 59, 999); // End of day
                if (rowDate > toDate) showRow = false;
            }
        }
        
        // Global search (searches all visible text)
        if (globalSearch) {
            const rowText = row.textContent.toLowerCase();
            if (!rowText.includes(globalSearch)) {
                showRow = false;
            }
        }
        
        // Show/hide row
        row.style.display = showRow ? '' : 'none';
    });
    
    updateResultsCount();
}

function performGlobalSearch() {
    applyFilters();
}

function resetFilters() {
    document.getElementById('searchInput').value = '';
    document.getElementById('courseFilter').value = '';
    document.getElementById('statusFilter').value = '';
    document.getElementById('dateFrom').value = '';
    document.getElementById('dateTo').value = '';
    document.getElementById('globalSearch').value = '';
    
    // Reset table body to original content
    const resultsBody = document.getElementById('resultsBody');
    resultsBody.innerHTML = originalResults.join('');
    
    // Reset sorting
    currentSortColumn = -1;
    sortDirection = 1;
    const headers = document.querySelectorAll('#results-table thead th');
    headers.forEach(header => {
        header.classList.remove('sort-asc', 'sort-desc');
    });
    
    updateResultsCount();
}

function sortTable(columnIndex) {
    const table = document.getElementById('results-table');
    const tbody = table.querySelector('tbody');
    const rows = Array.from(tbody.querySelectorAll('tr.result-row:not([style*="display: none"])'));
    
    // Update sort indicators
    const headers = table.querySelectorAll('thead th');
    headers.forEach((header, index) => {
        header.classList.remove('sort-asc', 'sort-desc');
        if (index === columnIndex) {
            if (currentSortColumn === columnIndex) {
                sortDirection *= -1;
            } else {
                sortDirection = 1;
                currentSortColumn = columnIndex;
            }
            header.classList.add(sortDirection === 1 ? 'sort-asc' : 'sort-desc');
        }
    });
    
    // Sort rows
    rows.sort((a, b) => {
        let aValue, bValue;
        
        // Get cell values based on column
        switch(columnIndex) {
            case 0: // Student Name
                aValue = a.cells[0].textContent.toLowerCase();
                bValue = b.cells[0].textContent.toLowerCase();
                break;
            case 1: // Date
                aValue = new Date(a.getAttribute('data-date'));
                bValue = new Date(b.getAttribute('data-date'));
                break;
            case 2: // Course
                aValue = a.cells[2].textContent.toLowerCase();
                bValue = b.cells[2].textContent.toLowerCase();
                break;
            case 3: // Time
                aValue = a.cells[3].textContent.toLowerCase();
                bValue = b.cells[3].textContent.toLowerCase();
                break;
            case 4: // Marks
                const aMarks = a.cells[4].textContent.split('/');
                const bMarks = b.cells[4].textContent.split('/');
                aValue = parseInt(aMarks[0]) / parseInt(aMarks[1]);
                bValue = parseInt(bMarks[0]) / parseInt(bMarks[1]);
                break;
            case 5: // Status
                aValue = a.getAttribute('data-status');
                bValue = b.getAttribute('data-status');
                // Custom order: Pass > Fail > Terminated
                const statusOrder = { 'Pass': 1, 'Fail': 2, 'Terminated': 3 };
                aValue = statusOrder[aValue] || 4;
                bValue = statusOrder[bValue] || 4;
                break;
            default:
                aValue = a.cells[columnIndex].textContent.toLowerCase();
                bValue = b.cells[columnIndex].textContent.toLowerCase();
        }
        
        // Compare values
        if (aValue < bValue) return -1 * sortDirection;
        if (aValue > bValue) return 1 * sortDirection;
        return 0;
    });
    
    // Reorder rows in DOM
    rows.forEach(row => tbody.appendChild(row));
    updateResultsCount();
}
</script>