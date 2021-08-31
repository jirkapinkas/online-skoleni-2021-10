/* TR001: Vytvořte trigger, který při vkládání nového záznamu do tabulky 
ucastnik_letu s počtem přestupků > 0 nastaví danému pasažérovi v tabulce 
pasazer příznak, že je problematický. */
CREATE OR REPLACE TRIGGER SET_problematicky_pasazer 
BEFORE INSERT ON ucastnik_letu FOR EACH ROW
DECLARE
BEGIN
  IF :NEW.pocet_prestupku > 0 THEN
    UPDATE pasazer SET problematicky = 'y' 
    WHERE pasazer_id = :NEW.pasazer_id;
  END IF;
END;
/
SHOW ERRORS;

-- Vyzkoušení triggeru:
INSERT INTO ucastnik_letu (cislo_letu, pasazer_id, odkud, kam, cena, 
pocet_prestupku) VALUES ('OK1', 54, 73, 16, 5000, 1);
COMMIT;


/* TR002: Vytvořte trigger, který znemožní vložení dalšího záznamu do tabulky 
ucastnik_letu pro daného pasažéra, pokud je stávající počet přestupků pasažéra 
(bez nového záznamu) 3 a více (pasažér se již nebude moci účastnit žádného 
dalšího letu aerolinek). */
CREATE OR REPLACE TRIGGER TR_max_pocet_prestupku
BEFORE INSERT ON ucastnik_letu FOR EACH ROW
DECLARE
  v_pocet_prestupku NUMBER := 0;
BEGIN
  SELECT SUM(ul.pocet_prestupku) INTO v_pocet_prestupku FROM ucastnik_letu ul
  WHERE ul.pasazer_id = :NEW.pasazer_id;
  
  IF v_pocet_prestupku >= 3 THEN
    -- jen pro ucely ladeni - rozpoznani, ze byl trigger spusten a zabranil
    -- vlozeni zaznamu
    DBMS_OUTPUT.PUT_LINE('Pasazer ma moc prestupku, nemuze se ucastnit dalsiho letu.');
    -- cislo aplikacni chyby muze byt od -20000 do -20999
    RAISE_APPLICATION_ERROR(-20800, 'Pasazer ma moc prestupku, nemuze se ucastnit dalsiho letu.');
  END IF;
END;
/
SHOW ERRORS;

-- Vyzkoušení triggeru:
SET SERVEROUTPUT ON
INSERT INTO ucastnik_letu (cislo_letu, pasazer_id, odkud, kam, cena, 
pocet_prestupku) VALUES ('OK5',	103, 7,	19,	2600,	1);
COMMIT;


/* TR003: Vytvořte trigger, který při mazání pilota z tabulky pilot nastaví 
v tabulce zamestnanec datum_ukonceni na aktuální datum a čas a aktivni 
na 'n'. */
CREATE OR REPLACE TRIGGER SET_ukonceni_pr_pomeru_pilota
AFTER DELETE ON pilot FOR EACH ROW
BEGIN
  UPDATE zamestnanec SET datum_ukonceni = SYSDATE, aktivni = 'n'
  WHERE zamestnanec_id = :OLD.zamestnanec_id;
END;
/
SHOW ERRORS;

-- Vyzkoušení triggeru:
DELETE FROM ucastnik_letu WHERE cislo_letu IN (
  SELECT cislo_letu FROM let WHERE pilot_id = 8
);
DELETE FROM let WHERE pilot_id = 8;
DELETE FROM pilot WHERE pilot_id = 8;
COMMIT;


/* TR004: Vytvořte trigger, který při přidávání/mazání/aktualizaci zastávky 
letové linky zkontroluje, zda se na dané lince vyskytují zastávky s pořadím 
0, 1, ... těsně za sebou bez přeskakování celých čísel, a že každá následující 
zastávka má pravidelny_cas_odletu větší než předchozí zastávka. Pokud bude 
některá z podmínek porušena, vyvolejte výjimku s Vašim vlastním chybovým kódem 
pomocí procedury RAISE_APPLICATION_ERROR. */

/* Tento příklad nemá jednoduché řešení!
Trigger nemůže modifikovat tabulku/procházet kurzorem takovou tabulku, 
jejíž změna vyvolala tento trigger!!! Při spouštění následujícího kódu dochází
k chybě ORA-04091: table name is mutating, trigger/function may not see it!!!
Musel by se napsat trigger, který nebude FOR EACH ROW!
Nepomůže např. použití autonomní transakce v triggeru (trigger by pak vyvoláním
výjimky nezabránil ve změně tabulky). Možným řešením by ale bylo napsat
pro získání informací z tabulky funkci, která by byla spouštěna z triggeru
v rámci autonomní transakce. 
*/
CREATE OR REPLACE TRIGGER TR_kontrola_zastavek
AFTER INSERT OR UPDATE OR DELETE ON zastavka FOR EACH ROW
DECLARE
  CURSOR c_zastavky_linky(
    p_cislo_letove_linky letova_linka.cislo_letove_linky%TYPE) IS
    SELECT poradi_zastavky, pravidelny_cas_odletu 
    FROM zastavka 
    WHERE cislo_letove_linky = p_cislo_letove_linky 
    ORDER BY poradi_zastavky;
  v_zastavka zastavka%ROWTYPE;
  v_poradi_zastavky zastavka.poradi_zastavky%TYPE;
  v_poradi_ovl_zastavky zastavka.poradi_zastavky%TYPE;
  v_pravidelny_cas_odletu zastavka.pravidelny_cas_odletu%TYPE;
  v_cislo_letove_linky letova_linka.cislo_letove_linky%TYPE;
  v_chyba NUMBER := 0;
BEGIN
  IF INSERTING OR UPDATING THEN
    SELECT :NEW.cislo_letove_linky INTO v_cislo_letove_linky FROM dual;
    SELECT :NEW.poradi_zastavky INTO v_poradi_ovl_zastavky FROM dual;
  ELSIF DELETING THEN 
    SELECT :OLD.cislo_letove_linky INTO v_cislo_letove_linky FROM dual;
    SELECT :OLD.poradi_zastavky INTO v_poradi_ovl_zastavky FROM dual;
  END IF;
  v_poradi_zastavky := -1;
  v_pravidelny_cas_odletu := TO_DATE('01.01.1970 0:0:0', 'DD.MM.YYYY HH24:MI:SS');
  FOR v_zastavka IN c_zastavky_linky(v_cislo_letove_linky)
  LOOP
      v_poradi_zastavky := v_poradi_zastavky + 1;
      IF v_poradi_zastavky <> v_zastavka.poradi_zastavky THEN
        -- cislo aplikacni chyby muze byt od -20000 do -20999
        v_chyba := 1;
      END IF;
      IF v_zastavka.pravidelny_cas_odletu <= v_pravidelny_cas_odletu THEN
        -- cislo aplikacni chyby muze byt od -20000 do -20999
        v_chyba := 1;
      END IF;
      v_pravidelny_cas_odletu := v_zastavka.pravidelny_cas_odletu;
  END LOOP;
  IF v_chyba = 1 THEN
    RAISE_APPLICATION_ERROR(-20801, 'Chyba v cislovani poradi zastavek nebo v souslednosti casu odletu.');
  END IF;
END;
/
SHOW ERRORS;


/* TR005: Vytvořte trigger, který při vkládání nového letu zkontroluje, 
zda cas_odletu je větší než datum a čas zakoupení letadla a větší než datum 
a čas nástupu pilota do zaměstnání a zda je pilot stále zaměstnaný 
(datum_ukonceni IS NULL). Pokud bude něco v nepořádku, vyvolá se výjimka, a 
zabrání se tak vložení logicky chybného záznamu. */
CREATE OR REPLACE TRIGGER TR_kontrola_udaju_letu
BEFORE INSERT ON let FOR EACH ROW
DECLARE 
  v_datum_zakoupeni_letadla letadlo.datum_porizeni%TYPE;
  v_datum_nastupu_pilota zamestnanec.datum_nastupu%TYPE;
  v_datum_odchodu_pilota zamestnanec.datum_ukonceni%TYPE;
BEGIN
  SELECT z.datum_nastupu, z.datum_ukonceni, l.datum_porizeni 
  INTO v_datum_nastupu_pilota, v_datum_odchodu_pilota, v_datum_zakoupeni_letadla
  FROM zamestnanec z, pilot p, letadlo l
  WHERE p.pilot_id = :NEW.pilot_id AND l.letadlo_id = :NEW.letadlo_id
  AND z.zamestnanec_id = p.zamestnanec_id;
  
  IF :NEW.cas_odletu <= v_datum_zakoupeni_letadla 
  OR :NEW.cas_odletu <= v_datum_nastupu_pilota
  OR v_datum_odchodu_pilota IS NOT NULL THEN
    RAISE_APPLICATION_ERROR(-20802, 'Nesrovnalost v datech, nebo pilot ukoncil pracovni pomer.');
  END IF;
END;
/
SHOW ERRORS;

-- Vyzkoušení triggeru:
INSERT INTO let (cas_odletu, cislo_letove_linky, cislo_letu, letadlo_id, pilot_id)
VALUES (TO_DATE('01.01.1970 0:0:0', 'DD.MM.YYYY HH24:MI:SS'), 5, 'OK999', 20, 1);


/* TR006: Vytvořte trigger, který zajistí, aby se jeden pilot nemohl v daném 
dni účastnit více jak dvou letů (pilot musí dostatečně odpočívat). */
CREATE OR REPLACE TRIGGER TR_kontrola_max_letu_pilota
BEFORE INSERT ON let FOR EACH ROW
DECLARE 
  v_pocet_letu NUMBER;
BEGIN
  SELECT COUNT(let.pilot_id) INTO v_pocet_letu FROM let 
  WHERE pilot_id = :NEW.pilot_id  AND 
  TO_CHAR(cas_odletu, 'DD.MM.YYYY') = TO_CHAR(:NEW.cas_odletu, 'DD.MM.YYYY');
  IF v_pocet_letu >= 2 THEN
    RAISE_APPLICATION_ERROR(-20803, 'Pilot nemuze tento den letet potreti.');
  END IF;
END;
/
SHOW ERRORS;


/* TR007: Napište trigger, který bude do Vámi zvoleného textového souboru 
(např. C:\oraclexe\logs\audit.log) logovat zprávu, kdykoliv někdo bude 
upravovat data v tabulce let (přidávat, aktualizovat, mazat záznamy). Můžete 
se inspirovat souborem plsql/­ukazky/­textove_soubory.sql v kurzu a přednáškou 
o triggerech (trigger pro více událostí). Soubor je potřeba otevřít 
s módem 'a' (append text), namísto módu 'w' (zápis/přepisování textu 
v souboru). */

/* Následující kód je potřeba spustit pod právy administrátora (např. pod
uživatelem SYSTEM) */

-- Vytvoření reprezentace (existujícího) adresáře pro Oracle:
CREATE OR REPLACE DIRECTORY dir_logs as 'C:\oraclexe\logs';
GRANT WRITE ON DIRECTORY dir_logs TO AERO;

CREATE OR REPLACE TRIGGER AERO.TR_log_let
AFTER INSERT OR UPDATE OR DELETE ON AERO.let FOR EACH ROW
DECLARE 
  PRAGMA AUTONOMOUS_TRANSACTION;
  v_zprava VARCHAR2(255);
  f utl_file.file_type;
BEGIN
  IF INSERTING THEN
    v_zprava := TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') || ' - ' 
      || 'INSERT' || ' let - ' || USER;
  ELSIF UPDATING THEN
    v_zprava := TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') || ' - ' 
      || 'UPDATE' || ' let - ' || USER;
  ELSIF DELETING THEN
    v_zprava := TO_CHAR(SYSDATE, 'YYYY-MM-DD HH24:MI:SS') || ' - ' 
      || 'DELETE' || ' let - ' || USER;
  END IF;
  -- Otevře existující soubor pro přidávání textu nebo vytvoří nový soubor
  -- Název adresáře musí být zadán velkými písmeny
  f := utl_file.fopen('DIR_LOGS', 'audit.log', 'a');
  utl_file.put_line(f, v_zprava);
  utl_file.fclose(f);
END;
/
SHOW ERRORS;

-- Vyzkoušení triggeru (už jako uživatel AERO):
INSERT INTO let (cas_odletu, cislo_letove_linky, cislo_letu, letadlo_id, 
pilot_id) VALUES (TO_DATE('20.07.2009', 'DD.MM.YYYY'), 5, 'OK997', 20, 2);





