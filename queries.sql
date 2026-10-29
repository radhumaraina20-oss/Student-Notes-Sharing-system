-- ============================================================================
-- Student Notes Sharing System - Common & Advanced SQL Queries
-- ============================================================================

-- ----------------------------------------------------------------------------
-- 1. SEARCH & FILTER NOTES (By Department, Semester, and Keyword)
-- ----------------------------------------------------------------------------
-- Search for approved notes in 'CS' department, semester 3 or 4, with keyword 'DSA' or 'Trees'
SELECT 
    n.note_id,
    n.title,
    n.file_type,
    n.file_size_kb,
    c.course_code,
    c.course_name,
    d.dept_code,
    u.full_name AS uploader,
    COALESCE(ROUND(AVG(r.rating), 1), 0) AS avg_rating,
    COUNT(r.review_id) AS total_reviews,
    n.downloads_count
FROM notes n
JOIN courses c ON n.course_id = c.course_id
JOIN departments d ON c.dept_id = d.dept_id
JOIN users u ON n.uploader_id = u.user_id
LEFT JOIN ratings_reviews r ON n.note_id = r.note_id
WHERE n.status = 'approved'
  AND d.dept_code = 'CS'
  AND (n.title LIKE '%DSA%' OR n.title LIKE '%Trees%' OR n.description LIKE '%Trees%')
GROUP BY n.note_id, c.course_id, d.dept_id, u.user_id
ORDER BY n.downloads_count DESC, avg_rating DESC;

-- ----------------------------------------------------------------------------
-- 2. FETCH SINGLE NOTE DETAILS (With tags aggregated)
-- ----------------------------------------------------------------------------
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
    c.course_code,
    c.course_name,
    u.user_id AS uploader_id,
    u.full_name AS uploader_name,
    GROUP_CONCAT(DISTINCT t.tag_name ORDER BY t.tag_name SEPARATOR ', ') AS tags,
    COALESCE(ROUND(AVG(r.rating), 1), 0.0) AS avg_rating,
    COUNT(DISTINCT r.review_id) AS total_reviews
FROM notes n
JOIN courses c ON n.course_id = c.course_id
JOIN users u ON n.uploader_id = u.user_id
LEFT JOIN note_tag_mappings ntm ON n.note_id = ntm.note_id
LEFT JOIN tags t ON ntm.tag_id = t.tag_id
LEFT JOIN ratings_reviews r ON n.note_id = r.note_id
WHERE n.note_id = 1
GROUP BY n.note_id, c.course_id, u.user_id;

-- ----------------------------------------------------------------------------
-- 3. FILTER NOTES BY TAG (e.g. Find all 'cheatsheet' or 'midterm-prep')
-- ----------------------------------------------------------------------------
SELECT 
    n.note_id,
    n.title,
    c.course_code,
    t.tag_name,
    n.downloads_count
FROM notes n
JOIN note_tag_mappings ntm ON n.note_id = ntm.note_id
JOIN tags t ON ntm.tag_id = t.tag_id
JOIN courses c ON n.course_id = c.course_id
WHERE t.tag_name = 'cheatsheet' AND n.status = 'approved'
ORDER BY n.downloads_count DESC;

-- ----------------------------------------------------------------------------
-- 4. STUDENT DASHBOARD: USER'S BOOKMARKED NOTES
-- ----------------------------------------------------------------------------
SELECT 
    b.bookmark_id,
    b.created_at AS bookmarked_on,
    n.note_id,
    n.title,
    n.file_url,
    c.course_code,
    c.course_name,
    u.full_name AS uploaded_by
FROM bookmarks b
JOIN notes n ON b.note_id = n.note_id
JOIN courses c ON n.course_id = c.course_id
JOIN users u ON n.uploader_id = u.user_id
WHERE b.user_id = 3
ORDER BY b.created_at DESC;

-- ----------------------------------------------------------------------------
-- 5. TOP DOWNLOADED NOTES (Platform-wide Hall of Fame)
-- ----------------------------------------------------------------------------
SELECT 
    n.note_id,
    n.title,
    c.course_code,
    u.full_name AS author,
    n.downloads_count,
    COALESCE(ROUND(AVG(r.rating), 1), 0) AS rating
FROM notes n
JOIN courses c ON n.course_id = c.course_id
JOIN users u ON n.uploader_id = u.user_id
LEFT JOIN ratings_reviews r ON n.note_id = r.note_id
WHERE n.status = 'approved'
GROUP BY n.note_id, c.course_id, u.user_id
ORDER BY n.downloads_count DESC
LIMIT 5;

-- ----------------------------------------------------------------------------
-- 6. FETCH THREADED DISCUSSION FOR A NOTE
-- ----------------------------------------------------------------------------
SELECT 
    c.comment_id,
    c.parent_comment_id,
    u.full_name AS commenter_name,
    u.role AS commenter_role,
    c.comment_text,
    c.created_at
FROM comments c
JOIN users u ON c.user_id = u.user_id
WHERE c.note_id = 1
ORDER BY COALESCE(c.parent_comment_id, c.comment_id), c.created_at ASC;

-- ----------------------------------------------------------------------------
-- 7. ADMIN MODERATION: PENDING NOTES QUEUE
-- ----------------------------------------------------------------------------
SELECT 
    n.note_id,
    n.title,
    n.file_type,
    n.file_size_kb,
    c.course_code,
    c.course_name,
    u.full_name AS uploader_name,
    u.email AS uploader_email,
    n.created_at AS submission_date
FROM notes n
JOIN courses c ON n.course_id = c.course_id
JOIN users u ON n.uploader_id = u.user_id
WHERE n.status = 'pending'
ORDER BY n.created_at ASC;

-- ----------------------------------------------------------------------------
-- 8. RECORD A DOWNLOAD & UPDATE STATS (Transactional safe operation)
-- ----------------------------------------------------------------------------
-- Step A: Insert log
-- INSERT INTO note_downloads (note_id, user_id, ip_address) VALUES (1, 3, '192.168.1.55');
-- Step B: Increment counter
-- UPDATE notes SET downloads_count = downloads_count + 1 WHERE note_id = 1;

