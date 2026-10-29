-- ============================================================================
-- Student Notes Sharing System - Database Schema
-- Compatible with: MySQL 8.0+, PostgreSQL 12+, MariaDB 10.5+
-- ============================================================================

-- Create Database (Optional, uncomment if creating a new database)
-- CREATE DATABASE IF NOT EXISTS notes_sharing_db;
-- USE notes_sharing_db;

-- ----------------------------------------------------------------------------
-- Drop tables if they exist (in reverse order of dependencies)
-- ----------------------------------------------------------------------------
DROP TABLE IF EXISTS report_logs;
DROP TABLE IF EXISTS note_downloads;
DROP TABLE IF EXISTS bookmarks;
DROP TABLE IF EXISTS comments;
DROP TABLE IF EXISTS ratings_reviews;
DROP TABLE IF EXISTS note_tag_mappings;
DROP TABLE IF EXISTS tags;
DROP TABLE IF EXISTS notes;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS departments;
DROP TABLE IF EXISTS users;

-- ----------------------------------------------------------------------------
-- 1. USERS TABLE
-- Stores details of students, instructors, and system administrators.
-- ----------------------------------------------------------------------------
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    role ENUM('student', 'faculty', 'admin') DEFAULT 'student',
    institution_name VARCHAR(150),
    bio TEXT,
    avatar_url VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_users_role (role),
    INDEX idx_users_email (email)
);

-- ----------------------------------------------------------------------------
-- 2. DEPARTMENTS TABLE
-- Academic departments (e.g., Computer Science, Electrical Engineering).
-- ----------------------------------------------------------------------------
CREATE TABLE departments (
    dept_id INT AUTO_INCREMENT PRIMARY KEY,
    dept_code VARCHAR(10) NOT NULL UNIQUE,
    dept_name VARCHAR(100) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ----------------------------------------------------------------------------
-- 3. COURSES / SUBJECTS TABLE
-- Specific courses belonging to a department.
-- ----------------------------------------------------------------------------
CREATE TABLE courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    dept_id INT NOT NULL,
    course_code VARCHAR(20) NOT NULL UNIQUE,
    course_name VARCHAR(150) NOT NULL,
    semester INT CHECK (semester BETWEEN 1 AND 8),
    academic_year VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id) ON DELETE CASCADE,
    INDEX idx_courses_dept (dept_id),
    INDEX idx_courses_code (course_code)
);

-- ----------------------------------------------------------------------------
-- 4. NOTES TABLE
-- Core table storing metadata and file references for shared notes.
-- ----------------------------------------------------------------------------
CREATE TABLE notes (
    note_id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    description TEXT,
    course_id INT NOT NULL,
    uploader_id INT NOT NULL,
    file_url VARCHAR(500) NOT NULL,
    file_type VARCHAR(10) NOT NULL,      -- e.g., 'pdf', 'docx', 'pptx', 'zip'
    file_size_kb INT NOT NULL,           -- file size in kilobytes
    total_pages INT DEFAULT NULL,
    semester INT CHECK (semester BETWEEN 1 AND 8),
    academic_year VARCHAR(20),           -- e.g., '2023-2024'
    status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    views_count INT UNSIGNED DEFAULT 0,
    downloads_count INT UNSIGNED DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE RESTRICT,
    FOREIGN KEY (uploader_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_notes_course (course_id),
    INDEX idx_notes_uploader (uploader_id),
    INDEX idx_notes_status (status),
    FULLTEXT idx_notes_search (title, description)
);

-- ----------------------------------------------------------------------------
-- 5. TAGS & MAPPINGS (M-N Relationship)
-- Helps categorize notes by keywords (e.g., 'algorithms', 'midterm', 'cheat-sheet').
-- ----------------------------------------------------------------------------
CREATE TABLE tags (
    tag_id INT AUTO_INCREMENT PRIMARY KEY,
    tag_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE note_tag_mappings (
    note_id INT NOT NULL,
    tag_id INT NOT NULL,
    PRIMARY KEY (note_id, tag_id),
    FOREIGN KEY (note_id) REFERENCES notes(note_id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES tags(tag_id) ON DELETE CASCADE
);

-- ----------------------------------------------------------------------------
-- 6. RATINGS & REVIEWS TABLE
-- Students can rate (1 to 5 stars) and review notes.
-- ----------------------------------------------------------------------------
CREATE TABLE ratings_reviews (
    review_id INT AUTO_INCREMENT PRIMARY KEY,
    note_id INT NOT NULL,
    user_id INT NOT NULL,
    rating TINYINT NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY uq_user_note_review (note_id, user_id),
    FOREIGN KEY (note_id) REFERENCES notes(note_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_ratings_note (note_id)
);

-- ----------------------------------------------------------------------------
-- 7. COMMENTS TABLE (Discussion thread)
-- Questions or remarks on specific notes, supporting nested replies.
-- ----------------------------------------------------------------------------
CREATE TABLE comments (
    comment_id INT AUTO_INCREMENT PRIMARY KEY,
    note_id INT NOT NULL,
    user_id INT NOT NULL,
    parent_comment_id INT DEFAULT NULL,  -- For nested/threaded comments
    comment_text TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (note_id) REFERENCES notes(note_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (parent_comment_id) REFERENCES comments(comment_id) ON DELETE CASCADE,
    INDEX idx_comments_note (note_id)
);

-- ----------------------------------------------------------------------------
-- 8. BOOKMARKS TABLE
-- Saved notes for quick access in student dashboard.
-- ----------------------------------------------------------------------------
CREATE TABLE bookmarks (
    bookmark_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    note_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uq_user_note_bookmark (user_id, note_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (note_id) REFERENCES notes(note_id) ON DELETE CASCADE
);

-- ----------------------------------------------------------------------------
-- 9. NOTE DOWNLOADS LOG
-- Audit trail to count downloads accurately and prevent spoofing.
-- ----------------------------------------------------------------------------
CREATE TABLE note_downloads (
    download_id INT AUTO_INCREMENT PRIMARY KEY,
    note_id INT NOT NULL,
    user_id INT DEFAULT NULL,            -- Can be NULL if guest downloads are permitted
    ip_address VARCHAR(45),
    downloaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (note_id) REFERENCES notes(note_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    INDEX idx_downloads_note (note_id)
);

-- ----------------------------------------------------------------------------
-- 10. REPORT LOGS (Moderation)
-- Flags for copyright violations, incorrect content, spam, etc.
-- ----------------------------------------------------------------------------
CREATE TABLE report_logs (
    report_id INT AUTO_INCREMENT PRIMARY KEY,
    note_id INT NOT NULL,
    reported_by INT NOT NULL,
    reason ENUM('copyright', 'inappropriate', 'poor_quality', 'wrong_subject', 'other') NOT NULL,
    details TEXT,
    status ENUM('pending', 'reviewed', 'resolved', 'dismissed') DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (note_id) REFERENCES notes(note_id) ON DELETE CASCADE,
    FOREIGN KEY (reported_by) REFERENCES users(user_id) ON DELETE CASCADE
);

-- ============================================================================
-- VIEWS FOR EASY DATA ACCESS & DASHBOARDS
-- ============================================================================

-- View: Approved Notes with Course, Uploader, and Average Rating
CREATE OR REPLACE VIEW vw_approved_notes AS
SELECT 
    n.note_id,
    n.title,
    n.description,
    n.file_url,
    n.file_type,
    n.file_size_kb,
    n.total_pages,
    n.views_count,
    n.downloads_count,
    n.created_at,
    c.course_code,
    c.course_name,
    c.semester,
    d.dept_code,
    d.dept_name,
    u.user_id AS uploader_id,
    u.username AS uploader_username,
    u.full_name AS uploader_name,
    COALESCE(ROUND(AVG(r.rating), 1), 0.0) AS average_rating,
    COUNT(r.review_id) AS total_reviews
FROM notes n
JOIN courses c ON n.course_id = c.course_id
JOIN departments d ON c.dept_id = d.dept_id
JOIN users u ON n.uploader_id = u.user_id
LEFT JOIN ratings_reviews r ON n.note_id = r.note_id
WHERE n.status = 'approved'
GROUP BY n.note_id, c.course_id, d.dept_id, u.user_id;

-- View: User Contribution Leaderboard
CREATE OR REPLACE VIEW vw_contributor_leaderboard AS
SELECT 
    u.user_id,
    u.username,
    u.full_name,
    u.institution_name,
    COUNT(DISTINCT n.note_id) AS total_notes_uploaded,
    COALESCE(SUM(n.downloads_count), 0) AS total_downloads_received,
    COALESCE(ROUND(AVG(r.rating), 2), 0.0) AS avg_content_rating
FROM users u
JOIN notes n ON u.user_id = n.uploader_id AND n.status = 'approved'
LEFT JOIN ratings_reviews r ON n.note_id = r.note_id
GROUP BY u.user_id
ORDER BY total_downloads_received DESC, total_notes_uploaded DESC;

