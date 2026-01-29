CREATE TABLE favorites_folders (
    favorites_folder_id INT NOT NULL PRIMARY KEY,
    creator_id INT NOT NULL,
    folder_name VARCHAR(50) NOT NULL,
    created_at DATETIME NOT NULL,
    CONSTRAINT fk_favorites_folders_creator FOREIGN KEY (creator_id) REFERENCES users(user_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;