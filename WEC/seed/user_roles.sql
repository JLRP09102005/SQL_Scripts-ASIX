-- ============================================================
-- FILE: user_roles.sql
-- DESC: Roles de usuarios de la aplicación
-- ============================================================
USE wec;

INSERT INTO user_roles (role_name) VALUES
('admin'),
('team_manager'),
('readonly');