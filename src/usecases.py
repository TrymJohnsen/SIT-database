import sqlite3

def get_connection():
    conn = sqlite3.connect("trening.db")
    conn.execute("PRAGMA foreign_keys = ON")
    return conn


#conn er databaseforbindelsen, cursor er verktøyet for å utføre SQL-kommandoer
def setup_database():
    conn = get_connection()
    cursor = conn.cursor()

    print("Setup database er ikke implementert ennå.")

    conn.close()


def booking_trening(epost, gruppetime_id):
    print(f"Booking av gruppetime {gruppetime_id} for {epost} er ikke implementert ennå.")


def registrer_oppmote(epost, gruppetime_id):
    print(f"Registrering av oppmøte for {epost} på gruppetime {gruppetime_id} er ikke implementert ennå.")


def vis_ukeplan(fra_dato, til_dato):
    conn = get_connection()
    cursor = conn.cursor()

    #? er plassholder for parameterne som skal settes inn i SQL-spørringen
    query = """
    SELECT g.gruppetime_id, a.navn, g.start_tid, g.slutt_tid, s.navn
    FROM gruppetime g
    JOIN aktivitet a ON g.aktivitet_id = a.aktivitet_id
    JOIN sal sa ON g.sal_id = sa.sal_id
    JOIN treningssenter s ON sa.senter_id = s.senter_id
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
    JOIN treningssenter s ON sa.senter_id = s.senter_id
    WHERE u.epost = ?
    AND date(g.start_tid) >= ?
    AND b.status = 'møtt'
    ORDER BY g.start_tid
    """

    cursor.execute(query, (epost, fra_dato))
    resultater = cursor.fetchall()

    print("\nTreningshistorikk:")
    for rad in resultater:
        print(rad)

    conn.close()


def svartelist_bruker(epost):
    print(f"Svartelisting for {epost} er ikke implementert ennå.")


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
    AND b.status = 'møtt'
    GROUP BY u.bruker_id
    HAVING antall = (
        SELECT MAX(cnt)
        FROM (
            SELECT COUNT(*) AS cnt
            FROM booker b2
            JOIN gruppetime g2 ON b2.gruppetime_id = g2.gruppetime_id
            WHERE strftime('%Y', g2.start_tid) = ?
            AND strftime('%m', g2.start_tid) = ?
            AND b2.status = 'møtt'
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
    print(f"Sjekker om {epost1} og {epost2} trener sammen.")