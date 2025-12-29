<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registration Successful</title>

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
            justify-content: center; /* Centers vertically */
            align-items: center; /* Centers horizontally */
            height: 100vh; /* Full viewport height */
        }

        .central-div {
            text-align: center;
            background-color: white;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
            padding: 30px;
            border-radius: 10px;
            width: 50%; /* Adjust width as needed */
        }

        h1 {
            color: #28a745; /* Green color for success */
            margin-bottom: 20px;
        }

        p {
            color: #333;
            margin-bottom: 20px;
        }
    </style>

    <script>
        // Redirect to login.jsp after 3 seconds
        setTimeout(function() {
            window.location.href = 'login.jsp'; // Redirect to login.jsp
        }, 3000); // 3000 milliseconds = 3 seconds
    </script>
</head>
<body>

    <!-- Content Div -->
    <div class="central-div">
        <h1>Registration Successful!</h1>
        <p>Your staff number has been added to the system. Which enables the user to register as lecture on the system</p>
        <p>The system will now be reloaded and you will be redirected shortly to login page</p>
    </div>

</body>
</html>