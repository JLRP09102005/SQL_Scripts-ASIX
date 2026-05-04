-- Active: 1763026326945@@127.0.0.1@3306@wecault_conections
-- EXECUTE METHOD ---------------
/* cd WEC
mysql -u usuario -p < main.sql */
---------------------------------

CREATE DATABASE IF NOT EXISTS wec;
USE wec;

-- Drop last schema
SOURCE cleanup/drop.all.sql;

--Basic DB structure
SOURCE schema/tables.sql;
SOURCE schema/foreign_keys.sql;
SOURCE schema/indexes.sql;
SOURCE schema/checks.sql;

-- Functions
SOURCE functions/functions.sql;

-- Procedures
SOURCE procedures/crud/crud.sql;
SOURCE procedures/queries/authenticated_queries.sql;
SOURCE procedures/queries/public_queries.sql;
SOURCE procedures/business/business.sql;

-- Tiggers
SOURCE triggers/trigger_apply_penalties.sql;
SOURCE triggers/trigger_calculate_position_points.sql;
SOURCE triggers/trigger_valid_inscription.sql;

-- Roles
SOURCE roles/create-roles.sql;
SOURCE roles/grant-privileges;

-- Users
SOURCE users/create-users.sql;
SOURCE users/grant-user-privileges.sql;