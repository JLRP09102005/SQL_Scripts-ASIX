REVOKE ALL ON wec.* FROM 'administratorDB';
REVOKE ALL ON wec.* FROM 'comissioner-boss';
REVOKE ALL ON wec.* FROM 'manufacturer-representative';
REVOKE ALL ON wec.* FROM 'mechanical-boss';
REVOKE ALL ON wec.* FROM 'pilot';
REVOKE ALL ON wec.* FROM 'team-manager';
REVOKE ALL ON wec.* FROM 'race-director';
REVOKE ALL ON wec.* FROM 'data-analyst';
REVOKE ALL ON wec.* FROM 'readonly-public';
REVOKE ALL PRIVILEGES ON wec.* TO 'wec_readonly'@'localhost';

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

DROP DATABASE IF EXISTS 'wec';