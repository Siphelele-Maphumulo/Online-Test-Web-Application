<%@page import="myPackage.classes.Exams"%>
<%@page import="myPackage.classes.Questions"%>
<%@page import="java.util.ArrayList"%>
<jsp:useBean id="pDAO" class="myPackage.DatabaseClass" scope="page"/>

<!-- SIDEBAR -->
<div class="sidebar">
    <div class="sidebar-background" style="background-color:#F3F3F3; color:black">
        <div style="flex: 1;">
            <img src="IMG/mut.png" alt="MUT Logo" style="max-height: 120px;">
        </div>
        <div class="left-menu">
            <a href="std-page.jsp?pgprt=0"><h2 style="color:black">Profile</h2></a>
            <a class="active" href="std-page.jsp?pgprt=1"><h2 style="color:black">Exams</h2></a>
            <a href="std-page.jsp?pgprt=2"><h2 style="color:black">Results</h2></a>
        </div>
    </div>
</div>

<!-- CONTENT AREA -->
<div class="content-area">
    <% if (session.getAttribute("examStarted") != null) { %> 
    
    <% } %>

    <% if (session.getAttribute("examStarted") != null && session.getAttribute("examStarted").equals("1")) { %>
        <span id="remainingTime" style="position: fixed;top:90px;left: 300px;font-size: 23px;background: rgba(255,0,77,0.38);border-radius: 5px;padding: 10px;box-shadow: 2px -2px 6px 0px;">
        </span>
        
        <script>
            var time = <%= pDAO.getRemainingTime(Integer.parseInt(session.getAttribute("examId").toString())) %>;
            time--;
            var sec = 60;
            document.getElementById("remainingTime").innerHTML = time + " : " + sec;
            var x = window.setInterval(timerFunction, 1000);

            function timerFunction() {
                sec--;
                if (time < 0) {
                    clearInterval(x);
                    document.getElementById("remainingTime").innerHTML = "00 : 00";
                    document.getElementById("myform").submit();
                }
                document.getElementById("remainingTime").innerHTML = time + " : " + sec;
                if (sec == 0) {
                    sec = 60;
                    time--;
                }
            }
        </script>

        <form id="myform" action="controller.jsp">
            <%
            ArrayList<Questions> questionsList = pDAO.getQuestions(request.getParameter("coursename"), 20);
            %>
            <input type="hidden" name="size" value="<%= questionsList.size() %>">
            <input type="hidden" name="totalmarks" value="<%= pDAO.getTotalMarksByName(request.getParameter("coursename")) %>">
            
            <%
            for (int i = 0; i < questionsList.size(); i++) {
                Questions question = questionsList.get(i);
            %>
            <center>
                <div class="question-panel">
                    <div class="question">
                        <label class="question-label"><%= i + 1 %></label>
                        <%= question.getQuestion() %>
                    </div>
                    <div class="answer">
                        <input type="radio" id="c1<%= i %>" name="ans<%= i %>" value="<%= question.getOpt1() %>"/>
                        <label for="c1<%= i %>"><%= question.getOpt1() %></label>
                        <input type="radio" id="c2<%= i %>" name="ans<%= i %>" value="<%= question.getOpt2() %>"/>
                        <label for="c2<%= i %>"><%= question.getOpt2() %></label>
                        <input type="radio" id="c3<%= i %>" name="ans<%= i %>" value="<%= question.getOpt3() %>"/>
                        <label for="c3<%= i %>"><%= question.getOpt3() %></label>
                        <input type="radio" id="c4<%= i %>" name="ans<%= i %>" value="<%= question.getOpt4() %>"/>
                        <label for="c4<%= i %>"><%= question.getOpt4() %></label>
                    </div>
                </div>
                <input type="hidden" name="question<%= i %>" value="<%= question.getQuestion() %>">
                <input type="hidden" name="qid<%= i %>" value="<%= question.getQuestionId() %>">
            </center>
            <% } %>
            <input type="hidden" name="page" value="exams">
            <input type="hidden" name="operation" value="submitted"> 
            <input type="submit" class="add-btn" value="Done">
        </form>
    <% } else if (request.getParameter("showresult") != null && request.getParameter("showresult").equals("1")) { 
        Exams result = pDAO.getResultByExamId(Integer.parseInt(request.getParameter("eid")));
    %>
        <div class="panel" style="float: left;max-width: 900px">
            <div class="title">Result of Recent Exam</div>
            <div class="profile">
                <span class="tag">Exam Date</span><span class="val"><%= result.getDate() %></span><br/>
                <span class="tag">Start Time</span><span class="val"><%= result.getStartTime() %></span><br/>
                <span class="tag">End Time</span><span class="val"><%= result.getEndTime() %></span><br/>
                <span class="tag">Course Name</span><span class="val"><%= result.getcName() %></span><br/>
                <span class="tag">Obtained Marks</span><span class="val"><%= result.getObtMarks() %></span><br/>
                <span class="tag">Total Marks</span><span class="val"><%= result.gettMarks() %></span><br/>
                <span class="tag">Result</span><span class="val"><%= result.getStatus() %></span>
            </div>
        </div>
    <% } else if (session.getAttribute("examStarted") == null) { %>
        <div class="panel form-style-6" style="float: left;max-width: 900px; padding-top: 40px;">
            <div class="title" style="margin-top: -60px;background-color: #D8A02E">Select Course to Take Exam</div>
            <form action="controller.jsp">
                <label>Select Course</label>
                <input type="hidden" name="page" value="exams">
                <input type="hidden" name="operation" value="startexam">
                <select name="coursename" class="text">
                    <% 
                    ArrayList<String> courseList = pDAO.getAllCourseNames();  // Method to get course names
                    for (String course : courseList) {
                    %>
                    <option value="<%= course %>"><%= course %></option>
                    <% } %>
                </select>

                <input type="submit" class="form-button" value="Take Exam" 
                       style="background-color: #d3d3d3; border: none; border-radius: 12px; padding: 10px 20px; font-size: 16px; color: #000; cursor: pointer;">
            </form>
        </div>
    <% } %>
</div>