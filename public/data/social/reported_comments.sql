-- 1. 建立表格 (確保與 Data Dictionary 一致)
CREATE TABLE IF NOT EXISTS reported_comments (
    reported_comment_id INT NOT NULL AUTO_INCREMENT,
    comment_id INT NOT NULL,
    reporter_id INT NOT NULL,
    report_type TINYINT NOT NULL,
    report_reason TEXT NOT NULL,
    status TINYINT DEFAULT 0,
    handler_id INT DEFAULT NULL, -- 預設 NULL，處理後會填入管理員 ID
    reported_at DATETIME NOT NULL,
    update_at DATETIME DEFAULT NULL,
    PRIMARY KEY (reported_comment_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- 2. 清空資料
TRUNCATE TABLE reported_comments;

-- 3. 插入資料 (包含未處理與已處理的範例)
INSERT INTO reported_comments (
    reported_comment_id, comment_id, reporter_id, report_type, 
    report_reason, status, handler_id, reported_at, update_at
) VALUES
-- 尚未處理的案件 (handler_id 為 NULL)
(1, 12, 2, 3, '在留言區發送加 LINE 領紅包的訊息，明顯是詐騙資訊。', 0, NULL, '2024-01-17 09:00:00', NULL),
(3, 60, 8, 1, '評論包含侮辱性字眼（髒話）並無端攻擊食譜作者。', 0, NULL, '2024-04-05 15:20:00', NULL),
-- 假設這筆已經由「小R」(ID: 2) 處理完畢
(5, 4, 7, 4, '惡意辱罵作者抄襲但未提供任何具體理由，純屬挑釁。', 1, 2, '2024-01-06 10:15:00', '2024-01-06 11:00:00');

-- 4. 建立外來鍵指令
-- 關連到留言表
ALTER TABLE reported_comments
  ADD CONSTRAINT fk_reports_comment FOREIGN KEY (comment_id) REFERENCES recipe_comments (comment_id) ON UPDATE CASCADE;

-- 關連到使用者表 (檢舉人)
ALTER TABLE reported_comments
  ADD CONSTRAINT fk_reports_reporter FOREIGN KEY (reporter_id) REFERENCES users (user_id) ON UPDATE CASCADE;

-- 關連到管理員表 (處理者：小R所在的表)
ALTER TABLE reported_comments
  ADD CONSTRAINT fk_reports_handler FOREIGN KEY (handler_id) REFERENCES admins (admin_id) ON UPDATE CASCADE;

COMMIT;