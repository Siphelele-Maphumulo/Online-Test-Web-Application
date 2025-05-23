<%@page import="myPackage.classes.Answers"%>
<%@page import="myPackage.classes.Exams"%>
<%@page import="myPackage.classes.Questions"%>
<%@page import="java.util.ArrayList"%>
<jsp:useBean id="pDAO" class="myPackage.DatabaseClass" scope="page"/>
<!-- SIDEBAR -->
<div class="sidebar" style="background-color:#3b5998">
    <div class="sidebar-background" style="background-color:#F3F3F3; color:black">
        <div style="flex: 1;">
            <img src="IMG/mut.png" alt="MUT Logo" style="max-height: 120px;">
        </div>
        <div class="left-menu">
            <a href="std-page.jsp?pgprt=0"><h2 style="color:black">Profile</h2></a>
            <a href="std-page.jsp?pgprt=1"><h2 style="color:black">Exams</h2></a>
            <a class="active" href="std-page.jsp?pgprt=2"><h2 style="color:black">Results</h2></a>
        </div>
    </div>
</div>
<!-- CONTENT AREA -->
<div class="content-area">
    <div class="panel" style="float: left; max-width: 900px">
        <% if (request.getParameter("eid") == null) { %>
            <div class="title" style="background-color: #D8A02E">All Results</div>
            <div style="float: right; padding: 10px;">
                <input type="text" id="courseSearch" placeholder="Search by Course" onkeyup="filterAndSortTable()">
            </div>
            <table id="rounded-corner">
                <thead>
                    <tr>
                        <th scope="col" class="rounded-company" id="nameColumn" style="text-align: center;"
                            title="Filter by Name"
                            onmouseover="this.style.background = '#D8A02E';"
                            onmouseout="this.style.background = '#F3F3F3';"
                            onclick="toggleSort(this)">
                            Name & Surname
                        </th>
                        <th scope="col" class="rounded-company" id="studentIdColumn" style="text-align: center;"
                            title="Filter by ID"
                            onmouseover="this.style.background = '#D8A02E';"
                            onmouseout="this.style.background = '#F3F3F3';"
                            onclick="toggleSort(this)">
                            Student ID
                        </th>
                        <th scope="col" class="rounded-company" id="emailColumn" style="text-align: center;"
                            title="Filter by Email"
                            onmouseover="this.style.background = '#D8A02E';"
                            onmouseout="this.style.background = '#F3F3F3';"
                            onclick="toggleSort(this)">
                            Email
                        </th>
                        <th scope="col" class="rounded-company" id="dateColumn" style="text-align: center;"
                            title="Filter by Date"
                            onmouseover="this.style.background = '#D8A02E';"
                            onmouseout="this.style.background = '#F3F3F3';"
                            onclick="toggleSort(this)">
                             Date
                        </th>
                        <th scope="col" class="rounded-q1" id="courseColumn" style="text-align: center;"
                            title="Filter by Course"
                            onmouseover="this.style.background = '#D8A02E';"
                            onmouseout="this.style.background = '#F3F3F3';"
                            onclick="toggleSort(this)">
                            Course
                        </th>
                        <th scope="col" class="rounded-q2" id="timeColumn" style="text-align: center;"
                            title="Filter by Time"
                            onmouseover="this.style.background = '#D8A02E';"
                            onmouseout="this.style.background = '#F3F3F3';"
                            onclick="toggleSort(this)">
                            Time
                        </th>
                        <th scope="col" class="rounded-q2" id="marksColumn" style="text-align: center;"
                            title="Filter by Marks"
                            onmouseover="this.style.background = '#D8A02E';"
                            onmouseout="this.style.background = '#F3F3F3';"
                            onclick="toggleSort(this)">
                            Marks
                        </th>
                        <th scope="col" class="rounded-q3" id="statusColumn" style="text-align: center;"
                            title="Filter by Status"
                            onmouseover="this.style.background = '#D8A02E';"
                            onmouseout="this.style.background = '#F3F3F3';"
                            onclick="toggleSort(this)">
                            Status
                        </th>
                        <th scope="col" class="rounded-q4" id="percentageColumn" style="text-align: center;"
                            title="Filter by %"
                            onmouseover="this.style.background = '#D8A02E';"
                            onmouseout="this.style.background = '#F3F3F3';"
                            onclick="toggleSort(this)">
                            %
                        </th>
                        <th scope="col" class="rounded-q4" style="text-align: center;">Action</th>
                    </tr>
                </thead>
                <tbody id="courseTable">
                    <% 
                        ArrayList<Exams> list = pDAO.getResultsFromExams(Integer.parseInt(session.getAttribute("userId").toString()));
                        for (int i = 0; i < list.size(); i++) {
                            Exams e = list.get(i);
                            double percentage = 0; // variable to hold percentage
                            if (e.gettMarks() > 0) {
                                percentage = (double) e.getObtMarks() / e.gettMarks() * 100; // Calculate percentage
                            }
                    %>
                    <tr>
                        <td style="text-align: center; white-space: nowrap;"><%= e.getFullName() %></td>
                        <td style="text-align: center; white-space: nowrap;"><%= e.getUserName() %></td>
                        <td style="text-align: center; white-space: nowrap;"><%= e.getEmail() %></td>
                        <td style="text-align: center; white-space: nowrap;"><%= e.getDate() %></td>
                        <td style="text-align: center; white-space: nowrap;"><%= e.getcName() %></td>
                        <td style="text-align: center; white-space: nowrap;"><%= e.getStartTime() + " - " + e.getEndTime() %></td>
                        <td style="text-align: center; white-space: nowrap;"><%= e.getObtMarks() %> / <%= e.gettMarks() %></td>
                        <% if (e.getStatus() != null) {
                            if (e.getStatus().equals("Pass")) { %>
                                <td style="background: #00cc33; color:white; text-align: center;"><%= e.getStatus() %></td>
                            <% } else { %>
                                <td style="background: #ff3333; color:white; text-align: center;"><%= e.getStatus() %></td>
                            <% } 
                        } else { %>
                            <td style="background: bisque; text-align: center;">Terminated</td>
                        <% } %>
                        <td style="text-align: center; white-space: nowrap;"><%= String.format("%.0f", percentage) + " %" %></td>
                        <td style="text-align: center;"><a href="std-page.jsp?pgprt=2&eid=<%= e.getExamId() %>">Details</a></td>
                    </tr>
                    <% } %>
                </tbody>
            </table>
        <% } else { %>
            <div class="title">Result Details</div>

            <table id="gradient-style">
                <%
                    ArrayList<Answers> list = pDAO.getAllAnswersByExamId(Integer.parseInt(request.getParameter("eid")));
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
            
                        <!-- Back Button -->
            <div style="padding: 10px;">
                <button onclick="window.history.back();" style="background-color: #d3d3d3; border: none; border-radius: 12px; padding: 10px 20px; font-size: 16px; color: #000; cursor: pointer;">
                    Back
                </button>
            </div>
        <% } %>
    </div>
</div>

<script>
    // Function to filter course table by course name
    function filterAndSortTable() {
        const courseInput = document.getElementById("courseSearch").value.toLowerCase();
        const courseTable = document.getElementById("courseTable");
        const rows = courseTable.getElementsByTagName("tr");
        
        for (let i = 0; i < rows.length; i++) {
            const row = rows[i];
            const courseCell = row.cells[4]; // Assuming course name is in the fifth column (index 4)
            if (courseCell) {
                const courseText = courseCell.textContent.toLowerCase();
                row.style.display = courseText.indexOf(courseInput) > -1 ? "" : "none";
            }
        }
    }

    function toggleSort(header) {
        const resultsTable = document.getElementById('courseTable');
        const rows = Array.from(resultsTable.rows).slice(1); // Skip header row
        const columnIndex = [...header.parentNode.children].indexOf(header);
        
        rows.sort((a, b) => {
            const cellA = a.cells[columnIndex].innerText;
            const cellB = b.cells[columnIndex].innerText;

            if (columnIndex === 6 || columnIndex === 8) { // Marks and %, treat as numbers
                return parseFloat(cellA) - parseFloat(cellB);
            } else {
                return cellA.localeCompare(cellB);
            }
        });
        
        rows.forEach((row) => resultsTable.appendChild(row));
        header.classList.toggle("rotate");
    }

    // Initialize event listeners
    window.onload = () => {
        const headers = document.querySelectorAll('th');
        headers.forEach((header) => {
            header.addEventListener("click", () => {
                toggleSort(header);
            });
        });
        
        document.getElementById("courseSearch").addEventListener("keyup", filterAndSortTable);
    };
</script>

<style>
    .rotate {
        transform: rotate(180deg);
    }
</style>