-- ============================================================
-- FILE: users.sql
-- DESC: Usuarios de la aplicación
--       Passwords: bcrypt hash de 'Password1!' (solo para seed)
--       team_id NULL = usuario sin equipo asignado (admin/readonly)
-- ============================================================
USE wec;

INSERT INTO users (username, email, password_hash, team_id) VALUES
-- Administradores (sin equipo)
('admin',               'admin@wec.com',                     '$2y$12$KzKMo6fn7ZSdxkut4cqoXeajnor6cm8fxDl/pHFkgnD5mi/9OZ1Ai', NULL),
('readonly_user',       'readonly@wec.com',                  '$2y$12$KzKMo6fn7ZSdxkut4cqoXeajnor6cm8fxDl/pHFkgnD5mi/9OZ1Ai', NULL),
('toyota_manager',      'manager@toyota-gr.com',             '$2y$12$KzKMo6fn7ZSdxkut4cqoXeajnor6cm8fxDl/pHFkgnD5mi/9OZ1Ai', 1),-- Team managers (team_id referencia 04_teams.sql)
('ferrari_manager',     'manager@ferrari-afcorse.com',       '$2y$12$KzKMo6fn7ZSdxkut4cqoXeajnor6cm8fxDl/pHFkgnD5mi/9OZ1Ai', 2),
('porsche_manager',     'manager@porsche-penske.com',        '$2y$12$KzKMo6fn7ZSdxkut4cqoXeajnor6cm8fxDl/pHFkgnD5mi/9OZ1Ai', 3),
('peugeot_manager',     'manager@peugeot-sport.com',         '$2y$12$KzKMo6fn7ZSdxkut4cqoXeajnor6cm8fxDl/pHFkgnD5mi/9OZ1Ai', 4),
('bmw_manager',         'manager@bmw-wrt.com',               '$2y$12$KzKMo6fn7ZSdxkut4cqoXeajnor6cm8fxDl/pHFkgnD5mi/9OZ1Ai', 5),
('cadillac_manager',    'manager@cadillac-racing.com',       '$2y$12$KzKMo6fn7ZSdxkut4cqoXeajnor6cm8fxDl/pHFkgnD5mi/9OZ1Ai', 6),
('lamborghini_manager', 'manager@lamborghini-ironlynx.com',  '$2y$12$KzKMo6fn7ZSdxkut4cqoXeajnor6cm8fxDl/pHFkgnD5mi/9OZ1Ai', 7),
('alpine_manager',      'manager@alpine-endurance.com',      '$2y$12$KzKMo6fn7ZSdxkut4cqoXeajnor6cm8fxDl/pHFkgnD5mi/9OZ1Ai', 8),
('united_manager',      'manager@united-autosports.com',     '$2y$12$KzKMo6fn7ZSdxkut4cqoXeajnor6cm8fxDl/pHFkgnD5mi/9OZ1Ai', 9),
('proton_manager',      'manager@proton-competition.com',    '$2y$12$KzKMo6fn7ZSdxkut4cqoXeajnor6cm8fxDl/pHFkgnD5mi/9OZ1Ai', 10);

-- ============================================================
-- Asignación de roles (user_userrole)
-- id_user_role: 1=admin, 2=team_manager, 3=readonly
-- ============================================================
INSERT INTO user_userrole (id_user, id_user_role) VALUES
(1,  1),   -- admin               → admin
(2,  3),   -- readonly_user       → readonly
(3,  2),   -- toyota_manager      → team_manager
(4,  2),   -- ferrari_manager     → team_manager
(5,  2),   -- porsche_manager     → team_manager
(6,  2),   -- peugeot_manager     → team_manager
(7,  2),   -- bmw_manager         → team_manager
(8,  2),   -- cadillac_manager    → team_manager
(9,  2),   -- lamborghini_manager → team_manager
(10, 2),   -- alpine_manager      → team_manager
(11, 2),   -- united_manager      → team_manager
(12, 2);   -- proton_manager      → team_manager