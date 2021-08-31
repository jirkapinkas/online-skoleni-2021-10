--------------------------------------------------------
--  File created - Støeda-øíjen-08-2014   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package Body PRESTUPKY
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "PRESTUPKY" AS

  CHYBNE_ZADANI EXCEPTION;

  PROCEDURE inc_prestupek(
      V_PASAZER_ID IN UCASTNIK_LETU.PASAZER_ID%TYPE ,
      V_CISLO_LETU IN UCASTNIK_LETU.CISLO_LETU%TYPE ) AS
  BEGIN
    $if $$debug_enabled $then
    dbms_output.put_line('start inc_prestupek()');
    $end

    update ucastnik_letu set POCET_PRESTUPKU = POCET_PRESTUPKU + 1 
    where PASAZER_ID = v_pasazer_id and CISLO_LETU = V_CISLO_LETU;
    if sql%rowcount != 1 then
      $if $$debug_enabled $then
        dbms_output.put_line('chybne zadani!');
      $end
      raise CHYBNE_ZADANI;
    end if;

    $if $$debug_enabled $then
    dbms_output.put_line('konec inc_prestupek()');
    $end
  END inc_prestupek;

  PROCEDURE set_problematicky(
      V_PASAZER_ID IN UCASTNIK_LETU.PASAZER_ID%TYPE) AS
  BEGIN
    $if $$debug_enabled $then
    dbms_output.put_line('start set_problematicky()');
    $end

    update pasazer set PROBLEMATICKY = 'y' where pasazer_id = v_pasazer_id;

    $if $$debug_enabled $then
    dbms_output.put_line('konec set_problematicky()');
    $end

  END set_problematicky;

  FUNCTION get_pocet_prestupku (
      V_PASAZER_ID IN UCASTNIK_LETU.PASAZER_ID%TYPE) 
    RETURN number is
    p_pocet_prestupku number;
  BEGIN
    $if $$debug_enabled $then
    dbms_output.put_line('start get_pocet_prestupku()');
    $end

    select sum(pocet_prestupku) into p_pocet_prestupku 
    from ucastnik_letu where PASAZER_ID = V_PASAZER_ID;

    $if $$debug_enabled $then
    dbms_output.put_line('konec get_pocet_prestupku() with result: ' || p_pocet_prestupku);
    $end

    return p_pocet_prestupku;
  END get_pocet_prestupku;

  PROCEDURE pridej(
      V_PASAZER_ID IN UCASTNIK_LETU.PASAZER_ID%TYPE ,
      V_CISLO_LETU IN UCASTNIK_LETU.CISLO_LETU%TYPE ) AS
  BEGIN

    $if $$debug_enabled $then
    dbms_output.put_line('start pridej()');
    $end
    
    

    inc_prestupek(V_PASAZER_ID,V_CISLO_LETU);
    if get_pocet_prestupku(V_PASAZER_ID) > 3 then
      set_problematicky(V_PASAZER_ID);
    end if;

    $if $$debug_enabled $then
    dbms_output.put_line('konec pridej()');
    $end
    
  END pridej;

END PRESTUPKY;
