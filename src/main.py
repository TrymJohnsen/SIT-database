from usecases import (
    setup_database,
    booking_trening,
    registrer_oppmote,
    vis_ukeplan,
    vis_historikk,
    svartelist_bruker,
    mest_aktive,
    trener_sammen,
)


def print_meny():
    print("\n--- TreningDB ---")
    print("1. Booking av gruppetime")
    print("2. Registrere oppmøte")
    print("3. Vise ukeplan")
    print("4. Vise personlig treningshistorikk")
    print("5. Svarteliste bruker")
    print("6. Månedens mest aktive medlemmer")
    print("7. Finne brukere som trener sammen")
    print("0. Avslutt")


def main():
    setup_database()
    while True:
        print_meny()
        valg = input("Velg et alternativ: ").strip()


        if valg == "1":
            epost = input("Oppgi e-post: ").strip()
            gruppetime_id = input("Oppgi gruppetime-ID: ").strip()
            booking_trening(epost, gruppetime_id)

        elif valg == "2":
            epost = input("Oppgi e-post: ").strip()
            gruppetime_id = input("Oppgi gruppetime-ID: ").strip()
            registrer_oppmote(epost, gruppetime_id)

        elif valg == "3":
            fra_dato = input("Oppgi fra-dato (YYYY-MM-DD): ").strip()
            til_dato = input("Oppgi til-dato (YYYY-MM-DD): ").strip()
            vis_ukeplan(fra_dato, til_dato)

        elif valg == "4":
            epost = input("Oppgi e-post: ").strip()
            fra_dato = input("Oppgi fra-dato (YYYY-MM-DD): ").strip()
            vis_historikk(epost, fra_dato)

        elif valg == "5":
            epost = input("Oppgi e-post: ").strip()
            svartelist_bruker(epost)

        elif valg == "6":
            aar = input("Oppgi år (YYYY): ").strip()
            maaned = input("Oppgi måned (1-12): ").strip()
            mest_aktive(aar, maaned)

        elif valg == "7":
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