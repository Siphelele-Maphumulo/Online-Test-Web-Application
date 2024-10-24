<%@page import="myPackage.classes.User"%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register New User</title>

    <!-- Bootstrap CSS -->
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">

    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            background-color: #f4f4f4;
            display: flex;
            flex-direction: column;
            min-height: 100vh;
        }

        .central-div {
            text-align: center;
            margin: auto;
            margin-top: 3%;
            width: 50%;
            background-color: white;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            padding: 30px;
            border-radius: 10px;
        }

        h2 {
            margin-bottom: 25px;
            color: #333;
        }

        .grid-container {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 15px;
            width: 100%;
            margin: 0 auto;
        }

        .grid-item {
            display: flex;
            flex-direction: column;
        }

        .grid-submit {
            grid-column: span 2;
            text-align: center;
        }

        input[type="text"], input[type="password"], input[type="email"], input[type="tel"] {
            width: 100%;
            padding: 12px;
            border: 1px solid #ccc;
            border-radius: 4px;
            box-sizing: border-box;
        }

        .button {
            width: 100%;
            padding: 12px;
            background-color: #09294D;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
            transition: background-color 0.3s ease;
        }

        .button:hover {
            background-color: #0056b3;
        }

        .error-message {
            color: #cc0000;
            font-size: 14px;
            display: block;
        }

    </style>
</head>
<body>

<% 
    // Retrieve the "from" parameter from the URL, defaulting to "default" if not present
    String fromPage = request.getParameter("from");
    if (fromPage == null) {
        fromPage = "default"; 
    }
%>

    <!-- Include the header -->
    <jsp:include page="header.jsp" />

<div class="central-div">
    <h2>Register New User</h2>

    <!-- Registration Form -->
    <form action="controller.jsp" method="POST" onsubmit="return validateForm();">
        <input type="hidden" name="page" value="register">
        <input type="hidden" name="from" value="<%= fromPage %>"> <!-- Pass the "from" parameter -->

        <div class="grid-container">
            <div class="grid-item">
                <input type="text" name="fname" class="text" placeholder="First Name" required>
            </div>
            <div class="grid-item">
                <input type="text" name="lname" class="text" placeholder="Last Name" required>
            </div>

            <div class="grid-item">
                <input type="text" name="uname" class="text" placeholder="MUT Identity Number" required>
            </div>

            <div class="grid-item">
                <input type="tel" name="contactno" class="text" placeholder="Contact No" required>
                <span id="errorContact" class="error-message"></span>
            </div>

            <div class="grid-item" style="grid-column: span 2; text-align: center;">
                <input type="email" name="email" class="text" placeholder="MUT Email" required>
                <span id="errorEmail" class="error-message"></span>
            </div>

            <div class="grid-item">
                <input type="text" name="city" class="text" placeholder="City" required>
            </div>

            <div class="grid-item">
                <input type="text" name="address" class="text" placeholder="Address" required>
            </div>

            <div class="grid-item">
                <input type="password" name="pass" class="text" placeholder="Password" required>
                <span id="errorPassword" class="error-message"></span>
            </div>
            <div class="grid-item">
                <input type="password" name="confrimpass" class="text" placeholder="Confirm Password" required>
                <span id="errorConfirmPassword" class="error-message"></span>
            </div>

            <div class="grid-item grid-submit">
                <input type="submit" value="Register Now" class="button">
            </div>
        </div>
    </form>
</div>

    <!-- JavaScript for validation -->
    <script>
        function validateForm() {
            let valid = true;

            const contactNo = document.querySelector('input[name="contactno"]');
            const email = document.querySelector('input[name="email"]');
            const password = document.querySelector('input[name="pass"]');
            const confirmPassword = document.querySelector('input[name="confrimpass"]');

            const errorContact = document.getElementById('errorContact');
            const errorEmail = document.getElementById('errorEmail');
            const errorPassword = document.getElementById('errorPassword');
            const errorConfirmPassword = document.getElementById('errorConfirmPassword');

            // Contact number validation
            const contactRegex = /^\d{10,13}$/;
            if (!contactRegex.test(contactNo.value)) {
                errorContact.textContent = "Invalid contact number.";
                valid = false;
            } else {
                errorContact.textContent = '';
            }

            // Email validation
            const emailRegex = /^[a-zA-Z0-9._%+-]+@(live\.mut\.ac\.za|mut\.ac\.za)$/;
            if (!emailRegex.test(email.value)) {
                errorEmail.textContent = "Invalid mut email address.";
                valid = false;
            } else {
                errorEmail.textContent = '';
            }

            // Password validation
            if (password.value.length < 8) {
                errorPassword.textContent = "Password must be strong password with 8 characters minimum.";
                valid = false;
            } else {
                errorPassword.textContent = '';
            }

            // Confirm password validation
            if (password.value !== confirmPassword.value) {
                errorConfirmPassword.textContent = "Passwords do not match.";
                valid = false;
            } else {
                errorConfirmPassword.textContent = '';
            }

            return valid;
        }
    </script>

    <!-- Include the footer -->
    <footer>
        <jsp:include page="footer.jsp" />
    </footer>

</body>
</html>
