# SIT-database

TreningDB er en liten menybasert SQLite-applikasjon laget for databasefaget. Programmet lar deg sette opp databasen, booke gruppetimer, registrere oppmote, vise ukeplan, hente treningshistorikk, svarteliste brukere og kjore analyser pa treningsdata.

## Starte programmet

1. Åpne en terminal i prosjektmappen.
2. Kjør:

```bash
python src/main.py
```

Programmet starter da en tekstmeny i terminalen.

## Viktig: databasen ma settes opp fra menyen

For at programmet skal fungere må databasen opprettes med menyvalg `1. sett opp/resette database`.

Dette menyvalget:

- oppretter SQLite-databasen `src/trening.db`
- kjører [src/schema.sql] for tabellene
- kjører [src/seed.sql] for testdata

Hvis du ikke velger menyvalg 1 først, vil de andre valgene mangle tabeller eller data.

## Kort om menyen

Når programmet kjører, velger du et tall og trykker Enter.

- `1`: setter opp eller nullstiller databasen med testdata
- `2`: booker en gruppetime for en bruker
- `3`: registrerer oppmøte på en allerede booket time
- `4`: viser ukeplan mellom to datoer
- `5`: viser personlig treningshistorikk fra en valgt dato
- `6`: sjekker om en bruker skal svartelistes
- `7`: finner medlemmet eller medlemmene med flest deltakelser i en måned
- `8`: viser hvor mange ganger to brukere har trent sammen
- `0`: avslutter programmet

## Sammenheng med brukstilfellene

Oppgaven er dekket slik i kodebasen:

- Brukstilfelle 1: SQL-oppsett og eksempeldata ligger i [src/schema.sql] og [src/seed.sql]
- Brukstilfelle 2: booking i Python ligger i [src/usecases.py], funksjonen `booking_trening`
- Brukstilfelle 3: oppmøteregistrering ligger i [src/usecases.py], funksjonen `registrer_oppmote`
- Brukstilfelle 4: ukeplan ligger i [src/usecases.py], funksjonen `vis_ukeplan`
- Brukstilfelle 5: besøkshistorikk ligger i [src/usecases.py], funksjonen `vis_historikk`
- Brukstilfelle 6: svartelisting ligger i [src/usecases.py], funksjonene `hent_prikker_siste_30_dager`, `legg_til_prikker_for_johnny` og `svartelist_bruker`
- Brukstilfelle 7: mest aktive medlemmer ligger i [src/usecases.py], funksjonen `mest_aktive`
- Brukstilfelle 8: analyse av brukere som trener sammen ligger i [src/usecases.py], funksjonen `trener_sammen`

## Eksempel på bruk

### 1. Sett opp databasen

Velg:

```text
1
ja
```

Da blir databasen opprettet på nytt med testdata.

### 2. Booking av "Spin60" for Johnny

Seed-dataene inneholder to `Spin60`-timer tirsdag `2026-03-17 18:30:00`, en på Øya og en på Dragvoll. Hvis du vil booke Øya-timen for `johnny@stud.ntnu.no`, kan du bruke:

```text
2
johnny@stud.ntnu.no
Spin60
2026-03-17 18:30:00
5
```

Forklaring:

- `2` velger booking
- `johnny@stud.ntnu.no` er brukeren
- `Spin60` er aktiviteten
- `2026-03-17 18:30:00` er starttidspunktet
- `5` er gruppetime-ID-en for Øya-økt

Programmet sjekker at treningen finnes før booking, og hvis flere timer matcher aktivitet og tidspunkt må du velge riktig `gruppetime_id`.

### 3. Registrere oppmøte

Eksempel på input:

```text
3
johnny@stud.ntnu.no
5
```

Dette registrerer oppmøte for Johnny pa gruppetime `5`. Denne funksjonen forutsetter egentlig at registreringen skjer senest 5 minutter for start, men for at det skal være reproduserbart har vi kommentert ut denne delen av koden.

### 4. Vise ukeplan for uke 12

For oppgavens periode `16.03.2026` til `23.03.2026`:

```text
4
2026-03-16
2026-03-23
```

### 5. Vise personlig historikk

```text
5
johnny@stud.ntnu.no
2026-01-01
```

Merk at historikken bare viser treninger med status `møtt`.

### 6. Svartelisting

```text
6
johnny@stud.ntnu.no
```

I implementasjonen vår legges det automatisk inn tre prikker for Johnny når du velger menyvalg 6 med akkurat denne e-posten. Deretter sjekker programmet om brukeren skal utestenges fra booking i 30 dager.

### 7. Mest aktive medlemmer i en maned

```text
7
2026
3
```

### 8. Finne to brukere som trener sammen

```text
8
johnny@stud.ntnu.no
emma@stud.ntnu.no
```

## Praktiske merknader

- Databasen opprettes som `trening.db` inni `src`-mappen.
- Programmet er laget for terminalbruk og all input skrives manuelt i menyen.
- Menyvalg 3 for oppmote er tidsavhengig. Hvis timen allerede har startet, vil programmet avvise innsjekking.
