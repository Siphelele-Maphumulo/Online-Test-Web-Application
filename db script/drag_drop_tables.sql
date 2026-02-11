-- Drag and Drop Question Type Tables
-- Add question_type column to questions table if it doesn't exist
ALTER TABLE questions 
ADD COLUMN IF NOT EXISTS question_type VARCHAR(50) DEFAULT 'MCQ',
ADD COLUMN IF NOT EXISTS total_marks INT DEFAULT 1,
ADD COLUMN IF NOT EXISTS image_path VARCHAR(255);

-- Create drag_items table for draggable items
CREATE TABLE IF NOT EXISTS drag_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    question_id INT NOT NULL,
    item_text TEXT NOT NULL,
    correct_target_id INT,
    item_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (question_id) REFERENCES questions(question_id) ON DELETE CASCADE
);

-- Create drop_targets table for drop zones
CREATE TABLE IF NOT EXISTS drop_targets (
    id INT AUTO_INCREMENT PRIMARY KEY,
    question_id INT NOT NULL,
    target_label VARCHAR(255) NOT NULL,
    target_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (question_id) REFERENCES questions(question_id) ON DELETE CASCADE
);

-- Create drag_drop_answers table for student submissions
CREATE TABLE IF NOT EXISTS drag_drop_answers (
    id INT AUTO_INCREMENT PRIMARY KEY,
    exam_id INT NOT NULL,
    question_id INT NOT NULL,
    student_id VARCHAR(45) NOT NULL,
    drag_item_id INT NOT NULL,
    drop_target_id INT NOT NULL,
    is_correct BOOLEAN DEFAULT FALSE,
    marks_obtained FLOAT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (question_id) REFERENCES questions(question_id) ON DELETE CASCADE,
    FOREIGN KEY (drag_item_id) REFERENCES drag_items(id) ON DELETE CASCADE,
    FOREIGN KEY (drop_target_id) REFERENCES drop_targets(id) ON DELETE CASCADE,
    UNIQUE KEY unique_answer (exam_id, question_id, student_id, drag_item_id)
);

-- Update existing questions to have question_type if null
UPDATE questions SET question_type = 'MCQ' WHERE question_type IS NULL;
