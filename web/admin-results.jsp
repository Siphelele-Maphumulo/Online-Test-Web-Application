<%@page import="myPackage.classes.Answers"%>
<%@page import="myPackage.classes.Exams"%>
<%@page import="myPackage.classes.Questions"%>
<%@page import="java.util.ArrayList"%>
<jsp:useBean id="pDAO" class="myPackage.DatabaseClass" scope="page"/>
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.3/css/all.min.css">

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
            <a class="active" href="adm-page.jsp?pgprt=5"><h2 style="color:black">Students Results</h2></a>
            <a href="adm-page.jsp?pgprt=1"><h2 style="color:black">Accounts</h2></a>
        </div>
    </div>
</div>

<!-- CONTENT AREA -->
<div class="content-area">
    <div class="panel" style="float: left; max-width: 900px">
        
        <!-- Search Box -->
        <div style="text-align: right; margin-bottom: 10px;">
            <input type="text" id="searchBox" placeholder="Search Student ID..." onkeyup="filterTable()" style="padding: 5px; width: 200px;">
        </div>
        
        <% if (request.getParameter("eid") == null) { %>
            <div class="title" style="background-color: #D8A02E">All Results</div>
            <table id="rounded-corner" style="width: 100%;">
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
                <tbody id="resultsTableBody">
                    <% 
                        // Fetching results for all students
                        ArrayList<Exams> list = pDAO.getResultsFromExams();
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
                        <td style="text-align: center;"><a href="adm-page.jsp?pgprt=5&eid=<%= e.getExamId() %>">Details</a></td>
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
                    <td rowspan="2" style="text-align: center;"><%= i + 1 %>)</td>
                    <td colspan="2" style="text-align: left;"><%= a.getQuestion() %></td>
                    <td rowspan="2" style="text-align: center;">
                        <% if (a.getStatus().equals("correct")) { %>
                            <span style="color: green;"><%= a.getStatus() %></span>
                        <% } else { %>
                            <span style="color: red;"><%= a.getStatus() %></span>
                        <% } %>
                    </td>
                </tr>
                <tr>
                    <td style="text-align: left;"><%="Your Ans: " + a.getAnswer() %></td>
                    <td style="text-align: left;"><%="Correct Ans: " + a.getCorrectAns() %></td>
                </tr>
                <tr>
                    <td colspan="3" style="background: white"></td>
                <% } %>
            </table>
        <% } %>
    </div>
</div>

<script>
    let table = document.getElementById('resultsTableBody');
    const rows = Array.from(table.rows);

    function toggleSort(header) {
        const columnIndex = [...header.children].indexOf(header.children[0]);
        rows.sort((a, b) => {
            const cellA = a.cells[columnIndex].innerText;
            const cellB = b.cells[columnIndex].innerText;

            if (columnIndex === 6 || columnIndex === 8) { // Marks and %, treat as numbers
                return a.dataset.direction === "asc"
                    ? parseFloat(cellA) - parseFloat(cellB)
                    : parseFloat(cellB) - parseFloat(cellA);
            } else {
                return a.dataset.direction === "asc"
                    ? cellA.localeCompare(cellB)
                    : cellB.localeCompare(cellA);
            }
        });
        
        rows.forEach((row) => table.appendChild(row));
        header.children[0].classList.toggle("rotate");
    }

    function filterTable() {
        const input = document.getElementById('searchBox');
        const filter = input.value.toLowerCase();
        const tableBody = document.getElementById('resultsTableBody');
        const rows = tableBody.getElementsByTagName('tr');

        for (let i = 0; i < rows.length; i++) {
            const cells = rows[i].getElementsByTagName('td');
            if (cells.length > 0) {
                const userIdCell = cells[1].innerText.toLowerCase(); // Assuming the User ID is in the second column
                if (userIdCell.includes(filter)) {
                    rows[i].style.display = "";
                } else {
                    rows[i].style.display = "none";
                }
            }
        }
    }

    // Initialize sorting and toggling rotation
    window.onload = () => {
        const headers = document.querySelectorAll('th');
        headers.forEach((header) => {
            header.addEventListener("click", () => {
                header.children[0].classList.toggle("rotate");
            });
        });
    };
</script>

<style>
    .rotate {
        transform: rotate(180deg);
    }
</style>