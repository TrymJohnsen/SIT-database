import sqlite3

# koble til databasen
conn = sqlite3.connect("trening.db")

# slå på foreign keys
conn.execute("PRAGMA foreign_keys = ON")

#cursor er verktøyet python bruker for å utføre SQL-kommandoer
cursor = conn.cursor()

# test-query sqlite_master er en systemtabell som inneholder metadata om alle tabellene i databasen og deres navn
cursor.execute("SELECT name FROM sqlite_master WHERE type='table';")

#hent alle radene i resultatet av queryen
tables = cursor.fetchall()

print("Tables in database:")
for table in tables:
    print(table[0])

conn.close()