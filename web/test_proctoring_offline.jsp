<%@ page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%
    // Set test session attributes
    session.setAttribute("userId", "123");
    session.setAttribute("examId", "456");
    session.setAttribute("userStatus", "1");
%>
<!DOCTYPE html>
<html>
<head>
    <title>Offline Proctoring Test</title>
    <style>
        body { font-family: Arial, sans-serif; padding: 20px; }
        .test-section { margin: 20px 0; padding: 15px; border: 1px solid #ddd; border-radius: 5px; }
        .status { padding: 10px; margin: 10px 0; border-radius: 3px; }
        .success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .info { background: #d1ecf1; color: #0c5460; border: 1px solid #bee5eb; }
        button { padding: 10px 15px; margin: 5px; cursor: pointer; }
    </style>
</head>
<body>
    <h1>🔒 Offline Proctoring System Test</h1>
    
    <div class="test-section">
        <h2>Test Session Information</h2>
        <p>Student ID: <%= session.getAttribute("userId") %></p>
        <p>Exam ID: <%= session.getAttribute("examId") %></p>
        <p>User Status: <%= session.getAttribute("userStatus") %></p>
    </div>

    <div class="test-section">
        <h2>Face Detection Models Check</h2>
        <div id="models-status" class="info">Checking for local face-api models...</div>
        <button onclick="checkModels()">Check Models</button>
    </div>

    <div class="test-section">
        <h2>Camera/Microphone Access Test</h2>
        <div id="media-status" class="info">Click to test camera and microphone access</div>
        <button onclick="testMediaAccess()">Test Media Access</button>
    </div>

    <div class="test-section">
        <h2>Proctoring System Test</h2>
        <div id="proctoring-status" class="info">Initialize proctoring system</div>
        <button onclick="initProctoring()">Initialize Proctoring</button>
        <button onclick="startProctoring()">Start Proctoring</button>
        <button onclick="stopProctoring()">Stop Proctoring</button>
    </div>

    <div class="test-section">
        <h2>Test Results</h2>
        <div id="test-results"></div>
    </div>

    <script>
        let proctoringSystem = null;
        let testResults = [];

        function addResult(message, type = 'info') {
            const resultDiv = document.createElement('div');
            resultDiv.className = 'status ' + type;
            resultDiv.innerHTML = '<strong>' + new Date().toLocaleTimeString() + ':</strong> ' + message;
            document.getElementById('test-results').appendChild(resultDiv);
            testResults.push({ time: new Date(), message, type });
        }

        async function checkModels() {
            const statusDiv = document.getElementById('models-status');
            
            try {
                // Check if models directory exists and is accessible
                const response = await fetch('/models/tiny_face_detector_model-shard1');
                if (response.ok) {
                    statusDiv.className = 'status success';
                    statusDiv.innerHTML = '✅ Local face-api models found and accessible';
                    addResult('Local face-api models verified successfully', 'success');
                } else {
                    statusDiv.className = 'status error';
                    statusDiv.innerHTML = '❌ Local models not accessible - fallback to CDN will be used';
                    addResult('Local models not accessible, system will use fallback detection', 'error');
                }
            } catch (error) {
                statusDiv.className = 'status error';
                statusDiv.innerHTML = '❌ Error checking local models: ' + error.message;
                addResult('Error checking local models: ' + error.message, 'error');
            }
        }

        async function testMediaAccess() {
            const statusDiv = document.getElementById('media-status');
            
            try {
                const stream = await navigator.mediaDevices.getUserMedia({ 
                    video: true, 
                    audio: true 
                });
                
                statusDiv.className = 'status success';
                statusDiv.innerHTML = '✅ Camera and microphone access granted';
                addResult('Media access test passed - camera and microphone available', 'success');
                
                // Stop the stream
                stream.getTracks().forEach(track => track.stop());
                
            } catch (error) {
                statusDiv.className = 'status error';
                statusDiv.innerHTML = '❌ Media access denied: ' + error.message;
                addResult('Media access test failed: ' + error.message, 'error');
            }
        }

        // Proctoring System class (simplified for testing)
        class TestProctoringSystem {
            constructor() {
                this.examActive = false;
                this.examId = '<%= session.getAttribute("examId") %>';
                this.studentId = '<%= session.getAttribute("userId") %>';
                this.faceapi = null;
            }

            async initialize() {
                console.log('Initializing proctoring system...');
                addResult('Proctoring system initialization started', 'info');
                
                // Load face-api
                await this.loadFaceApi();
                
                // Initialize media
                await this.initVideoMonitoring();
                await this.initAudioMonitoring();
                
                this.examActive = true;
                addResult('Proctoring system initialized successfully', 'success');
            }

            async loadFaceApi() {
                return new Promise((resolve) => {
                    if (window.faceapi) {
                        this.faceapi = window.faceapi;
                        addResult('Face-api already loaded', 'info');
                        resolve();
                        return;
                    }

                    const script = document.createElement('script');
                    script.src = 'https://cdn.jsdelivr.net/npm/face-api.js@0.22.2/dist/face-api.min.js';
                    script.onload = async () => {
                        try {
                            // Try local models first
                            await faceapi.nets.tinyFaceDetector.load('/models');
                            await faceapi.nets.faceLandmark68Net.load('/models');
                            await faceapi.nets.faceExpressionNet.load('/models');
                            this.faceapi = faceapi;
                            addResult('✅ Face detection models loaded from local files', 'success');
                            resolve();
                        } catch (err) {
                            addResult('⚠️ Local models failed, using CDN fallback', 'info');
                            try {
                                // Fallback to CDN
                                await faceapi.nets.tinyFaceDetector.loadFromUri('https://raw.githubusercontent.com/justadudewhohacks/face-api.js/master/weights');
                                await faceapi.nets.faceLandmark68Net.loadFromUri('https://raw.githubusercontent.com/justadudewhohacks/face-api.js/master/weights');
                                await faceapi.nets.faceExpressionNet.loadFromUri('https://raw.githubusercontent.com/justadudewhohacks/face-api.js/master/weights');
                                this.faceapi = faceapi;
                                addResult('✅ Face detection models loaded from CDN', 'success');
                                resolve();
                            } catch (cdnErr) {
                                addResult('❌ Both local and CDN models failed', 'error');
                                resolve();
                            }
                        }
                    };
                    script.onerror = () => {
                        addResult('❌ Could not load face-api.js', 'error');
                        resolve();
                    };
                    document.head.appendChild(script);
                });
            }

            async initVideoMonitoring() {
                try {
                    const stream = await navigator.mediaDevices.getUserMedia({ video: true });
                    const video = document.createElement('video');
                    video.srcObject = stream;
                    video.style.display = 'none';
                    document.body.appendChild(video);
                    await video.play();
                    addResult('✅ Video monitoring initialized', 'success');
                } catch (err) {
                    addResult('❌ Video monitoring failed: ' + err.message, 'error');
                }
            }

            async initAudioMonitoring() {
                try {
                    const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
                    addResult('✅ Audio monitoring initialized', 'success');
                    // Stop the stream
                    stream.getTracks().forEach(track => track.stop());
                } catch (err) {
                    addResult('❌ Audio monitoring failed: ' + err.message, 'error');
                }
            }

            stop() {
                this.examActive = false;
                addResult('Proctoring system stopped', 'info');
            }
        }

        async function initProctoring() {
            proctoringSystem = new TestProctoringSystem();
            await proctoringSystem.initialize();
        }

        function startProctoring() {
            if (proctoringSystem && !proctoringSystem.examActive) {
                proctoringSystem.examActive = true;
                addResult('Proctoring system started', 'success');
            } else {
                addResult('Please initialize proctoring system first', 'error');
            }
        }

        function stopProctoring() {
            if (proctoringSystem) {
                proctoringSystem.stop();
            }
        }

        // Run initial checks
        window.addEventListener('DOMContentLoaded', function() {
            addResult('Test page loaded successfully', 'success');
            checkModels();
        });
    </script>
</body>
</html>