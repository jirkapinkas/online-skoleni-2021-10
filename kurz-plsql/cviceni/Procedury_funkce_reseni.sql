/* PF001: Vytvořte funkci, která vrátí počet letů pilota se zadaným id 
(pilot.pilot_id). S použitím této funkce napište SQL dotaz, který vrátí 
jména a příjmení pilotů, kteří letěli alespoň 2x. */
SET SERVEROUTPUT ON
CREATE OR REPLACE FUNCTION get_pocet_letu(p_pilot_id pilot.pilot_id%TYPE) 
RETURN NUMBER AS
  v_pocet_letu NUMBER DEFAULT 0;
BEGIN
  SELECT COUNT(let.pilot_id) INTO v_pocet_letu 
  FROM pilot p LEFT JOIN let ON p.pilot_id = let.pilot_id
  WHERE p.pilot_id = p_pilot_id;

  RETURN v_pocet_letu;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    dbms_output.put_line('Pilot s ID = ' || p_pilot_id || ' nebyl nalezen.');
  WHEN TOO_MANY_ROWS THEN
    dbms_output.put_line('Bylo vybrano mnoho radku, ne jeden!');
END;
/
SHOW ERRORS;

SELECT z.prijmeni, z.jmeno FROM zamestnanec z, pilot p 
WHERE z.zamestnanec_id = p.zamestnanec_id
AND get_pocet_letu(p.pilot_id) >= 2;

-- Bez PL/SQL
SELECT z.prijmeni, z.jmeno, COUNT(let.pilot_id) AS pocet_letu 
FROM zamestnanec z, pilot p 
LEFT JOIN let ON p.pilot_id = let.pilot_id
WHERE z.zamestnanec_id = p.zamestnanec_id
GROUP BY let.pilot_id, z.prijmeni, z.jmeno
HAVING COUNT(let.pilot_id) >= 2;


/* PF002: Napište proceduru, která vypíše na konzoli všechny pasažéry, 
se kterými letěl pilot se zadaným pilot_id. */
SET SERVEROUTPUT ON
CREATE OR REPLACE PROCEDURE vypis_pasazery_pilota(p_pilot_id pilot.pilot_id%TYPE) AS
  v_jmeno pasazer.jmeno%TYPE;
  v_prijmeni pasazer.prijmeni%TYPE;
  CURSOR pasazeri_pilota IS 
    SELECT pa.jmeno, pa.prijmeni 
    FROM pasazer pa, let, ucastnik_letu ul
    WHERE let.pilot_id = p_pilot_id AND let.cislo_letu = ul.cislo_letu
    AND ul.pasazer_id = pa.pasazer_id;
BEGIN
  IF NOT pasazeri_pilota%ISOPEN THEN
    OPEN pasazeri_pilota;
  END IF;
  LOOP
    FETCH pasazeri_pilota INTO v_jmeno, v_prijmeni;
    EXIT WHEN pasazeri_pilota%NOTFOUND;
    dbms_output.put_line('Jméno: ' || v_jmeno || ', příjmení: ' || v_prijmeni);
  END LOOP;
  CLOSE pasazeri_pilota;
END;
/
SHOW ERRORS;

-- Pro otestování spustit v samostatném SQL worksheet příkazy: 
SET SERVEROUTPUT ON
EXECUTE AERO.vypis_pasazery_pilota(1);


/* PF003: Napište proceduru, která vypíše jména všech zaměstnanců ve 
formátu: <příjmení><zadaný znak><jméno>. Jako výchozí hodnotu spojovacího 
znaku použijte '_', aby nemusel uživatel procedury znak vždy zadávat. 
Zkuste proceduru zavolat se zadáním a bez zadání spojovacího znaku. */
SET SERVEROUTPUT ON
CREATE OR REPLACE PROCEDURE vypis_jmena_zamestnancu(p_spojovaci_znak CHAR DEFAULT '_') AS
  v_zamestnanec zamestnanec%ROWTYPE;
  CURSOR zamestnanci IS
    SELECT z.prijmeni, z.jmeno FROM zamestnanec z;
BEGIN
  FOR v_zamestnanec IN zamestnanci 
  LOOP
    dbms_output.put_line(v_zamestnanec.prijmeni 
      || p_spojovaci_znak || v_zamestnanec.jmeno);
  END LOOP;
END;
/
SHOW ERRORS;

-- Pro otestování spustit v samostatném SQL worksheet příkazy: 
SET SERVEROUTPUT ON
EXECUTE AERO.vypis_jmena_zamestnancu;
EXECUTE AERO.vypis_jmena_zamestnancu();
EXECUTE AERO.vypis_jmena_zamestnancu('-');
-- všechny tyto varianty fungují


/* PF004: Napište proceduru, která povýší všechny "Dispečery letového provozu", 
kteří do aerolinek nastoupili do zadaného data včetně (zadáno v parametru), 
na "Hlavní dispečery letového provozu" (viz. zaměstnání v tabulce zamestnani). 
Proceduru vyzkoušejte na datu 1.1.2002. Po provedení procedury by měli být 
2 dispečeři povýšeni na hlavní dispečery a v aerolinkách by mělo zůstat 
13 "obyčejných" dispečerů letového provozu. */
SET SERVEROUTPUT ON
CREATE OR REPLACE PROCEDURE povys_dispecery(p_nastup_do_data DATE) AS
  v_dispecer zamestnanec%ROWTYPE;
  v_hlavni_dispecer_id zamestnani.zamestnani_id%TYPE;
  -- Kurzor pro vyber povysovanych dispeceru, 
  -- uzamknuti vyslednych radku pro nasledny UPDATE
  CURSOR dispeceri IS
    SELECT zc.zamestnanec_id 
    FROM zamestnanec zc, zamestnani zi
    WHERE zc.zamestnani_id = zi.zamestnani_id
    AND zi.nazev_pozice = 'Dispečer letového provozu'
    AND zc.datum_nastupu <= p_nastup_do_data
    FOR UPDATE OF zc.zamestnani_id;
BEGIN
  -- Zjistime ID zamestnani 'Hlavní dispečer letového provozu'
  SELECT zamestnani_id INTO v_hlavni_dispecer_id FROM zamestnani
  WHERE nazev_pozice = 'Hlavní dispečer letového provozu';

  -- Povyseni dispeceru
  FOR v_dispecer IN dispeceri LOOP
    UPDATE zamestnanec SET zamestnani_id = v_hlavni_dispecer_id 
    WHERE CURRENT OF dispeceri;
  END LOOP;
  -- Potvrzeni zmeny, uvolneni zamcenych zaznamu
  COMMIT;
END;
/


/* PF005: Napište proceduru, která pro zadané tabulky (jména tabulek) vytvoří 
záložní tabulky s názvem <jméno tabulky>_bak a do těchto záložních tabulek 
zduplikuje data z originálních tabulek. Při tvorbě procedury použijte příkaz 
CREATE TABLE <název tabulky> AS <příkaz SELECT>; a příkaz EXECUTE IMMEDIATE. */
CREATE OR REPLACE TYPE seznam_db_nazvu AS TABLE OF VARCHAR2(32 CHAR);

SET SERVEROUTPUT ON
CREATE OR REPLACE PROCEDURE zalohuj_tabulky(p_tabulky seznam_db_nazvu) AS
BEGIN
  FOR i IN p_tabulky.FIRST .. p_tabulky.LAST LOOP
    EXECUTE IMMEDIATE
      'CREATE TABLE ' || p_tabulky(i) || '_bak AS SELECT * FROM ' 
        || p_tabulky(i);
  END LOOP;
END;
/
SHOW ERRORS;

-- Vyzkoušení procedury:
EXECUTE zalohuj_tabulky(seznam_db_nazvu('zamestnanec', 'typ_letadla'));


/* PF006: Napište funkci, která spočítá počet zaměstnanců, kteří byli přijati 
v zadaném rozmezí roků (např. v intervalu <2002; 2005>) - roky budou 
parametry funkce. */
SET SERVEROUTPUT ON
CREATE OR REPLACE FUNCTION get_pocet_zam_prij_v_letech(
p_rok_od NUMBER, p_rok_do NUMBER) RETURN NUMBER AS
  v_pocet NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_pocet FROM zamestnanec z
  WHERE EXTRACT(YEAR FROM z.datum_nastupu) BETWEEN p_rok_od AND p_rok_do;
  RETURN v_pocet;
END;
/
SHOW ERRORS;

-- Vyzkoušení funkce:
SELECT get_pocet_zam_prij_v_letech(2002, 2005) AS pocet FROM dual;


/* PF007: Napište proceduru, která na konzoli vypíše přehlednou tabulku 
s příjmeními, jmény, platem zaměstnanců a počtem letů, které daný zaměstnanec 
absolvoval – pokud se jedná o pilota, vypište skutečný počet letů, 
u ostatních zaměstnanců vždy 0. Údaje vypište pouze pro zaměstnance, kteří 
byli přijati v zadaném rozmezí roků (např. v intervalu <2002; 2005>)  - roky 
budou parametry procedury. Tabulku vykreslete se záhlavím pomocí čárové 
grafiky. Pro zarovnávání údajů do sloupců tabulky použijte funkce LPAD, RPAD. */
SET SERVEROUTPUT ON
CREATE OR REPLACE PROCEDURE vypis_zamestnance_s_lety(
p_rok_od NUMBER, p_rok_do NUMBER) AS
  TYPE z_zamestnanec IS RECORD (
    prijmeni    zamestnanec.prijmeni%TYPE,
    jmeno       zamestnanec.jmeno%TYPE,
    plat        zamestnanec.plat%TYPE,
    pocet_letu  NUMBER
  );
  
  CURSOR c_zamestnanci IS
    SELECT z.prijmeni, z.jmeno, z.plat, COUNT(let.pilot_id) AS pocet_letu
    FROM zamestnanec z LEFT JOIN pilot p ON z.zamestnanec_id = p.zamestnanec_id
    LEFT JOIN let ON p.pilot_id = let.pilot_id
    WHERE EXTRACT(YEAR FROM z.datum_nastupu) BETWEEN p_rok_od AND p_rok_do
    GROUP BY z.zamestnanec_id, z.prijmeni, z.jmeno, z.plat
    ORDER BY z.prijmeni, z.jmeno;
BEGIN
  DBMS_OUTPUT.PUT_LINE('PRIJMENI        JMENO        PLAT       POCET_LETU');
  DBMS_OUTPUT.PUT_LINE('--------------- ------------ ---------- ----------');
  FOR z_zamestnanec IN c_zamestnanci
  LOOP
    DBMS_OUTPUT.PUT_LINE(
      RPAD(z_zamestnanec.prijmeni, 15, ' ') || ' ' 
      || RPAD(z_zamestnanec.jmeno, 12, ' ') || ' '
      || LPAD(z_zamestnanec.plat, 10, ' ') || ' ' 
      || LPAD(z_zamestnanec.pocet_letu, 10, ' '));
  END LOOP;
END;
/
SHOW ERRORS;

-- Vyzkoušení procedury:
EXECUTE vypis_zamestnance_s_lety(2002, 2005);


/* PF008: Napište funkci, která pro daného zaměstnance (zamestnanec_id) vrátí 
počet podřízených na zadané úrovni pod zaměstnancem – použijte parametr 
uroven_podrizenych: 1 = přímí podřízení, 2 podřízení přímých podřízených atd. 
Pro průchod hierarchií lze použít dotaz SELECT – FROM – WHERE – START WITH – 
CONNECT BY (nebo pouhé spojování tabulek – tabulky zamestnanec jednou v roli 
nadřízených, jindy v roli podřízených zaměstnanců). Pokud by byla zadaná 
úroveň 0, vyvolejte ve funkci vlastní výjimku NEPLATNA_UROVEN a v sekci 
EXCEPTION tuto výjimku ošetřete výpisem chybového hlášení na konzoli. */
CREATE OR REPLACE FUNCTION get_pocet_podrizenych(p_zamestnanec_id IN NUMBER, 
p_uroven IN NUMBER) RETURN NUMBER AS
  v_pocet_podrizenych NUMBER;
  NEPLATNA_UROVEN EXCEPTION;
BEGIN
  IF p_uroven < 1 THEN
    RAISE NEPLATNA_UROVEN;
  END IF;
  
  SELECT COUNT(*) INTO v_pocet_podrizenych FROM zamestnanec z
  WHERE level = p_uroven + 1 -- primi podrizeni maji level 2
  START WITH z.zamestnanec_id = p_zamestnanec_id
  CONNECT BY PRIOR z.zamestnanec_id = z.nadrizeny;
  
  RETURN v_pocet_podrizenych;
EXCEPTION
  WHEN NEPLATNA_UROVEN THEN 
    DBMS_OUTPUT.PUT_LINE(
      'Uroven podrizenych musi byt vetsi nez 0: ' 
        || '1 = primi podrizeni, 2 podrizeni primych podrizenych atd.');
END;
/
SHOW ERRORS;

-- Vyzkoušení funkce:
SELECT get_pocet_podrizenych(1, 1) AS pocet_podrizenych FROM dual;


/* PF009: Vytvořte proceduru vypis_podrizene, která pro každého zaměstnance 
vypíše počet podřízených na první a druhé úrovni ve smyslu příkladu PF008 
(můžete využít předchozí funkci). */
CREATE OR REPLACE PROCEDURE vypis_podrizene AS
  v_zamestnanec zamestnanec%ROWTYPE;  
  CURSOR c_zamestnanci IS
    SELECT z.zamestnanec_id, z.prijmeni, z.jmeno
    FROM zamestnanec z
    ORDER BY z.prijmeni, z.jmeno;
BEGIN
  FOR v_zamestnanec IN c_zamestnanci
  LOOP
    DBMS_OUTPUT.PUT_LINE(
      RPAD(v_zamestnanec.prijmeni, 15, ' ') || ' ' 
      || RPAD(v_zamestnanec.jmeno, 12, ' ') || ' '
      || LPAD(get_pocet_podrizenych(v_zamestnanec.zamestnanec_id, 1), 4, ' ') || ' ' 
      || LPAD(get_pocet_podrizenych(v_zamestnanec.zamestnanec_id, 2), 4, ' '));
  END LOOP;
END;
/
SHOW ERRORS;

-- Vyzkoušení procedury:
EXECUTE vypis_podrizene;


/* PF010: Vytvořte rekurzivní funkci, která spočítá všechny podřízené daného 
zaměstnance  (tj. od 1. úrovně "hlouběji", úroveň chápejte ve smyslu zadání 
příkladu PF008). Nepoužívejte SELECT – FROM – WHERE – START WITH – CONNECT BY. 
*/
CREATE OR REPLACE FUNCTION get_pocet_podrizenych_rek(
p_zamestnanec_id IN NUMBER) RETURN NUMBER AS
  v_pocet_podrizenych NUMBER;
  -- primy podrizeny tohoto zamestnance (s p_zamestnanec_id):
  v_primy_podrizeny zamestnanec%ROWTYPE;
  -- kurzor pro zjisteni primych podrizenych tohoto zamestnance 
  -- (s p_zamestnanec_id):
  CURSOR c_primi_podrizeni IS
    SELECT z.zamestnanec_id FROM zamestnanec z
    WHERE z.nadrizeny = p_zamestnanec_id;
BEGIN
  -- spocitame pocet primych podrizenych
  SELECT COUNT(*) INTO v_pocet_podrizenych FROM zamestnanec z
  WHERE z.nadrizeny = p_zamestnanec_id;
  -- projdeme vsechny podrizene a rekurzivne spocitame pocet jejich podrizenych
  FOR v_primy_podrizeny IN c_primi_podrizeni LOOP
    v_pocet_podrizenych := v_pocet_podrizenych +
      get_pocet_podrizenych_rek(v_primy_podrizeny.zamestnanec_id);
  END LOOP;
  
  RETURN v_pocet_podrizenych;
END;
/
SHOW ERRORS;

-- Vyzkoušení funkce:
SELECT get_pocet_podrizenych_rek(1) FROM dual;


