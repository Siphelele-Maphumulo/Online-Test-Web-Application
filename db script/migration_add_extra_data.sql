-- Migration to add extra_data column to questions table if it doesn't exist
ALTER TABLE questions ADD COLUMN IF NOT EXISTS extra_data TEXT AFTER image_path;
