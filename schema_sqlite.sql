-- ============================================================================
-- Student Notes Sharing System - SQLite Compatible Schema
-- ============================================================================

PRAGMA foreign_keys = ON;

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

-- 1. USERS TABLE
CREATE TABLE users (
    user_id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL UNIQUE,
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    full_name TEXT NOT NULL,
    role TEXT CHECK(role IN ('student', 'faculty', 'admin')) DEFAULT 'student',
    institution_name TEXT,
    bio TEXT,
    avatar_url TEXT,
    is_active INTEGER DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 2. DEPARTMENTS TABLE
CREATE TABLE departments (
    dept_id INTEGER PRIMARY KEY AUTOINCREMENT,
    dept_code TEXT NOT NULL UNIQUE,
    dept_name TEXT NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. COURSES TABLE
CREATE TABLE courses (
    course_id INTEGER PRIMARY KEY AUTOINCREMENT,
    dept_id INTEGER NOT NULL,
    course_code TEXT NOT NULL UNIQUE,
    course_name TEXT NOT NULL,
    semester INTEGER CHECK (semester BETWEEN 1 AND 8),
    academic_year TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (dept_id) REFERENCES departments(dept_id) ON DELETE CASCADE
);

-- 4. NOTES TABLE
CREATE TABLE notes (
    note_id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    description TEXT,
    course_id INTEGER NOT NULL,
    uploader_id INTEGER NOT NULL,
    file_url TEXT NOT NULL,
    file_type TEXT NOT NULL,
    file_size_kb INTEGER NOT NULL,
    total_pages INTEGER,
    semester INTEGER CHECK (semester BETWEEN 1 AND 8),
    academic_year TEXT,
    status TEXT CHECK(status IN ('pending', 'approved', 'rejected')) DEFAULT 'pending',
    views_count INTEGER DEFAULT 0,
    downloads_count INTEGER DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (course_id) REFERENCES courses(course_id) ON DELETE RESTRICT,
    FOREIGN KEY (uploader_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- 5. TAGS & MAPPINGS
CREATE TABLE tags (
    tag_id INTEGER PRIMARY KEY AUTOINCREMENT,
    tag_name TEXT NOT NULL UNIQUE
);

CREATE TABLE note_tag_mappings (
    note_id INTEGER NOT NULL,
    tag_id INTEGER NOT NULL,
    PRIMARY KEY (note_id, tag_id),
    FOREIGN KEY (note_id) REFERENCES notes(note_id) ON DELETE CASCADE,
    FOREIGN KEY (tag_id) REFERENCES tags(tag_id) ON DELETE CASCADE
);

-- 6. RATINGS & REVIEWS TABLE
CREATE TABLE ratings_reviews (
    review_id INTEGER PRIMARY KEY AUTOINCREMENT,
    note_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    rating INTEGER NOT NULL CHECK (rating BETWEEN 1 AND 5),
    review_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (note_id, user_id),
    FOREIGN KEY (note_id) REFERENCES notes(note_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- 7. COMMENTS TABLE
CREATE TABLE comments (
    comment_id INTEGER PRIMARY KEY AUTOINCREMENT,
    note_id INTEGER NOT NULL,
    user_id INTEGER NOT NULL,
    parent_comment_id INTEGER DEFAULT NULL,
    comment_text TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (note_id) REFERENCES notes(note_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (parent_comment_id) REFERENCES comments(comment_id) ON DELETE CASCADE
);

-- 8. BOOKMARKS TABLE
CREATE TABLE bookmarks (
    bookmark_id INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id INTEGER NOT NULL,
    note_id INTEGER NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE (user_id, note_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (note_id) REFERENCES notes(note_id) ON DELETE CASCADE
);

-- 9. NOTE DOWNLOADS LOG
CREATE TABLE note_downloads (
    download_id INTEGER PRIMARY KEY AUTOINCREMENT,
    note_id INTEGER NOT NULL,
    user_id INTEGER DEFAULT NULL,
    ip_address TEXT,
    downloaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (note_id) REFERENCES notes(note_id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL
);

-- 10. REPORT LOGS
CREATE TABLE report_logs (
    report_id INTEGER PRIMARY KEY AUTOINCREMENT,
    note_id INTEGER NOT NULL,
    reported_by INTEGER NOT NULL,
    reason TEXT CHECK(reason IN ('copyright', 'inappropriate', 'poor_quality', 'wrong_subject', 'other')) NOT NULL,
    details TEXT,
    status TEXT CHECK(status IN ('pending', 'reviewed', 'resolved', 'dismissed')) DEFAULT 'pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (note_id) REFERENCES notes(note_id) ON DELETE CASCADE,
    FOREIGN KEY (reported_by) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Indexes for performance
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_courses_dept ON courses(dept_id);
CREATE INDEX idx_courses_code ON courses(course_code);
CREATE INDEX idx_notes_course ON notes(course_id);
CREATE INDEX idx_notes_uploader ON notes(uploader_id);
CREATE INDEX idx_notes_status ON notes(status);
CREATE INDEX idx_ratings_note ON ratings_reviews(note_id);
CREATE INDEX idx_comments_note ON comments(note_id);
CREATE INDEX idx_downloads_note ON note_downloads(note_id);

-- View: Approved Notes Summary
CREATE VIEW IF NOT EXISTS vw_approved_notes AS
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
GROUP BY n.note_id;

