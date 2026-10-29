"""
Verification test script for Student Notes Sharing System.
Creates an SQLite database, executes schema and seed data, and runs sample queries.
"""
import sqlite3
import os

DB_FILE = "notes_sharing.db"

def run_test():
    if os.path.exists(DB_FILE):
        os.remove(DB_FILE)

    print("==> Connecting to SQLite and building database...")
    conn = sqlite3.connect(DB_FILE)
    cursor = conn.cursor()

    # 1. Load schema
    with open("schema_sqlite.sql", "r", encoding="utf-8") as f:
        schema_sql = f.read()
    cursor.executescript(schema_sql)
    print("[OK] Schema created successfully.")

    # 2. Load seed data
    with open("seed_data.sql", "r", encoding="utf-8") as f:
        seed_sql = f.read()
    cursor.executescript(seed_sql)
    print("[OK] Seed data inserted successfully.")

    conn.commit()

    # 3. Query: View approved notes
    print("\n--- [Query 1: Approved Notes with Avg Ratings] ---")
    cursor.execute("""
        SELECT note_id, title, course_code, uploader_name, average_rating, total_reviews, downloads_count
        FROM vw_approved_notes
    """)
    rows = cursor.fetchall()
    for row in rows:
        print(f"ID: {row[0]} | Title: {row[1][:30]}... | Course: {row[2]} | By: {row[3]} | Rating: {row[4]}* ({row[5]} reviews) | Downloads: {row[6]}")

    # 4. Query: User contributions
    print("\n--- [Query 2: Top Contributors] ---")
    cursor.execute("""
        SELECT u.full_name, COUNT(n.note_id) as total_notes, SUM(n.downloads_count) as total_dl
        FROM users u
        JOIN notes n ON u.user_id = n.uploader_id
        WHERE n.status = 'approved'
        GROUP BY u.user_id
        ORDER BY total_dl DESC
    """)
    for row in cursor.fetchall():
        print(f"User: {row[0]} | Uploaded: {row[1]} notes | Total Downloads Received: {row[2]}")

    # 5. Query: Bookmarked notes for user 3 (Rahul)
    print("\n--- [Query 3: Rahul's Bookmarks] ---")
    cursor.execute("""
        SELECT b.bookmark_id, n.title, c.course_code, u.full_name
        FROM bookmarks b
        JOIN notes n ON b.note_id = n.note_id
        JOIN courses c ON n.course_id = c.course_id
        JOIN users u ON n.uploader_id = u.user_id
        WHERE b.user_id = 3
    """)
    for row in cursor.fetchall():
        print(f"Bookmark #{row[0]} | Note: {row[1][:35]} | Course: {row[2]} | Author: {row[3]}")

    conn.close()
    print("\n[OK] All tests passed cleanly! 'notes_sharing.db' is ready for use.")

if __name__ == "__main__":
    run_test()
