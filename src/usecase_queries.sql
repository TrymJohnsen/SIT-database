-- SQL for brukstilfellene i TreningDB

PRAGMA foreign_keys = ON;

-- =========================================================
-- Brukstilfelle 1
-- Legg inn treningssenter, saler, sykler, brukere, trenere og treninger.
-- Dette er levert i eksisterende SQL-filer:
--   schema.sql  -> oppretter tabellene
--   seed.sql    -> legger inn dataene
-- =========================================================


-- =========================================================
-- Brukstilfelle 2
-- Booking av trening "Spin60" på 2026-03-17 18:30:00
-- for bruker "johnny@stud.ntnu.no".
-- Parametere:
--   :epost       f.eks. 'johnny@stud.ntnu.no'
--   :aktivitet   f.eks. 'Spin60'
--   :start_tid   f.eks. '2026-03-17 18:30:00'
--   :gruppetime_id velges hvis flere treff finnes
-- =========================================================

-- 2A. Finn bruker
SELECT bruker_id
FROM bruker
WHERE epost = :epost;

-- 2B. Sjekk om brukeren er svartelistet
SELECT g.start_tid
FROM booker b
JOIN gruppetime g ON b.gruppetime_id = g.gruppetime_id
WHERE b.bruker_id = :bruker_id
  AND b.booking_status = 'ikke_møtt'
ORDER BY g.start_tid;

-- 2C. Finn alle gruppetimer som matcher aktivitet og starttid
SELECT g.gruppetime_id, t.navn, g.start_tid, g.slutt_tid, s.kapasitet
FROM gruppetime g
JOIN aktivitet a ON g.aktivitet_id = a.aktivitet_id
JOIN sal s ON g.sal_id = s.sal_id
JOIN treningssenter t ON s.treningssenter_id = t.treningssenter_id
WHERE LOWER(a.navn) = LOWER(:aktivitet)
  AND g.start_tid = :start_tid
ORDER BY t.navn;

-- 2D. Sjekk om bruker allerede er booket på valgt time
SELECT 1
FROM booker
WHERE gruppetime_id = :gruppetime_id
  AND bruker_id = :bruker_id;

-- 2E. Tell antall bookede/møtte for kapasitetssjekk
SELECT COUNT(*)
FROM booker
WHERE gruppetime_id = :gruppetime_id
  AND booking_status IN ('booket', 'møtt');

-- 2F. Sjekk om brukeren har overlappende bookinger
SELECT g.gruppetime_id, g.start_tid, g.slutt_tid
FROM booker b
JOIN gruppetime g ON b.gruppetime_id = g.gruppetime_id
WHERE b.bruker_id = :bruker_id
  AND b.booking_status IN ('booket', 'møtt', 'venteliste')
  AND g.start_tid < :ny_slutt_tid
  AND g.slutt_tid > :ny_start_tid;

-- 2G. Opprett booking
-- Sett :status til 'booket' eller 'venteliste' etter kapasitetssjekken.
INSERT INTO booker (gruppetime_id, bruker_id, booket_tid, booking_status)
VALUES (:gruppetime_id, :bruker_id, CURRENT_TIMESTAMP, :status);


-- =========================================================
-- Brukstilfelle 3
-- Registrering av oppmøte.
-- Parametere:
--   :epost
--   :gruppetime_id
-- =========================================================

-- 3A. Finn bruker
SELECT bruker_id
FROM bruker
WHERE epost = :epost;

-- 3B. Sjekk om booking finnes og hent starttid
SELECT b.booking_status, g.start_tid
FROM booker b
JOIN gruppetime g ON b.gruppetime_id = g.gruppetime_id
WHERE b.gruppetime_id = :gruppetime_id
  AND b.bruker_id = :bruker_id;

-- 3C. Registrer oppmøte
UPDATE booker
SET booking_status = 'møtt',
    sjekket_inn_tid = CURRENT_TIMESTAMP
WHERE gruppetime_id = :gruppetime_id
  AND bruker_id = :bruker_id;


-- =========================================================
-- Brukstilfelle 4
-- Ukeplan for valgt periode.
-- Parametere:
--   :fra_dato  f.eks. '2026-03-16'
--   :til_dato  f.eks. '2026-03-23'
-- =========================================================

SELECT g.gruppetime_id, a.navn, g.start_tid, g.slutt_tid, s.navn
FROM gruppetime g
JOIN aktivitet a ON g.aktivitet_id = a.aktivitet_id
JOIN sal sa ON g.sal_id = sa.sal_id
JOIN treningssenter s ON sa.treningssenter_id = s.treningssenter_id
WHERE date(g.start_tid) BETWEEN :fra_dato AND :til_dato
ORDER BY g.start_tid;


-- =========================================================
-- Brukstilfelle 5
-- Personlig besøkshistorie for Johnny siden 2026-01-01.
-- Parametere:
--   :epost
--   :fra_dato
-- =========================================================

SELECT DISTINCT a.navn, g.start_tid, s.navn
FROM booker b
JOIN bruker u ON b.bruker_id = u.bruker_id
JOIN gruppetime g ON b.gruppetime_id = g.gruppetime_id
JOIN aktivitet a ON g.aktivitet_id = a.aktivitet_id
JOIN sal sa ON g.sal_id = sa.sal_id
JOIN treningssenter s ON sa.treningssenter_id = s.treningssenter_id
WHERE u.epost = :epost
  AND date(g.start_tid) >= :fra_dato
  AND b.booking_status = 'møtt'
ORDER BY g.start_tid;


-- =========================================================
-- Brukstilfelle 6
-- Svartelisting.
-- Parametere:
--   :epost
-- =========================================================

-- 6A. Finn bruker
SELECT bruker_id
FROM bruker
WHERE epost = :epost;

-- 6B. Finn prikker siste 30 dager
SELECT g.start_tid
FROM booker b
JOIN gruppetime g ON b.gruppetime_id = g.gruppetime_id
WHERE b.bruker_id = :bruker_id
  AND b.booking_status = 'ikke_møtt'
  AND datetime(g.start_tid) >= datetime('now', '-30 days')
ORDER BY g.start_tid;

-- 6C. Tell antall prikker siste 30 dager
SELECT COUNT(*) AS antall_prikker
FROM booker b
JOIN gruppetime g ON b.gruppetime_id = g.gruppetime_id
WHERE b.bruker_id = :bruker_id
  AND b.booking_status = 'ikke_møtt'
  AND datetime(g.start_tid) >= datetime('now', '-30 days');

-- 6D. Finn utestengt til dersom brukeren har minst tre prikker
SELECT MIN(datetime(g.start_tid, '+30 days')) AS utestengt_til
FROM booker b
JOIN gruppetime g ON b.gruppetime_id = g.gruppetime_id
WHERE b.bruker_id = :bruker_id
  AND b.booking_status = 'ikke_møtt'
  AND datetime(g.start_tid) >= datetime('now', '-30 days');


-- =========================================================
-- Brukstilfelle 7
-- Mest aktive medlemmer i en gitt måned.
-- Parametere:
--   :aar     f.eks. '2026'
--   :maaned  f.eks. '03'
-- =========================================================

SELECT u.epost, COUNT(*) AS antall
FROM booker b
JOIN bruker u ON b.bruker_id = u.bruker_id
JOIN gruppetime g ON b.gruppetime_id = g.gruppetime_id
WHERE strftime('%Y', g.start_tid) = :aar
  AND strftime('%m', g.start_tid) = :maaned
  AND b.booking_status = 'møtt'
GROUP BY u.bruker_id
HAVING antall = (
    SELECT MAX(cnt)
    FROM (
        SELECT COUNT(*) AS cnt
        FROM booker b2
        JOIN gruppetime g2 ON b2.gruppetime_id = g2.gruppetime_id
        WHERE strftime('%Y', g2.start_tid) = :aar
          AND strftime('%m', g2.start_tid) = :maaned
          AND b2.booking_status = 'møtt'
        GROUP BY b2.bruker_id
    )
);


-- =========================================================
-- Brukstilfelle 8
-- Finn to brukere som trener sammen.
-- Parametere:
--   :epost1
--   :epost2
-- =========================================================

SELECT u1.epost, u2.epost, COUNT(*) AS antall_felles_treninger
FROM booker b1
JOIN booker b2 ON b1.gruppetime_id = b2.gruppetime_id
JOIN bruker u1 ON b1.bruker_id = u1.bruker_id
JOIN bruker u2 ON b2.bruker_id = u2.bruker_id
WHERE u1.epost = :epost1
  AND u2.epost = :epost2
  AND b1.booking_status = 'møtt'
  AND b2.booking_status = 'møtt';
