<!-- Header Section (header.jsp) -->
<header class="header" style="background-color: #4A171E; padding: 10px 0;">
    <div style="display: flex; align-items: center; justify-content: space-between; width: 100%; padding: 0 20px;">
        <!-- Logo on the left -->
        <div style="flex: 1;">
            <img src="IMG/enviromentt.png" alt="MUT Logo" style="max-height: 40px;">
        </div>

        <!-- Centered Title -->
        <div style="flex: 2; text-align: center; padding-left: 4%;">
            <h1 style="color: white; font-size: 22px; font-weight: bold; margin: 0;">
                Web-Based Online Assessment System
            </h1>
        </div>

        <!-- Navigation Links on the right -->
        <nav style="flex: 1; display: flex; justify-content: flex-end; padding-right: 3%">
            <ul style="list-style-type: none; margin: 0; padding: 0; display: flex; gap: 10px; font-weight: bold;">
                <!-- Sign Up and Login Links (Hidden if logged in) -->
                <li id="signup-link">
                    <a href="signup.jsp" style="color: #D8A02E; text-decoration: none;">Sign Up</a>
                </li>
                <li id="login-link">
                    <a href="login.jsp" style="color: #D8A02E; text-decoration: none;">Login</a>
                </li>
                <!-- Logout Link (Visible only when logged in) -->
                <li id="logout-link" style="display: none;">
                    <a href="controller.jsp?page=logout" style="color: #D8A02E; text-decoration: none;">Logout</a>
                </li>
            </ul>
        </nav>
    </div>
</header>

<!-- JavaScript to manage visibility of links based on login status and current page -->
<script>
    // Simulating session login status with a variable (replace this with actual session check in backend)
    const isLoggedIn = <%= session.getAttribute("userStatus") != null && session.getAttribute("userStatus").equals("1") %>;

    // Get the current page URL
    const currentPage = window.location.pathname;

    // Hide links based on the login status and current page
    if (isLoggedIn) {
        // If the user is logged in, show Logout and hide Sign Up and Login links
        document.getElementById('signup-link').style.display = 'none';
        document.getElementById('login-link').style.display = 'none';
        document.getElementById('logout-link').style.display = 'block';
    } else {
        // Hide appropriate links based on the current page if not logged in
        if (currentPage.includes("login.jsp")) {
            document.getElementById('login-link').style.display = 'none'; // Hide Login link on login page
            document.getElementById('logout-link').style.display = 'none'; // Ensure Logout is hidden
        } else if (currentPage.includes("signup.jsp")) {
            document.getElementById('signup-link').style.display = 'none'; // Hide Sign Up link on sign up page
            document.getElementById('logout-link').style.display = 'none'; // Ensure Logout is hidden
        }
    }
</script>
