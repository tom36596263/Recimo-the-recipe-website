CREATE TABLE browsing_history (
    browsing_history_id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    recipe_id INT NOT NULL,
    viewed_at DATETIME NOT NULL,
    CONSTRAINT fk_history_user_id FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_history_recipe_id FOREIGN KEY (recipe_id) REFERENCES recipes(recipe_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;