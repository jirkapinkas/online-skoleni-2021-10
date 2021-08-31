create or replace PROCEDURE TRUNCATE_TABLE 
(
  NAZEV_TABULKY IN VARCHAR2 
) authid current_user AS 
BEGIN
  execute immediate 'truncate table ' || nazev_tabulky;
END TRUNCATE_TABLE;
