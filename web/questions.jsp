<%@page import="java.util.ArrayList"%>
<%@page import="myPackage.DatabaseClass"%>
<jsp:useBean id="pDAO" class="myPackage.DatabaseClass" scope="page"/>

<style>
    .sidebar {
        width: 250px;
        height: 100vh;
        background-color: black;
        position: fixed;
        top: 0;
        left: 0;
        color: white;
        display: flex;
        flex-direction: column;
        justify-content: space-between;
    }    
</style>

<!-- SIDEBAR -->
<div class="sidebar">
    <div class="sidebar-background" style="background-color:#F3F3F3; color:black">
        <div style="text-align: center; margin: 20px 0;">
            <img src="IMG/mut.png" alt="MUT Logo" style="max-height: 120px;">
        </div>
        <div class="left-menu">
            <a href="adm-page.jsp?pgprt=0"><h2 style="color:black">Profile</h2></a>
            <a href="adm-page.jsp?pgprt=2"><h2 style="color:black">Courses</h2></a>
            <a class="active" href="adm-page.jsp?pgprt=3"><h2 style="color:black">Questions</h2></a>
            <a href="adm-page.jsp?pgprt=5"><h2 style="color:black">Students Results</h2></a>
            <a href="adm-page.jsp?pgprt=1"><h2 style="color:black">Accounts</h2></a>
        </div>
    </div>
</div>

<!-- CONTENT AREA -->
<div class="content-area">
    <div class="panel form-style-6" style="min-width: 300px; max-width: 390px; float: left">
        <form action="adm-page.jsp">
            <div class="title" style="background-color: #D8A02E">Show All Questions for</div>
            <br><br>
            <label>Select Course</label>
            <input type="hidden" name="pgprt" value="4">
            <select name="coursename" class="text" id="courseSelectShowAll">
                <% 
                ArrayList<String> courseNames = pDAO.getAllCourseNames(); 
                String lastCourseName = pDAO.getLastCourseName(); // Get the last course name
                for (String course : courseNames) {
                %>
                <option value="<%=course%>" <%=lastCourseName.equals(course) ? "selected" : ""%>><%=course%></option>
                <% } %>
            </select>
            <input type="submit" class="form-button" value="Show" style="background-color: #d3d3d3; border: none; border-radius: 12px; padding: 10px 20px; font-size: 16px; color: #000; cursor: pointer;">
        </form>
    </div>

    <div class="panel form-style-6" style="max-width: 600px; float: left">
        <form action="controller.jsp" method="POST">
            <div class="title" style="background-color: #D8A02E">Add New Question</div>
            <table>
                <tr>
                    <td><label>Select Course:</label></td>
                    <td colspan="4">
                        <select name="coursename" class="text" id="courseSelectAddNew" required>
                            <option value="">Select Course</option>
                            <% 
                            ArrayList<String> allCourseNames = pDAO.getAllCourseNames();
                            lastCourseName = pDAO.getLastCourseName(); // Get the last course name
                            for (String course : allCourseNames) {
                            %>
                            <option value="<%=course%>" <%=lastCourseName.equals(course) ? "selected" : ""%>><%=course%></option>
                            <% } %>
                        </select>
                    </td>
                </tr>

                <tr>
                    <td><label>Your Question:</label></td>
                    <td colspan="4">
                        <input type="text" name="question" class="text" placeholder="Type your question here" style="width: 540px;" required>
                    </td>
                </tr>

                <tr>
                    <td><label>Question Type</label></td>
                    <td colspan="4">
                        <select name="questionType" id="questionType" class="text" onchange="toggleOptions()">
                            <option value="MCQ">Multiple Choice</option>
                            <option value="TrueFalse">True/False</option>
                        </select>
                    </td>
                </tr>

                <tr id="mcqOptions">
                    <td><label>Options</label></td>
                    <td><input type="text" name="opt1" class="text" placeholder="First Option" style="width: 130px;"></td>
                    <td><input type="text" name="opt2" class="text" placeholder="Second Option" style="width: 130px;"></td>
                    <td><input type="text" name="opt3" class="text" placeholder="Third Option" style="width: 130px;"></td>
                    <td><input type="text" name="opt4" class="text" placeholder="Fourth Option" style="width: 130px;"></td>
                </tr>

                <tr>
                    <td><label>Correct Answer</label></td>
                    <td colspan="4">
                        <input type="text" id="correctAnswer" name="correct" class="text" placeholder="Correct Answer" style="width: 130px;" required>
                    </td>
                </tr>

                <tr>
                    <td colspan="5">
                        <input type="hidden" name="page" value="questions">
                        <input type="hidden" name="operation" value="addnew">
                        <center>
                            <input type="submit" class="form-button" value="Add" 
                            style="background-color: #d3d3d3; border: none; border-radius: 12px; padding: 10px 20px; font-size: 16px; color: #000; cursor: pointer;width:50%">
                        </center>
                    </td>
                </tr>
            </table>
        </form>

        <script>
            function toggleOptions() {
                var questionType = document.getElementById("questionType").value;
                var mcqOptions = document.getElementById("mcqOptions");
                var correctAnswer = document.getElementById("correctAnswer");

                if (questionType === "TrueFalse") {
                    mcqOptions.style.display = "none"; 
                    correctAnswer.value = ""; 
                    correctAnswer.placeholder = "True/False"; 
                } else {
                    mcqOptions.style.display = "table-row"; 
                    correctAnswer.placeholder = "Correct Answer"; 
                }
            }

            window.onload = function() {
                toggleOptions(); 
                
                // Synchronize course dropdowns
                const courseSelectAddNew = document.getElementById('courseSelectAddNew');
                const courseSelectShowAll = document.getElementById('courseSelectShowAll');

                courseSelectAddNew.addEventListener('change', function() {
                    courseSelectShowAll.value = this.value; // Update the Show All Questions dropdown
                });
            };
        </script>
    </div>
</div>