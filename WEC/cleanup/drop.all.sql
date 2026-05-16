REVOKE ALL ON wec.* FROM 'administratorDB' IF EXISTS;
REVOKE ALL ON wec.* FROM 'comissioner-boss' IF EXISTS;
REVOKE ALL ON wec.* FROM 'manufacturer-representative' IF EXISTS;
REVOKE ALL ON wec.* FROM 'mechanical-boss' IF EXISTS;
REVOKE ALL ON wec.* FROM 'pilot' IF EXISTS;
REVOKE ALL ON wec.* FROM 'team-manager' IF EXISTS;
REVOKE ALL ON wec.* FROM 'race-director' IF EXISTS;
REVOKE ALL ON wec.* FROM 'data-analyst' IF EXISTS;
REVOKE ALL ON wec.* FROM 'readonly-public' IF EXISTS;
REVOKE ALL PRIVILEGES ON wec.* FROM 'wec_readonly'@'localhost' IF EXISTS;

DROP ROLE IF EXISTS 'administratorDB';
DROP ROLE IF EXISTS 'comissioner-boss';
DROP ROLE IF EXISTS 'manufacturer-representative';
DROP ROLE IF EXISTS 'mechanical-boss';
DROP ROLE IF EXISTS 'pilot';
DROP ROLE IF EXISTS 'team-manager';
DROP ROLE IF EXISTS 'race-director';
DROP ROLE IF EXISTS 'data-analyst';
DROP ROLE IF EXISTS 'readonly-public';
DROP USER IF EXISTS 'wec_readonly'@'localhost';

DROP DATABASE IF EXISTS wec;