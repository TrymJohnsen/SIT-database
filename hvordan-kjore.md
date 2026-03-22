# Hvordan kjøre brukstilfeller

## 1. Sett opp databasen

Velg:

```text
1
ja
```

Da blir databasen opprettet på nytt med testdata.

## 2. Booking av "Spin60" for Johnny

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

## 3. Registrere oppmøte

Eksempel på input:

```text
3
johnny@stud.ntnu.no
5
```

Dette registrerer oppmøte for Johnny pa gruppetime `5`. Denne funksjonen forutsetter egentlig at registreringen skjer senest 5 minutter før start, men for at det skal være reproduserbart har vi kommentert ut denne delen av koden.

## 4. Vise ukeplan for uke 12

For oppgavens periode `16.03.2026` til `23.03.2026`:

```text
4
2026-03-16
2026-03-23
```

## 5. Vise personlig historikk

```text
5
johnny@stud.ntnu.no
2026-01-01
```

Merk at historikken bare viser treninger med status `møtt`.

## 6. Svartelisting

```text
6
johnny@stud.ntnu.no
```

I implementasjonen vår legges det automatisk inn tre prikker for Johnny når du velger menyvalg 6 med akkurat denne e-posten. Deretter sjekker programmet om brukeren skal utestenges fra booking i 30 dager.

## 7. Mest aktive medlemmer i en måned

```text
7
2026
3
```

## 8. Finne to brukere som trener sammen

```text
8
johnny@stud.ntnu.no
emma@stud.ntnu.no
```
