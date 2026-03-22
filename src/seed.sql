PRAGMA foreign_keys = ON;

BEGIN;

-- Tøm tabeller i riktig rekkefølge
DELETE FROM reservasjon;
DELETE FROM medlem_av;
DELETE FROM "gruppe";
DELETE FROM idrettslag;

DELETE FROM booker;
DELETE FROM bruker;

DELETE FROM gruppetime;
DELETE FROM instruktor;
DELETE FROM aktivitet;

DELETE FROM tredemolle;
DELETE FROM sykkel;
DELETE FROM sal;

DELETE FROM senter_tilbyr;
DELETE FROM fasilitet;

DELETE FROM aapningstid;
DELETE FROM treningssenter;

-- 1) Treningssentre
INSERT INTO treningssenter (treningssenter_id, har_gruppetrening, navn, adresse) VALUES
(1, 1, 'SiT Trening Øya',        'Vangslunds gate 2'),
(2, 1, 'SiT Trening Gløshaugen', 'Chr. Frederiks gate 20'),
(3, 1, 'SiT Trening Dragvoll',   'Loholt allé 81'),
(4, 0, 'SiT Trening Moholt',     'Moholt Allmenning 12'),
(5, 0, 'SiT Trening DMMH',       'DMMH, Trondheim');

-- 2) Åpningstider
INSERT INTO aapningstid (dag, start_tid, slutt_tid, bemannet, treningssenter_id) VALUES
-- Øya
('mandag',  '06:00', '22:00', 1, 1),
('tirsdag', '06:00', '22:00', 1, 1),
('onsdag',  '06:00', '22:00', 1, 1),
('torsdag', '06:00', '22:00', 1, 1),
('fredag',  '06:00', '20:00', 1, 1),
('lørdag',  '08:00', '18:00', 0, 1),
('søndag',  '08:00', '18:00', 0, 1),

-- Dragvoll
('mandag',  '06:00', '22:00', 1, 3),
('tirsdag', '06:00', '22:00', 1, 3),
('onsdag',  '06:00', '22:00', 1, 3),
('torsdag', '06:00', '22:00', 1, 3),
('fredag',  '06:00', '20:00', 1, 3),
('lørdag',  '08:00', '18:00', 0, 3),
('søndag',  '08:00', '18:00', 0, 3);

-- 3) Fasiliteter
INSERT INTO fasilitet (fasilitet_id, fasilitet_type) VALUES
(1, 'Garderobe'),
(2, 'Dusj'),
(3, 'Badstue'),
(4, 'Spinningsal');

INSERT INTO senter_tilbyr (treningssenter_id, fasilitet_id) VALUES
(1, 1), (1, 2), (1, 4),
(3, 1), (3, 2), (3, 4);

-- 4) Saler
INSERT INTO sal (sal_id, navn, kapasitet, sal_type, treningssenter_id) VALUES
(1, 'Øya Spinningsal', 30, 'spinning', 1),
(2, 'Øya Sal 2',       25, 'gruppe',   1),
(3, 'Dragvoll Spinningsal', 20, 'spinning', 3);

-- 5) Sykler
INSERT INTO sykkel (sykkel_nr, har_bodybike, sal_id) VALUES
-- Øya spinningsal
(1,1,1),(2,1,1),(3,1,1),(4,0,1),(5,0,1),
(6,1,1),(7,0,1),(8,0,1),(9,1,1),(10,0,1),

-- Dragvoll spinningsal
(1,0,3),(2,0,3),(3,1,3),(4,0,3);

-- 6) Aktiviteter
INSERT INTO aktivitet (aktivitet_id, navn, kategori, beskrivelse) VALUES
(1, 'Spin45', 'spin', 'Intervallbasert spinning i 45 minutter'),
(2, 'Spin60', 'spin', 'Spinning i 60 minutter');

-- 7) Instruktører
INSERT INTO instruktor (instruktor_id, navn, epost, mobilnr) VALUES
(1, 'Lina', 'lina@sit.no', '11112222'),
(2, 'Ola',  'ola@sit.no',  '33334444');

-- 8) Gruppetimer
INSERT INTO gruppetime (gruppetime_id, start_tid, slutt_tid, publisert_tid, sal_id, aktivitet_id, instruktor_id) VALUES
-- 16.03.2026
(1, '2026-03-16 17:00:00', '2026-03-16 17:45:00', '2026-03-13 12:00:00', 1, 1, 1),
(2, '2026-03-16 18:00:00', '2026-03-16 19:00:00', '2026-03-13 12:00:00', 1, 2, 2),
(3, '2026-03-16 19:00:00', '2026-03-16 19:45:00', '2026-03-13 12:00:00', 3, 1, 1),

-- 17.03.2026
(4, '2026-03-17 17:30:00', '2026-03-17 18:15:00', '2026-03-14 12:00:00', 1, 1, 2),
(5, '2026-03-17 18:30:00', '2026-03-17 19:30:00', '2026-03-14 12:00:00', 1, 2, 1),
(6, '2026-03-17 18:30:00', '2026-03-17 19:30:00', '2026-03-14 12:00:00', 3, 2, 2),

-- 18.03.2026
(7, '2026-03-18 17:00:00', '2026-03-18 18:00:00', '2026-03-15 12:00:00', 1, 2, 2),
(8, '2026-03-18 18:00:00', '2026-03-18 18:45:00', '2026-03-15 12:00:00', 3, 1, 1);

-- 9) Brukere
INSERT INTO bruker (bruker_id, navn, epost, mobilnr) VALUES
(1, 'Johnny Student', 'johnny@stud.ntnu.no', '55556666'),
(2, 'Emma Larsen',    'emma@stud.ntnu.no',   '55557777'),
(3, 'Ali Hansen',     'ali@stud.ntnu.no',    '55558888'),
(4, 'Mars Viner',   'marsvin@stud.ntnu.no', '55559999');

-- 10) Bookinger for test av brukstilfelle 5 og 7
INSERT INTO booker (gruppetime_id, bruker_id, booket_tid, sjekket_inn_tid, booking_status, kansellert_tid) VALUES
(1, 1, '2026-03-15 09:30:00', '2026-03-16 16:55:00', 'møtt', NULL),
(5, 1, '2026-03-16 10:15:00', '2026-03-17 18:25:00', 'møtt', NULL),
(8, 1, '2026-03-17 12:00:00', '2026-03-18 17:55:00', 'møtt', NULL),
(1, 4, '2026-03-15 10:00:00', '2026-03-16 16:55:00', 'møtt', NULL),
(2, 4, '2026-03-15 10:05:00', '2026-03-16 17:55:00', 'møtt', NULL),
(5, 4, '2026-03-16 10:00:00', '2026-03-17 18:25:00', 'møtt', NULL);

COMMIT;
