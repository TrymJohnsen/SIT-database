from usecases import (
    setup_database,
    booking_trening,
    registrer_oppmote,
    vis_ukeplan,
    vis_historikk,
    legg_til_prikker_for_johnny,
    svartelist_bruker,
    mest_aktive,
    trener_sammen,
    vis_gruppetimer,
)


def print_meny():
    print("\n--- TreningDB ---")
    print("1. sett opp/resette database")
    print("2. Booking av gruppetime")
    print("3. Registrere oppmøte")
    print("4. Vise ukeplan")
    print("5. Vise personlig treningshistorikk")
    print("6. Svarteliste bruker")
    print("7. Månedens mest aktive medlemmer")
    print("8. Finne brukere som trener sammen")
    print("0. Avslutt")


def main():
    # setup_database()
    while True:
        print_meny()
        valg = input("Velg et alternativ: ").strip()

        if valg == "1":
            setup_database()
            print("Database satt opp med testdata.")

        if valg == "2":
            vis_gruppetimer()
            epost = input("\nOppgi e-post: ").strip()
            aktivitet = input("Oppgi aktivitet: ").strip().title()
            start_tid = input("Oppgi start-tid (YYYY-MM-DD HH:MM:SS): ").strip()
            booking_trening(epost, aktivitet, start_tid)

        elif valg == "3":
            epost = input("Oppgi e-post: ").strip()
            gruppetime_id = input("Oppgi gruppetime-ID: ").strip()
            registrer_oppmote(epost, gruppetime_id)

        elif valg == "4":
            fra_dato = input("Oppgi fra-dato (YYYY-MM-DD): ").strip()
            til_dato = input("Oppgi til-dato (YYYY-MM-DD): ").strip()
            vis_ukeplan(fra_dato, til_dato)

        elif valg == "5":
            epost = input("Oppgi e-post: ").strip()
            fra_dato = input("Oppgi fra-dato (YYYY-MM-DD): ").strip()
            vis_historikk(epost, fra_dato)

        elif valg == "6":
            epost = input("Oppgi e-post: ").strip()
            if epost == "johnny@stud.ntnu.no":
                legg_til_prikker_for_johnny()
            svartelist_bruker(epost)

        elif valg == "7":
            aar = input("Oppgi år (YYYY): ").strip()
            maaned = input("Oppgi måned (1-12): ").strip()
            mest_aktive(aar, maaned)

        elif valg == "8":
            epost1 = input("Oppgi e-post til første bruker: ").strip()
            epost2 = input("Oppgi e-post til andre bruker: ").strip()
            trener_sammen(epost1, epost2)

        elif valg == "0":
            print("Avslutter programmet.")
            break

        else:
            print("Ugyldig valg. Prøv igjen.")


if __name__ == "__main__":
    main()
