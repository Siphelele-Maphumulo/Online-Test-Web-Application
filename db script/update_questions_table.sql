-- Update questions table to add missing columns
-- This script adds the question_type, image_path, and extra_data columns

ALTER TABLE `questions` 
ADD COLUMN `question_type` VARCHAR(45) DEFAULT NULL AFTER `correct`,
ADD COLUMN `image_path` VARCHAR(255) DEFAULT NULL AFTER `question_type`,
ADD COLUMN `extra_data` TEXT DEFAULT NULL AFTER `image_path`;

-- Verify the changes
DESCRIBE `questions`;

-- Test the new structure with a sample insert
INSERT INTO `questions` (course_name, question, opt1, opt2, opt3, opt4, correct, question_type, image_path, extra_data) 
VALUES ('Test Course', 'Sample question', 'Option A', 'Option B', 'Option C', 'Option D', 'A', 'MultipleChoice', NULL, 'Sample extra data');

-- Verify the insert worked
SELECT * FROM `questions` WHERE course_name = 'Test Course';

-- Clean up test data
DELETE FROM `questions` WHERE course_name = 'Test Course';