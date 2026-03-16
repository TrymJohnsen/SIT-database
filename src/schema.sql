CREATE TABLE treningssenter(
    treningssenter_id INT,
    har_gruppetrening INT NOT NULL CHECK(har_gruppetrening IN (0, 1)),
    navn VARCHAR(100) NOT NULL,
    adresse VARCHAR(100) NOT NULL,
    PRIMARY KEY (treningssenter_id)
);


CREATE TABLE aapningstid(
    dag VARCHAR(7) NOT NULL CHECK(dag IN ('mandag', 'tirsdag', 'onsdag', 'torsdag', 'fredag', 'lørdag', 'søndag')),
    start_tid TIME NOT NULL,
    slutt_tid TIME NOT NULL CHECK(slutt_tid > start_tid),
    bemannet INT NOT NULL CHECK(bemannet IN (0, 1)),
    treningssenter_id INT NOT NULL,
    PRIMARY KEY (treningssenter_id, dag, start_tid, bemannet),
    FOREIGN KEY (treningssenter_id) REFERENCES treningssenter(treningssenter_id)
);


CREATE TABLE fasilitet(
    fasilitet_id INT,
    fasilitet_type VARCHAR(50) NOT NULL UNIQUE,
    PRIMARY KEY (fasilitet_id)
);


CREATE TABLE senter_tilbyr(
    treningssenter_id INT NOT NULL,
    fasilitet_id INT NOT NULL,
    PRIMARY KEY (treningssenter_id, fasilitet_id),
    FOREIGN KEY (treningssenter_id) REFERENCES treningssenter(treningssenter_id),
    FOREIGN KEY (fasilitet_id) REFERENCES fasilitet(fasilitet_id)
);


CREATE TABLE sal(
    sal_id INT,
    navn VARCHAR(100) NOT NULL,
    kapasitet INT NOT NULL CHECK(kapasitet > 0),
    sal_type VARCHAR(100) NOT NULL,
    treningssenter_id INT NOT NULL,
    UNIQUE(treningssenter_id, navn),
    PRIMARY KEY (sal_id),
    FOREIGN KEY (treningssenter_id) REFERENCES treningssenter(treningssenter_id)
);


CREATE TABLE sykkel(
    sykkel_nr INT,
    har_bodybike INT NOT NULL CHECK(har_bodybike IN (0, 1)),
    sal_id INT NOT NULL,
    PRIMARY KEY (sykkel_nr, sal_id),
    FOREIGN KEY (sal_id) REFERENCES sal(sal_id)
);


CREATE TABLE tredemolle(
    tredemolle_nr INT,
    makshastighet NUMERIC(3,1) CHECK(makshastighet >= 0 AND makshastighet <= 30),
    maksstigning NUMERIC(3,1) CHECK(maksstigning >=0 AND maksstigning <= 90),
    produsent VARCHAR(50),
    sal_id INT NOT NULL,
    PRIMARY KEY (tredemolle_nr, sal_id),
    FOREIGN KEY (sal_id) REFERENCES sal(sal_id)
);


CREATE TABLE aktivitet(
    aktivitet_id INT,
    navn VARCHAR(100) NOT NULL UNIQUE,
    kategori VARCHAR(50) NOT NULL,
    beskrivelse TEXT,
    PRIMARY KEY (aktivitet_id)
);


CREATE TABLE instruktor(
    instruktor_id INT,
    navn VARCHAR(100) NOT NULL,
    epost VARCHAR(100) NOT NULL UNIQUE,
    mobilnr VARCHAR(8) NOT NULL UNIQUE,
    PRIMARY KEY (instruktor_id)
);


CREATE TABLE gruppetime(
    gruppetime_id INT,
    start_tid TIMESTAMP NOT NULL,
    slutt_tid TIMESTAMP NOT NULL CHECK(slutt_tid > start_tid),
    publisert_tid TIMESTAMP NOT NULL CHECK(start_tid >= datetime(publisert_tid, '+48 hours')),
    sal_id INT NOT NULL,
    aktivitet_id INT NOT NULL,
    instruktor_id INT NOT NULL,
    PRIMARY KEY (gruppetime_id),
    FOREIGN KEY (sal_id) REFERENCES sal(sal_id),
    FOREIGN KEY (aktivitet_id) REFERENCES aktivitet(aktivitet_id),
    FOREIGN KEY (instruktor_id) REFERENCES instruktor(instruktor_id)
);


CREATE TABLE bruker(
    bruker_id INT,
    navn VARCHAR(100) NOT NULL,
    epost VARCHAR(100) NOT NULL UNIQUE,
    mobilnr VARCHAR(8) NOT NULL UNIQUE,
    PRIMARY KEY (bruker_id)
);


CREATE TABLE booker(
    gruppetime_id INT NOT NULL,
    bruker_id INT NOT NULL,
    booket_tid TIMESTAMP NOT NULL,
    sjekket_inn_tid TIMESTAMP,
    booking_status VARCHAR(20) NOT NULL CHECK(booking_status IN ('booket', 'kansellert', 'ikke_møtt', 'møtt', 'venteliste')),
    kansellert_tid TIMESTAMP CHECK(kansellert_tid IS NULL OR booking_status='kansellert'),
    PRIMARY KEY (gruppetime_id, bruker_id),
    FOREIGN KEY (gruppetime_id) REFERENCES gruppetime(gruppetime_id),
    FOREIGN KEY (bruker_id) REFERENCES bruker(bruker_id)
);


CREATE TABLE idrettslag(
    idrettslag_id INT,
    navn VARCHAR(100) NOT NULL UNIQUE,
    PRIMARY KEY (idrettslag_id)
);


CREATE TABLE medlem_av(
    bruker_id INT,
    idrettslag_id INT,
    PRIMARY KEY (bruker_id, idrettslag_id),
    FOREIGN KEY (bruker_id) REFERENCES bruker(bruker_id),
    FOREIGN KEY (idrettslag_id) REFERENCES idrettslag(idrettslag_id)
);


CREATE TABLE gruppe(
    gruppe_id INT,
    navn VARCHAR(100) NOT NULL,
    idrettslag_id INT NOT NULL,
    UNIQUE(idrettslag_id, navn),
    PRIMARY KEY (gruppe_id),
    FOREIGN KEY (idrettslag_id) REFERENCES idrettslag(idrettslag_id)
);


CREATE TABLE reservasjon(
    reservasjon_id INT,
    dag VARCHAR(7) NOT NULL CHECK(dag IN ('mandag', 'tirsdag', 'onsdag', 'torsdag', 'fredag', 'lørdag', 'søndag')),
    start_tid TIME NOT NULL,
    slutt_tid TIME NOT NULL CHECK(slutt_tid > start_tid),
    valid_from DATE NOT NULL,
    valid_to DATE NOT NULL CHECK(valid_to >= valid_from),
    gruppe_id INT NOT NULL,
    sal_id INT NOT NULL,
    PRIMARY KEY (reservasjon_id),
    FOREIGN KEY (gruppe_id) REFERENCES gruppe(gruppe_id),
    FOREIGN KEY (sal_id) REFERENCES sal(sal_id)
);