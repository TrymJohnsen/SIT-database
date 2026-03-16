PRAGMA foreign_keys = ON;

BEGIN;

-- Tøm tabeller
DELETE FROM reservasjon;
DELETE FROM medlem_av;
DELETE FROM gruppe;
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
INSERT INTO treningssenter(treningssenter_id, har_gruppetrening, navn, adresse) VALUES
(1, 1, 'SiT Trening Øya',        'Vangslunds gate 2'),
(2, 1, 'SiT Trening Gløshaugen', 'Chr. Frederiks gate 20'),
(3, 1, 'SiT Trening Dragvoll',   'Loholt allé 81'),
(4, 0, 'SiT Trening Moholt',     'Moholt Allmenning 12'),
(5, 0, 'SiT Trening DMMH',       'DMMH, Trondheim');

-- 2) Åpningstider (Øya + Dragvoll)
INSERT INTO aapningstid (dag, start_tid, slutt_tid, bemannet, treningssenter_id) VALUES
-- Øya
('mandag','06:00','22:00',1,1),
('tirsdag','06:00','22:00',1,1),
('onsdag','06:00','22:00',1,1),
('torsdag','06:00','22:00',1,1),
('fredag','06:00','20:00',1,1),
('lørdag','08:00','18:00',0,1),
('søndag','08:00','18:00',0,1),

-- Dragvoll
('mandag','06:00','22:00',1,3),
('tirsdag','06:00','22:00',1,3),
('onsdag','06:00','22:00',1,3),
('torsdag','06:00','22:00',1,3),
('fredag','06:00','20:00',1,3),
('lørdag','08:00','18:00',0,3),
('søndag','08:00','18:00',0,3);

-- 3) Fasiliteter 
INSERT INTO fasilitet (fasilitet_id, fasilitet_type) VALUES
(1,'dusj'),
(2,'badstue'),
(3,'garderobe'),
(4,'spinning'),
(5,'tredemølle');

-- 4) senter_tilbyr 
INSERT INTO senter_tilbyr (treningssenter_id, fasilitet_id) VALUES
-- Øya
(1,1),(1,2),(1,3),(1,4),(1,5),
-- Gløshaugen
(2,1),(2,3),(2,4),
-- Dragvoll
(3,1),(3,3),(3,4),
-- Moholt
(4,1),(4,3),
-- DMMH
(5,1),(5,3);

-- 5) Saler 
INSERT INTO sal (sal_id, navn, kapasitet, sal_type, treningssenter_id) VALUES
(1,'Øya Spinningsal',30,'spinning',1),
(2,'Øya Sal 2',25,'gruppe',1),
(3,'Dragvoll Spinningsal',20,'spinning',3),
(4,'Gløshaugen Spinningsal',20,'spinning',2);

-- 6) Utstyr
INSERT INTO sykkel (sykkel_nr, har_bodybike, sal_id) VALUES
-- Øya spinningsal
(1,1,1),(2,1,1),(3,1,1),(4,0,1),(5,0,1),(6,1,1),(7,0,1),(8,0,1),(9,1,1),(10,0,1),
-- Dragvoll spinningsal
(1,0,3),(2,0,3),(3,1,3),(4,0,3),
-- Gløshaugen spinningsal
(1,1,4),(2,1,4),(3,1,4);

INSERT INTO tredemolle (tredemolle_nr, makshastighet, maksstigning, produsent, sal_id) VALUES
(1,20.0,15.0,'Technogym',2),
(2,18.0,12.0,'LifeFitness',2);

-- 7) Aktiviteter
INSERT INTO aktivitet (aktivitet_id, navn, kategori, beskrivelse) VALUES
(1,'Spin45','spin','Intervallbasert spinning i 45 minutter'),
(2,'Spin60','spin','Spinning i 60 minutter');

-- 8) Instruktører
INSERT INTO instruktor (instruktor_id, navn, epost, mobilnr) VALUES
(1,'Lina','lina@sit.no','11112222'),
(2,'Ola','ola@sit.no','33334444');

-- 9) Gruppetimer
INSERT INTO gruppetime (gruppetime_id, start_tid, slutt_tid, publisert_tid, sal_id, aktivitet_id, instruktor_id) VALUES
-- 16.03.2026 Øya + Dragvoll
(1,'2026-03-16 17:00','2026-03-16 17:45','2026-03-13 12:00',1,1,1),
(2,'2026-03-16 18:00','2026-03-16 19:00','2026-03-13 12:00',1,2,2),
(3,'2026-03-16 19:00','2026-03-16 19:45','2026-03-13 12:00',3,1,1),

-- 17.03.2026 (inkl. Spin60 18:30 på Øya)
(4,'2026-03-17 17:30','2026-03-17 18:15','2026-03-14 12:00',1,1,2),
(5,'2026-03-17 18:30','2026-03-17 19:30','2026-03-14 12:00',1,2,1),
(6,'2026-03-17 18:30','2026-03-17 19:30','2026-03-14 12:00',3,2,2),

-- 18.03.2026
(7,'2026-03-18 17:00','2026-03-18 18:00','2026-03-15 12:00',1,2,2),
(8,'2026-03-18 18:00','2026-03-18 18:45','2026-03-15 12:00',3,1,1);

-- 10) Brukere
INSERT INTO bruker (bruker_id, navn, epost, mobilnr) VALUES
(1,'Johnny Student','johnny@stud.ntnu.no','55556666'),
(2,'Han Grove','hangrove@stud.ntnu.no','77778888'),
(3, 'Babas Grill', 'babasgrill@stud.ntnu.no', '88889999');

-- 11) Booker
INSERT INTO booker (gruppetime_id, bruker_id, booket_tid, sjekket_inn_tid, booking_status, kansellert_tid) VALUES
(2,2,'2026-03-13 14:00','2026-03-16 17:55','møtt',NULL),
(3,3,'2026-03-13 15:00','2026-03-16 18:55','møtt',NULL),
(8,2,'2026-03-15 11:00',NULL,'venteliste',NULL);

-- 12) Idrettslag / medlemmer / grupper
INSERT INTO idrettslag (idrettslag_id, navn) VALUES
(1,'NTNUI');

INSERT INTO medlem_av (bruker_id, idrettslag_id) VALUES
(1,1),
(2,1);

INSERT INTO gruppe (gruppe_id, navn, idrettslag_id) VALUES
(1,'Fotball',1),
(2,'Basketball',1);

-- 13) Reservasjoner
INSERT INTO reservasjon (reservasjon_id, dag, start_tid, slutt_tid, valid_from, valid_to, gruppe_id, sal_id) VALUES
(1,'tirsdag','18:00','20:00','2026-03-16','2026-03-23',1,2),
(2,'torsdag','17:00','19:00','2026-03-16','2026-03-23',2,2);

COMMIT;