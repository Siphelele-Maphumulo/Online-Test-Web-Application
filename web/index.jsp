<!DOCTYPE html>
<html lang="en">

<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=0.8">

    <!-- Bootstrap CSS for responsiveness -->
    <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">
    
    <!-- Link to your custom CSS file -->


    <title>Online Exam</title>

    <style>
        body {
            transform-origin: top left;
            width: 100%;
        }

        .container {
            min-height: 100vh;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            text-align: center;
        }

        img {
            max-width: 100%;
            height: auto;
        }
    </style>
</head>

<body>

    <div class="container">
        <img src="IMG/Result.gif" alt="Assessment System">
        
        <div class="callout_row callout_row_text">
            Welcome to our automatic grading and test submissions.<br>
            Please click the start button to begin.
        </div>

        <div class="app_buttons">
            <a href="login.jsp" class="btn btn-primary">START</a>
        </div>
    </div>

        <div class="callout_row callout_row_text">
            <br>
            Create by Siphelele Maphumulo.
        </div>

    <!-- Required scripts for Bootstrap -->
    <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
    <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.5.2/dist/umd/popper.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>

    <script>
        document.addEventListener("DOMContentLoaded", function () {
            function updateScale() {
                const body = document.body;
                const windowWidth = window.innerWidth;
                const windowHeight = window.innerHeight;
                const bodyWidth = body.scrollWidth;
                const bodyHeight = body.scrollHeight;

                const scaleX = windowWidth / bodyWidth;
                const scaleY = windowHeight / bodyHeight;
                const scale = Math.min(scaleX, scaleY, 1); // Prevent excessive shrinking

                body.style.transform = `scale(${scale})`;
                body.style.transformOrigin = "top left";
            }

            updateScale(); // Apply scale on load
            window.addEventListener("resize", updateScale); // Update on resize
        });
    </script>

</body>

</html>
