<%@ page contentType="text/html;charset=UTF-8" %>
<%
    String target = (String) request.getAttribute("targetUrl");
    if (target == null) target = request.getParameter("target") != null ? request.getParameter("target") : "index.jsp";
    String message = (String) request.getAttribute("message");
    if (message == null) message = request.getParameter("message") != null ? request.getParameter("message") : "Please wait...";
    Integer delayMsObj = (Integer) request.getAttribute("delayMs");
    int delayMs = (delayMsObj != null) ? delayMsObj.intValue() : 1500;
%>
<!doctype html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Redirecting...</title>
    <meta http-equiv="refresh" content="<%= (delayMs/1000.0) %>;url=<%= target %>">
    <style>
        body { margin:0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: #09294d; color: #fff; display:flex; align-items:center; justify-content:center; height:100vh; }
        .loader-wrap { text-align:center; }
        .loader-wave { width: 10vmin; height: 10vmin; border-radius: 50%; background: rgba(255,255,255,0.12); position: relative; animation: breath 2.2s infinite ease-in-out; margin: 0 auto; }
        .loader-wave::before, .loader-wave::after { content: ''; position:absolute; inset:0; border-radius:inherit; background:inherit; animation: breath 2.2s infinite ease-in-out; }
        .loader-wave::before { animation-delay: 0.7s; }
        .loader-wave::after  { animation-delay: 1.4s; }
        @keyframes breath { 0%,100% { transform: scale(1); opacity:0.4 } 50% { transform: scale(1.4); opacity:0.8 } }

/* Horizontal flip image loader */
.loader-img {
    width: 25vmin;
    max-width: 280px;
    height: auto;
    display: block;
    margin: 0 auto;

    animation: flipHorizontal 1.6s infinite ease-in-out;
    transform-style: preserve-3d;
    will-change: transform;
}

/* Horizontal flip animation */
@keyframes flipHorizontal {
    0% {
        transform: rotateY(0deg);
    }
    50% {
        transform: rotateY(180deg);
    }
    100% {
        transform: rotateY(360deg);
    }
}


        .loader-text { margin-top: 24px; font-size:1.05rem; color:#fff; }
    </style>
    <script>
        (function(){
            var delay = <%= delayMs %>;
            setTimeout(function () {
                window.location.replace('<%= target %>');
            }, delay);
            // prevent back-button flashing
            window.addEventListener('pageshow', function (ev) {
                if (ev.persisted) window.location.replace('<%= target %>');
            });
        })();
    </script>
</head>
<body>
<div class="loader-wrap" role="status" aria-live="polite">
    <img
        src="./IMG/Design.png"
        class="loader-img"
        alt="Loading results animation"
        aria-hidden="true"
    >

    <div class="loader-text">
        <%= message %>
    </div>
</div>

</body>
</html>