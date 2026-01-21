<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <title>Test Image Upload</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 600px;
            margin: 50px auto;
            padding: 20px;
        }
        .form-group {
            margin-bottom: 15px;
        }
        label {
            display: block;
            margin-bottom: 5px;
            font-weight: bold;
        }
        input[type="text"], textarea, select {
            width: 100%;
            padding: 8px;
            border: 1px solid #ccc;
            border-radius: 4px;
            box-sizing: border-box;
        }
        .drop-zone {
            border: 2px dashed #ccc;
            border-radius: 4px;
            padding: 20px;
            text-align: center;
            cursor: pointer;
            margin-bottom: 10px;
        }
        .drop-zone.drag-over {
            border-color: #4a90e2;
            background-color: #f0f8ff;
        }
        .file-name-display {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 10px;
            background-color: #e8f4fd;
            border: 1px solid #b3d9ff;
            border-radius: 4px;
            margin-top: 10px;
        }
        .remove-file-btn {
            background: #ff6b6b;
            color: white;
            border: none;
            border-radius: 50%;
            width: 24px;
            height: 24px;
            cursor: pointer;
            font-size: 16px;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        .btn {
            background-color: #4CAF50;
            color: white;
            padding: 10px 20px;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            font-size: 16px;
        }
        .btn:hover {
            background-color: #45a049;
        }
    </style>
</head>
<body>
    <h1>Test Image Upload for Questions</h1>
    
    <form action="controller.jsp" method="post" enctype="multipart/form-data">
        <input type="hidden" name="page" value="questions">
        <input type="hidden" name="operation" value="addnew">
        
        <div class="form-group">
            <label for="question">Question:</label>
            <textarea id="question" name="question" rows="4" required></textarea>
        </div>
        
        <div class="form-group">
            <label for="opt1">Option 1:</label>
            <input type="text" id="opt1" name="opt1" required>
        </div>
        
        <div class="form-group">
            <label for="opt2">Option 2:</label>
            <input type="text" id="opt2" name="opt2" required>
        </div>
        
        <div class="form-group">
            <label for="opt3">Option 3:</label>
            <input type="text" id="opt3" name="opt3">
        </div>
        
        <div class="form-group">
            <label for="opt4">Option 4:</label>
            <input type="text" id="opt4" name="opt4">
        </div>
        
        <div class="form-group">
            <label for="correct">Correct Answer:</label>
            <input type="text" id="correct" name="correct" required>
        </div>
        
        <div class="form-group">
            <label for="coursename">Course:</label>
            <select id="coursename" name="coursename" required>
                <option value="">Select Course</option>
                <option value="Mathematics">Mathematics</option>
                <option value="Science">Science</option>
                <option value="English">English</option>
            </select>
        </div>
        
        <div class="form-group">
            <label for="questionType">Question Type:</label>
            <select id="questionType" name="questionType">
                <option value="MCQ">Multiple Choice</option>
                <option value="TrueFalse">True/False</option>
            </select>
        </div>
        
        <!-- Image Upload Section -->
        <div class="form-group">
            <label>Upload Question Image (Optional):</label>
            <div class="drop-zone" id="imageDropZone">
                <div class="drop-zone-content">
                    <p>Drag & drop your image here or click to browse</p>
                    <p style="font-size: 12px; color: #666;">Supports JPG, PNG, GIF (Max 3MB)</p>
                    <input type="file" name="imageFile" id="imageFile" accept=".jpg,.jpeg,.png,.gif" style="display: none;">
                </div>
            </div>
            <div id="imageFileNameDisplay" class="file-name-display" style="display: none;">
                <span id="imageFileName"></span>
                <button type="button" class="remove-file-btn" onclick="removeImageFile()">×</button>
            </div>
        </div>
        
        <button type="submit" class="btn">Add Question</button>
    </form>

    <script>
        function initImageUpload() {
            const imageFileInput = document.getElementById('imageFile');
            const imageDropZone = document.getElementById('imageDropZone');
            
            if (imageFileInput && imageDropZone) {
                // Click to browse
                imageDropZone.addEventListener('click', () => {
                    imageFileInput.click();
                });
                
                // File input change
                imageFileInput.addEventListener('change', function() {
                    if (this.files && this.files[0]) {
                        displayImageFileName(this.files[0]);
                    }
                });
                
                // Drag and drop events
                ['dragenter', 'dragover', 'dragleave', 'drop'].forEach(eventName => {
                    imageDropZone.addEventListener(eventName, preventImageDefaults, false);
                });
                
                function preventImageDefaults(e) {
                    e.preventDefault();
                    e.stopPropagation();
                }
                
                ['dragenter', 'dragover'].forEach(eventName => {
                    imageDropZone.addEventListener(eventName, highlightImage, false);
                });
                
                ['dragleave', 'drop'].forEach(eventName => {
                    imageDropZone.addEventListener(eventName, unhighlightImage, false);
                });
                
                function highlightImage() {
                    imageDropZone.classList.add('drag-over');
                }
                
                function unhighlightImage() {
                    imageDropZone.classList.remove('drag-over');
                }
                
                imageDropZone.addEventListener('drop', handleImageDrop, false);
                
                function handleImageDrop(e) {
                    const dt = e.dataTransfer;
                    const files = dt.files;
                    
                    if (files.length > 0) {
                        const file = files[0];
                        // Check if it's an image file
                        if (file.type.match('image.*')) {
                            // Set the file to the hidden input
                            const dataTransfer = new DataTransfer();
                            dataTransfer.items.add(file);
                            imageFileInput.files = dataTransfer.files;
                            displayImageFileName(file);
                        } else {
                            alert('Please select an image file (JPG, PNG, GIF).');
                        }
                    }
                }
                
                function displayImageFileName(file) {
                    const imageFileNameDisplay = document.getElementById('imageFileNameDisplay');
                    const imageFileNameSpan = document.getElementById('imageFileName');
                    
                    imageFileNameSpan.textContent = file.name;
                    imageFileNameDisplay.style.display = 'flex';
                    imageDropZone.style.display = 'none';
                }
            }
        }
        
        function removeImageFile() {
            const imageFileInput = document.getElementById('imageFile');
            const imageFileNameDisplay = document.getElementById('imageFileNameDisplay');
            const imageDropZone = document.getElementById('imageDropZone');
            
            // Reset file input
            imageFileInput.value = '';
            
            // Hide file name display and show drop zone
            imageFileNameDisplay.style.display = 'none';
            imageDropZone.style.display = 'block';
        }
        
        // Initialize image upload functionality when page loads
        document.addEventListener('DOMContentLoaded', function() {
            initImageUpload();
        });
    </script>
</body>
</html>