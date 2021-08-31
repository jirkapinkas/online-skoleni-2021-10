-- F001:
-- Funkce:
CREATE OR REPLACE FUNCTION CENA_S_DPH(
    P_CENA IN NUMBER )
  RETURN NUMBER
AS
BEGIN
  RETURN p_cena * 1.21;
END CENA_S_DPH;

-- Test:
select jmeno, prijmeni, cena, cena_s_dph(cena) 
from ucastnik_letu
inner join pasazer
using (pasazer_id);

-- F002:
-- Funkce:
CREATE OR REPLACE FUNCTION TO_JMENO 
(
  P_JMENO IN VARCHAR2 
, P_PRIJMENI IN VARCHAR2 
) RETURN VARCHAR2 AS 
BEGIN
  RETURN p_jmeno || ' ' || upper(p_prijmeni);
END TO_JMENO;

-- Test:
select to_jmeno(jmeno, prijmeni) 
from zamestnanec;

-- F003
-- Funkce:
CREATE OR REPLACE FUNCTION POCET_ZAMESTNANCU(
    P_START_ROK  IN NUMBER ,
    P_FINISH_ROK IN NUMBER )
  RETURN NUMBER
AS
    v_result NUMBER;
  BEGIN
    SELECT COUNT(*) into v_result
    FROM zamestnanec
    WHERE extract(YEAR FROM datum_nastupu) >= p_start_rok
    AND extract(YEAR FROM datum_nastupu)   <= p_finish_rok;
    RETURN v_result;
  END POCET_ZAMESTNANCU;

-- Test:
select pocet_zamestnancu(2002, 2005) from dual;
