-- Active: 1763026326945@@127.0.0.1@3306@wec
-- EXECUTE METHOD ---------------
cd WEC
mysql -u usuario -p < main.sql
---------------------------------

CREATE DATABASE IF NOT EXISTS wec;
USE wec;

SOURCE schema/tables.sql;