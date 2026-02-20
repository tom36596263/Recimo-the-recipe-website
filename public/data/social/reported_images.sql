-- 1. 建立表格
CREATE TABLE IF NOT EXISTS reported_galleries (
    reported_gallery_id INT NOT NULL AUTO_INCREMENT,
    gallery_id INT NOT NULL,
    reporter_id INT NOT NULL,
    report_type TINYINT NOT NULL,
    report_reason TEXT NOT NULL,
    status TINYINT DEFAULT 0,
    handler_id INT DEFAULT NULL,
    reported_at DATETIME NOT NULL,
    update_at DATETIME DEFAULT NULL,
    PRIMARY KEY (reported_gallery_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. 清空資料
TRUNCATE TABLE reported_galleries;

-- 3. 插入資料
INSERT INTO reported_galleries (
    reported_gallery_id, gallery_id, reporter_id, report_type, 
    report_reason, status, handler_id, reported_at, update_at
) VALUES
(1, 5, 5, 3, '盜用網路圖片且公然侮辱食譜作者，語氣極度惡劣。', 0, NULL, '2026-01-21 09:15:00', NULL),
(2, 12, 7, 1, '在成品分享區散佈疑似投資詐騙的 LINE 帳號資訊。', 1, 2, '2026-01-21 10:30:00', '2026-01-21 10:45:00'),
(3, 25, 8, 3, '涉及恐嚇與偏激謾罵，內容與食譜分享無關，純屬惡意鬧板。', 0, NULL, '2026-01-21 11:45:00', NULL);

-- 4. 建立外來鍵指令
-- 第一個：連結到成品照片表 (recipe_gallery)
ALTER TABLE reported_galleries
  ADD CONSTRAINT fk_reports_gallery FOREIGN KEY (gallery_id) REFERENCES recipe_gallery (gallery_id) ON UPDATE CASCADE;

-- 第二個：連結到使用者表 (users) - 檢舉人
ALTER TABLE reported_galleries
  ADD CONSTRAINT fk_reports_gal_reporter FOREIGN KEY (reporter_id) REFERENCES users (user_id) ON UPDATE CASCADE;

-- 第三個：連結到管理員表 (admins) - 處理者
ALTER TABLE reported_galleries
  ADD CONSTRAINT fk_reports_gal_handler FOREIGN KEY (handler_id) REFERENCES admins (admin_id) ON UPDATE CASCADE;

COMMIT;