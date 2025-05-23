<%@page import="myPackage.classes.User"%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register New Lecture</title>

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

        input[type="text"], input[type="email"] {
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
    String fromPage = request.getParameter("from");
    if (fromPage == null) {
        fromPage = "default"; 
    }
%>

    <!-- Include the header -->
    <jsp:include page="header.jsp" />

<div class="central-div">
    <h2>Register New Staff Numbers</h2>

    <!-- Registration Form -->
    <form action="staff_Numbers.jsp" method="POST">
        <input type="hidden" name="page" value="register">
        <input type="hidden" name="from" value="<%= fromPage %>"> <!-- Pass the "from" parameter -->

        <div class="grid-container">
            <div class="grid-item">
                <input type="text" name="fullNames" class="text" placeholder="Full Names" required>
            </div>
            <div class="grid-item">
                <input type="text" name="staffNum" class="text" placeholder="Staff Number" required>
            </div>
<div class="grid-item grid-submit">  
    <input type="email" name="email" class="text" style="text-align: center" placeholder="Email" required >  
    <span id="errorEmail" class="error-message"></span>  
</div>
            <div class="grid-item grid-submit">
                <input type="submit" value="Register Now" class="button">
            </div>
        </div>
        <div style="padding-top:50px;">
                <span class="back-button" onclick="window.history.back()" style="background-color: #d3d3d3; border: none; border-radius: 12px; padding: 10px 20px; font-size: 16px; color: #000; cursor: pointer;">
                    Back
                </span>
        </div>
    </form>
</div>

    <footer>
        <jsp:include page="footer.jsp" />
    </footer>

</body>
</html>