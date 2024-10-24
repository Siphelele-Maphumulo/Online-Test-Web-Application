<!DOCTYPE html>
<html lang="en">
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=utf-8"/>
    <meta http-equiv="x-dns-prefetch-control" content="off"/>
    <meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=1, user-scalable=no" id="viewport">
    <meta name="robots" content="noindex"/>

    <!-- Include Bootstrap CSS -->
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

        .full-height {
            display: flex;
            justify-content: center;
            align-items: center;
            flex: 1;
        }
        
        .central-div {
            max-width: 400px;
            width: 100%;
            padding: 30px;
            background-color: white;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            border-radius: 8px;
        }

        h2 {
            text-align: center;
            margin-bottom: 25px;
            color: #333;
        }

        input[type="text"], input[type="password"] {
            width: 100%;
            padding: 12px;
            margin-bottom: 15px;
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
            font-size: 17px;
            text-align: center;
            margin: 10px 0;
        }

        .forgot-password {
            display: block;
            text-align: center;
            margin-top: 10px;
            color: #007bff;
            text-decoration: none;
        }

        .forgot-password:hover {
            text-decoration: underline;
        }

        footer {
            background-color: #f8f9fa;
            padding: 10px 0;
            text-align: center;
            width: 100%;
            position: relative;
        }

        @media (max-width: 768px) {
            .central-div {
                margin: 50px 20px;
            }
        }

        @media (max-width: 576px) {
            .central-div {
                margin: 30px 10px;
            }

            input[type="text"], input[type="password"], .button {
                font-size: 14px;
            }
        }
    </style>
    
    <title>Login</title>
</head>

<body>

    <!-- Include the header -->
    <jsp:include page="header.jsp" />

    <div class="full-height">
        <div class="central-div">
            <form method='post' action="controller.jsp">
                <input type="hidden" name="page" value="login"> 
                <h2>Login</h2>

                <input type="text" class="form-control" placeholder="MUT Identity Number" name="username" required>
                <input type="password" class="form-control" placeholder="Password" name="password" required>

                <% if (request.getSession().getAttribute("userStatus") != null && request.getSession().getAttribute("userStatus").equals("-1")) { %>
                    <p class="error-message">MUT Email or password is incorrect</p>
                <% } %>

                <input type="submit" value="Login" class="button">
                <a class="forgot-password" href="#">Forgot Password?</a>
            </form>
        </div>
    </div>

    <!-- Include the footer -->
    <footer>
        <jsp:include page="footer.jsp" />
    </footer>

    <!-- Include Bootstrap JS (Optional) -->
    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@4.5.2/dist/js/bootstrap.bundle.min.js"></script>
    
</body>
</html>