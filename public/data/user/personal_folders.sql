CREATE TABLE personal_folders (
    personal_folder_id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    creator_id INT NOT NULL,
    folder_name VARCHAR(50) NOT NULL,
    created_at DATETIME NOT NULL,
    CONSTRAINT fk_personal_folders_creator FOREIGN KEY (creator_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;