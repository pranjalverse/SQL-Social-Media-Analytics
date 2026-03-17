-- Project : Social_Media_Analytics

-- 1.	Find the total number of posts made by each user.
-- 2.	Calculate the average number of likes per post.
-- 3.	Identify the most active user (based on posts, comments, and likes combined).
-- 4.	List all comments on a specific user's posts.
-- 5.	Find users who have not made any posts (inactive users).
-- 6.	Find the post with the highest number of comments.
-- 7.	Calculate the number of new followers gained per user per month.
-- 8.	Identify users who are followed by more than 100 people.
-- 9.	List the top 3 posts with the highest engagement (likes + comments).
-- 10.	Find mutual follows (pairs of users who follow each other).

create database social_media_analytics;
use social_media_analytics;

CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    join_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    bio TEXT
);

INSERT INTO users (user_id, username, join_date, bio) VALUES
(1, 'Aarav', '2024-01-10', 'Tech Enthusiast'),
(2, 'Suhana', '2024-02-15', 'Food Blogger'),
(3, 'Rohan', '2024-03-05', 'Traveler'),
(4, 'Meera', '2024-04-12', 'Student'),
(5, 'Kabir', '2024-05-01', 'Photographer');


CREATE TABLE posts (
    post_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    content TEXT NOT NULL,
    post_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id));


INSERT INTO posts (post_id, user_id, content, post_date) VALUES
(101, 1, 'Exploring AI tools!', '2024-06-01'),
(102, 1, 'My first blog post!', '2024-06-05'),
(103, 2, 'Delicious pasta recipe!', '2024-06-03'),
(104, 3, 'Trip to Manali!', '2024-06-04'),
(105, 4, 'Study tips for exams', '2024-06-06'),
(106, 5, 'Sunset photography', '2024-06-02');


CREATE TABLE comments (
    comment_id INT AUTO_INCREMENT PRIMARY KEY,
    post_id INT NOT NULL,
    user_id INT NOT NULL,
    comment_text TEXT NOT NULL,
    comment_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (post_id) REFERENCES posts(post_id),
  FOREIGN KEY (user_id) REFERENCES users(user_id));

INSERT INTO comments (comment_id, post_id, user_id, comment_text, comment_date) VALUES
(201, 101, 2, 'Very interesting!', '2024-06-02'),
(202, 101, 3, 'Nice post!', '2024-06-02'),
(203, 103, 1, 'Looks tasty!', '2024-06-03'),
(204, 104, 4, 'Beautiful place!', '2024-06-04'),
(205, 104, 2, 'I want to visit too!', '2024-06-05'),
(206, 105, 5, 'Helpful tips!', '2024-06-06');


CREATE TABLE likes (
  like_id INT PRIMARY KEY,
  post_id INT,
  user_id INT,
  like_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (post_id) REFERENCES posts(post_id),
  FOREIGN KEY (user_id) REFERENCES users(user_id));

INSERT INTO likes (like_id, post_id, user_id, like_date) VALUES
(301, 101, 2, '2024-06-02'),
(302, 101, 3, '2024-06-02'),
(303, 103, 1, '2024-06-03'),
(304, 104, 2, '2024-06-04'),
(305, 104, 5, '2024-06-05'),
(306, 106, 1, '2024-06-02'),
(307, 106, 3, '2024-06-03');


CREATE TABLE follows (
  follower_id INT,
  followee_id INT,
  follow_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (follower_id) REFERENCES users(user_id),
  FOREIGN KEY (followee_id) REFERENCES users(user_id));

INSERT INTO follows (follower_id, followee_id, follow_date) VALUES
(1, 2, '2024-05-01'),
(1, 3, '2024-05-03'),
(2, 1, '2024-05-02'),
(2, 3, '2024-05-04'),
(3, 4, '2024-05-05'),
(4, 1, '2024-05-06'),
(5, 2, '2024-05-07');


select * from users;

select * from posts;

select follower_id from follows;

SET FOREIGN_KEY_CHECKS = 0;

TRUNCATE TABLE comments;
TRUNCATE TABLE likes;
TRUNCATE TABLE follows;
TRUNCATE TABLE posts;
TRUNCATE TABLE users;

SET FOREIGN_KEY_CHECKS = 1;





-- 1. Find the total number of posts made by each user.
SELECT
  u.user_id,
  u.username,
  COUNT(p.post_id) AS total_posts
FROM users u
LEFT JOIN posts p ON u.user_id = p.user_id
GROUP BY u.user_id, u.username
ORDER BY total_posts DESC;

-- 2.	Calculate the average number of likes per post.
SELECT
  AVG(like_count) AS avg_likes_per_post
FROM (
  SELECT p.post_id, COUNT(l.like_id) AS like_count
  FROM posts p
  LEFT JOIN likes l ON p.post_id = l.post_id
  GROUP BY p.post_id
) t;


-- 4.	List all comments on a specific user's posts.
SELECT
  c.comment_id,
  c.post_id,
  p.user_id AS post_owner_id,
  u.username AS post_owner,
  cu.user_id   AS commenter_id,
  cu.username  AS commenter_name,
  c.comment_text,
  c.comment_date
FROM comments c
JOIN posts p ON c.post_id = p.post_id
JOIN users cu ON c.user_id = cu.user_id
JOIN users u ON p.user_id = u.user_id
WHERE p.user_id = u.user_id
ORDER BY c.comment_date;

-- 5. Find users who have not made any posts (inactive users).
SELECT
  u.user_id,
  u.username,
  u.join_date
FROM users u
LEFT JOIN posts p ON u.user_id = p.user_id
WHERE p.post_id IS NULL;

-- 6.	Find the post with the highest number of comments.
SELECT
  p.post_id,
  p.content,
  p.user_id,
  u.username,
  COUNT(c.comment_id) AS comments_count
FROM posts p
LEFT JOIN comments c ON p.post_id = c.post_id
JOIN users u ON p.user_id = u.user_id
GROUP BY p.post_id, p.content, p.user_id, u.username
ORDER BY comments_count DESC
LIMIT 1;

-- 7.	Calculate the number of new followers gained per user per month.
SELECT
  f.followee_id AS user_id,
  u.username,
  YEAR(f.follow_date) AS year,
  MONTH(f.follow_date) AS month,
  COUNT(*) AS new_followers
FROM follows f
JOIN users u ON f.followee_id = u.user_id
GROUP BY f.followee_id, YEAR(f.follow_date), MONTH(f.follow_date)
ORDER BY f.followee_id, year, month;

-- 8.	Identify users who are followed by more than 100 people.
SELECT
  f.followee_id AS user_id,
  u.username,
  COUNT(f.follower_id) AS followers_count
FROM follows f
JOIN users u ON f.followee_id = u.user_id
GROUP BY f.followee_id, u.username
HAVING COUNT(f.follower_id) > 100
ORDER BY followers_count DESC;

-- 9.	List the top 3 posts with the highest engagement (likes + comments).
SELECT 
    p.post_id,
    p.content,
    u.username AS author,
    COUNT(l.like_id) AS likes,
    COUNT(c.comment_id) AS comments,
    (COUNT(l.like_id) + COUNT(c.comment_id)) AS engagement
FROM posts p
JOIN users u ON p.user_id = u.user_id
LEFT JOIN likes l ON p.post_id = l.post_id
LEFT JOIN comments c ON p.post_id = c.post_id
GROUP BY p.post_id, p.content, u.username
ORDER BY engagement DESC
LIMIT 3;

-- 10.	Find mutual follows (pairs of users who follow each other).
SELECT 
    f1.follower_id AS user_a,
    f1.followee_id AS user_b
FROM follows f1
JOIN follows f2
  ON f1.follower_id = f2.followee_id
 AND f1.followee_id = f2.follower_id;
 
 


























