create or replace PROCEDURE PRIDEJPRESTUPEK 
(
  V_PASAZER_ID IN  UCASTNIK_LETU.PASAZER_ID%TYPE
, V_CISLO_LETU IN varchar2
) AS 
p_pocet_prestupku UCASTNIK_LETU.POCET_PRESTUPKU%TYPE;
BEGIN
  update ucastnik_letu set POCET_PRESTUPKU = POCET_PRESTUPKU + 1 
  where PASAZER_ID = v_pasazer_id and CISLO_LETU = V_CISLO_LETU;
  select sum(pocet_prestupku) into p_pocet_prestupku 
  from ucastnik_letu where PASAZER_ID = V_PASAZER_ID;
  if p_pocet_prestupku > 3 then
    update pasazer set PROBLEMATICKY = 'y' where pasazer_id = v_pasazer_id;
  end if;
END PRIDEJPRESTUPEK;
