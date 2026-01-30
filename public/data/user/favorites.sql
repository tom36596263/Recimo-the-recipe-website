CREATE TABLE favorites (
    favorite_id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    recipe_id INT NOT NULL,
    folder_id INT,
    like_at DATETIME NOT NULL,
    CONSTRAINT fk_favorites_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_favorites_recipe FOREIGN KEY (recipe_id) REFERENCES recipes(recipe_id),
    CONSTRAINT fk_favorites_folder FOREIGN KEY (folder_id) REFERENCES favorites_folders(favorites_folder_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;