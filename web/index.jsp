        
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8"/>
    <meta name="viewport" content="width=device-width, initial-scale=1, minimum-scale=1, maximum-scale=1, user-scalable=no">
    <meta name="robots" content="noindex"/>
    
    <!-- Bootstrap CSS for responsiveness -->
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
    
    <style>
        body {
            background-color: #FFFFFF;
            color: black;
            font-family: Arial, sans-serif;
            margin: 0;
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
        }

        .container {
            text-align: center;
        }

        img {
            max-width: 100%;
            height: auto;
            margin-bottom: 20px;
        }

        .callout_row_text {
            color: #808080;
            margin-bottom: 20px;
            font-size: 18px;
        }

        .app_buttons a {
            display: inline-block;
            padding: 10px 20px;
            background-color: #0C314D;
            color: white;
            border-radius: 5px;
            font-weight: bolder;
            text-decoration: none;
        }

        .app_buttons a:hover {
            background-color: #0056b3;
        }

        @media screen and (max-width: 768px) {
            img {
                height: auto;
                width: 70%;
            }

            .callout_row_text {
                font-size: 16px;
            }
        }

        @media screen and (max-width: 480px) {
            img {
                width: 90%;
            }

            .callout_row_text {
                font-size: 14px;
            }

            .app_buttons a {
                padding: 8px 16px;
            }
        }
    </style>
    <title>Online Exam</title>
</head>

<body>

<div class="container">
    <img src="IMG/Result.gif" alt="Assessment System" style="padding-left:3%">
    <div class="callout_row callout_row_text">Welcome to our automatic grading and test submissions. <br>Please click the start button to begin</div>
    <div class="app_buttons">
        <a href="login.jsp">START</a>
    </div>
</div>

<!-- Required scripts for Bootstrap navbar toggle -->
<script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.5.2/dist/umd/popper.min.js"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>

</body>
</html>


