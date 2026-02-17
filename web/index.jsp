<% request.setAttribute("disableLoader", "true"); %>
<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Online Exam</title>

  <!-- Bootstrap CSS -->
  <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">

  <style>
    body {
      width: 100%;
      background: linear-gradient(135deg, #e0f7fa, #ffffff);
      min-height: 100vh;
      font-family: 'Poppins', sans-serif;
      margin: 0;
      padding: 0;
    }

    .landing-container {
      min-height: 100vh;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      text-align: center;
      padding: 20px;
    }

    .landing-img {
      max-width: 100%;
      height: auto;
      border-radius: 20px;
      box-shadow: 0 4px 20px rgba(0, 0, 0, 0.2);
      margin-bottom: 20px;
    }

    .callout_row_text {
      margin-top: 20px;
      font-size: 1.1rem;
      color: #333;
    }

    .app_buttons a {
      padding: 12px 25px;
      font-size: 1.2rem;
      border-radius: 25px;
      transition: transform 0.3s ease, box-shadow 0.3s ease;
    }

    .app_buttons a:hover {
      transform: scale(1.05);
      box-shadow: 0 4px 15px rgba(0, 123, 255, 0.4);
    }

    /* ? Floating ?by Siphelele Maphumulo? animation */
    .floating-signature {
      position: absolute;
      bottom: 20px;
      right: 30px;
      font-weight: 600;
      color: #007bff;
      font-size: 1.2rem;
      opacity: 0.9;
      animation: floatAround 12s ease-in-out infinite alternate;
      text-shadow: 0 2px 5px rgba(0, 0, 0, 0.2);
    }

    @keyframes floatAround {
      0% {
        transform: translate(0, 0) rotate(0deg);
      }

      25% {
        transform: translate(-40px, -30px) rotate(3deg);
      }

      50% {
        transform: translate(20px, -50px) rotate(-2deg);
      }

      75% {
        transform: translate(40px, 20px) rotate(2deg);
      }

      100% {
        transform: translate(-30px, 30px) rotate(-3deg);
      }
    }
  </style>
  

</head>

<body>

  <div class="landing-container">
    <img src="IMG/main_large.gif" alt="Assessment System" class="landing-img">

    <div class="callout_row callout_row_text">
      Welcome to our automatic grading and test submissions.<br>
      Please click the start button to begin.
    </div>

    <div class="app_buttons mt-4">
      <a href="login.jsp" class="btn btn-primary shadow-lg px-5 py-3">START</a>
    </div>
  </div>

  <!-- Floating Signature -->
  <div class="floating-signature">
    by Siphelele Maphumulo
  </div>

  <!-- Bootstrap Scripts -->
  <script src="https://code.jquery.com/jquery-3.5.1.slim.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.5.2/dist/umd/popper.min.js"></script>
  <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/js/bootstrap.min.js"></script>

  <script>
    // Page Loader - Show for exactly 2 seconds
    (function() {
      var loader = document.getElementById('pageLoader');
      if (loader) {
        // Ensure loader is visible immediately
        loader.style.display = 'flex';
        
        // Hide loader after 0.5 seconds
        setTimeout(function() {
          loader.classList.add('hidden');
          setTimeout(function() {
            loader.style.display = 'none';
          }, 300); // Wait for fade-out transition
        }, 500); // 0.5 seconds
      }
    })();
  </script>

</body>

</html>
