import os
import sqlite3

from datetime import datetime, timedelta
from pathlib import Path


BASE_DIR = Path(__file__).resolve().parent


def get_connection():
    conn = sqlite3.connect(DB_PATH)
    conn.execute("PRAGMA foreign_keys = ON")
    return conn


DB_PATH = BASE_DIR / "trening.db"
SCHEMA_PATH = BASE_DIR / "schema.sql"
SEED_PATH = BASE_DIR / "seed.sql"


def hent_prikker_siste_30_dager(cursor, bruker_id):
    cursor.execute(
        """
        SELECT g.start_tid
        FROM booker b
        JOIN gruppetime g ON b.gruppetime_id = g.gruppetime_id
        WHERE b.bruker_id = ?
          AND b.booking_status = 'ikke_møtt'
        ORDER BY g.start_tid
        """,
        (bruker_id,)
    )

    rader = cursor.fetchall()
    grense = datetime.now() - timedelta(days=30)
    prikker = []

    for start_tid, in rader:
        start_dt = datetime.fromisoformat(start_tid)
        if start_dt >= grense:
            prikker.append(start_dt)

    return prikker


def setup_database():
    if os.path.exists(DB_PATH):
        os.remove(DB_PATH)

    conn = sqlite3.connect(DB_PATH)
    conn.execute("PRAGMA foreign_keys = ON")

    try:
        with open(SCHEMA_PATH, "r", encoding="utf-8") as f:
            schema_sql = f.read()

        with open(SEED_PATH, "r", encoding="utf-8") as f:
            seed_sql = f.read()

        conn.executescript(schema_sql)
        conn.executescript(seed_sql)

        conn.commit()
        print("Databasen ble resatt og initialisert på nytt.")

    except Exception as e:
        conn.rollback()
        print(f"Feil ved oppsett av database: {e}")

    finally:
        conn.close()





def vis_gruppetimer():
    conn = get_connection()
    cursor = conn.cursor()

    query = """
    SELECT g.gruppetime_id, a.navn, g.start_tid, g.slutt_tid, t.navn
    FROM gruppetime g
    JOIN aktivitet a ON g.aktivitet_id = a.aktivitet_id
    JOIN sal s ON g.sal_id = s.sal_id
    JOIN treningssenter t ON s.treningssenter_id = t.treningssenter_id
    ORDER BY g.start_tid
    """

    cursor.execute(query)
    resultater = cursor.fetchall()

    print("\nTilgjengelige gruppetimer:")
    for gruppetime_id, aktivitet, start_tid, slutt_tid, senter in resultater:
        print(f"{gruppetime_id} | {aktivitet} | {start_tid} | {slutt_tid} | {senter}")

    conn.close()


def booking_trening(epost, aktivitet, start_tid):
    conn = get_connection()
    cursor = conn.cursor()

    try:
        # 1. Finn bruker
        cursor.execute("""
            SELECT bruker_id
            FROM bruker
            WHERE epost = ?
        """, (epost,))
        bruker = cursor.fetchone()

        if not bruker:
            print("Bruker finnes ikke.")
            return

        bruker_id = bruker[0]

        prikker_siste_30 = hent_prikker_siste_30_dager(cursor, bruker_id)
        if len(prikker_siste_30) >= 3:
            print("Brukeren er svartelistet og kan ikke booke timen.")
            return

        # 2. Finn alle gruppetimer som matcher aktivitet + starttid
        cursor.execute("""
            SELECT g.gruppetime_id, t.navn, g.start_tid, g.slutt_tid, s.kapasitet
            FROM gruppetime g
            JOIN aktivitet a ON g.aktivitet_id = a.aktivitet_id
            JOIN sal s ON g.sal_id = s.sal_id
            JOIN treningssenter t ON s.treningssenter_id = t.treningssenter_id
            WHERE LOWER(a.navn) = LOWER(?)
              AND g.start_tid = ?
            ORDER BY t.navn
        """, (aktivitet, start_tid))

        treff = cursor.fetchall()

        if len(treff) == 0:
            print("Treningen finnes ikke.")
            return

        # 3. Hvis flere treff: la brukeren velge gruppetime_id
        if len(treff) > 1:
            print("Flere treninger matcher aktivitet og tidspunkt:")
            for gruppetime_id, senter_navn, start, slutt, kapasitet in treff:
                print(f"{gruppetime_id} | {aktivitet} | {start} | {slutt} | {senter_navn}")

            valgt_id = int(input("Oppgi gruppetime-ID for timen du vil booke: ").strip())

            valgt_treff = None
            for rad in treff:
                if rad[0] == valgt_id:
                    valgt_treff = rad
                    break

            if valgt_treff is None:
                print("Ugyldig gruppetime-ID blant treffene.")
                return

            gruppetime_id, senter_navn, start, slutt, kapasitet = valgt_treff

        else:
            gruppetime_id, senter_navn, start, slutt, kapasitet = treff[0]

        # 4. Sjekk om brukeren allerede er booket
        cursor.execute("""
            SELECT 1
            FROM booker
            WHERE gruppetime_id = ?
              AND bruker_id = ?
        """, (gruppetime_id, bruker_id))

        if cursor.fetchone():
            print("Bruker er allerede booket på denne timen.")
            return

        # 5. Sjekk kapasitet
        cursor.execute("""
            SELECT COUNT(*)
            FROM booker
            WHERE gruppetime_id = ?
              AND booking_status IN ('booket', 'møtt')
        """, (gruppetime_id,))

        antall_booket = cursor.fetchone()[0]
        status = "booket" if antall_booket < kapasitet else "venteliste"

        #5.5 Sjekk for overlappende bookinger som er restriksjon i DB1 vi sier vi skal håndtere her
        cursor.execute("""
            SELECT g.gruppetime_id, g.start_tid, g.slutt_tid
            FROM booker b
            JOIN gruppetime g ON b.gruppetime_id = g.gruppetime_id
            WHERE b.bruker_id = ?
            AND b.booking_status IN ('booket', 'møtt', 'venteliste')
            AND g.start_tid < ?
            AND g.slutt_tid > ?
        """, (bruker_id, slutt, start))

        overlapp = cursor.fetchone()

        if overlapp:
            print("Brukeren er allerede booket på en annen time som overlapper.")
            return

        # 6. Opprett booking
        cursor.execute("""
            INSERT INTO booker (gruppetime_id, bruker_id, booket_tid, booking_status)
            VALUES (?, ?, CURRENT_TIMESTAMP, ?)
        """, (gruppetime_id, bruker_id, status))

        conn.commit()
        print(f"Booking registrert med status: {status}")
        print(f"Gruppetime: {aktivitet} | {start} | {senter_navn}")

    except Exception as e:
        conn.rollback()
        print("Feil ved booking:", e)

    finally:
        conn.close()




def registrer_oppmote(epost, gruppetime_id):
    conn = get_connection()
    cursor = conn.cursor()

    try:
        # 1 Finn bruker
        cursor.execute(
            "SELECT bruker_id FROM bruker WHERE epost = ?",
            (epost,)
        )
        bruker = cursor.fetchone()

        if not bruker:
            print("Bruker finnes ikke.")
            return

        bruker_id = bruker[0]

        # 2 Sjekk om booking finnes + hent starttid
        cursor.execute(
            """
            SELECT b.booking_status, g.start_tid
            FROM booker b
            JOIN gruppetime g ON b.gruppetime_id = g.gruppetime_id
            WHERE b.gruppetime_id = ?
            AND b.bruker_id = ?
            """,
            (gruppetime_id, bruker_id)
        )

        booking = cursor.fetchone()

        if not booking:
            print("Brukeren har ikke booket denne treningen.")
            return

        status = booking[0]
        start_tid = booking[1]

        if status == "kansellert":
            print("Kan ikke registrere oppmøte på en kansellert booking.")
            return

        if status == "møtt":
            print("Oppmøte er allerede registrert.")
            return

        # 3 Sjekk 5-minuttersregel
        start_dt = datetime.fromisoformat(start_tid)
        frist = start_dt - timedelta(minutes=5)
        now = datetime.now()

        if now > frist:
            print("Oppmøte må registreres senest 5 minutter før start.")
            return

        # 4 Registrer oppmøte
        cursor.execute(
            """
            UPDATE booker
            SET booking_status = 'møtt',
                sjekket_inn_tid = CURRENT_TIMESTAMP
            WHERE gruppetime_id = ?
            AND bruker_id = ?
            """,
            (gruppetime_id, bruker_id)
        )

        conn.commit()
        print("Oppmøte registrert.")

    except Exception as e:
        conn.rollback()
        print("Feil ved registrering av oppmøte:", e)

    finally:
        conn.close()

def vis_ukeplan(fra_dato, til_dato):
    conn = get_connection()
    cursor = conn.cursor()

    #? er plassholder for parameterne som skal settes inn i SQL-spørringen
    query = """
    SELECT g.gruppetime_id, a.navn, g.start_tid, g.slutt_tid, s.navn
    FROM gruppetime g
    JOIN aktivitet a ON g.aktivitet_id = a.aktivitet_id
    JOIN sal sa ON g.sal_id = sa.sal_id
    JOIN treningssenter s ON sa.treningssenter_id = s.treningssenter_id
    WHERE date(g.start_tid) BETWEEN ? AND ?
    ORDER BY g.start_tid
    """

    cursor.execute(query, (fra_dato, til_dato))
    resultater = cursor.fetchall()

    print("\nUkeplan:")
    for rad in resultater:
        print(rad)

    conn.close()


def vis_historikk(epost, fra_dato):
    conn = get_connection()
    cursor = conn.cursor()

    query = """
    SELECT DISTINCT a.navn, g.start_tid, s.navn
    FROM booker b
    JOIN bruker u ON b.bruker_id = u.bruker_id
    JOIN gruppetime g ON b.gruppetime_id = g.gruppetime_id
    JOIN aktivitet a ON g.aktivitet_id = a.aktivitet_id
    JOIN sal sa ON g.sal_id = sa.sal_id
    JOIN treningssenter s ON sa.treningssenter_id = s.treningssenter_id
    WHERE u.epost = ?
    AND date(g.start_tid) >= ?
    AND b.booking_status = 'møtt'
    ORDER BY g.start_tid
    """

    cursor.execute(query, (epost, fra_dato))
    resultater = cursor.fetchall()

    print("\nTreningshistorikk:")
    for rad in resultater:
        print(rad)

    conn.close()


def svartelist_bruker(epost):
    conn = get_connection()
    cursor = conn.cursor()

    try:
        # 1 Finn bruker
        cursor.execute(
            """
            SELECT bruker_id
            FROM bruker
            WHERE epost = ?
            """,
            (epost,)
        )

        bruker = cursor.fetchone()

        if not bruker:
            print("Bruker finnes ikke.")
            return

        bruker_id = bruker[0]

        prikker_siste_30 = hent_prikker_siste_30_dager(cursor, bruker_id)
        now = datetime.now()

        antall_prikker = len(prikker_siste_30)

        print(f"Bruker: {epost}")
        print(f"Antall prikker siste 30 dager: {antall_prikker}")

        if antall_prikker < 3:
            print("Brukeren er ikke utestengt.")
            return

        eldste_prikk = min(prikker_siste_30)
        utestengt_til = eldste_prikk + timedelta(days=30)

        if now < utestengt_til:
            print("Brukeren er utestengt fra nettbooking.")
            print("Utestengt til:", utestengt_til.strftime("%Y-%m-%d %H:%M:%S"))
        else:
            print("Brukeren er ikke lenger utestengt.")

    except Exception as e:
        print("Feil ved svartelisting:", e)

    finally:
        conn.close()




def legg_til_prikker_for_johnny():
    conn = get_connection()
    cursor = conn.cursor()

    try:
        cursor.execute(
            """
            SELECT bruker_id
            FROM bruker
            WHERE epost = ?
            """,
            ("johnny@stud.ntnu.no",)
        )
        bruker = cursor.fetchone()

        if not bruker:
            print("Fant ikke johnny@stud.ntnu.no i databasen.")
            return

        bruker_id = bruker[0]

        cursor.execute(
            """
            SELECT gruppetime_id
            FROM gruppetime
            ORDER BY start_tid DESC
            LIMIT 3
            """
        )
        gruppetimer = cursor.fetchall()

        if len(gruppetimer) < 3:
            print("Fant ikke tre gruppetimer for å registrere prikker.")
            return

        for gruppetime_id, in gruppetimer:
            cursor.execute(
                """
                INSERT INTO booker (
                    gruppetime_id,
                    bruker_id,
                    booket_tid,
                    sjekket_inn_tid,
                    booking_status,
                    kansellert_tid
                )
                VALUES (?, ?, CURRENT_TIMESTAMP, NULL, 'ikke_møtt', NULL)
                ON CONFLICT(gruppetime_id, bruker_id) DO UPDATE SET
                    sjekket_inn_tid = NULL,
                    booking_status = 'ikke_møtt',
                    kansellert_tid = NULL
                """,
                (gruppetime_id, bruker_id)
            )

        conn.commit()

    except Exception as e:
        conn.rollback()
        print("Feil ved registrering av prikker:", e)

    finally:
        conn.close()



def mest_aktive(aar, maaned):
    conn = get_connection()
    cursor = conn.cursor()

    #strftime er en SQLite-funksjon for å hente ut deler av en dato. 
    query = """
    SELECT u.epost, COUNT(*) AS antall
    FROM booker b
    JOIN bruker u ON b.bruker_id = u.bruker_id
    JOIN gruppetime g ON b.gruppetime_id = g.gruppetime_id
    WHERE strftime('%Y', g.start_tid) = ?
    AND strftime('%m', g.start_tid) = ?
    AND b.booking_status = 'møtt'
    GROUP BY u.bruker_id
    HAVING antall = (
        SELECT MAX(cnt)
        FROM (
            SELECT COUNT(*) AS cnt
            FROM booker b2
            JOIN gruppetime g2 ON b2.gruppetime_id = g2.gruppetime_id
            WHERE strftime('%Y', g2.start_tid) = ?
            AND strftime('%m', g2.start_tid) = ?
            AND b2.booking_status = 'møtt'
            GROUP BY b2.bruker_id
        )
    )
    """

    #zfill(2) sørger for at måneden alltid har to sifre (f.eks. "1" blir "01" for januar).
    cursor.execute(query, (aar, maaned.zfill(2), aar, maaned.zfill(2)))
    resultater = cursor.fetchall()

    print("\nMest aktive medlemmer:")
    for rad in resultater:
        print(rad)

    conn.close()


def trener_sammen(epost1, epost2):
    conn = get_connection()
    cursor = conn.cursor()

    query = """
    SELECT COUNT(*)
    FROM booker b1
    JOIN booker b2 
        ON b1.gruppetime_id = b2.gruppetime_id
    JOIN bruker u1 
        ON b1.bruker_id = u1.bruker_id
    JOIN bruker u2 
        ON b2.bruker_id = u2.bruker_id
    WHERE u1.epost = ?
    AND u2.epost = ?
    AND b1.booking_status = 'møtt'
    AND b2.booking_status = 'møtt'
    """

    cursor.execute(query, (epost1, epost2))
    resultat = cursor.fetchone()[0]

    print(f"{epost1} og {epost2} har trent sammen {resultat} ganger.")

    conn.close()
