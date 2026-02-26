class ProctoringSystem { 
    constructor() { 
        this.examActive = true; 
        this.terminated = false; // Flag to prevent multiple submissions
        this.violations = []; 
        this.warningCount = 0; 
        this.MAX_WARNINGS = 8; // ← CHANGED TO 8 ATTEMPTS (as requested)

        // Anti-false-positive controls
        this.violationCooldownMs = 12000;
        this.lastViolationAt = {}; 
        this.examStartAt = Date.now();
        this.gracePeriodMs = 12000;

        // Natural behavior tolerance
        this.noiseSpikeMinDurationMs = 2500;
        this.voiceVarianceMinDurationMs = 5000;
        this.headMovementMinDurationMs = 2500;
        this.noiseSpikeStartAt = null;
        this.voiceVarianceStartAt = null;
        this.headMovementStartAt = null;
        this.fastMouseStartAt = null;
        this.lastFastMouseFlagAt = 0;

        // Detection thresholds (calibrated for real cheating scenarios) 
        this.NOISE_THRESHOLD = 38;
        this.MULTIPLE_VOICES_THRESHOLD = 420;
        this.EYE_OFF_SCREEN_THRESHOLD = 2800;
        this.HEAD_MOVEMENT_THRESHOLD = 0.145;
        this.FACE_LOST_THRESHOLD = 1500;           // ← Increased to 1.5 seconds to reduce false positives
        this.MOUTH_MOVEMENT_THRESHOLD = 1.7;
        this.LOOKING_DOWN_ANGLE = -13;

        // PERFECT 10-SECOND COUNTDOWN
        this.FACE_LOST_MAX_SECONDS = 15;          // ← Increased to 15 seconds for more tolerance
        this.countdownActive = false;
        this.countdownValue = 10;
        this.countdownOverlay = null;

        // Behavioral thresholds
        this.FAST_MOUSE_SPEED_PX_PER_S = 6200;
        this.FAST_MOUSE_SUSTAIN_MS = 650;
        this.FAST_MOUSE_COOLDOWN_MS = 14000;

        // State tracking 
        this.lastEyeContact = Date.now(); 
        this.lastFaceDetected = Date.now(); 
        this.backgroundNoiseBaseline = 40; 
        this.calibrationComplete = false; 
        this.previousNosePosition = null; 
        this.previousMouthHeight = null; 
        this.currentAudioLevel = 0; // Store current audio level in dB 

        // Media streams 
        this.audioStream = null; 
        this.videoStream = null;
        this.sharedStream = null;
        this.streamActive = true;

        // Face detection 
        this.faceapi = null; 
        this.detectionInterval = null; 
        this.audioMonitor = null;

        // Bind methods
        this.handleVisibilityChange = this.handleVisibilityChange.bind(this);
        this.handleBeforeUnload = this.handleBeforeUnload.bind(this);
    } 

    async initialize(sharedStream) { 
        console.log('🔒 Initializing Professional Proctoring System...'); 

        this.showStatusBanner(); 
        // Load Face-API in the background so the exam UI is not delayed by CDN/model downloads.
        // The monitoring loop will use fallback detection until face-api becomes available.
        this.loadFaceApi().catch(() => {});

        if (sharedStream) {
            this.sharedStream = sharedStream;
            this.audioStream = sharedStream;
            this.videoStream = sharedStream;
        }

        // Set up stream persistence
        this.setupStreamPersistence();

        await this.initAudioMonitoring(); 
        await this.initVideoMonitoring(); 
        this.initEnvironmentLockdown(); 
        this.initBehavioralMonitoring(); 

        this.startMonitoringLoop(); 

        console.log('✅ Proctoring System Active'); 
        this.logToServer('INFO', 'Proctoring started successfully'); 
    } 

    setupStreamPersistence() {
        document.addEventListener('visibilitychange', this.handleVisibilityChange);
        window.addEventListener('beforeunload', this.handleBeforeUnload);
        window.addEventListener('pagehide', this.handleBeforeUnload);
        window.addEventListener('pageshow', this.handlePageShow);
        this.streamHealthInterval = setInterval(() => this.checkStreamHealth(), 5000);
    }

    handleVisibilityChange() {
        if (document.hidden) {
            console.log('Tab hidden - preserving streams');
            if (this.detectionInterval) {
                clearInterval(this.detectionInterval);
                this.detectionInterval = null;
            }
        } else {
            console.log('Tab visible - resuming detection');
            if (!this.detectionInterval && this.videoElement) {
                this.startFaceDetection(this.videoElement);
            }
        }
    }

    handleBeforeUnload(event) {
        console.log('Page unloading - preserving stream references');
        try {
            sessionStorage.setItem('proctorAutoStart', '1');
        } catch (e) {}
        // Mark potential refresh for detection on reload
        try {
            sessionStorage.setItem('examPageUnload', Date.now().toString());
        } catch (e) {}
    }

    handlePageShow(event) {
        // Detect page refresh/reload
        if (event.persisted) {
            console.log('Page restored from cache - treating as refresh violation');
            this.autoSubmitForCheating('Page refreshed/reloaded');
            return;
        }
        try {
            const unloadTime = sessionStorage.getItem('examPageUnload');
            if (unloadTime) {
                const elapsed = Date.now() - parseInt(unloadTime, 10);
                if (elapsed < 5000) {
                    console.log('Page reload detected within 5 seconds - terminating exam');
                    this.autoSubmitForCheating('Page refreshed/reloaded');
                }
                sessionStorage.removeItem('examPageUnload');
            }
        } catch (e) {}
    }

    checkStreamHealth() {
        if (!this.examActive) return;

        if (this.videoStream) {
            const videoTracks = this.videoStream.getVideoTracks();
            if (videoTracks.length === 0 || !videoTracks[0].enabled || videoTracks[0].readyState === 'ended') {
                console.warn('Video stream unhealthy - attempting recovery');
                this.recoverStream('video');
            }
        }

        if (this.audioStream) {
            const audioTracks = this.audioStream.getAudioTracks();
            if (audioTracks.length === 0 || !audioTracks[0].enabled || audioTracks[0].readyState === 'ended') {
                console.warn('Audio stream unhealthy - attempting recovery');
                this.recoverStream('audio');
            }
        }

        if (this.videoElement && this.videoElement.paused) {
            console.warn('Video element paused - attempting to resume');
            this.videoElement.play().catch(err => {
                console.error('Failed to resume video:', err);
                this.recoverStream('video');
            });
        }
    }

    async recoverStream(type = 'all') {
        try {
            console.log(`Attempting to recover ${type} stream...`);

            if (type === 'video' || type === 'all') {
                if (this.videoStream) {
                    this.videoStream.getVideoTracks().forEach(track => {
                        track.stop();
                        this.videoStream.removeTrack(track);
                    });
                }
            }

            if (type === 'audio' || type === 'all') {
                if (this.audioStream) {
                    this.audioStream.getAudioTracks().forEach(track => {
                        track.stop();
                        this.audioStream.removeTrack(track);
                    });
                }
            }

            const constraints = {
                video: (type === 'video' || type === 'all'),
                audio: (type === 'audio' || type === 'all')
            };

            const newStream = await navigator.mediaDevices.getUserMedia(constraints);

            if (type === 'video' || type === 'all') {
                if (this.videoStream) {
                    newStream.getVideoTracks().forEach(track => {
                        this.videoStream.addTrack(track);
                    });
                } else {
                    this.videoStream = newStream;
                }
            }

            if (type === 'audio' || type === 'all') {
                if (this.audioStream) {
                    newStream.getAudioTracks().forEach(track => {
                        this.audioStream.addTrack(track);
                    });
                } else {
                    this.audioStream = newStream;
                }
            }

            if (this.videoElement && (type === 'video' || type === 'all')) {
                this.videoElement.srcObject = this.videoStream;
                await this.videoElement.play();
            }

            if (type === 'audio' || type === 'all') {
                if (this.audioMonitor) {
                    clearInterval(this.audioMonitor);
                }
                await this.initAudioMonitoring();
            }

            console.log(`✅ ${type} stream recovered successfully`);
            this.logToServer('INFO', `${type} stream recovered automatically`);

        } catch (err) {
            console.error(`Failed to recover ${type} stream:`, err);
            this.logViolation('CRITICAL', `Camera/microphone stream lost and couldn't recover`);
        }
    }

    showStatusBanner() { 
        const banner = document.createElement('div'); 
        banner.id = 'proctoring-banner'; 
        banner.style.cssText = 'position: fixed; bottom: 12px; left: 50%; transform: translateX(-50%); background: #09294d; color: white; padding: 8px 15px; border-radius: 20px; font-size: 12px; z-index: 9999; display: flex; align-items: center; gap: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.2);'; 
        banner.innerHTML = '<span class="live-indicator" style="width: 10px; height: 10px; background: #10b981; border-radius: 50%; animation: pulse 2s infinite;"></span>' + 
            '<span>Proctoring Active</span>' + 
            '<span id="violation-counter" style="background: #ef4444; padding: 2px 6px; border-radius: 10px; font-size: 10px;">0/' + this.MAX_WARNINGS + '</span>'; 
        document.body.appendChild(banner); 

        const style = document.createElement('style'); 
        style.textContent = ` 
            @keyframes pulse { 
                0% { opacity: 1; transform: scale(1); } 
                50% { opacity: 0.5; transform: scale(1.2); } 
                100% { opacity: 1; transform: scale(1); } 
            } 
        `; 
        document.head.appendChild(style); 
    } 

    async loadFaceApi() { 
        return new Promise((resolve) => { 
            if (window.faceapi) { 
                this.faceapi = window.faceapi; 
                resolve(); 
                return; 
            } 

            const script = document.createElement('script'); 
            script.src = 'https://cdn.jsdelivr.net/npm/face-api.js@0.22.2/dist/face-api.min.js'; 
            script.onload = async () => { 
                try { 
                    await faceapi.nets.tinyFaceDetector.loadFromUri('https://raw.githubusercontent.com/justadudewhohacks/face-api.js/master/weights'); 
                    await faceapi.nets.faceLandmark68Net.loadFromUri('https://raw.githubusercontent.com/justadudewhohacks/face-api.js/master/weights'); 
                    await faceapi.nets.faceExpressionNet.loadFromUri('https://raw.githubusercontent.com/justadudewhohacks/face-api.js/master/weights'); 
                    this.faceapi = faceapi; 
                    console.log('✅ Face detection models loaded from CDN'); 
                    resolve(); 
                } catch (err) { 
                    console.warn('Could not load face-api models, using fallback detection', err); 
                    resolve(); 
                } 
            }; 
            script.onerror = () => { 
                console.warn('Could not load face-api.js, using fallback detection'); 
                resolve(); 
            }; 
            document.head.appendChild(script); 
        }); 
    } 

    async initAudioMonitoring() { 
        try { 
            if (!this.audioStream) {
                this.audioStream = await navigator.mediaDevices.getUserMedia({
                    audio: {
                        echoCancellation: false,
                        noiseSuppression: false,
                        autoGainControl: false
                    }
                });
            }

            const audioContext = new (window.AudioContext || window.webkitAudioContext)(); 
            if (audioContext.state === 'suspended') {
                await audioContext.resume();
            }

            const source = audioContext.createMediaStreamSource(this.audioStream); 
            const analyser = audioContext.createAnalyser(); 
            analyser.fftSize = 2048; 

            source.connect(analyser); 

            const bufferLength = analyser.frequencyBinCount; 
            const dataArray = new Uint8Array(bufferLength); 

            setTimeout(() => this.calibrateNoise(analyser), 5000); 

            this.audioMonitor = setInterval(() => { 
                analyser.getByteFrequencyData(dataArray); 
                this.analyzeAudio(dataArray); 
            }, 500); 

        } catch (err) { 
            this.logViolation('CRITICAL', 'Audio monitoring unavailable - microphone access denied'); 
        } 
    } 

    calibrateNoise(analyser) { 
        const dataArray = new Uint8Array(analyser.frequencyBinCount); 
        let sum = 0; 

        for (let i = 0; i < 10; i++) { 
            analyser.getByteFrequencyData(dataArray); 
            sum += dataArray.reduce((a, b) => a + b, 0) / dataArray.length; 
        } 

        this.backgroundNoiseBaseline = sum / 10; 
        this.calibrationComplete = true; 
        console.log('✅ Noise baseline calibrated:', this.backgroundNoiseBaseline.toFixed(2)); 
    } 

    analyzeAudio(dataArray) { 
        if (!this.calibrationComplete) return;

        const average = dataArray.reduce(function(a, b) { return a + b; }, 0) / dataArray.length; 
        const dbLevel = 20 * Math.log10(average || 1); 
        
        // Store current audio level for lip movement detection
        this.currentAudioLevel = dbLevel;

        const now = Date.now();
        const noiseThreshold = this.backgroundNoiseBaseline + 12;

        if (dbLevel > noiseThreshold) { 
            if (!this.noiseSpikeStartAt) this.noiseSpikeStartAt = now; 
            if (now - this.noiseSpikeStartAt >= this.noiseSpikeMinDurationMs) { 
                this.logViolation('AUDIO', 'Sustained loud background noise detected (' + Math.round(dbLevel) + 'dB)'); 
                this.noiseSpikeStartAt = now; 
            } 
        } else { 
            this.noiseSpikeStartAt = null; 
        }

        const variance = this.calculateVariance(dataArray); 
        if (variance > this.MULTIPLE_VOICES_THRESHOLD) {
            if (!this.voiceVarianceStartAt) this.voiceVarianceStartAt = now;
            if (now - this.voiceVarianceStartAt >= this.voiceVarianceMinDurationMs) {
                this.logViolation('AUDIO', 'Sustained multiple voices/conversation detected in background');
                this.voiceVarianceStartAt = now;
            }
        } else {
            this.voiceVarianceStartAt = null;
        }
    } 

    calculateVariance(dataArray) { 
        const mean = dataArray.reduce((a, b) => a + b, 0) / dataArray.length; 
        const variance = dataArray.reduce((a, b) => a + Math.pow(b - mean, 2), 0) / dataArray.length; 
        return variance; 
    } 

    async initVideoMonitoring() { 
        try { 
            if (!this.videoStream) {
                this.videoStream = await navigator.mediaDevices.getUserMedia({
                    video: {
                        width: { ideal: 1280 },
                        height: { ideal: 720 },
                        frameRate: { ideal: 30 }
                    }
                });
            }

            let videoElement = document.getElementById('faceVideo'); 
            if (!videoElement) { 
                videoElement = document.createElement('video'); 
                videoElement.id = 'proctorVideo'; 
                videoElement.style.display = 'none';
                videoElement.setAttribute('playsinline', '');
                videoElement.setAttribute('autoplay', '');
                videoElement.setAttribute('muted', '');
                document.body.appendChild(videoElement); 
            } 

            videoElement.srcObject = this.videoStream; 
            videoElement.muted = true; 
            
            await new Promise((resolve) => {
                videoElement.onloadeddata = resolve;
                videoElement.play().catch(resolve);
            });

            this.videoCanvas = document.createElement('canvas'); 
            this.videoContext = this.videoCanvas.getContext('2d'); 

            this.startFaceDetection(videoElement); 

        } catch (err) { 
            this.logViolation('CRITICAL', 'Camera monitoring unavailable - webcam access denied'); 
        } 
    } 

    async startFaceDetection(videoElement) { 
        this.videoElement = videoElement; 

        if (this.detectionInterval) {
            clearInterval(this.detectionInterval);
        }

        // Run detection every 300ms
        this.detectionInterval = setInterval(async () => { 
            if (!this.examActive || !videoElement.videoWidth) return; 

            try { 
                if (this.faceapi && videoElement.videoWidth > 0) { 
                    const detections = await this.faceapi 
                        .detectAllFaces(videoElement, new this.faceapi.TinyFaceDetectorOptions({ 
                            inputSize: 416, 
                            scoreThreshold: 0.25  // ← Lowered threshold for better detection
                        })) 
                        .withFaceLandmarks() 
                        .withFaceExpressions(); 

                    this.processFaceDetections(detections); 
                } else { 
                    this.processFallbackDetection(videoElement); 
                } 
            } catch (err) { 
                // Silent fail 
            } 
        }, 300); 
    } 

    processFaceDetections(detections) { 
        // More lenient face detection - accept lower confidence faces
        const validFaces = detections.filter(d => d.detection && d.detection.score > 0.35);
        
        // Debug logging
        if (detections.length > 0) {
            console.log('🔍 Face detection:', {
                total: detections.length,
                valid: validFaces.length,
                scores: detections.map(d => d.detection ? d.detection.score.toFixed(3) : 'null')
            });
        }

        if (validFaces.length === 0) { 
            // If countdown is running and we see ANY face boxes (even low-confidence),
            // immediately stop the countdown and refresh lastFaceDetected.
            if (this.countdownActive && detections.length > 0) {
                this.lastFaceDetected = Date.now();
                console.log('✅ Face boxes detected during countdown (low confidence), stopping countdown immediately');
                this.hideCountdown();
                return;
            }

            const timeLost = Date.now() - this.lastFaceDetected;
            console.log('⚠️ No valid faces detected, time lost:', timeLost + 'ms');
            
            // Only start countdown after longer threshold
            if (timeLost > this.FACE_LOST_THRESHOLD) { 
                this.handleCountdown(timeLost, 'FACE NOT DETECTED');
            } else {
                // Still update last face detected occasionally to prevent false triggers
                if (detections.length > 0 && timeLost < 800) {
                    this.lastFaceDetected = Date.now();
                    console.log('🔄 Updated lastFaceDetected due to low-confidence detection');
                    if (this.countdownActive) {
                        console.log('✅ Low-confidence face detected, stopping countdown immediately');
                        this.hideCountdown();
                    }
                }
            }
            return; 
        } 

        this.lastFaceDetected = Date.now(); 
        if (this.countdownActive) {
            console.log('✅ Face re-detected, hiding countdown immediately');
            this.hideCountdown();
        }
        
        if (this.countdownActive) {
            console.log('🔧 Force hiding countdown after face detection');
            this.hideCountdown();
        }

        if (detections.length > 1) { 
            this.logViolation('VISUAL', 'Multiple people detected in camera frame'); 
        } 

        const face = validFaces[0]; 

        const lookingAtScreen = this.detectGazeDirection(face.landmarks); 
        if (!lookingAtScreen) { 
            if (Date.now() - this.lastEyeContact > this.EYE_OFF_SCREEN_THRESHOLD) { 
                this.logViolation('VISUAL', 'Looking away from screen for >3 seconds'); 
            } 
        } else { 
            this.lastEyeContact = Date.now(); 
        } 

        const headMovement = this.detectHeadMovement(face.landmarks); 
        if (headMovement > this.HEAD_MOVEMENT_THRESHOLD) {
            const now = Date.now();
            if (!this.headMovementStartAt) this.headMovementStartAt = now;
            if (now - this.headMovementStartAt >= this.headMovementMinDurationMs) {
                this.logViolation('VISUAL', 'Sustained excessive head movement detected');
                this.headMovementStartAt = now;
            }
        } else {
            this.headMovementStartAt = null;
        }

        if (this.detectFaceObstruction(face.landmarks)) { 
            this.logViolation('VISUAL', 'Face partially obscured - possible phone or notes'); 
        } 

        const headPose = this.estimateHeadPose(face.landmarks); 
        if (headPose.pitch < this.LOOKING_DOWN_ANGLE) { 
            this.logViolation('VISUAL', 'Looking down - possible phone use'); 
        } 

        if (this.detectLipMovement(face.landmarks, face.expressions)) { 
            this.logViolation('BEHAVIOR', 'Lip movement detected - possible verbal communication'); 
        } 
    } 

    detectGazeDirection(landmarks) { 
        if (!landmarks) return true; 

        try { 
            const leftEye = landmarks.getLeftEye(); 
            const rightEye = landmarks.getRightEye(); 

            const leftEAR = this.eyeAspectRatio(leftEye); 
            const rightEAR = this.eyeAspectRatio(rightEye); 

            if (leftEAR < 0.20 || rightEAR < 0.20) { 
                return false; 
            } 

            return true; 
        } catch (err) { 
            return true; 
        } 
    } 

    eyeAspectRatio(eye) { 
        if (!eye || eye.length < 8) return 0.3; 

        try { 
            const A = Math.hypot(eye[1].x - eye[5].x, eye[1].y - eye[5].y); 
            const B = Math.hypot(eye[2].x - eye[4].x, eye[2].y - eye[4].y); 
            const C = Math.hypot(eye[0].x - eye[3].x, eye[0].y - eye[3].y); 
            return (A + B) / (2 * C); 
        } catch (err) { 
            return 0.3; 
        } 
    } 

    detectHeadMovement(landmarks) { 
        if (!landmarks) return 0; 

        try { 
            const nose = landmarks.getNose(); 
            if (!nose || nose.length === 0) return 0; 

            let faceScale = 100; 
            try {
                const leftEye = landmarks.getLeftEye();
                const rightEye = landmarks.getRightEye();
                if (leftEye && leftEye.length > 0 && rightEye && rightEye.length > 0) {
                    const lx = leftEye[0].x;
                    const ly = leftEye[0].y;
                    const rx = rightEye[3] ? rightEye[3].x : rightEye[0].x;
                    const ry = rightEye[3] ? rightEye[3].y : rightEye[0].y;
                    const d = Math.hypot(rx - lx, ry - ly);
                    if (d && d > 20) faceScale = d;
                }
            } catch (e) {}

            if (!this.previousNosePosition) { 
                this.previousNosePosition = { x: nose[0].x, y: nose[0].y, scale: faceScale }; 
                return 0; 
            } 

            const pxMove = Math.hypot( 
                nose[0].x - this.previousNosePosition.x, 
                nose[0].y - this.previousNosePosition.y 
            );

            const scale = this.previousNosePosition.scale || faceScale || 100;
            const movement = pxMove / scale;

            this.previousNosePosition = { x: nose[0].x, y: nose[0].y, scale: faceScale }; 
            return movement; 
        } catch (err) { 
            return 0; 
        } 
    } 

    detectFaceObstruction(landmarks) { 
        if (!landmarks) return false; 

        try { 
            const jaw = landmarks.getJawOutline(); 
            const mouth = landmarks.getMouth(); 

            if (!jaw || jaw.length === 0 || !mouth || mouth.length === 0) return false; 

            const jawWidth = Math.abs(jaw[0].x - jaw[jaw.length - 1].x); 
            const mouthWidth = Math.abs(mouth[0].x - mouth[6].x); 

            return mouthWidth < jawWidth * 0.2; 
        } catch (err) { 
            return false; 
        } 
    } 

    estimateHeadPose(landmarks) { 
        if (!landmarks) return { pitch: 0 }; 

        try { 
            const nose = landmarks.getNose(); 
            const leftEye = landmarks.getLeftEye(); 
            const rightEye = landmarks.getRightEye(); 

            if (!nose || nose.length === 0 || !leftEye || leftEye.length === 0 || !rightEye || rightEye.length === 0) { 
                return { pitch: 0 }; 
            } 

            const eyeY = (leftEye[0].y + rightEye[0].y) / 2; 
            const pitch = nose[0].y - eyeY; 

            return { pitch }; 
        } catch (err) { 
            return { pitch: 0 }; 
        } 
    } 

    detectLipMovement(landmarks, expressions) { 
        if (!landmarks) return false; 

        try { 
            const mouth = landmarks.getMouth(); 
            if (!mouth || mouth.length < 14) return false; 

            if (!this.previousMouthHeight) { 
                this.previousMouthHeight = Math.abs(mouth[13].y - mouth[14].y); 
                return false; 
            } 

            const mouthHeight = Math.abs(mouth[13].y - mouth[14].y); 
            const movement = Math.abs(mouthHeight - this.previousMouthHeight); 

            this.previousMouthHeight = mouthHeight; 

            // Require at least 10dB of audio before flagging lip movement
            const hasSufficientAudio = this.currentAudioLevel >= 10;
            
            return movement > this.MOUTH_MOVEMENT_THRESHOLD &&  
                   (!expressions || expressions.happy < 0.5) &&
                   hasSufficientAudio; 
        } catch (err) { 
            return false; 
        } 
    } 

    processFallbackDetection(videoElement) { 
        if (!this.videoCanvas) return; 

        try { 
            this.videoCanvas.width = videoElement.videoWidth; 
            this.videoCanvas.height = videoElement.videoHeight; 
            this.videoContext.drawImage(videoElement, 0, 0); 

            const frame = this.videoContext.getImageData(0, 0, this.videoCanvas.width, this.videoCanvas.height); 

            if (this.lastFrame) { 
                let diff = 0; 
                let pixelCount = 0; 
                
                for (let i = 0; i < frame.data.length; i += 40) { 
                    diff += Math.abs(frame.data[i] - this.lastFrame.data[i]); 
                    pixelCount++;
                } 

                const avgDiff = diff / pixelCount;
                
                if (avgDiff > 15) {
                    this.lastFaceDetected = Date.now();
                    if (this.countdownActive) {
                        console.log('✅ Movement detected via fallback, hiding countdown');
                        this.hideCountdown();
                    }
                } else if (avgDiff > 5) {
                    const timeSinceLastUpdate = Date.now() - this.lastFaceDetected;
                    if (timeSinceLastUpdate < 2000) {
                        this.lastFaceDetected = Date.now();
                        if (this.countdownActive) {
                            console.log('✅ Minor movement detected, stopping countdown immediately');
                            this.hideCountdown();
                        }
                    }
                }
            } else {
                this.lastFaceDetected = Date.now();
            }

            this.lastFrame = frame; 
            
            const timeSinceLastFace = Date.now() - this.lastFaceDetected;
            if (timeSinceLastFace > 5000) {
                console.log('⚠️ Fallback detection: No significant movement for', Math.round(timeSinceLastFace/1000), 'seconds');
            }
            
        } catch (err) { 
            console.error('Fallback detection error:', err);
        } 
    } 

    initEnvironmentLockdown() { 
        var self = this;
        document.addEventListener('keyup', function(e) { 
            if (e.key === 'PrintScreen') { 
                self.logViolation('LOCKDOWN', 'Print screen attempted'); 
                navigator.clipboard.writeText('').catch(function() {}); 
            } 
        }); 

        let lastFocusTime = Date.now(); 
        window.addEventListener('blur', function() { 
            lastFocusTime = Date.now(); 
            self.logViolation('LOCKDOWN', 'Window focus lost - possible Alt+Tab'); 
        }); 

        window.addEventListener('focus', function() { 
            if (Date.now() - lastFocusTime > 2000) {} 
        }); 

        document.addEventListener('contextmenu', function(e) { 
            e.preventDefault(); 
            self.logViolation('LOCKDOWN', 'Right-click attempted'); 
            return false; 
        }); 

        document.addEventListener('keydown', function(e) { 
            if (e.ctrlKey || e.altKey || e.metaKey) { 
                e.preventDefault(); 
                self.logViolation('LOCKDOWN', 'Forbidden key combination: ' + e.key); 
            } 

            if (e.key.startsWith('F') && e.key.length > 1 && !isNaN(parseInt(e.key.substring(1)))) { 
                e.preventDefault(); 
                self.logViolation('LOCKDOWN', 'Function key pressed: ' + e.key); 
            } 
        }); 

        this.enforceFullscreen(); 
    } 

    enforceFullscreen() {
        // Request fullscreen immediately
        this.requestFullscreenNow();
        // Then check every 500ms and re-request if exited
        this.fullscreenInterval = setInterval(() => {
            if (!document.fullscreenElement && this.examActive) {
                this.logViolation('LOCKDOWN', 'Exited fullscreen mode');
                this.requestFullscreenNow();
            }
        }, 500);
    }

    requestFullscreenNow() {
        const el = document.documentElement;
        if (el.requestFullscreen) {
            el.requestFullscreen().catch(err => {
                console.warn('Fullscreen request failed:', err);
            });
        } else if (el.webkitRequestFullscreen) {
            el.webkitRequestFullscreen();
        } else if (el.msRequestFullscreen) {
            el.msRequestFullscreen();
        }
    } 

    initBehavioralMonitoring() { 
        let mouseMovements = []; 
        let mouseStoppedTime = Date.now(); 
        let lastMousePosition = { x: 0, y: 0 }; 

        document.addEventListener('mousemove', (e) => { 
            const now = Date.now(); 

            if (e.clientX <= 5 || e.clientY <= 5 ||  
                e.clientX >= window.innerWidth - 5 ||  
                e.clientY >= window.innerHeight - 5) { 
                this.logViolation('BEHAVIOR', 'Mouse moved to screen edge - possible second monitor'); 
            } 

            if (lastMousePosition.x !== 0) { 
                const distance = Math.hypot(e.clientX - lastMousePosition.x, e.clientY - lastMousePosition.y); 
                const dt = now - mouseStoppedTime; 

                if (dt >= 20) {
                    const speedPxPerS = (distance / dt) * 1000;

                    const isExtreme = speedPxPerS >= this.FAST_MOUSE_SPEED_PX_PER_S;
                    if (isExtreme) {
                        if (!this.fastMouseStartAt) this.fastMouseStartAt = now;

                        const sustainedMs = now - this.fastMouseStartAt;
                        const cooldownOk = !this.lastFastMouseFlagAt || ((now - this.lastFastMouseFlagAt) >= this.FAST_MOUSE_COOLDOWN_MS);

                        if (sustainedMs >= this.FAST_MOUSE_SUSTAIN_MS && cooldownOk) {
                            this.lastFastMouseFlagAt = now;
                            this.fastMouseStartAt = null;
                            mouseMovements = [];
                            this.logViolation('BEHAVIOR', 'Unusually fast sustained mouse movements - possible automation');
                        }
                    } else {
                        this.fastMouseStartAt = null;
                    }

                    mouseMovements.push(speedPxPerS);
                    if (mouseMovements.length > 20) mouseMovements.shift();
                }
            }

            lastMousePosition = { x: e.clientX, y: e.clientY }; 
            mouseStoppedTime = now; 
        }); 

        document.addEventListener('visibilitychange', () => { 
            if (document.hidden && this.examActive) { 
                this.logViolation('BEHAVIOR', 'Tab/window hidden - possible cheating'); 
            } 
        }); 
    } 

    startMonitoringLoop() { 
        setInterval(() => { 
            if (!this.examActive) return; 

            const widthThreshold = window.outerWidth - window.innerWidth > 160; 
            const heightThreshold = window.outerHeight - window.innerHeight > 160; 

            if (widthThreshold || heightThreshold) { 
                this.logViolation('SECURITY', 'Developer tools detected - possible inspection'); 
            } 

            const userAgent = navigator.userAgent.toLowerCase(); 
            if (userAgent.includes('virtualbox') ||  
                userAgent.includes('vmware') || 
                userAgent.includes('parallels')) { 
                this.logViolation('SECURITY', 'Virtual machine detected'); 
            } 

            if (window.screen.width > 2000) { 
                this.logViolation('SECURITY', 'Wide screen detected - possible multiple monitors'); 
            } 

        }, 5000); 

        setInterval(() => { 
            if (this.examActive) { 
                console.log('Proctoring heartbeat - monitoring active'); 
            } 
        }, 30000); 
    } 

    shouldCountViolation(type, description) {
        if (type === 'CRITICAL') return false;
        if (type === 'SECURITY') return false;
        if (type === 'LOCKDOWN') {
            if (description && description.indexOf('Exited fullscreen mode') !== -1) return true;
            return false;
        }
        return true;
    }

    isInGracePeriod() {
        return (Date.now() - this.examStartAt) < this.gracePeriodMs;
    }

    logViolation(type, description) { 
        if (!this.examActive) return; 

        if (this.isInGracePeriod() && type !== 'CRITICAL') {
            try {
                this.sendViolationToServer({
                    timestamp: new Date().toISOString(),
                    type: type,
                    description: description,
                    examId: window.examId || '0',
                    studentId: window.studentId || '0'
                });
            } catch (e) {}
            return;
        }

        var key = String(type) + '|' + String(description);
        var now = Date.now();
        if (this.lastViolationAt[key] && (now - this.lastViolationAt[key]) < this.violationCooldownMs) {
            return;
        }
        this.lastViolationAt[key] = now;

        const violation = { 
            timestamp: new Date().toISOString(), 
            type: type, 
            description: description, 
            examId: (function(){
                try {
                    var el = document.querySelector('input[name="examId"]');
                    return (el && el.value) ? el.value : window.examId;
                } catch (e) {
                    return window.examId || '0';
                }
            })(),
            studentId: window.studentId || '0' 
        }; 

        this.violations.push(violation); 

        var countThis = this.shouldCountViolation(type, description);
        if (countThis) {
            this.warningCount++; 
        }

        const counter = document.getElementById('violation-counter'); 
        if (counter) counter.textContent = this.warningCount + '/' + this.MAX_WARNINGS; 

        this.captureEvidence(violation); 

        if (countThis) {
            this.showWarning(violation); 
        }

        if (countThis && this.warningCount >= this.MAX_WARNINGS) { 
            this.autoSubmitForCheating(); 
        } else { 
            this.sendViolationToServer(violation); 
        } 
    } 

    async captureEvidence(violation) { 
        if (!this.videoElement || !this.videoElement.videoWidth) return; 

        try { 
            const canvas = document.createElement('canvas'); 
            canvas.width = this.videoElement.videoWidth; 
            canvas.height = this.videoElement.videoHeight; 
            canvas.getContext('2d').drawImage(this.videoElement, 0, 0); 
            violation.screenshot = canvas.toDataURL('image/jpeg', 0.6); 
        } catch (err) {} 
    } 

    showWarning(violation) { 
        const warningModal = document.createElement('div'); 
        warningModal.style.cssText = 'position: fixed; top: 20px; left: 50%; transform: translateX(-50%); background: #fee2e2; border: 2px solid #ef4444; border-radius: 8px; padding: 15px 25px; z-index: 10000; box-shadow: 0 4px 20px rgba(0,0,0,0.3); text-align: center; animation: slideDown 0.3s ease-out;'; 

        warningModal.innerHTML = '<div style="color: #b91c1c; font-weight: bold; margin-bottom: 5px;">' + 
                '⚠️ Proctoring Warning (' + this.warningCount + '/' + this.MAX_WARNINGS + ')' + 
            '</div>' + 
            '<div style="color: #7f1d1d; font-size: 14px;">' + 
                violation.type + ': ' + violation.description + 
            '</div>' + 
            '<div style="color: #991b1b; font-size: 12px; margin-top: 5px;">' + 
                'This incident has been recorded.' + 
            '</div>'; 

        document.body.appendChild(warningModal); 

        const style = document.createElement('style'); 
        style.textContent = ` 
            @keyframes slideDown { 
                from { opacity: 0; transform: translate(-50%, -20px); } 
                to { opacity: 1; transform: translate(-50%, 0); } 
            } 
        `; 
        document.head.appendChild(style); 

        setTimeout(() => { 
            if (warningModal.parentNode) { 
                warningModal.parentNode.removeChild(warningModal); 
            } 
        }, 4000); 
    }

    handleCountdown(timeLost, reason) {
        // Check if face has returned - IMMEDIATE STOP
        const currentFaceLost = Date.now() - this.lastFaceDetected;
        if (currentFaceLost < this.FACE_LOST_THRESHOLD) {
            console.log('✅ Face returned! Stopping countdown immediately');
            this.hideCountdown();
            return;
        }
        
        const remaining = Math.max(0, this.FACE_LOST_MAX_SECONDS - Math.floor(currentFaceLost / 1000));
        
        console.log('⏱️ Countdown:', {
            currentFaceLost: currentFaceLost,
            remaining: remaining,
            maxSeconds: this.FACE_LOST_MAX_SECONDS,
            reason: reason
        });
        
        if (remaining > 0) {
            if (!this.countdownActive) {
                this.showCountdown(remaining, reason);
            } else if (remaining !== this.countdownValue) {
                this.updateCountdown(remaining);
            }
        }

        // Terminate if face is not detected for the full duration
        if (currentFaceLost >= this.FACE_LOST_MAX_SECONDS * 1000) {
            console.log('🚫 Exam terminated - face lost for', this.FACE_LOST_MAX_SECONDS, 'seconds');
            this.autoSubmitForCheating('Face not detected for ' + this.FACE_LOST_MAX_SECONDS + ' seconds');
        }
    }

    autoSubmitForCheating(reason = 'Multiple violations detected') {
        if (this.terminated) return;
        this.terminated = true;
        this.examActive = false;
        this.hideCountdown();

        // Disable all exam controls immediately
        this.disableExamControls();

        // Show termination message with score
        this.showTerminationMessage(reason);

        // Gather all answers immediately
        if (typeof window.gatherAllAnswers === 'function') {
            window.gatherAllAnswers();
        } else if (typeof gatherAllAnswers === 'function') {
            gatherAllAnswers();
        }

        // Mark the submission as terminated so backend saves result_status = 'Terminated'
        try {
            const form = document.getElementById('myform');
            if (form) {
                let terminatedFlag = form.querySelector('input[name="cheating_terminated"]');
                if (!terminatedFlag) {
                    terminatedFlag = document.createElement('input');
                    terminatedFlag.type = 'hidden';
                    terminatedFlag.name = 'cheating_terminated';
                    form.appendChild(terminatedFlag);
                }
                terminatedFlag.value = 'true';

                let reasonInput = form.querySelector('input[name="termination_reason"]');
                if (!reasonInput) {
                    reasonInput = document.createElement('input');
                    reasonInput.type = 'hidden';
                    reasonInput.name = 'termination_reason';
                    form.appendChild(reasonInput);
                }
                reasonInput.value = String(reason || 'Terminated');
            }
        } catch (e) {
            console.warn('Could not append termination flags to form', e);
        }

        // Submit exam automatically
        setTimeout(() => {
            try {
                const form = document.getElementById('myform');
                if (form) {
                    const submitBtn = form.querySelector('[type="submit"]');
                    if (submitBtn) {
                        submitBtn.click();
                    } else {
                        form.submit();
                    }
                }
            } catch (e) {
                console.error('Auto-submit failed:', e);
            }
        }, 2000);
    }

    disableExamControls() {
        try {
            const inputs = document.querySelectorAll('input, select, textarea, button');
            inputs.forEach(input => {
                if (input.type === 'hidden') return;

                if ((input.type === 'radio' || input.type === 'checkbox') && input.checked) {
                    return;
                }

                if (input.tagName && input.tagName.toLowerCase() === 'textarea') {
                    return;
                }

                input.disabled = true;
                input.style.opacity = '0.5';
            });

            if (window.examTimer) {
                clearInterval(window.examTimer);
            }
        } catch (e) {
            console.error('Failed to disable exam controls:', e);
        }
    }

    showTerminationMessage(reason) {
        const modal = document.createElement('div');
        modal.style.cssText = 'position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.9);color:white;z-index:10001;display:flex;align-items:center;justify-content:center;text-align:center;font-family:sans-serif;';
        
        modal.innerHTML = 
            '<div style="background:#dc2626;padding:40px;border-radius:12px;max-width:500px;width:90%;">' +
                '<h1 style="margin:0 0 20px 0;font-size:28px;">🚫 Exam Terminated</h1>' +
                '<p style="margin:0 0 20px 0;font-size:16px;line-height:1.5;">' +
                    'Your exam has been automatically terminated due to multiple proctoring violations.<br><br>' +
                    '<strong>Reason:</strong> ' + reason +
                '</p>' +
                '<p style="margin:0;font-size:14px;opacity:0.8;">' +
                    'This incident has been recorded and will be reviewed by the instructor.' +
                '</p>' +
            '</div>';
        
        document.body.appendChild(modal);
    }

    showCountdown(seconds, reason) {
        this.countdownActive = true;
        this.countdownValue = seconds;
        
        const existing = document.getElementById('proctor-countdown');
        if (existing) existing.remove();

        this.countdownOverlay = document.createElement('div');
        this.countdownOverlay.id = 'proctor-countdown';
        this.countdownOverlay.style.cssText = 'position:fixed;top:0;left:0;width:100%;height:100%;background:rgba(0,0,0,0.85);backdrop-filter:blur(8px);color:white;z-index:10000;display:flex;flex-direction:column;align-items:center;justify-content:center;text-align:center;font-family:sans-serif;';
        
        let guideHtml = '';
        if (reason.indexOf('FACE') !== -1) {
            guideHtml = '<div style="position:relative; width:320px; height:240px; margin-bottom:20px; border:2px solid rgba(255,255,255,0.2); border-radius:12px; overflow:hidden;">' +
                '<div style="position:absolute; top:50%; left:50%; transform:translate(-50%, -50%); width:160px; height:210px; border:3px dashed #ef4444; border-radius:50% 50% 40% 40%; box-shadow: 0 0 0 1000px rgba(0,0,0,0.4); animation: proctorPulse 2s infinite;"></div>' +
                '<div style="position:absolute; bottom:10px; width:100%; text-align:center; font-size:12px; color:#ef4444; font-weight:bold;">ALIGN FACE IN OVAL</div>' +
            '</div>';
        }

        this.countdownOverlay.innerHTML = 
            '<div style="background:rgba(239,68,68,0.9); padding:40px; border-radius:24px; box-shadow:0 20px 50px rgba(0,0,0,0.5); max-width:500px; width:90%; display:flex; flex-direction:column; align-items:center;">' +
                '<h1 style="font-size:32px; margin:0 0 10px 0; color:white; display:flex; align-items:center; gap:15px;"><i class="fas fa-exclamation-triangle"></i> VIOLATION DETECTED</h1>' +
                '<p style="font-size:18px; margin:0 0 20px 0; opacity:0.9;">' + reason + '</p>' +
                guideHtml +
                '<div id="proctor-countdown-value" style="font-size:80px; font-weight:bold; margin:10px 0; line-height:1;">' + seconds + '</div>' +
                '<p style="font-size:16px; margin:20px 0 0 0; font-weight:500;">Please reposition yourself immediately.</p>' +
                '<p style="font-size:14px; margin:10px 0 0 0; opacity:0.8;">The exam will be terminated if you do not return before the timer reaches <strong>0</strong>.</p>' +
            '</div>';
        document.body.appendChild(this.countdownOverlay);

        if (!document.getElementById('proctor-pulse-style')) {
            const style = document.createElement('style');
            style.id = 'proctor-pulse-style';
            style.textContent = '@keyframes proctorPulse { 0%, 100% { opacity: 1; transform: translate(-50%, -50%) scale(1); } 50% { opacity: 0.5; transform: translate(-50%, -50%) scale(1.05); } }';
            document.head.appendChild(style);
        }
    }

    updateCountdown(seconds) {
        this.countdownValue = seconds;
        const countDiv = document.getElementById('proctor-countdown-value');
        if (countDiv) countDiv.textContent = seconds;
    }

    hideCountdown() {
        this.countdownActive = false;
        const overlay = document.getElementById('proctor-countdown');
        if (overlay) {
            overlay.remove();
        }
        this.countdownOverlay = null;
    }

    sendViolationToServer(violation) { 
        const formData = new FormData(); 
        formData.append('page', 'proctoring'); 
        formData.append('operation', 'log_violation'); 
        formData.append('violation_data', JSON.stringify(violation)); 

        if (navigator.sendBeacon) { 
            navigator.sendBeacon('controller.jsp', formData); 
        } else { 
            fetch('controller.jsp', {  
                method: 'POST',  
                body: formData, 
                keepalive: true  
            }).catch(() => {}); 
        } 
    } 

    logToServer(type, message) { 
        const violation = { 
            timestamp: new Date().toISOString(), 
            type: 'INFO', 
            description: message, 
            examId: window.examId || '0', 
            studentId: window.studentId || '0' 
        }; 
        this.sendViolationToServer(violation); 
    } 

    stop() { 
        this.examActive = false; 

        if (this.detectionInterval) { 
            clearInterval(this.detectionInterval); 
        } 

        if (this.audioMonitor) { 
            clearInterval(this.audioMonitor); 
        } 

        if (this.streamHealthInterval) {
            clearInterval(this.streamHealthInterval);
        }

        if (this.fullscreenInterval) {
            clearInterval(this.fullscreenInterval);
        }

        document.removeEventListener('visibilitychange', this.handleVisibilityChange);
        window.removeEventListener('beforeunload', this.handleBeforeUnload);
        window.removeEventListener('pagehide', this.handleBeforeUnload);
        window.removeEventListener('pageshow', this.handlePageShow);

        if (!this.examActive) {
            if (this.audioStream) { 
                this.audioStream.getTracks().forEach(t => t.stop()); 
            } 

            if (this.videoStream) { 
                this.videoStream.getTracks().forEach(t => t.stop()); 
            }

            if (this.sharedStream) {
                this.sharedStream.getTracks().forEach(t => t.stop());
            }
        }

        console.log('🛑 Proctoring stopped'); 
    } 
} 

// Auto-restart proctoring after the exam starts (page navigation/reload stops media streams).
document.addEventListener('DOMContentLoaded', function () {
    try {
        var examForm = document.getElementById('myform');
        if (!examForm) return;

        if (window.proctor) return;

        var shouldAutoStart = false;
        try {
            shouldAutoStart = sessionStorage.getItem('proctorAutoStart') === '1';
        } catch (e) {
            shouldAutoStart = false;
        }

        if (!shouldAutoStart) return;

        try {
            sessionStorage.removeItem('proctorAutoStart');
        } catch (e) {}

        (async function () {
            try {
                var stream = null;
                if (navigator.mediaDevices && navigator.mediaDevices.getUserMedia) {
                    stream = await navigator.mediaDevices.getUserMedia({ 
                        video: { 
                            width: { ideal: 1280 }, 
                            height: { ideal: 720 },
                            frameRate: { ideal: 30 }
                        }, 
                        audio: { 
                            echoCancellation: false, 
                            noiseSuppression: false, 
                            autoGainControl: false 
                        } 
                    });
                }

                var p = new ProctoringSystem();
                window.proctor = p;
                await p.initialize(stream);
            } catch (err) {
                console.error('Auto-start proctoring failed:', err);
            }
        })();
    } catch (outerErr) {
        console.error('Auto-start proctoring setup failed:', outerErr);
    }
});

// Also check for exam start button click to set auto-start flag
document.addEventListener('click', function(e) {
    if (e.target && e.target.id === 'beginExam' || 
        (e.target.tagName === 'BUTTON' && e.target.textContent.includes('Begin Exam'))) {
        try {
            sessionStorage.setItem('proctorAutoStart', '1');
        } catch (e) {}
    }
}, true);