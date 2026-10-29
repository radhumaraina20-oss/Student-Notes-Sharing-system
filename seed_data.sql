-- ============================================================================
-- Sample Seed Data for Student Notes Sharing System
-- ============================================================================

-- 1. Insert Departments
INSERT INTO departments (dept_code, dept_name, description) VALUES
('CS', 'Computer Science & Engineering', 'Software, Algorithms, Data Systems, and AI'),
('EE', 'Electrical & Electronics Engineering', 'Circuits, Power Systems, and Signal Processing'),
('ME', 'Mechanical Engineering', 'Thermodynamics, Mechanics, and Design'),
('MATH', 'Mathematics & Computing', 'Applied Calculus, Linear Algebra, and Discrete Math');

-- 2. Insert Users
INSERT INTO users (username, email, password_hash, full_name, role, institution_name, bio) VALUES
('admin_alex', 'alex.admin@university.edu', '$2b$12$e8YkYk4qR.8nK9zHnF9/E.fL/qO5GzC9WjT2l.u5yH6R2m1k4O6P', 'Alex Mercer', 'admin', 'Apex Institute of Technology', 'System Administrator'),
('sarah_c', 'sarah.c@university.edu', '$2b$12$J9gV.8p9kY2qZ7nF1/E.eL/qO5GzC9WjT2l.u5yH6R2m1k4O6P', 'Sarah Chen', 'student', 'Apex Institute of Technology', 'Sophomore CS Major passionate about Systems and AI.'),
('rahul_k', 'rahul.sharma@university.edu', '$2b$12$K1rF.7x8lZ3mP0qA2/W.rL/tO4BvX8YkS1l.v4xG5Q1l0j3N5M', 'Rahul Sharma', 'student', 'Apex Institute of Technology', 'Junior in Electrical Engineering. Sharing lab manuals & notes.'),
('prof_miller', 'miller.prof@university.edu', '$2b$12$L2sG.9y9ma4nQ1rB3/X.sM/uP5CwY9ZlT2m.w5yH6R2m1k4O6P', 'Dr. David Miller', 'faculty', 'Apex Institute of Technology', 'Professor of Computer Science & Discrete Structures.'),
('emily_w', 'emily.watson@university.edu', '$2b$12$M3tH.0z0nb5oR2sC4/Y.tN/vQ6DxZ0AmU3n.x6zI7S3n2l5P7Q', 'Emily Watson', 'student', 'Apex Institute of Technology', 'Freshman preparing study guides for Math & Physics.');

-- 3. Insert Courses
INSERT INTO courses (dept_id, course_code, course_name, semester, academic_year) VALUES
(1, 'CS101', 'Data Structures & Algorithms', 3, '2023-2024'),
(1, 'CS202', 'Database Management Systems', 4, '2023-2024'),
(1, 'CS305', 'Operating Systems', 5, '2024-2025'),
(2, 'EE201', 'Signals and Systems', 3, '2023-2024'),
(4, 'MATH101', 'Calculus and Linear Algebra', 1, '2023-2024');

-- 4. Insert Tags
INSERT INTO tags (tag_name) VALUES
('midterm-prep'),
('final-exam'),
('cheatsheet'),
('handwritten'),
('lecture-slides'),
('lab-manual'),
('solved-problems');

-- 5. Insert Notes
INSERT INTO notes (title, description, course_id, uploader_id, file_url, file_type, file_size_kb, total_pages, semester, academic_year, status, views_count, downloads_count) VALUES
('Complete DSA Handwritten Notes (Trees & Graphs)', 'Comprehensive handwritten summary for mid-terms covering BST, AVL, DFS, BFS, and Dijkstra algorithm with dry runs.', 1, 2, 'https://cdn.example.com/notes/cs101_trees_graphs.pdf', 'pdf', 4520, 32, 3, '2023-2024', 'approved', 340, 112),
('DBMS SQL Query Cheat Sheet & Normalization Guide', 'Quick reference for complex joins, subqueries, group by, 1NF to BCNF rules, and ACID transaction properties.', 2, 2, 'https://cdn.example.com/notes/cs202_dbms_cheatsheet.pdf', 'pdf', 1840, 12, 4, '2023-2024', 'approved', 520, 245),
('Operating Systems - Process Scheduling & Deadlocks', 'Detailed notes on Round Robin, Priority, Banker algorithm, and memory management (Paging & Segmentation).', 3, 4, 'https://cdn.example.com/notes/cs305_os_module1_3.pdf', 'pdf', 6200, 48, 5, '2024-2025', 'approved', 190, 68),
('Signals and Systems Fourier Transform Practice Problems', 'Step-by-step solved problems on Continuous and Discrete Time Fourier Transforms for Unit 3 exams.', 4, 3, 'https://cdn.example.com/notes/ee201_fourier_solved.pdf', 'pdf', 3150, 24, 3, '2023-2024', 'approved', 145, 41),
('Calculus I Summary Formulas & Derivatives', 'One-sheet review of limits, derivative rules, integration tables, and matrix eigenvalues.', 5, 5, 'https://cdn.example.com/notes/math101_formulas.docx', 'docx', 980, 6, 1, '2023-2024', 'pending', 25, 4);

-- 6. Link Tags to Notes
INSERT INTO note_tag_mappings (note_id, tag_id) VALUES
(1, 1), -- Note 1: midterm-prep
(1, 4), -- Note 1: handwritten
(2, 1), -- Note 2: midterm-prep
(2, 3), -- Note 2: cheatsheet
(3, 5), -- Note 3: lecture-slides
(4, 7), -- Note 4: solved-problems
(5, 3); -- Note 5: cheatsheet

-- 7. Insert Ratings and Reviews
INSERT INTO ratings_reviews (note_id, user_id, rating, review_text) VALUES
(1, 3, 5, 'Crystal clear handwriting and tree rotation diagrams saved my midterms! 10/10.'),
(1, 5, 4, 'Great notes, loved the BFS/DFS algorithm comparison tables.'),
(2, 3, 5, 'The normalization examples made BCNF so easy to understand.'),
(2, 4, 5, 'Very clean reference sheet. I recommend this to my students.'),
(3, 2, 4, 'Good coverage of memory paging and TLB caching.');

-- 8. Insert Comments
INSERT INTO comments (note_id, user_id, parent_comment_id, comment_text) VALUES
(1, 3, NULL, 'Does this note also cover Red-Black Tree delete operations?'),
(1, 2, 1, 'It covers insertion and coloring rules, but deletion is only briefly outlined in Appendix A.');

-- 9. Insert Bookmarks
INSERT INTO bookmarks (user_id, note_id) VALUES
(3, 1),
(3, 2),
(5, 1),
(2, 3);

-- 10. Insert Download Logs
INSERT INTO note_downloads (note_id, user_id, ip_address) VALUES
(1, 3, '192.168.1.101'),
(1, 5, '192.168.1.102'),
(2, 3, '192.168.1.101'),
(2, 4, '192.168.1.150'),
(3, 2, '192.168.1.103');

