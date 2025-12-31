<%
    String message = (String) session.getAttribute("message");
    String error = (String) session.getAttribute("error");
%>

<% if (message != null) { %>
    <div class="alert alert-success" role="alert">
        <%= message %>
    </div>
    <% session.removeAttribute("message"); %>
<% } %>

<% if (error != null) { %>
    <div class="alert alert-danger" role="alert">
        <%= error %>
    </div>
    <% session.removeAttribute("error"); %>
<% } %>
