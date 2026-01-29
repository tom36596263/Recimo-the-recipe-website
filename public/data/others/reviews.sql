CREATE TABLE reviews (
    review_id INT NOT NULL,
    reviewer_name VARCHAR(50) NOT NULL,
    reviewer_avatar_url VARCHAR(255) NOT NULL,
    review_comment VARCHAR(255) NOT NULL,
    review_rating DECIMAL(2,1) NOT NULL,
    reviewed_at DATETIME NOT NULL,
    PRIMARY KEY (review_id, review_comment, review_rating)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;