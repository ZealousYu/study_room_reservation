-- 已有库升级：users.password 扩为 varchar(256)，以存储 bcrypt 哈希（约 60 字符）
-- 新库直接导入 study_room_reservation.sql 即可，无需执行本脚本

ALTER TABLE `users`
  MODIFY COLUMN `password` varchar(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL COMMENT 'bcrypt 哈希或历史明文';
