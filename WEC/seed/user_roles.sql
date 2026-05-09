-- ============================================================
-- FILE: user_roles.sql
-- DESC: Roles de usuarios de la aplicación (WEC)
-- ============================================================
USE wec;

INSERT INTO user_roles (role_name) VALUES
('software-administrator'),
('administratorDB'),
('commissioner-boss'),
('manufacturer-representative'),
('mechanical-boss'),
('pilot'),
('team-manager'),
('race-director'),
('data-analyst'),
('readonly-public');