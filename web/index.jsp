<!DOCTYPE html>
<html lang="en">

<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width, initial-scale=0.8">
  <title>Online Exam</title>

  <!-- Bootstrap CSS -->
  <link href="https://stackpath.bootstrapcdn.com/bootstrap/4.5.2/css/bootstrap.min.css" rel="stylesheet">

  <style>
    body {
      transform-origin: top left;
      width: 100%;
      background: linear-gradient(135deg, #e0f7fa, #ffffff);
      overflow: hidden;
      font-family: 'Poppins', sans-serif;
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
      border-radius: 20px;
      box-shadow: 0 4px 20px rgba(0, 0, 0, 0.2);
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

  <div class="container">
    <img src="IMG/Result.gif" alt="Assessment System">

    <div class="callout_row callout_row_text">
      Welcome to our automatic grading and test submissions.<br>
      Please click the start button to begin.
    </div>

    <div class="app_buttons mt-4">
      <a href="login.jsp" class="btn btn-primary shadow-lg">START</a>
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
    document.addEventListener("DOMContentLoaded", function () {
      function updateScale() {
        const body = document.body;
        const windowWidth = window.innerWidth;
        const windowHeight = window.innerHeight;
        const bodyWidth = body.scrollWidth;
        const bodyHeight = body.scrollHeight;

        const scaleX = windowWidth / bodyWidth;
        const scaleY = windowHeight / bodyHeight;
        const scale = Math.min(scaleX, scaleY, 1);

        body.style.transform = `scale(${scale})`;
        body.style.transformOrigin = "top left";
      }

      updateScale();
      window.addEventListener("resize", updateScale);
    });
  </script>

</body>

</html>
