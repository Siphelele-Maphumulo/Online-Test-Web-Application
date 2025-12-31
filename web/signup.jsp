<%@page import="myPackage.classes.User"%>
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
    .back-button{ background:#09294D; color:white; border:none; }
    .back-button:hover{ background:#6c757d; }
    .user-type-badge{ background:#09294D; color:white; padding:5px 15px; border-radius:20px; font-size:0.9rem; }
    @media (max-width:575.98px){ .auth-card{ border-radius:.75rem; } .auth-title{ font-size:1.25rem; } }
  </style>
</head>
<%
    // Get parameters
    String userType = request.getParameter("user_type");
    String fromPage = request.getParameter("from");

    // Check if should show back button
    boolean showBackButton = false;

    // Show back button for admin / lecturer
    if (
        "admin".equals(userType) ||
        "lecture".equals(userType) ||
        "admin".equals(fromPage) ||
        (
            session.getAttribute("userRole") != null &&
            (
                "admin".equals(session.getAttribute("userRole")) ||
                "lecture".equals(session.getAttribute("userRole"))
            )
        )
    ) {
        showBackButton = true;
    }

    // Store in session (unchanged)
    if (userType != null) {
        session.setAttribute("signup_user_type", userType);
    }
    if (fromPage != null) {
        session.setAttribute("signup_from_page", fromPage);
    }

    // Determine display user type
    String displayUserType = "Student";
    if ("admin".equals(userType)) {
        displayUserType = "Administrator";
    } else if ("lecture".equals(userType)) {
        displayUserType = "Lecturer";
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
            
            <!-- Back Button (Conditional) -->
            <% if (showBackButton) { %>
                <a href="index.jsp"
                   class="btn back-button btn-sm" 
                   onclick="history.back(); return false;">
                    <i class="fas fa-arrow-left mr-1"></i>
                </a>
            <% } %>

            
            <h2 class="auth-title h4 mb-3 text-center">Create your account</h2>
            
            <!-- User Type Badge -->
            <% if ("admin".equals(userType) || "lecture".equals(userType)) { %>
            <div class="text-center mb-3">
              <span class="user-type-badge">
                <i class="fas fa-user-shield mr-1"></i> Creating <%= displayUserType %> Account
              </span>
            </div>
            <% } %>
            
            <p class="text-center text-muted mb-4">Please fill in your details to sign up.</p>

            <!-- Hidden field to indicate admin/lecture creation -->
            <form action="controller.jsp" method="POST" onsubmit="return validateForm();">
              <input type="hidden" name="page" value="register"/>
              
              <!-- User type parameter -->
              <% if (userType != null && !userType.isEmpty()) { %>
              <input type="hidden" name="user_type" value="<%= userType %>"/>
              <% } %>
              
              <!-- From page parameter -->
              <% if (fromPage != null && !fromPage.isEmpty()) { %>
              <input type="hidden" name="from_page" value="<%= fromPage %>"/>
              <% } %>
              
              <!-- Pass the referrer ID if creating from admin/lecture account -->
              <% 
                Object userId = session.getAttribute("userId");
                Object userRole = session.getAttribute("userRole");
                if (userId != null && ("admin".equals(userRole) || "lecture".equals(userRole))) {
              %>
              <input type="hidden" name="created_by" value="<%= userId %>"/>
              <input type="hidden" name="creator_role" value="<%= userRole %>"/>
              <% } %>

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

                <div class="col-12">
                  <label class="sr-only" for="email">Email</label>
                  <div class="input-icon">
                    <i class="fas fa-envelope"></i>
                    <input id="email" type="email" name="email" class="form-control" placeholder="Email" required 
                           onblur="checkEmailFormat(this.value)"/>
                  </div>
                  <span id="errorEmail" class="error-message"></span>
                  <small id="emailHint" class="form-text text-muted">
                    <% if ("admin".equals(userType) || "lecture".equals(userType)) { %>
                    <i class="fas fa-info-circle"></i> For <%= displayUserType.toLowerCase() %> accounts, use your institutional email.
                    <% } else { %>
                    <i class="fas fa-info-circle"></i> Use your institutional email. System will detect your role automatically.
                    <% } %>
                  </small>
                </div>
                
                <!-- Additional fields for admin/lecture creation -->
                <% if ("admin".equals(userType) || "lecture".equals(userType)) { %>
                <div class="col-12">
                  <div class="alert alert-warning p-2 mb-3">
                    <i class="fas fa-exclamation-triangle mr-1"></i>
                    <small>You are creating a <strong><%= displayUserType %></strong> account. This account will have elevated privileges.</small>
                  </div>
                </div>
                <% } %>
                
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
                    <i class="fa-solid fa-user-plus mr-1"></i> 
                    <% if ("admin".equals(userType) || "lecture".equals(userType)) { %>
                    Create <%= displayUserType %> Account
                    <% } else { %>
                    Sign Up
                    <% } %>
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
      const setErr = (id,msg)=>{ 
          const elem = document.getElementById(id);
          if(elem) {
              elem.textContent = msg; 
              if(msg) valid=false;
          }
      };

      // Validate ID number (8 digits)
      const idRegex = /^\d{8}$/;
      setErr("errorUsername", idRegex.test(uname.value.trim()) ? "" : "ID must be exactly 8 digits.");
      
      // Validate contact (at least 10 digits)
      const contactRegex = /^\d{10,}$/;
      const cleanContact = contact.value.trim().replace(/[^\d]/g, '');
      setErr("errorContact", contactRegex.test(cleanContact) ? "" : "Contact must be at least 10 digits.");
      
      // Validate email
      const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
      setErr("errorEmail", emailRegex.test(email.value.trim()) ? "" : "Enter a valid email address.");
      
      // Validate names
      setErr("errorFirstName", fname.value.trim() ? "" : "First name is required.");
      setErr("errorLastName",  lname.value.trim() ? "" : "Last name is required.");
      
      // Validate password
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
    
    // Real-time ID validation
    document.getElementById('uname')?.addEventListener('input', function() {
        const value = this.value.replace(/\D/g, '').substring(0, 8);
        this.value = value;
        const errorElem = document.getElementById('errorUsername');
        if (errorElem) {
            errorElem.textContent = value.length === 8 ? '' : 'ID must be exactly 8 digits.';
        }
    });
    
    // Real-time contact validation
    document.getElementById('contactno')?.addEventListener('input', function() {
        const value = this.value.replace(/\D/g, '');
        this.value = value;
    });
    
    function checkEmailFormat(email) {
        const emailHint = document.getElementById('emailHint');
        if (!emailHint) return;
        
        const userType = '<%= userType %>';
        
        // For admin/lecture accounts
        if (userType === 'admin' || userType === 'lecture') {
            // Check if it looks like an institutional email
            const eduDomains = ['edu', 'ac.', 'school', 'college', 'university'];
            const isInstitutional = eduDomains.some(domain => email.includes(domain));
            
            if (!isInstitutional) {
                emailHint.innerHTML = '<i class="fas fa-exclamation-triangle text-warning"></i> For <%= displayUserType.toLowerCase() %> accounts, please use your institutional email address.';
                emailHint.className = 'form-text text-warning';
            } else {
                emailHint.innerHTML = '<i class="fas fa-check-circle text-success"></i> Valid institutional email for <%= displayUserType.toLowerCase() %> account.';
                emailHint.className = 'form-text text-success';
            }
        }
    }
  </script>

  <!-- If header.jsp already includes these, remove to avoid duplicates -->
  <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.5.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>