-- 1. 建立表格
CREATE TABLE IF NOT EXISTS reported_recipes (
    reported_recipe_id INT PRIMARY KEY AUTO_INCREMENT,
    recipe_id INT NOT NULL,
    reporter_id INT NOT NULL,
    report_type TINYINT NOT NULL,
    report_reason TEXT NOT NULL,
    status TINYINT DEFAULT 0,
    handler_id INT DEFAULT NULL,
    reported_at DATETIME NOT NULL,
    update_at DATETIME DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. 清空資料
TRUNCATE TABLE reported_recipes;

-- 3. 插入資料
INSERT INTO reported_recipes (
    reported_recipe_id, recipe_id, reporter_id, report_type, 
    report_reason, status, handler_id, reported_at, update_at
) VALUES 
(1, 6, 45, 2, '關於荷蘭醬的製作步驟，文中提到的攪拌溫度與實際操作有落差，容易導致油水分離，建議官方確認步驟描述。', 0, NULL, '2026-01-20 14:00:00', NULL),
(2, 11, 33, 1, '食譜下方的關聯商品連結點開後跳出大量與食譜無關的抽獎廣告，懷疑連結安全性。', 0, NULL, '2026-01-22 16:20:00', NULL),
(3, 14, 18, 4, '這道豆腐漢堡排的分類似乎放錯了，標籤標示為全素，但食材內含有豬絞肉，請官方修正分類。', 0, NULL, '2026-01-25 09:30:00', NULL);

-- 4. 建立外來鍵指令
-- 第一個：連結到食譜表 (recipes)
ALTER TABLE reported_recipes
  ADD CONSTRAINT fk_reports_recipe FOREIGN KEY (recipe_id) REFERENCES recipes (recipe_id) ON UPDATE CASCADE;

-- 第二個：連結到使用者表 (users) - 檢舉人
ALTER TABLE reported_recipes
  ADD CONSTRAINT fk_reports_rec_reporter FOREIGN KEY (reporter_id) REFERENCES users (user_id) ON UPDATE CASCADE;

-- 第三個：連結到管理員表 (admins) - 處理者
ALTER TABLE reported_recipes
  ADD CONSTRAINT fk_reports_rec_handler FOREIGN KEY (handler_id) REFERENCES admins (admin_id) ON UPDATE CASCADE;

COMMIT;