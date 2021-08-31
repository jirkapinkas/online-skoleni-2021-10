create or replace PROCEDURE PRIDEJ_ZAMESTNANCE(
    V_JMENO    IN VARCHAR2 ,
    V_PRIJMENI IN VARCHAR2 ,
    V_PLAT     IN NUMBER ,
    V_POHLAVI  IN VARCHAR2 )
AS
BEGIN
  DBMS_OUTPUT.PUT_LINE('insert zamestnanec');
  INSERT
  INTO ZAMESTNANEC
    (
      ZAMESTNANI_ID,
      NADRIZENY,
      JMENO,
      PRIJMENI,
      PLAT,
      DATUM_NASTUPU,
      DATUM_UKONCENI,
      POHLAVI
    )
    VALUES
    (
      9,
      1,
      v_jmeno,
      v_prijmeni,
      v_plat,
      sysdate,
      NULL,
      v_pohlavi
    );
END PRIDEJ_ZAMESTNANCE;