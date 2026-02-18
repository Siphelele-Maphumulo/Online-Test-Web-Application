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
    <title>Continuous Camera Proctoring Test</title>
    <style>
        body { font-family: Arial, sans-serif; padding: 20px; background: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; }
        .test-section { margin: 20px 0; padding: 20px; background: white; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .status { padding: 12px; margin: 10px 0; border-radius: 4px; font-weight: bold; }
        .success { background: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .error { background: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .info { background: #d1ecf1; color: #0c5460; border: 1px solid #bee5eb; }
        .warning { background: #fff3cd; color: #856404; border: 1px solid #ffeaa7; }
        button { padding: 12px 20px; margin: 8px; cursor: pointer; border: none; border-radius: 4px; font-weight: bold; }
        .btn-primary { background: #007bff; color: white; }
        .btn-success { background: #28a745; color: white; }
        .btn-danger { background: #dc3545; color: white; }
        .btn-warning { background: #ffc107; color: black; }
        .video-preview { width: 320px; height: 240px; border: 2px solid #ddd; border-radius: 4px; margin: 10px 0; }
        .stream-info { background: #f8f9fa; padding: 15px; border-radius: 4px; margin: 15px 0; }
        .log { height: 200px; overflow-y: auto; background: #000; color: #0f0; padding: 10px; font-family: monospace; font-size: 12px; border-radius: 4px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>🎥 Continuous Camera Proctoring Test</h1>
        <p>This test verifies that the camera stream remains active throughout the entire proctoring process.</p>
        
        <div class="test-section">
            <h2>📋 Test Session Information</h2>
            <div class="stream-info">
                <p><strong>Student ID:</strong> <%= session.getAttribute("userId") %></p>
                <p><strong>Exam ID:</strong> <%= session.getAttribute("examId") %></p>
                <p><strong>User Status:</strong> <%= session.getAttribute("userStatus") %></p>
            </div>
        </div>

        <div class="test-section">
            <h2>🎮 Media Stream Test</h2>
            <div id="media-status" class="info">Click to test camera and microphone access</div>
            <button class="btn-primary" onclick="testMediaAccess()">Test Media Access</button>
            <button class="btn-warning" onclick="checkStreamStatus()">Check Stream Status</button>
            
            <div class="stream-info">
                <h3>Stream Information:</h3>
                <div id="stream-info">No stream active</div>
            </div>
            
            <video id="testVideo" class="video-preview" autoplay muted></video>
        </div>

        <div class="test-section">
            <h2>🔒 Proctoring System Test</h2>
            <div id="proctoring-status" class="info">Initialize continuous proctoring system</div>
            <button class="btn-success" onclick="initProctoring()">Initialize Proctoring</button>
            <button class="btn-primary" onclick="startProctoring()">Start Proctoring</button>
            <button class="btn-danger" onclick="stopProctoring()">Stop Proctoring</button>
            <button class="btn-warning" onclick="simulateExamFlow()">Simulate Exam Flow</button>
        </div>

        <div class="test-section">
            <h2>📊 Stream Continuity Test</h2>
            <div id="continuity-status" class="info">Test camera stream persistence</div>
            <button class="btn-primary" onclick="testStreamContinuity()">Test Stream Continuity</button>
            <button class="btn-warning" onclick="forceStreamRestart()">Force Stream Restart</button>
            
            <div class="stream-info">
                <h3>Continuity Metrics:</h3>
                <div id="continuity-info">No continuity test running</div>
            </div>
        </div>

        <div class="test-section">
            <h2>📝 Test Log</h2>
            <div id="test-log" class="log"></div>
            <button class="btn-warning" onclick="clearLog()">Clear Log</button>
        </div>
    </div>

    <script>
        let proctoringSystem = null;
        let testStream = null;
        let continuityInterval = null;
        let startTime = null;

        function log(message, type = 'info') {
            const logDiv = document.getElementById('test-log');
            const timestamp = new Date().toLocaleTimeString();
            const entry = document.createElement('div');
            entry.innerHTML = '[' + timestamp + '] &lt;span style="color: ' + getColor(type) + '"&gt;' + type.toUpperCase() + ':&lt;/span&gt; ' + message;
            logDiv.appendChild(entry);
            logDiv.scrollTop = logDiv.scrollHeight;
        }

        function getColor(type) {
            const colors = {
                'info': '#0f0',
                'success': '#0f0',
                'error': '#f00',
                'warning': '#ff0'
            };
            return colors[type] || '#0f0';
        }

        function clearLog() {
            document.getElementById('test-log').innerHTML = '';
        }

        async function testMediaAccess() {
            const statusDiv = document.getElementById('media-status');
            
            try {
                log('Requesting camera and microphone access...', 'info');
                testStream = await navigator.mediaDevices.getUserMedia({ 
                    video: { width: 640, height: 480 },
                    audio: true 
                });
                
                const videoElement = document.getElementById('testVideo');
                videoElement.srcObject = testStream;
                
                statusDiv.className = 'status success';
                statusDiv.innerHTML = '✅ Camera and microphone access granted';
                log('Media access test passed - camera and microphone available', 'success');
                
                updateStreamInfo();
                
            } catch (error) {
                statusDiv.className = 'status error';
                statusDiv.innerHTML = '❌ Media access denied: ' + error.message;
                log('Media access test failed: ' + error.message, 'error');
            }
        }

        function checkStreamStatus() {
            const infoDiv = document.getElementById('stream-info');
            
            if (testStream) {
                const tracks = testStream.getTracks();
                const videoTracks = tracks.filter(t => t.kind === 'video');
                const audioTracks = tracks.filter(t => t.kind === 'audio');
                
                var videoStatus = 'N/A';
                var audioStatus = 'N/A';
                
                if (videoTracks.length > 0) {
                    videoStatus = videoTracks[0].readyState;
                }
                
                if (audioTracks.length > 0) {
                    audioStatus = audioTracks[0].readyState;
                }
                
                infoDiv.innerHTML = '<strong>Active Stream:</strong><br>' +
                    'Video Tracks: ' + videoTracks.length + ' (' + videoStatus + ')<br>' +
                    'Audio Tracks: ' + audioTracks.length + ' (' + audioStatus + ')<br>' +
                    'Stream ID: ' + testStream.id + '<br>' +
                    'Active Duration: ' + (startTime ? Math.floor((Date.now() - startTime) / 1000) + 's' : 'N/A');
                
                log('Stream status - Video: ' + videoTracks.length + ', Audio: ' + audioTracks.length, 'info');
            } else {
                infoDiv.innerHTML = 'No active stream';
                log('No active stream found', 'warning');
            }
        }

        function updateStreamInfo() {
            startTime = Date.now();
            setInterval(checkStreamStatus, 1000);
        }

        // Continuous Proctoring System
        class ContinuousProctoringSystem {
            constructor() {
                this.examActive = false;
                this.stream = null;
                this.examId = '<%= session.getAttribute("examId") %>';
                this.studentId = '<%= session.getAttribute("userId") %>';
                this.violations = [];
                this.warningCount = 0;
            }

            async initialize() {
                log('Initializing continuous proctoring system...', 'info');
                
                try {
                    // Request single stream with both video and audio
                    this.stream = await navigator.mediaDevices.getUserMedia({
                        video: { width: 640, height: 480, frameRate: 15 },
                        audio: { echoCancellation: false, noiseSuppression: false }
                    });
                    
                    log('✅ Single stream with video and audio acquired', 'success');
                    
                    // Initialize monitoring with the same stream
                    await this.initVideoMonitoring();
                    await this.initAudioMonitoring();
                    
                    this.examActive = true;
                    log('Continuous proctoring system initialized successfully', 'success');
                    
                    return true;
                } catch (error) {
                    log('Failed to initialize proctoring: ' + error.message, 'error');
                    return false;
                }
            }

            async initVideoMonitoring() {
                try {
                    const videoElement = document.createElement('video');
                    videoElement.id = 'proctor-video';
                    videoElement.style.display = 'none';
                    videoElement.srcObject = this.stream;
                    videoElement.muted = true;
                    document.body.appendChild(videoElement);
                    
                    await videoElement.play();
                    log('✅ Video monitoring initialized with persistent stream', 'success');
                } catch (error) {
                    log('Video monitoring failed: ' + error.message, 'error');
                }
            }

            async initAudioMonitoring() {
                try {
                    const audioContext = new (window.AudioContext || window.webkitAudioContext)();
                    const source = audioContext.createMediaStreamSource(this.stream);
                    const analyser = audioContext.createAnalyser();
                    analyser.fftSize = 2048;
                    
                    source.connect(analyser);
                    log('✅ Audio monitoring initialized with persistent stream', 'success');
                } catch (error) {
                    log('Audio monitoring failed: ' + error.message, 'error');
                }
            }

            start() {
                if (this.examActive) {
                    log('Proctoring system already active', 'warning');
                    return;
                }
                this.examActive = true;
                log('Proctoring system started', 'success');
            }

            stop() {
                this.examActive = false;
                
                if (this.stream) {
                    this.stream.getTracks().forEach(track => track.stop());
                    this.stream = null;
                    log('✅ Stream stopped and resources released', 'success');
                }
                
                const videoElement = document.getElementById('proctor-video');
                if (videoElement) {
                    videoElement.remove();
                }
                
                log('Proctoring system stopped', 'info');
            }

            getStreamStatus() {
                if (!this.stream) return null;
                
                const tracks = this.stream.getTracks();
                return {
                    videoTracks: tracks.filter(t => t.kind === 'video').length,
                    audioTracks: tracks.filter(t => t.kind === 'audio').length,
                    streamId: this.stream.id,
                    active: this.examActive
                };
            }
        }

        async function initProctoring() {
            const statusDiv = document.getElementById('proctoring-status');
            
            proctoringSystem = new ContinuousProctoringSystem();
            const success = await proctoringSystem.initialize();
            
            if (success) {
                statusDiv.className = 'status success';
                statusDiv.innerHTML = '✅ Proctoring system initialized with persistent stream';
            } else {
                statusDiv.className = 'status error';
                statusDiv.innerHTML = '❌ Failed to initialize proctoring system';
            }
        }

        function startProctoring() {
            const statusDiv = document.getElementById('proctoring-status');
            
            if (proctoringSystem) {
                proctoringSystem.start();
                statusDiv.className = 'status success';
                statusDiv.innerHTML = '✅ Proctoring system active with continuous stream';
                log('Proctoring system started with continuous stream', 'success');
            } else {
                statusDiv.className = 'status error';
                statusDiv.innerHTML = '❌ Initialize proctoring system first';
                log('Cannot start - proctoring system not initialized', 'error');
            }
        }

        function stopProctoring() {
            const statusDiv = document.getElementById('proctoring-status');
            
            if (proctoringSystem) {
                proctoringSystem.stop();
                proctoringSystem = null;
                statusDiv.className = 'status info';
                statusDiv.innerHTML = 'ℹ️ Proctoring system stopped';
                log('Proctoring system stopped', 'info');
            }
        }

        async function simulateExamFlow() {
            log('Simulating complete exam flow with continuous camera...', 'info');
            
            // Step 1: Initialize
            await initProctoring();
            await new Promise(resolve => setTimeout(resolve, 1000));
            
            // Step 2: Start proctoring
            startProctoring();
            await new Promise(resolve => setTimeout(resolve, 2000));
            
            // Step 3: Verify stream continuity
            checkStreamStatus();
            await new Promise(resolve => setTimeout(resolve, 3000));
            
            // Step 4: Stop (like exam ending)
            stopProctoring();
            
            log('Exam flow simulation completed', 'success');
        }

        function testStreamContinuity() {
            const statusDiv = document.getElementById('continuity-status');
            const infoDiv = document.getElementById('continuity-info');
            
            if (!proctoringSystem || !proctoringSystem.stream) {
                statusDiv.className = 'status error';
                statusDiv.innerHTML = '❌ No active stream to test';
                log('Cannot test continuity - no active stream', 'error');
                return;
            }
            
            statusDiv.className = 'status info';
            statusDiv.innerHTML = '⏳ Testing stream continuity...';
            
            let testCount = 0;
            const startTime = Date.now();
            
            continuityInterval = setInterval(() => {
                if (!proctoringSystem || !proctoringSystem.stream) {
                    clearInterval(continuityInterval);
                    statusDiv.className = 'status error';
                    statusDiv.innerHTML = '❌ Stream lost during test';
                    log('Stream continuity test failed - stream lost', 'error');
                    return;
                }
                
                testCount++;
                const elapsed = Math.floor((Date.now() - startTime) / 1000);
                const status = proctoringSystem.getStreamStatus();
                
                infoDiv.innerHTML = 'Test Duration: ' + elapsed + 's<br>' +
                    'Tests Completed: ' + testCount + '<br>' +
                    'Video Tracks: ' + status.videoTracks + '<br>' +
                    'Audio Tracks: ' + status.audioTracks + '<br>' +
                    'Status: ' + (status.active ? 'Active' : 'Inactive');
                
                log('Continuity check #' + testCount + ': ' + status.videoTracks + ' video, ' + status.audioTracks + ' audio tracks', 'info');
                
                if (elapsed >= 10) { // Test for 10 seconds
                    clearInterval(continuityInterval);
                    statusDiv.className = 'status success';
                    statusDiv.innerHTML = '✅ Stream continuity maintained for 10 seconds';
                    log('Stream continuity test PASSED - stream maintained throughout', 'success');
                }
            }, 1000);
        }

        function forceStreamRestart() {
            const statusDiv = document.getElementById('continuity-status');
            
            if (proctoringSystem) {
                log('Forcing stream restart...', 'warning');
                proctoringSystem.stop();
                setTimeout(() => {
                    initProctoring();
                }, 1000);
            } else {
                statusDiv.className = 'status error';
                statusDiv.innerHTML = '❌ No proctoring system to restart';
            }
        }

        // Initialize
        window.addEventListener('DOMContentLoaded', function() {
            log('Continuous Camera Proctoring Test loaded', 'success');
            log('Ready to test persistent camera stream functionality', 'info');
        });
    </script>
</body>
</html>