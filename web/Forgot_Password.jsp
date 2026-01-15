
<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
    <title>Forgot Password</title>
    <link rel="stylesheet" href="style.css">
    <style>
        .container {
            display: flex;
            min-height: 80vh;
        }
        .sidebar {
            width: 20%;
            background-color: #f0f0f0;
        }
        .content {
            width: 80%;
            padding: 20px;
        }
    </style>
    <script>
        function checkEmail() {
            var email = document.getElementById("email").value;
            var xhttp = new XMLHttpRequest();
            xhttp.onreadystatechange = function() {
                if (this.readyState == 4 && this.status == 200) {
                    if (this.responseText.trim() === "exists") {
                        document.getElementById("resetBtn").disabled = false;
                    } else {
                        document.getElementById("resetBtn").disabled = true;
                    }
                }
            };
            xhttp.open("POST", "controller.jsp", true);
            xhttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
            xhttp.send("page=forgot_password&action=check_email&email=" + email);
        }

        function sendResetLink(event) {
            event.preventDefault();
            var email = document.getElementById("email").value;
            var xhttp = new XMLHttpRequest();
            xhttp.onreadystatechange = function() {
                if (this.readyState == 4 && this.status == 200) {
                    showResetForm();
                }
            };
            xhttp.open("POST", "controller.jsp", true);
            xhttp.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
            xhttp.send("page=forgot_password&action=send_code&email=" + email);
        }

        function showResetForm() {
            document.getElementById("emailForm").style.display = "none";
            document.getElementById("resetForm").style.display = "block";
            document.querySelector("#resetForm input[name='email']").value = document.getElementById("email").value;
        }
    </script>
</head>
<body>
    <jsp:include page="header.jsp" />
    <div class="container">
        <div class="sidebar">
            </div>
        <div class="content">
            <h1>Forgot Password</h1>
            <div id="emailForm">
                <p>Please enter your email address to reset your password.</p>
                <form action="controller.jsp" method="post" onsubmit="sendResetLink(event)">
                    <input type="hidden" name="page" value="forgot_password">
                    <input type="hidden" name="action" value="send_code">
                    <input type="email" name="email" id="email" placeholder="Enter your email" onkeyup="checkEmail()" required>
                    <input type="submit" id="resetBtn" value="Reset Password" disabled>
                </form>
            </div>
            <div id="resetForm" style="display:none;">
                <p>A verification code has been sent to your email. Please enter the code and your new password.</p>
                <form action="controller.jsp" method="post">
                    <input type="hidden" name="page" value="forgot_password">
                    <input type="hidden" name="action" value="reset_password">
                    <input type="hidden" name="email" value="<%= request.getParameter("email") %>">
                    <input type="text" name="code" placeholder="Enter verification code" required>
                    <input type="password" name="password" placeholder="Enter new password" required>
                    <input type="password" name="confirm_password" placeholder="Confirm new password" required>
                    <input type="submit" value="Change Password">
                </form>
            </div>
        </div>
    </div>
    <jsp:include page="footer.jsp" />
</body>
</html>
