CREATE TABLE IF NOT EXISTS reported_comments (
    reported_comment_id INT PRIMARY KEY AUTO_INCREMENT,
    comment_id INT NOT NULL,
    reporter_id INT NOT NULL,
    report_type TINYINT NOT NULL,
    report_reason TEXT NOT NULL,
    status TINYINT DEFAULT 0,
    handler_id INT DEFAULT NULL,
    reported_at DATETIME NOT NULL,
    update_at DATETIME DEFAULT NULL
);

TRUNCATE TABLE reported_comments;

INSERT INTO reported_comments (
    reported_comment_id, comment_id, reporter_id, report_type, 
    report_reason, status, handler_id, reported_at, update_at
) VALUES
(1, 12, 10, 3, '在留言區發送加 LINE 領紅包的訊息，明顯是詐騙資訊。', 0, NULL, '2024-01-17 09:00:00', NULL),
(3, 60, 8, 1, '評論包含侮辱性字眼（髒話）並無端攻擊食譜作者。', 0, NULL, '2024-04-05 15:20:00', NULL),
(5, 4, 7, 4, '惡意辱罵作者抄襲但未提供任何具體理由，純屬挑釁。', 0, NULL, '2024-01-06 10:15:00', NULL);