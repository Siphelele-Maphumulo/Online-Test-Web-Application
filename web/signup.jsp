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
    
    /* Modal Styles */
    .modal-overlay {
        display: none;
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0, 0, 0, 0.5);
        z-index: 9999;
        align-items: center;
        justify-content: center;
    }
    .modal-content {
        background: white;
        border-radius: 8px;
        max-width: 500px;
        width: 90%;
        max-height: 90vh;
        overflow-y: auto;
    }
    .modal-header {
        padding: 20px;
        border-bottom: 1px solid #eee;
        display: flex;
        justify-content: space-between;
        align-items: center;
    }
    .modal-title {
        margin: 0;
        font-size: 1.25rem;
    }
    .close-button {
        background: none;
        border: none;
        font-size: 24px;
        cursor: pointer;
        color: #666;
    }
    .modal-body {
        padding: 20px;
    }
    .modal-footer {
        padding: 20px;
        border-top: 1px solid #eee;
        text-align: right;
    }
    
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
    } else if ("lecture".equalsIgnoreCase(userType) || "lecturer".equalsIgnoreCase(userType)) {
        title = "Creating Lecturer Account";
        subtitle = "You are creating a lecturer account with elevated privileges.";
    } else if ("admin".equalsIgnoreCase(userType)) {
        title = "Creating Administrator Account";
        subtitle = "You are creating an administrator account with elevated privileges.";
    }
    
    String emailLabel = "Email";
    if ("student".equalsIgnoreCase(userType)) {
        emailLabel = "Student account email";
    } else if ("lecture".equalsIgnoreCase(userType) || "lecturer".equalsIgnoreCase(userType)) {
        emailLabel = "Lecturer account email";
    } else if ("admin".equalsIgnoreCase(userType)) {
        emailLabel = "Administrator account email";
    }
    
    // Check for session errors first, then URL parameters
    String sessionError = (String) session.getAttribute("error");
    String sessionMessage = (String) session.getAttribute("message");
    String urlError = request.getParameter("error");
    
    // Map URL error codes to user-friendly messages
    String errorMessage = "";
    if (urlError != null && !urlError.isEmpty()) {
        switch(urlError) {
            case "missing_fields":
                errorMessage = "All required fields must be filled.";
                break;
            case "invalid_id":
                errorMessage = "ID number must be 8 digits.";
                break;
            case "duplicate_username":
                errorMessage = "Username/ID number already exists.";
                break;
            case "duplicate_email":
                errorMessage = "Email already registered.";
                break;
            case "duplicate_contact":
                errorMessage = "Contact number already registered.";
                break;
            default:
                errorMessage = "An error occurred during registration.";
        }
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
            <h2 class="auth-title h4 mb-3 text-center"><%= title %></h2>
            <p class="text-center text-muted mb-4"><%= subtitle %></p>

            <!-- Display messages if any -->
            <% if (sessionMessage != null && !sessionMessage.isEmpty()) { %>
                <div class="alert alert-success alert-dismissible fade show" role="alert">
                    <%= sessionMessage %>
                    <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
            <% } %>
            
            <% if (sessionError != null && !sessionError.isEmpty()) { %>
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <%= sessionError %>
                    <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
            <% } else if (urlError != null && !urlError.isEmpty()) { %>
                <div class="alert alert-danger alert-dismissible fade show" role="alert">
                    <%= errorMessage %>
                    <button type="button" class="close" data-dismiss="alert" aria-label="Close">
                        <span aria-hidden="true">&times;</span>
                    </button>
                </div>
            <% } %>

            <!-- Add hidden fields for user_type and from_page -->
            <form action="controller.jsp" method="POST" onsubmit="return validateForm();">
              <input type="hidden" name="page" value="register"/>
              <input type="hidden" id="hiddenUserType" name="user_type" value="<%= userType != null ? userType : "" %>"/>
              <input type="hidden" name="from_page" value="<%= fromPage != null ? fromPage : "" %>"/>
              
              <!-- You might also want to pass the referrer for admin/lecture users -->
              <input type="hidden" name="referrer_id" value="<%= session.getAttribute("userId") != null ? session.getAttribute("userId") : "" %>"/>

              <div class="form-row">
                <div class="col-12 col-md-6">
                  <label class="sr-only" for="fname">First Name</label>
                  <div class="input-icon">
                    <i class="fas fa-user"></i>
                    <input id="fname" type="text" name="fname" class="form-control" placeholder="First Name" 
                           value="<%= request.getParameter("fname") != null ? request.getParameter("fname") : "" %>" required/>
                  </div>
                  <span id="errorFirstName" class="error-message"></span>
                </div>

                <div class="col-12 col-md-6">
                  <label class="sr-only" for="lname">Last Name</label>
                  <div class="input-icon">
                    <i class="fas fa-user"></i>
                    <input id="lname" type="text" name="lname" class="form-control" placeholder="Last Name" 
                           value="<%= request.getParameter("lname") != null ? request.getParameter("lname") : "" %>" required/>
                  </div>
                  <span id="errorLastName" class="error-message"></span>
                </div>

                <div class="col-12 col-md-6">
                  <label class="sr-only" for="uname">8 digits of ID Number</label>
                  <div class="input-icon">
                    <i class="fas fa-id-badge"></i>
                    <input id="uname" type="text" name="uname" class="form-control" placeholder="8 digits of ID Number" 
                           value="<%= request.getParameter("uname") != null ? request.getParameter("uname") : "" %>" required/>
                  </div>
                  <span id="errorUsername" class="error-message"></span>
                </div>

                <div class="col-12 col-md-6">
                  <label class="sr-only" for="contactno">Contact No</label>
                  <div class="input-icon">
                    <i class="fas fa-phone"></i>
                    <input id="contactno" type="tel" name="contactno" class="form-control" placeholder="Contact No" 
                           value="<%= request.getParameter("contactno") != null ? request.getParameter("contactno") : "" %>" required/>
                  </div>
                  <span id="errorContact" class="error-message"></span>
                </div>

                  <div class="col-12">
                  <label class="sr-only" for="email"><%= emailLabel %></label>
                  <div class="input-icon">
                    <i class="fas fa-envelope"></i>
                    <input id="email" type="email" name="email" class="form-control" placeholder="<%= emailLabel %>" 
                           value="<%= request.getParameter("email") != null ? request.getParameter("email") : "" %>" required/>
                  </div>
                  <span id="errorEmail" class="error-message"></span>
                </div>
                  <br><br>
                <div class="col-12 col-md-6">
                  <label class="sr-only" for="pass">Password</label>
                  <div class="input-icon">
                    <i class="fas fa-lock"></i>
                    <input id="pass" type="password" name="pass" class="form-control" placeholder="Password" required/>
                    <i class="fas fa-eye toggle-password" onclick="togglePassword('pass', this)"></i>
                  </div>
                  <span id="errorPassword" class="error-message"></span>
                </div>

                <div class="col-12 col-md-6">
                  <label class="sr-only" for="cpass">Confirm Password</label>
                  <div class="input-icon">
                    <i class="fas fa-lock"></i>
                    <input id="cpass" type="password" name="cpass" class="form-control" placeholder="Confirm Password" required/>
                    <i class="fas fa-eye toggle-password" onclick="togglePassword('cpass', this)"></i>
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

  <script>
    function validateForm(){
      let valid = true;
      const fname = document.getElementById("fname");
      const lname = document.getElementById("lname");
      const uname = document.getElementById("uname");
      const contact = document.getElementById("contactno");
      const email = document.getElementById("email");
      const pass = document.getElementById("pass");
      const cpass = document.getElementById("cpass");
      const setErr = (id,msg)=>{ document.getElementById(id).textContent = msg; if(msg) valid=false; };

      setErr("errorFirstName", fname.value.trim() ? "" : "First name is required.");
      setErr("errorLastName",  lname.value.trim() ? "" : "Last name is required.");
      setErr("errorUsername",  uname.value.trim() ? "" : "Identity number is required.");
      setErr("errorContact", /^[0-9+()\s-]{7,}$/.test(contact.value.trim()) ? "" : "Enter a valid contact number.");
      setErr("errorEmail", /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email.value.trim()) ? "" : "Enter a valid email address.");
      setErr("errorPassword", pass.value.length >= 6 ? "" : "Password must be at least 6 characters.");
      setErr("errorConfirmPassword", pass.value === cpass.value ? "" : "Passwords do not match.");
      return valid;
    }

    function togglePassword(fieldId, icon){
      const input = document.getElementById(fieldId);
      const revealing = input.type === "password";
      input.type = revealing ? "text" : "password";
      icon.classList.toggle("fa-eye");
      icon.classList.toggle("fa-eye-slash");
    }

    document.getElementById('uname').addEventListener('blur', function() {
        const username = this.value;
        if (username.length > 0) {
            fetch('controller.jsp?page=check_username&username=' + username)
                .then(response => response.json())
                .then(data => {
                    if (data.exists) {
                        document.getElementById('errorUsername').textContent = 'Username already exists.';
                    } else {
                        document.getElementById('errorUsername').textContent = '';
                    }
                });
        }
    });
    
    // Add a function to handle form submission
    document.getElementById('registerForm').addEventListener('submit', function(e) {
        e.preventDefault();
        
        // Clear all previous field-specific errors
        document.querySelectorAll('.error-message').forEach(el => el.textContent = '');
        
        // Run validation
        if (validateForm()) {
            // If validateForm returns true (basic validation passed), 
            // it will handle async checks and submission
            return false;
        }
        return false;
    });
});

function validateField(fieldId) {
    const field = document.getElementById(fieldId);
    const value = field.value.trim();
    
    switch(fieldId) {
        case 'fname':
            if (!value) {
                document.getElementById('errorFirstName').textContent = 'First name is required.';
            } else {
                document.getElementById('errorFirstName').textContent = '';
            }
            break;
        case 'lname':
            if (!value) {
                document.getElementById('errorLastName').textContent = 'Last name is required.';
            } else {
                document.getElementById('errorLastName').textContent = '';
            }
            break;
        case 'uname':
            if (!value) {
                document.getElementById('errorUsername').textContent = 'Identity number is required.';
            } else if (!/^\d{8}$/.test(value)) {
                document.getElementById('errorUsername').textContent = 'ID number must be 8 digits.';
            } else {
                document.getElementById('errorUsername').textContent = '';
            }
            break;
        case 'contactno':
            if (!value) {
                document.getElementById('errorContact').textContent = 'Contact number is required.';
            } else if (!/^[0-9+()\s-]{7,}$/.test(value)) {
                document.getElementById('errorContact').textContent = 'Enter a valid contact number.';
            } else {
                document.getElementById('errorContact').textContent = '';
            }
            break;
        case 'email':
            if (!value) {
                document.getElementById('errorEmail').textContent = 'Email is required.';
            } else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)) {
                document.getElementById('errorEmail').textContent = 'Enter a valid email address.';
            } else {
                document.getElementById('errorEmail').textContent = '';
            }
            break;
        case 'pass':
            if (!value) {
                document.getElementById('errorPassword').textContent = 'Password is required.';
            } else if (value.length < 6) {
                document.getElementById('errorPassword').textContent = 'Password must be at least 6 characters.';
            } else {
                document.getElementById('errorPassword').textContent = '';
            }
            break;
        case 'cpass':
            const passValue = document.getElementById('pass').value;
            if (!value) {
                document.getElementById('errorConfirmPassword').textContent = 'Please confirm your password.';
            } else if (value !== passValue) {
                document.getElementById('errorConfirmPassword').textContent = 'Passwords do not match.';
            } else {
                document.getElementById('errorConfirmPassword').textContent = '';
            }
            break;
    }
    
    // Update submit button state
    checkAllValidations();
}
</script>


  <script src="https://code.jquery.com/jquery-3.5.1.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.5.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>

<!--I want the signup to know how to register users as staff or students by first checking if the email of the user signing up exists on the staff table-->