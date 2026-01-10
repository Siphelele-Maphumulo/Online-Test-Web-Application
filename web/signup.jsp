<%@page import="myPackage.classes.User"%>
<%@page import="java.net.URL"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1"/>
  <title>Register New User</title>

  <!-- If header.jsp already loads Bootstrap/Icons, you can remove these two lines -->
  <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet"/>
  <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.0/css/all.min.css" rel="stylesheet"/>

  <style>
    :root{ --primary:#09294D; --error:#dc3545; }
    body{ background:#E5E5E5; min-height:100vh; display:flex; flex-direction:column; }
    .auth-card{ background:#fff; border:1px solid rgba(9,41,77,.12); border-radius:1rem; box-shadow:0 12px 24px rgba(0,0,0,.08); }
    .auth-title{ color:var(--primary); font-weight:700; letter-spacing:.2px; }
    .input-icon{ position:relative; }
    .input-icon > i{ position:absolute; left:12px; top:50%; transform:translateY(-50%); color:var(--primary); opacity:.6; pointer-events:none; }
    .input-icon input{ padding-left:40px; }
    .toggle-password{ position:absolute; right:12px; top:50%; transform:translateY(-50%); color:#777; cursor:pointer; }
    .error-message{ color:var(--error); font-size:.875rem; margin-top:4px; }
    .form-row > .col-md-6{ margin-bottom:1rem; }
    .btn-auth{ background:linear-gradient(135deg, var(--primary), #1e4580); border:none; }
    .btn-auth:hover{ background:#1e4580; }
    @media (max-width:575.98px){ .auth-card{ border-radius:.75rem; } .auth-title{ font-size:1.25rem; } }
  </style>
</head>
<%
    // Get the user_type from request parameter
    String userType = request.getParameter("user_type");
    if (userType == null) {
        userType = "student"; // Default to student
    }
    String fromPage = request.getParameter("from");
    
    // Store these in session or hidden fields for use after registration
    if (userType != null) {
        session.setAttribute("signup_user_type", userType);
    }
    if (fromPage != null) {
        session.setAttribute("signup_from_page", fromPage);
    }
    
    String title = "Create your account";
    String subtitle = "Please fill in your details to sign up.";
    if ("student".equalsIgnoreCase(userType)) {
        title = "Creating Student Account";
        subtitle = "You are creating a student account.";
    } else if ("lecture".equalsIgnoreCase(userType)) {
        title = "Creating Lecturer Account";
        subtitle = "You are creating a lecturer account with elevated privileges.";
    } else if ("admin".equalsIgnoreCase(userType)) {
        title = "Creating Administrator Account";
        subtitle = "You are creating an administrator account with elevated privileges.";
    }
    
    String emailLabel = "Email";
    if ("student".equalsIgnoreCase(userType)) {
        emailLabel = "Student account email";
    } else if ("lecture".equalsIgnoreCase(userType)) {
        emailLabel = "Lecturer account email";
    } else if ("admin".equalsIgnoreCase(userType)) {
        emailLabel = "Administrator account email";
    }
%>

<body>

  <!-- Header -->
  <jsp:include page="header.jsp" />

<!-- Main -->
  <main class="flex-fill d-flex align-items-center">
    <div class="container py-4">
      <div class="row justify-content-center">
        <div class="col-12 col-md-10 col-lg-8 col-xl-6">
          <div class="auth-card p-4 p-md-5">
            <%@ include file="header-messages.jsp" %>
            <h2 class="auth-title h4 mb-3 text-center"><%= title %></h2>
            <p class="text-center text-muted mb-4"><%= subtitle %></p>

            <!-- Add hidden fields for user_type and from_page -->
           <!-- <form action="controller.jsp" method="POST" onsubmit="return validateForm();">-->
              <form method="POST" onsubmit="return validateForm(event);">
              <input type="hidden" name="page" value="register"/>
              <input type="hidden" name="user_type" value="<%= userType != null ? userType : "" %>"/>
              <input type="hidden" name="from_page" value="<%= fromPage != null ? fromPage : "" %>"/>
              
              <!-- You might also want to pass the referrer for admin/lecture users -->
              <input type="hidden" name="referrer_id" value="<%= session.getAttribute("userId") != null ? session.getAttribute("userId") : "" %>"/>

              <div class="form-row">
                <div class="col-12 col-md-6">
                  <label class="sr-only" for="fname">First Name</label>
                  <div class="input-icon">
                    <i class="fas fa-user"></i>
                    <input id="fname" type="text" name="fname" class="form-control" placeholder="First Name" required/>
                  </div>
                  <span id="errorFirstName" class="error-message"></span>
                </div>

                <div class="col-12 col-md-6">
                  <label class="sr-only" for="lname">Last Name</label>
                  <div class="input-icon">
                    <i class="fas fa-user"></i>
                    <input id="lname" type="text" name="lname" class="form-control" placeholder="Last Name" required/>
                  </div>
                  <span id="errorLastName" class="error-message"></span>
                </div>

                <div class="col-12 col-md-6">
                  <label class="sr-only" for="uname">8 digits of ID Number</label>
                  <div class="input-icon">
                    <i class="fas fa-id-badge"></i>
                    <input id="uname" type="text" name="uname" class="form-control" placeholder="8 digits of ID Number" required/>
                  </div>
                  <span id="errorUsername" class="error-message"></span>
                </div>

                <div class="col-12 col-md-6">
                  <label class="sr-only" for="contactno">Contact No</label>
                  <div class="input-icon">
                    <i class="fas fa-phone"></i>
                    <input id="contactno" type="tel" name="contactno" class="form-control" placeholder="Contact No" required/>
                  </div>
                  <span id="errorContact" class="error-message"></span>
                </div>

                  <div class="col-12 ">
                  <label class="sr-only" for="email"><%= emailLabel %></label>
                  <div class="input-icon">
                    <i class="fas fa-envelope"></i>
                    <input id="email" type="email" name="email" class="form-control" placeholder="<%= emailLabel %>" required/>
                  </div>
                  <span id="errorEmail" class="error-message"></span>
                </div>
                  <br><br>
                <div class="col-12 col-md-6">
                  <label class="sr-only" for="pass">Password</label>
                  <div class="input-icon">
                    <i class="fas fa-lock"></i>
                    <input id="pass" type="password" name="pass" class="form-control" placeholder="Password" required/>
                    <i class=" toggle-password" onclick="togglePassword('pass', this)"></i>
                  </div>
                  <span id="errorPassword" class="error-message"></span>
                </div>

                <div class="col-12 col-md-6">
                  <label class="sr-only" for="cpass">Confirm Password</label>
                  <div class="input-icon">
                    <i class="fas fa-lock"></i>
                    <input id="cpass" type="password" name="cpass" class="form-control" placeholder="Confirm Password" required/>
                    <i class="toggle-password" onclick="togglePassword('cpass', this)"></i>
                  </div>
                  <span id="errorConfirmPassword" class="error-message"></span>
                </div>

                <div class="col-12 mt-2">
                  <button type="submit" class="btn btn-primary btn-auth btn-block">
                    <i class="fa-solid fa-user-plus mr-1"></i> Sign Up
                  </button>
                </div>

                <div class="col-12 text-center mt-3">
                  <small class="text-muted">
                    Already have an account?
                    <a href="login.jsp">Log in</a>
                  </small>
                </div>
              </div>
            </form>

          </div>
        </div>
      </div>
    </div>
  </main>

  <!-- Footer -->
  <footer class="mt-auto">
    <jsp:include page="footer.jsp"/>
  </footer>

  <!-- Verification Modal -->
  <div class="modal fade" id="verificationModal" tabindex="-1" role="dialog" aria-labelledby="verificationModalLabel" aria-hidden="true">
    <div class="modal-dialog" role="document">
      <div class="modal-content">
        <div class="modal-header">
          <h5 class="modal-title" id="verificationModalLabel">Enter Verification Code</h5>
          <button type="button" class="close" data-dismiss="modal" aria-label="Close">
            <span aria-hidden="true">&times;</span>
          </button>
        </div>
        <div class="modal-body">
          <p>A verification code has been sent to your email address. Please enter the code below to complete your registration.</p>
          <form id="verificationForm" action="controller.jsp" method="POST">
            <input type="hidden" name="page" value="verify_code"/>
            <input type="hidden" name="email" id="verificationEmail"/>
            <div class="form-group">
              <label for="verificationCode">Verification Code</label>
              <input type="text" class="form-control" id="verificationCode" name="code" required>
            </div>
            <button type="submit" class="btn btn-primary">Verify and Sign Up</button>
          </form>
        </div>
      </div>
    </div>
  </div>
  <script>
    function validateForm(event){
        event.preventDefault();
        console.log("Form submitted - Starting validation");

        // Clear errors
        document.querySelectorAll('.error-message').forEach(el => el.textContent = '');

        // Get form values
        const fname = document.getElementById("fname").value.trim();
        const lname = document.getElementById("lname").value.trim();
        const uname = document.getElementById("uname").value.trim();
        const email = document.getElementById("email").value.trim();
        const pass = document.getElementById("pass").value;
        const cpass = document.getElementById("cpass").value;
        const userType = document.querySelector('input[name="user_type"]').value;

        console.log("User type:", userType);
        console.log("Username:", uname);
        console.log("Email:", email);

        // Basic validation
        let valid = true;

        if (!fname) {
            document.getElementById("errorFirstName").textContent = "First name is required.";
            valid = false;
        }
        if (!lname) {
            document.getElementById("errorLastName").textContent = "Last name is required.";
            valid = false;
        }
        if (!uname) {
            document.getElementById("errorUsername").textContent = "Identity number is required.";
            valid = false;
        }
        if (!email) {
            document.getElementById("errorEmail").textContent = "Email is required.";
            valid = false;
        }
        if (pass.length < 6) {
            document.getElementById("errorPassword").textContent = "Password must be at least 6 characters.";
            valid = false;
        }
        if (pass !== cpass) {
            document.getElementById("errorConfirmPassword").textContent = "Passwords do not match.";
            valid = false;
        }

        if (!valid) {
            console.log("Basic validation failed");
            return false;
        }

        // Change button to loading state
        const submitBtn = event.target.querySelector('button[type="submit"]');
        const originalText = submitBtn.innerHTML;
        submitBtn.innerHTML = '<i class="fa-solid fa-spinner fa-spin mr-1"></i> Validating...';
        submitBtn.disabled = true;

        // Start validation chain
        validateStepByStep();

        function validateStepByStep() {
            console.log("Step 1: Checking username availability...");

            // Step 1: Check username
            fetch('controller.jsp?page=check_username&username=' + encodeURIComponent(uname) + '&t=' + new Date().getTime())
                .then(response => {
                    if (!response.ok) throw new Error('Network response was not ok');
                    return response.text();
                })
                .then(text => {
                    console.log("Username check response:", text);
                    try {
                        const data = JSON.parse(text);

                        if (data.exists) {
                            document.getElementById("errorUsername").textContent = "Username already exists.";
                            resetButton();
                            return;
                        }

                        // Step 2: Check email in users table
                        console.log("Step 2: Checking if email is already registered...");
                        return fetch('controller.jsp?page=check_staff_email&checkRegistered=1&email=' + encodeURIComponent(email) + '&t=' + new Date().getTime());
                    } catch (e) {
                        console.error("Failed to parse JSON:", e);
                        document.getElementById("errorUsername").textContent = "Server error. Please try again.";
                        resetButton();
                        throw e;
                    }
                })
                .then(response => {
                    if (response) {
                        if (!response.ok) throw new Error('Network response was not ok');
                        return response.text();
                    }
                    return null;
                })
                .then(text => {
                    if (text) {
                        console.log("Email registration check response:", text);
                        try {
                            const data = JSON.parse(text);

                            // Check if email is already registered as a user
                            if (data.registered) {
                                document.getElementById("errorEmail").textContent = "Email is already registered.";
                                resetButton();
                                return;
                            }

                            // Step 3: If lecturer/admin, check staff authorization
                            if (userType === "lecture" || userType === "admin") {
                                console.log("Step 3: Checking staff authorization for:", userType);
                                return fetch('controller.jsp?page=check_staff_email&email=' + encodeURIComponent(email) + '&t=' + new Date().getTime());
                            } else {
                                // For students, proceed directly to verification
                                console.log("Student registration - proceeding to verification");
                                return Promise.resolve({text: () => Promise.resolve('{"exists": true}')});
                            }
                        } catch (e) {
                            console.error("Failed to parse email check JSON:", e);
                            document.getElementById("errorEmail").textContent = "Server error. Please try again.";
                            resetButton();
                            throw e;
                        }
                    }
                    return null;
                })
                .then(response => {
                    if (response && response.text) {
                        return response.text();
                    }
                    return '{"exists": true}';
                })
                .then(text => {
                    console.log("Staff authorization check response:", text);
                    try {
                        const data = JSON.parse(text);

                        if ((userType === "lecture" || userType === "admin") && !data.exists) {
                            document.getElementById("errorEmail").textContent = 
                                "Email not authorized for " + userType + " registration. Please contact administrator.";
                            resetButton();
                            return;
                        }

                        // All checks passed, send verification code
                        console.log("All validations passed, sending verification code...");
                        sendVerificationCode(event);

                    } catch (e) {
                        console.error("Failed to parse staff authorization JSON:", e);
                        document.getElementById("errorEmail").textContent = "Server error. Please try again.";
                        resetButton();
                    }
                })
                .catch(error => {
                    console.error("Validation error:", error);
                    document.getElementById("errorUsername").textContent = "Network error. Please check your connection.";
                    resetButton();
                });
        }

        function resetButton() {
            submitBtn.innerHTML = originalText;
            submitBtn.disabled = false;
        }

        return false;
    }

    function sendVerificationCode(event) {
        const form = event.target.closest('form');
        const formData = new FormData(form);
        formData.set("page", "send_code");

        console.log("Sending verification code...");

        fetch("controller.jsp", {
            method: "POST",
            body: formData
        })
        .then(response => response.text())
        .then(text => {
            console.log("Send code response:", text);
            try {
                const data = JSON.parse(text);
                if (data.success) {
                    document.getElementById("verificationEmail").value = document.getElementById("email").value.trim();
                    $('#verificationModal').modal('show');
                } else {
                    document.getElementById("errorEmail").textContent = data.message || "Failed to send verification code.";
                }
            } catch (e) {
                console.error("Failed to parse send code JSON:", e);
                document.getElementById("errorEmail").textContent = "Server error. Please try again.";
            }
            resetButton();
        })
        .catch(error => {
            console.error("Send code error:", error);
            document.getElementById("errorEmail").textContent = "Network error. Please try again.";
            resetButton();
        });
    }
    function togglePassword(fieldId, icon){
        const input = document.getElementById(fieldId);
        const revealing = input.type === "password";
        input.type = revealing ? "text" : "password";
        icon.classList.toggle("fa-eye");
        icon.classList.toggle("fa-eye-slash");
    }

    // Initialize password toggle icons
    document.addEventListener('DOMContentLoaded', function() {
        const passIcon = document.querySelector('#pass + .toggle-password');
        const cpassIcon = document.querySelector('#cpass + .toggle-password');
        if (passIcon) passIcon.classList.add('fa-eye');
        if (cpassIcon) cpassIcon.classList.add('fa-eye');
    });
  </script>

  <!-- If header.jsp already includes these, remove to avoid duplicates -->
  <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.5.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

<!--I want the signup to know how to register users as staff or students by first checking if the email of the user signing up exists on the staff table-->