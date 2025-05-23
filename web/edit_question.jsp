<%@page import="java.util.ArrayList"%>
<%@page import="myPackage.DatabaseClass"%>
<%@page import="myPackage.classes.Questions"%>
<%@page import="java.sql.*"%>
<%@page contentType="text/html" pageEncoding="UTF-8"%>

<%
    DatabaseClass pDAO = new DatabaseClass(); // Ensure you properly instantiate
    int questionId = Integer.parseInt(request.getParameter("qid"));
    Questions questionToEdit = null;

    // Retrieve question details for the given questionId
    try {
        String sql = "SELECT * FROM questions WHERE question_id=?";
        PreparedStatement pstm = pDAO.conn.prepareStatement(sql);
        pstm.setInt(1, questionId);
        ResultSet rs = pstm.executeQuery();
        if (rs.next()) {
            questionToEdit = new Questions(
                rs.getInt("question_id"),
                rs.getString("question"),
                rs.getString("opt1"),
                rs.getString("opt2"),
                rs.getString("opt3"),
                rs.getString("opt4"),
                rs.getString("correct"),
                rs.getString("course_name")
            );
        }
    } catch (SQLException e) {
        e.printStackTrace();
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Edit Question</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
        }

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
        }
        
        .sidebar-background {
            background-color: #F3F3F3;
            color: black;
            flex: 1;
        }

        .left-menu a {
            color: black;
            text-decoration: none;
            padding: 10px;
            display: block;
        }

        .left-menu a:hover {
            background-color: #D8A02E;
            color: white;
        }

        .content-area {
            margin-left: 260px; /* account for sidebar width plus spacing */
            padding: 20px;
        }

        .form-style-6 {
            padding: 20px;
            border: 1px solid #009;
            background: #F7F7F7;
            width: 600px;
            box-shadow: 0 0 10px rgba(0,0,0,0.2);
        }

        .title {
            background-color: #D8A02E;
            color: white;
            padding: 10px;
            text-align: center;
            font-size: 1.5em;
        }

        label {
            margin: 10px 0 5px;
            display: block;
        }

        input[type="text"], select {
            width: calc(100% - 20px);
            padding: 10px;
            margin-bottom: 10px;
            border: 1px solid #ccc;
            border-radius: 5px;
        }

        input[type="submit"] {
            padding: 10px;
            background-color: #D8A02E;
            border: none;
            border-radius: 5px;
            color: white;
            cursor: pointer;
            font-size: 1em;
            width: 100%;
        }

        input[type="submit"]:hover {
            background-color: #B78C2B; /* Darker shade for hover */
        }
    </style>
</head>
<body>
    <div class="sidebar">
        <div class="sidebar-background">
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

    <div class="content-area">
        <div class="panel form-style-6">
            <div class="title">Edit Question</div>
            <form action="controller.jsp" method="POST">
                <input type="hidden" name="page" value="questions">
                <input type="hidden" name="operation" value="edit">
                <input type="hidden" name="qid" value="<%= questionToEdit.getQuestionId() %>">

                <label>Select Course:</label>
                <select name="coursename" class="text" id="courseSelect" required>
                    <% 
                    ArrayList<String> allCourseNames = pDAO.getAllCourseNames();
                    String lastCourseName = questionToEdit.getCourseName(); // Set the current course from the question data
                    for (String course : allCourseNames) {
                    %>
                    <option value="<%=course%>" <%=lastCourseName.equals(course) ? "selected" : ""%>><%=course%></option>
                    <% } %>
                </select>

                <label>Question:</label>
                <input type="text" name="question" value="<%= questionToEdit.getQuestion() %>" required>

                <label>Option 1:</label>
                <input type="text" name="opt1" value="<%= questionToEdit.getOpt1() %>" required>

                <label>Option 2:</label>
                <input type="text" name="opt2" value="<%= questionToEdit.getOpt2() %>" required>

                <label>Option 3:</label>
                <input type="text" name="opt3" value="<%= questionToEdit.getOpt3() %>" required>

                <label>Option 4:</label>
                <input type="text" name="opt4" value="<%= questionToEdit.getOpt4() %>" required>

                <label>Correct Option:</label>
                <input type="text" name="correct" value="<%= questionToEdit.getCorrect() %>" required>

                <input type="submit" value="Update Question">
            </form>
        </div>
    </div>
</body>
</html>
