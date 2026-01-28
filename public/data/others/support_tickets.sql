CREATE TABLE support_tickets (
    ticket_id INT NOT NULL PRIMARY KEY,
    user_id INT,
    user_name VARCHAR(50) NOT NULL,
    user_email VARCHAR(50) NOT NULL,
    ticket_type TINYINT NOT NULL,
    ticket_subject VARCHAR(255) NOT NULL,
    ticket_content VARCHAR(1000) NOT NULL,
    status TINYINT,
    reply_content VARCHAR(1000),
    created_at DATETIME NOT NULL,
    replied_at DATETIME,
    CONSTRAINT fk_tickets_user_id FOREIGN KEY (user_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;