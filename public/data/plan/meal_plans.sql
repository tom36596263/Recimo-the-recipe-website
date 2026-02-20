-- 創建資料表
CREATE TABLE meal_plans (
    plan_id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    user_id INT NOT NULL,
    source_template_id INT,
    title VARCHAR(100) NOT NULL,
    cover_type TINYINT NOT NULL COMMENT '0:系統自動合成, 1:官方預設, 2:使用者上傳',
    custom_cover_url VARCHAR(255),
    cover_template_id INT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    created_at DATETIME NOT NULL,
    CONSTRAINT fk_plan_user FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_plan_source FOREIGN KEY (source_template_id) REFERENCES meal_plan_templates(template_id),
    CONSTRAINT fk_plan_cover FOREIGN KEY (cover_template_id) REFERENCES meal_plan_cover_template(cover_template_id)
);

INSERT INTO meal_plans (plan_id, user_id, source_template_id, title, cover_type, custom_cover_url, cover_template_id, start_date, end_date, created_at) VALUES
(1, 2, NULL, '健康均衡三日自煮計畫', 1, NULL, 12, '2026-01-19', '2026-01-21', '2026-01-18 20:30:00'),
(2, 2, NULL, '活力輕食三日自煮計畫', 1, NULL, 11, '2026-01-22', '2026-01-24', '2026-01-21 10:00:00'),
(3, 2, NULL, '春節團圓年菜五日計畫', 1, NULL, 7, '2026-02-16', '2026-02-20', '2026-01-22 08:30:00'),
(4, 2, NULL, '環球味蕾：從浪漫歐陸到經典台韓六日饗宴', 1, NULL, 4, '2026-02-10', '2026-02-15', '2026-01-28 20:30:00'),
(5, 2, NULL, '2026 丙午馬年：除夕至初二團圓年菜計畫', 1, NULL, 5, '2026-02-16', '2026-02-18', '2026-01-28 20:35:00'),
(6, 2, NULL, '春意盎然：三月山林露營三日計畫', 1, NULL, 1, '2026-03-13', '2026-03-15', '2026-01-28 20:43:00'),
(7, 2, NULL, '520 浪漫食光：情侶專屬奢華饗宴計畫', 1, NULL, 9, '2026-05-19', '2026-05-21', '2026-01-28 20:50:00');