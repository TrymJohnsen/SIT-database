# SIT-database

TreningDB er en liten menybasert SQLite-applikasjon laget for databasefaget. Programmet lar deg sette opp databasen, booke gruppetimer, registrere oppmøte, vise ukeplan, hente treningshistorikk, svarteliste brukere og kjøre analyser på treningsdata.

## Starte programmet

1. Åpne en terminal i prosjektmappen.
2. Kjør:

```bash
python src/main.py
```

Programmet starter da en tekstmeny i terminalen.

## Viktig: databasen må settes opp fra menyen

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

## Hvordan kjøre brukstilfeller

En egen oppskrift med eksempelinput ligger i [hvordan-kjore.md].

## SQL-leveranse

SQL for brukstilfellene ligger i [src/usecase_queries.sql].
For å gjøre det enkelt å kjøre er all sql som kjøres inni usecases.py og kjøres gjennom terminalen.

Brukstilfelle 1 er dekket av:

- [src/schema.sql]
- [src/seed.sql]

## Praktiske merknader

- Databasen opprettes som `trening.db` inni `src`-mappen.
- Programmet er laget for terminalbruk og all input skrives manuelt i menyen.
