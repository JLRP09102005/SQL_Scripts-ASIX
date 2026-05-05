-- Active: 1763026326945@@127.0.0.1@3306@wecault_conections
-- EXECUTE METHOD ---------------
/* cd WEC
mysql -u usuario -p < main.sql */
---------------------------------

-- Drop last schema
SOURCE cleanup/drop.all.sql;

CREATE DATABASE IF NOT EXISTS wec;
USE wec;

--Basic DB structure
SOURCE schema/tables.sql;
SOURCE schema/foreign_keys.sql;
SOURCE schema/indexes.sql;
SOURCE schema/checks.sql;

-- Functions
SOURCE functions/functions.sql;

-- Procedures
SOURCE procedures/crud/crud.sql;
SOURCE procedures/queries/auth_queries.sql;
SOURCE procedures/queries/authenticated_queries.sql;
SOURCE procedures/queries/public_queries.sql;
SOURCE procedures/business/business.sql;

-- Tiggers
SOURCE triggers/trigger_apply_penalties.sql;
SOURCE triggers/trigger_calculate_position_points.sql;
SOURCE triggers/trigger_valid_inscription.sql;

-- Roles
SOURCE roles/create-roles.sql;
SOURCE roles/grant-privileges.sql;

-- Users
SOURCE users/create-users.sql;
SOURCE users/grant-user-privileges.sql;

-- Data example
SOURCE seed/circuits,sql;
SOURCE seed/inscriptions.sql;
SOURCE seed/manufacturers.sql;
SOURCE seed/penalties.sql;
SOURCE seed/pilot_categories.sql;
SOURCE seed/pilots_inscriptions.sql;
SOURCE seed/pilots.sql;
SOURCE seed/races.sql;
SOURCE seed/results.sql;
SOURCE seed/teams.sql;
SOURCE seed/user_roles.sql;
SOURCE seed/users.sql;
SOURCE seed/vehicles.sql;