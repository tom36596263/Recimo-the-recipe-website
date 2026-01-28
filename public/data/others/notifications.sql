CREATE TABLE notifications (
    notification_id INT NOT NULL PRIMARY KEY,
    notification_type VARCHAR(50) NOT NULL,
    notification_title VARCHAR(255) NOT NULL,
    notification_content VARCHAR(1000) NOT NULL,
    notification_photo_url VARCHAR(255) NOT NULL,
    link_url VARCHAR(255),
    created_at DATETIME NOT NULL,
    receiver_id INT NOT NULL,
    sender_id INT,
    is_read BOOLEAN NOT NULL,
    CONSTRAINT fk_notifications_receiver FOREIGN KEY (receiver_id) REFERENCES users(user_id),
    CONSTRAINT fk_notifications_sender FOREIGN KEY (sender_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;