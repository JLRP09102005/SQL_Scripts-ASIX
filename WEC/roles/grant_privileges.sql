USE wec;

GRANT ALL ON *.* TO 'software-administrator' WITH GRANT OPTION;

GRANT ALL ON wec.* TO 'administratorDB' WITH GRANT OPTION;

GRANT SELECT ON wec.penalties TO 'comissioner-boss';
GRANT SELECT ON wec.results TO 'comissioner-boss';
GRANT SELECT ON wec.races TO 'comissioner-boss';

GRANT SELECT ON wec.manufacturers TO 'manufacturer-representative';
GRANT SELECT ON wec.teams TO 'manufacturer-representative';
GRANT SELECT ON wec.vehicles TO 'manufacturer-representative';

GRANT SELECT ON wec.vehicles TO 'mechanical-boss';
GRANT SELECT ON wec.circuits TO 'mechanical-boss';
GRANT SELECT ON wec.races TO 'mechanical-boss';

GRANT SELECT ON wec.pilots TO 'pilot';
GRANT SELECT ON wec.pilots_inscriptions TO 'pilot';

GRANT SELECT ON wec.teams TO 'team-manager';
GRANT SELECT ON wec.pilots TO 'team-manager';
GRANT SELECT ON wec.pilots_inscriptions TO 'team-manager';
GRANT SELECT ON wec.vehicles TO 'team-manager';
GRANT SELECT ON wec.inscriptions TO 'team-manager';
GRANT SELECT ON wec.results TO 'team-manager';
GRANT SELECT ON wec.penalties TO 'team-manager';
GRANT SELECT ON wec.penalties_results TO 'team-manager';

GRANT SELECT ON wec.penalties TO 'race-director';
GRANT SELECT ON wec.results TO 'race-director';
GRANT SELECT ON wec.penalties_results TO 'race-director';
GRANT SELECT ON wec.races TO 'race-director';

GRANT SELECT ON wec.races TO 'data-analyst';
GRANT SELECT ON wec.circuits TO 'data-analyst';
GRANT SELECT ON wec.pilot_categories TO 'data-analyst';
GRANT SELECT ON wec.results TO 'data-analyst';
GRANT SELECT ON wec.teams TO 'data-analyst';
GRANT SELECT ON wec.penalties TO 'data-analyst';
GRANT SELECT ON wec.pilots TO 'data-analyst';
GRANT SELECT ON wec.pilots_inscriptions TO 'data-analyst';
GRANT SELECT ON wec.inscriptions TO 'data-analyst';
GRANT SELECT ON wec.vehicles TO 'data-analyst';
GRANT SELECT ON wec.penalties_results TO 'data-analyst';

GRANT SELECT ON wec.races TO 'readonly-public';
GRANT SELECT ON wec.circuits TO 'readonly-public';
GRANT SELECT ON wec.pilots TO 'readonly-public';
GRANT SELECT ON wec.results TO 'readonly-public';