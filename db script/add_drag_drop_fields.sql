-- Add drag and drop specific fields to the questions table
ALTER TABLE questions 
ADD COLUMN drag_items TEXT NULL COMMENT 'JSON array of draggable items',
ADD COLUMN drop_targets TEXT NULL COMMENT 'JSON array of drop targets',
ADD COLUMN drag_correct_targets TEXT NULL COMMENT 'JSON array of correct target mappings';

-- Update existing DRAG_AND_DROP questions to have proper structure
UPDATE questions 
SET 
    drag_items = '[]',
    drop_targets = '[]',
    drag_correct_targets = '[]'
WHERE question_type = 'DRAG_AND_DROP' 
AND (drag_items IS NULL OR drop_targets IS NULL OR drag_correct_targets IS NULL);
