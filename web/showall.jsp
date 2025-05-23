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
            <a href="adm-page.jsp?pgprt=0"><h2 style="color:black">Profile</h2></a>
            <a href="adm-page.jsp?pgprt=2"><h2 style="color:black">Courses</h2></a>
            <a class="active" href="adm-page.jsp?pgprt=3"><h2 style="color:black">Questions</h2></a>
            <a href="adm-page.jsp?pgprt=5"><h2 style="color:black">Students Results</h2></a>
            <a href="adm-page.jsp?pgprt=1"><h2 style="color:black">Accounts</h2></a>
        </div>
    </div>
</div>

<!-- CONTENT AREA -->
<div class="content-area" >
    <center>
        <%
          if (request.getParameter("coursename") != null) {
              ArrayList list = pDAO.getAllQuestions(request.getParameter("coursename"));
              for (int i = 0; i < list.size(); i++) {
                  Questions question = (Questions) list.get(i);
                  String questionId = String.valueOf(question.getQuestionId());
                  String questionNumber = String.valueOf(i + 1);
                  String questionText = question.getQuestion();
                  String opt1 = question.getOpt1();
                  String opt2 = question.getOpt2();
                  String opt3 = question.getOpt3();
                  String opt4 = question.getOpt4();
                  String correct = question.getCorrect();

                  %>
                  <div class="question-panel">
                    <div class="question" >
                        <label class="question-label"><%=questionNumber%></label>
                        <%=questionText %>	

                    </div>
                    
                    <div class="answer">
                        <label class="show"><%=opt1%></label>
                        <label class="show"><%=opt2%></label>
                        <% if (opt3 != null && !opt3.isEmpty()) { %>
                            <label class="show"><%=opt3%></label>
                        <% } %>
                        <% if (opt4 != null && !opt4.isEmpty()) { %>
                            <label class="show"><%=opt4%></label>
                        <% } %>
                        <label class="show-correct"><%=correct%></label>
                        <!-- Edit button on the far end cornener -->
                    </div>
                    <a href="controller.jsp?page=questions&operation=del&qid=<%= question.getQuestionId() %>" 
                       onclick="return confirm('Are you sure you want to delete this question?');" style="padding-left: 60%;">
                        <button class="delete-btn"  >Delete </button>
                    </a>
                        
                    <!-- Edit Button -->
                    <a href="edit_question.jsp?qid=<%= question.getQuestionId() %>">
                        <button class="edit-btn"> Edit </button>
                    </a>   
                  </div>  
                  <% 
              }
          } 
        %>
    </center>
</div>