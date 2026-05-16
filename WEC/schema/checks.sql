-- Active: 1763026326945@@127.0.0.1@3306@wec
USE wec;

--====== CHECKS ======
ALTER TABLE results
ADD CONSTRAINT IF NOT EXISTS chk_result_position CHECK (position >= 1 AND position <= 60),
ADD CONSTRAINT IF NOT EXISTS chk_result_time CHECK (final_time != '00:00:00');

ALTER TABLE penalties
ADD CONSTRAINT IF NOT EXISTS chk_max_penalty_points CHECK(
    (penalty_type = 'POINTS' AND penalty_value <= 25) OR
    (penalty_type = 'TIME' AND penalty_value <= 60) OR
    (penalty_type = 'DSQ') OR
    (penalty_type = 'DNF')
);

ALTER TABLE inscriptions
ADD CONSTRAINT IF NOT EXISTS chk_vehicle_limit CHECK(vehicles_quantity <= 2);

ALTER TABLE pilots
ADD CONSTRAINT IF NOT EXISTS chk_basic_pilot_name CHECK(pilot_name LIKE '% %'),
ADD CONSTRAINT IF NOT EXISTS chk_pilot_age CHECK(pilot_age >= 18);