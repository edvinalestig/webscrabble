# Upplägg av projektet

## Logiken
Skriven i ruby med sinatra.

All spellogik styrs med hjälp av ruby. Uppkopplingen mot klienterna styrs av sinatra och gränssnittet skapas med HTML, CSS och javascript. Gränssnittet använder p5.js för att skapa spelplanen och annan grafik.

## Användargränssnitt

Skriven i javascript med hjälp av libraryt p5.js.

## Version 1
Spelare 1 går in på \<adress>/p1 och spelare 2 går in på \<adress>/p2 i sin webbläsare. De kopplas upp mot servern och får varsitt gränssnitt. Spelare 1 gör sitt drag och spelare 2 får manuellt uppdatera sidan.


Spelet har en main class som har massa methods som styr spelet. Spelarna har varsin class för att hålla reda på deras speldata (poäng, ev. namn, m.m.).

En class sköter orden och kollar om de finns. Ändras ev. till OED:s API i senare versioner.