CREATE TABLE announcement (
    announcement_id INT NOT NULL AUTO_INCREMENT,
    announcement_type VARCHAR(50) NOT NULL,
    announcement_title VARCHAR(255) NOT NULL,
    announcement_content VARCHAR(1000) NOT NULL,
    announcement_photo_url VARCHAR(255) NOT NULL,
    announced_at DATETIME NOT NULL,
    PRIMARY KEY (announcement_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;