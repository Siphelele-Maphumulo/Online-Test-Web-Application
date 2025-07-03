<%@page import="myPackage.classes.User"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Register New User</title>

  <!-- Bootstrap CSS -->
  <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet" />
  <!-- Font Awesome -->
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet" />

  <style>
              :root {
            --header-login: #555555;
            --primary-color: #09294D;
            --secondary-color: #0056b3;
            --error-color: #dc3545;
            --light-gray: #f8f9fa;
            --input-height: 3.125rem; /* Consistent height for all inputs */
        }
    body {
      margin: 0;
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        background-color: #E5E5E5;
        display: flex;
        flex-direction: column;
        min-height: 100vh;
        color: #333;
      min-height: 100vh;
    }

    .central-div {
      text-align: center;
      margin: auto;
      margin-top: 3%;
      width: 50%;
      padding: 30px;
      border-radius: 16px;
      box-shadow: 0 8px 32px rgba(9, 41, 77, 0.3);
      backdrop-filter: blur(12px);
      -webkit-backdrop-filter: blur(12px);
      border: 1px solid rgba(9, 41, 77, 0.2);
    }

    h2 {
      margin-bottom: 25px;
      color: #09294D;
      font-weight: bold;
    }

    .grid-container {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 15px;
      width: 100%;
    }

    .grid-item {
      display: flex;
      flex-direction: column;
    }

    .grid-submit {
      grid-column: span 2;
      text-align: center;
    }

    .input-icon {
      position: relative;
      display: flex;
      align-items: center;
    }

    .input-icon i {
      position: absolute;
      left: 12px;
      color: #09294D;
      font-size: 16px;
    }

    .input-icon input {
      width: 100%;
      padding: 12px 12px 12px 38px;
      border: 1px solid #ccc;
      border-radius: 4px;
      transition: border-color 0.3s ease;
    }

    .input-icon input:focus {
      border-color: #09294D;
      outline: none;
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
      margin-top: 5px;
    }
    
    .input-icon {
    position: relative;
    display: flex;
    align-items: center;
}

.input-icon i.fas.fa-lock {
    position: absolute;
    left: 12px;
    color: #777;
    font-size: 16px;
}

.input-icon input {
    width: 100%;
    padding: 12px 38px 12px 38px; /* Adjust padding for both icons */
    border: 1px solid #ccc;
    border-radius: 4px;
    box-sizing: border-box;
}

.input-icon .toggle-password {
    position: absolute;
    left: 90%;
    color: #777;
    cursor: pointer;
}
  </style>
</head>
<body>

<%
  String fromPage = request.getParameter("from");
  if (fromPage == null) {
      fromPage = "default";
  }
%>

<!-- Header -->
<jsp:include page="header.jsp" />

<div class="central-div">
  <h2><i class="fas fa-user-plus"></i> Register New User</h2>

  <form action="controller.jsp" method="POST" onsubmit="return validateForm();">
      <input type="hidden" name="page" value="register">
    <div class="grid-container">
      <div class="grid-item">
        <div class="input-icon">
          <i class="fas fa-user"></i>
          <input type="text" name="fname" placeholder="First Name" required />
        </div>
      </div>

      <div class="grid-item">
        <div class="input-icon">
          <i class="fas fa-user"></i>
          <input type="text" name="lname" placeholder="Last Name" required />
        </div>
      </div>

      <div class="grid-item">
        <div class="input-icon">
          <i class="fas fa-id-badge"></i>
          <input type="text" name="uname" placeholder="MUT Identity Number" required />
        </div>
      </div>

      <div class="grid-item">
        <div class="input-icon">
          <i class="fas fa-phone"></i>
          <input type="tel" name="contactno" placeholder="Contact No" required />
        </div>
        <span id="errorContact" class="error-message"></span>
      </div>

      <div class="grid-item" style="grid-column: span 2;">
        <div class="input-icon">
          <i class="fas fa-envelope"></i>
          <input type="email" name="email" placeholder="MUT Email" required />
        </div>
        <span id="errorEmail" class="error-message"></span>
      </div>

      <div class="grid-item">
        <div class="input-icon">
          <i class="fas fa-city"></i>
          <input type="text" name="city" placeholder="City" required />
        </div>
      </div>

      <div class="grid-item">
        <div class="input-icon">
          <i class="fas fa-home"></i>
          <input type="text" name="address" placeholder="Address" required />
        </div>
      </div>

    <div class="grid-item">
      <div class="input-icon">
        <i class="fas fa-lock"></i>
        <input type="password" id="password" name="pass" placeholder="Password" required />
        <i class="fas fa-eye toggle-password" onclick="togglePassword('password', this)"></i>
      </div>
      <span id="errorPassword" class="error-message"></span>
    </div>

    <div class="grid-item">
      <div class="input-icon">
        <i class="fas fa-lock"></i>
        <input type="password" id="confirmPassword" name="confrimpass" placeholder="Confirm Password" required />
        <i class="fas fa-eye toggle-password" onclick="togglePassword('confirmPassword', this)"></i>
      </div>
      <span id="errorConfirmPassword" class="error-message"></span>
    </div>


      <div class="grid-item grid-submit">
        <input type="submit" value="Register Now" class="button" />
      </div>
    </div>
  </form>
</div>

<!-- JS Validation -->
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

    const contactRegex = /^\d{10,13}$/;
    if (!contactRegex.test(contactNo.value)) {
      errorContact.textContent = "Invalid contact number.";
      valid = false;
    } else {
      errorContact.textContent = '';
    }

    const emailRegex = /^[a-zA-Z0-9._%+-]+@(live\.mut\.ac\.za|mut\.ac\.za)$/;
    if (!emailRegex.test(email.value)) {
      errorEmail.textContent = "Invalid MUT email address.";
      valid = false;
    } else {
      errorEmail.textContent = '';
    }

    if (password.value.length < 8) {
      errorPassword.textContent = "Password must be at least 8 characters.";
      valid = false;
    } else {
      errorPassword.textContent = '';
    }

    if (password.value !== confirmPassword.value) {
      errorConfirmPassword.textContent = "Passwords do not match.";
      valid = false;
    } else {
      errorConfirmPassword.textContent = '';
    }

    return valid;
  }
  
  
  <!----Eye see----->
  function togglePassword(fieldId, icon) {
    const input = document.getElementById(fieldId);
    const isPassword = input.type === "password";
    input.type = isPassword ? "text" : "password";
    icon.classList.toggle("fa-eye");
    icon.classList.toggle("fa-eye-slash");
}
</script>

<!-- Footer -->
<footer>
  <jsp:include page="footer.jsp" />
</footer>

</body>
</html>
