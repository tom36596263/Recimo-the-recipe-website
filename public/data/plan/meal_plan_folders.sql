-- 創建資料夾_備餐計畫資料表
CREATE TABLE meal_plan_folders (
    meal_plan_folder_id INT NOT NULL,
    creator_id INT NOT NULL,
    folder_name VARCHAR(50) NOT NULL,
    created_at DATETIME NOT NULL,
    PRIMARY KEY (meal_plan_folder_id),
    CONSTRAINT fk_meal_plan_folders_creator_id FOREIGN KEY (creator_id) 
        REFERENCES users (user_id)
);