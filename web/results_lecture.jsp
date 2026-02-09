<%@page import="myPackage.classes.User"%>
<%@page import="myPackage.classes.Answers"%>
<%@page import="myPackage.classes.Exams"%>
<%@page import="myPackage.classes.Questions"%>
<%@page import="java.util.ArrayList"%>
<%@page import="java.util.UUID"%>
<%--<jsp:useBean id="pDAO" class="myPackage.DatabaseClass" scope="page"/>--%>

<%! 
// Function to escape HTML characters for safe display
public String escapeHtml(String input) {
    if (input == null) return "";
    return input.replace("&", "&amp;")
               .replace("<", "&lt;")
               .replace(">", "&gt;")
               .replace("\"", "&quot;")
               .replace("'", "&#x27;");
}
%>

<%
    // The main adm-page.jsp will handle user session checks.
    // We just need the DAO and a fresh CSRF token.
    myPackage.DatabaseClass pDAO = myPackage.DatabaseClass.getInstance();
    // Standardized to csrf_token for consistency across the application
    String csrfToken = (String) session.getAttribute("csrf_token");
    if (csrfToken == null) {
        csrfToken = UUID.randomUUID().toString();
        session.setAttribute("csrf_token", csrfToken);
    }
    
    // Get the current user from the request scope, set by adm-page.jsp
    User currentUser = (User) request.getAttribute("currentUser");

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

<%@ include file="modal_assets.jspf" %>

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

            <!-- Main Form for Bulk Actions -->
            <form id="resultsForm" action="controller.jsp" method="post">
                <input type="hidden" name="page" value="results">
                <input type="hidden" name="operation" id="bulkOperation" value="">
                <input type="hidden" name="csrf_token" value="<%= csrfToken %>">

                <!-- Results Header with Delete Selected Button at Top -->
                <div class="results-header">
                    <div>
                        <div class="results-title">All Results</div>
                        <div class="results-count" id="resultsCount">Loading...</div>
                    </div>
                    <div class="search-container">
                        <input type="text" id="globalSearch" class="search-input" placeholder="Search in all columns...">
                        <button type="button" onclick="performGlobalSearch()" class="filter-button">Search</button>
                    </div>
                </div>

                <!-- Results Table -->
                <table id="results-table">
                    <thead>
                        <tr>
                            <th style="width: 20px;"><input type="checkbox" id="selectAll"></th>
                            <th onclick="sortTable(1)">Student Name</th>
                            <th onclick="sortTable(2)">Date</th>
                            <th onclick="sortTable(3)">Course</th>
                            <th onclick="sortTable(4)">Time</th>
                            <th onclick="sortTable(5)">Marks</th>
                            <th onclick="sortTable(6)">Status</th>
                            <th>Action</th>
                        </tr>
                    </thead>
                    <tbody id="resultsBody">
                        <%
                            ArrayList<Exams> list = pDAO.getAllExamsWithResults();
                            
                            if (list.isEmpty()) {
                        %>
                        <tr>
                            <td colspan="8" class="no-results">No results found</td>
                        </tr>
                        <%
                            } else {
                                for (Exams e : list) {
                                    String statusClass = "";
                                    String statusText = e.getStatus() != null ? e.getStatus() : "Terminated";
                                    if (statusText.equals("Pass")) {
                                        statusClass = "status-pass";
                                    } else if (statusText.equals("Fail")) {
                                        statusClass = "status-fail";
                                    } else {
                                        statusClass = "status-terminated";
                                    }
                        %>
                        <tr class="result-row"
                            data-student="<%= e.getFullName().toLowerCase() %> <%= e.getEmail().toLowerCase() %>"
                            data-course="<%= e.getcName() %>"
                            data-status="<%= statusText %>"
                            data-date="<%= e.getDate() %>">
                            <td><input type="checkbox" name="eids" value="<%= e.getExamId() %>" class="record-checkbox" onchange="updateBulkDeleteButton()"></td>
                            <td><%= e.getFullName() %><br><small><%= e.getEmail() %></small></td>
                            <td><%= e.getDate() %></td>
                            <td><%= e.getcName() %></td>
                            <td><%= e.getStartTime() + " - " + e.getEndTime() %></td>
                            <td><strong><%= e.getObtMarks() %> / <%= e.gettMarks() %></strong></td>
                            <td><span class="<%= statusClass %>"><%= statusText %></span></td>
                            <td>
                                <a href="adm-page.jsp?pgprt=5&eid=<%= e.getExamId() %>" class="action-link">Details</a>
                                <button type="button" class="action-link delete-btn"
                                        data-exam-id="<%= e.getExamId() %>"
                                        data-student-name="<%= e.getFullName() %>"
                                        data-course-name="<%= e.getcName() %>"
                                        data-student-email="<%= e.getEmail() %>"
                                        data-marks="<%= e.getObtMarks() %>/<%= e.gettMarks() %>"
                                        style="border: none; background: none; cursor: pointer; color: #dc3545; text-decoration: underline;">Delete</button>
                            </td>
                        </tr>
                        <%
                                }
                            }
                        %>
                    </tbody>
                </table>
            </form>
            
            <!-- Delete Confirmation Modal -->
            <div id="deleteConfirmationModal" class="modal-overlay">
                <div class="modal-content">
                    <div class="modal-header">
                        <h2 class="modal-title"><i class="fas fa-trash"></i> Confirm Deletion</h2>
                        <button class="close-button" onclick="closeDeleteModal()">&times;</button>
                    </div>
                    <div class="modal-body">
                        <p id="deleteModalMessage"></p>
                    </div>
                    <div class="modal-footer" id="deleteModalFooter">
                        <!-- Buttons will be populated by JavaScript -->
                    </div>
                </div>
            </div>
            
        <% } else { %>
            <!-- Result Details View (this part remains unchanged) -->
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
                        <td><%= escapeHtml(a.getAnswer() != null ? a.getAnswer() : "No Answer") %></td>
                        <td><%= escapeHtml(a.getCorrectAnswer() != null ? a.getCorrectAnswer() : "N/A") %></td>
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
const csrfToken = '<%= csrfToken %>';

// Update bulk delete button state based on selected checkboxes
function updateBulkDeleteButton() {
    const selectedCheckboxes = document.querySelectorAll('.record-checkbox:checked');
    const bulkDeleteBtn = document.getElementById('bulkDeleteBtn');
    bulkDeleteBtn.disabled = selectedCheckboxes.length === 0;
}

// Initialize when page loads
document.addEventListener('DOMContentLoaded', function() {
    if (document.getElementById('resultsBody')) {
        const rows = document.querySelectorAll('#resultsBody tr.result-row');
        originalResults = Array.from(rows).map(row => row.outerHTML);
        updateResultsCount();

        // Attach event listeners
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
        
        // --- DELETION LOGIC ---
        // Select All Checkbox
        document.getElementById('selectAll').addEventListener('change', function(e) {
            document.querySelectorAll('.record-checkbox').forEach(checkbox => {
                checkbox.checked = e.target.checked;
                // Trigger onchange event to update bulk delete button
                checkbox.dispatchEvent(new Event('change'));
            });
        });

        // Single Delete Buttons
        document.querySelectorAll('.delete-btn').forEach(button => {
            button.addEventListener('click', function() {
                const examId = this.dataset.examId;
                const studentName = this.dataset.studentName;
                const courseName = this.dataset.courseName;
                const studentEmail = this.dataset.studentEmail;
                const marks = this.dataset.marks;
                
                openDeleteModal(
                    `Are you sure you want to delete the result for <strong>${studentName}</strong> in <strong>${courseName}</strong>?<br><br>` +
                    `<strong>Student:</strong> ${studentName}<br>` +
                    `<strong>Email:</strong> ${studentEmail}<br>` +
                    `<strong>Course:</strong> ${courseName}<br>` +
                    `<strong>Marks:</strong> ${marks}<br>` +
                    `<br>This action cannot be undone.`,
                    () => submitSingleDelete(examId)
                );
            });
        });

        // Bulk Delete Button
        document.getElementById('bulkDeleteBtn').addEventListener('click', function() {
            const selectedIds = getSelectedIds();
            if (selectedIds.length === 0) {
                alert('Please select at least one record to delete.');
                return;
            }
            openDeleteModal(
                `Are you sure you want to delete the <strong>${selectedIds.length}</strong> selected record(s)?<br><br>` +
                `This action cannot be undone.`,
                () => submitBulkDelete()
            );
        });
    }
});

function getSelectedIds() {
    return Array.from(document.querySelectorAll('.record-checkbox:checked')).map(cb => cb.value);
}

function submitSingleDelete(examId) {
    // Create a form to submit the delete request
    const form = document.createElement('form');
    form.method = 'POST';
    form.action = 'controller.jsp';
    form.style.display = 'none'; // Hide the form
    
    // Add hidden inputs
    const pageInput = document.createElement('input');
    pageInput.type = 'hidden';
    pageInput.name = 'page';
    pageInput.value = 'results';
    
    const operationInput = document.createElement('input');
    operationInput.type = 'hidden';
    operationInput.name = 'operation';
    operationInput.value = 'delete';
    
    const examIdInput = document.createElement('input');
    examIdInput.type = 'hidden';
    examIdInput.name = 'eid';
    examIdInput.value = examId;
    
    const csrfTokenInput = document.createElement('input');
    csrfTokenInput.type = 'hidden';
    csrfTokenInput.name = 'csrf_token';
    csrfTokenInput.value = csrfToken;
    
    // Append inputs to form
    form.appendChild(pageInput);
    form.appendChild(operationInput);
    form.appendChild(examIdInput);
    form.appendChild(csrfTokenInput);
    
    // Append form to body and submit
    document.body.appendChild(form);
    form.submit();
}

function submitBulkDelete() {
    const form = document.getElementById('resultsForm');
    const selectedIds = getSelectedIds();
    
    if (selectedIds.length === 0) {
        alert('No items selected for deletion.');
        return;
    }
    
    // Add a hidden input for the operation
    const operationInput = document.createElement('input');
    operationInput.type = 'hidden';
    operationInput.name = 'operation';
    operationInput.value = 'delete';
    form.appendChild(operationInput);
    
    // Submit the form
    form.submit();
}

const deleteModal = document.getElementById('deleteConfirmationModal');
const modalMessage = document.getElementById('deleteModalMessage');
const modalFooter = document.getElementById('deleteModalFooter');

function openDeleteModal(message, confirmCallback) {
    modalMessage.innerHTML = message;
    modalFooter.innerHTML = `
        <button type="button" class="btn btn-secondary" onclick="closeDeleteModal()">Cancel</button>
        <button type="button" class="btn btn-error" id="confirmDeleteBtn">Yes, Delete</button>
    `;
    document.getElementById('confirmDeleteBtn').onclick = function() {
        this.innerHTML = '<i class="fas fa-spinner fa-spin"></i> Deleting...';
        this.disabled = true;
        confirmCallback();
    };
    deleteModal.style.display = 'flex';
}

function closeDeleteModal() {
    deleteModal.style.display = 'none';
}


// --- FILTERING AND SORTING LOGIC ---
function updateResultsCount() {
    const visibleRows = document.querySelectorAll('#resultsBody tr.result-row:not([style*="display: none"])').length;
    const totalRows = originalResults.length;
    document.getElementById('resultsCount').textContent = 'Showing ' + visibleRows + ' of ' + totalRows + ' results';
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
        
        if (searchTerm && !row.dataset.student.includes(searchTerm)) {
            showRow = false;
        }
        if (courseFilter && row.dataset.course !== courseFilter) {
            showRow = false;
        }
        if (statusFilter && row.dataset.status !== statusFilter) {
            showRow = false;
        }
        
        if (dateFrom || dateTo) {
            const rowDate = new Date(row.dataset.date);
            if (dateFrom && rowDate < new Date(dateFrom)) {
                showRow = false;
            }
            if (dateTo) {
                const toDate = new Date(dateTo);
                toDate.setHours(23, 59, 59, 999);
                if (rowDate > toDate) showRow = false;
            }
        }
        
        if (globalSearch && !row.textContent.toLowerCase().includes(globalSearch)) {
            showRow = false;
        }
        
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
    
    const resultsBody = document.getElementById('resultsBody');
    resultsBody.innerHTML = originalResults.join('');
    
    currentSortColumn = -1;
    sortDirection = 1;
    document.querySelectorAll('#results-table thead th').forEach(header => {
        header.classList.remove('sort-asc', 'sort-desc');
    });
    
    updateResultsCount();
}

function sortTable(columnIndex) {
    const table = document.getElementById('results-table');
    const tbody = table.querySelector('tbody');
    const rows = Array.from(tbody.querySelectorAll('tr.result-row:not([style*="display: none"])'));
    
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
    
    rows.sort((a, b) => {
        let aValue, bValue;
        
        switch(columnIndex) {
            case 1:
                aValue = a.cells[1].textContent.toLowerCase();
                bValue = b.cells[1].textContent.toLowerCase();
                break;
            case 2:
                aValue = new Date(a.dataset.date);
                bValue = new Date(b.dataset.date);
                break;
            case 3:
                aValue = a.cells[3].textContent.toLowerCase();
                bValue = b.cells[3].textContent.toLowerCase();
                break;
            case 4:
                aValue = a.cells[4].textContent.toLowerCase();
                bValue = b.cells[4].textContent.toLowerCase();
                break;
            case 5:
                const aMarks = a.cells[5].textContent.split('/');
                const bMarks = b.cells[5].textContent.split('/');
                aValue = parseInt(aMarks[0]) / parseInt(aMarks[1]);
                bValue = parseInt(bMarks[0]) / parseInt(bMarks[1]);
                break;
            case 6:
                const statusOrder = { 'Pass': 1, 'Fail': 2, 'Terminated': 3 };
                aValue = statusOrder[a.dataset.status] || 4;
                bValue = statusOrder[b.dataset.status] || 4;
                break;
            default:
                return 0;
        }
        
        if (aValue < bValue) return -1 * sortDirection;
        if (aValue > bValue) return 1 * sortDirection;
        return 0;
    });
    
    rows.forEach(row => tbody.appendChild(row));
    updateResultsCount();
}
</script>
