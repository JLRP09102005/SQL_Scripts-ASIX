USE wec;

GRANT SELECT PRIVILEGES ON wec.* TO 'wec_readonly'@'localhost';
GRANT ALL PRIVILEGES ON wec.* TO 'wec_admin'@'localhost';
FLUSH PRIVILEGES;