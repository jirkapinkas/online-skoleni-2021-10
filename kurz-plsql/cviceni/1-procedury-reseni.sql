-- P001:
-- Procedura:
CREATE OR REPLACE PROCEDURE INC_SALARY(
    P_PROCENTO IN NUMBER )
AS
BEGIN
  UPDATE zamestnanec SET plat = plat * (1+ (p_procento / 100));
END INC_SALARY;

-- Test:
exec inc_salary(10);


-- P002:
-- Procedura:
CREATE OR REPLACE PROCEDURE SET_PROBLEMATICKY 
(
  P_PASAZER_ID IN NUMBER 
, P_PROBLEMATICKY IN CHAR 
) AS 
BEGIN
  update pasazer set problematicky = p_problematicky
  where pasazer_id = p_pasazer_id;
END SET_PROBLEMATICKY;

-- Test:
exec set_problematicky(1, 'n');


-- P003:
-- Procedura:
CREATE OR REPLACE PROCEDURE TOGGLE_PROBLEMATICKY(
    P_PASAZER_ID IN NUMBER )
IS
  v_pasazer pasazer%rowtype;
BEGIN
  SELECT *
  INTO v_pasazer
  FROM pasazer
  WHERE pasazer_id           = p_pasazer_id FOR UPDATE;
  IF v_pasazer.problematicky = 'y' THEN
    UPDATE pasazer SET problematicky = 'n' WHERE pasazer_id = p_pasazer_id;
  ELSE
    UPDATE pasazer SET problematicky = 'y' WHERE pasazer_id = p_pasazer_id;
  END IF;
END TOGGLE_PROBLEMATICKY;

-- Test:
exec toggle_problematicky(1);


-- P004:
-- Procedura:
CREATE OR REPLACE PROCEDURE findByPrijmeni
(  res OUT SYS_REFCURSOR, 
   vLastName IN zamestnanec.prijmeni%type  ) AS
BEGIN
  OPEN res FOR
    SELECT * FROM zamestnanec WHERE prijmeni = vLastName;
END findByPrijmeni;

-- Test:
declare
l_cursor SYS_REFCURSOR;
v_zamestnanec zamestnanec%ROWTYPE;
begin
  findByPrijmeni(l_cursor, 'Boss');
  LOOP 
    FETCH l_cursor INTO  v_zamestnanec;
    EXIT WHEN l_cursor%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(v_zamestnanec.jmeno);
  END LOOP;
  CLOSE l_cursor;
end;


-- P005:
-- Procedura:
CREATE OR REPLACE PROCEDURE FIND_ACTIVE_EMPLOYEES 
(
res OUT SYS_REFCURSOR,
  P_ACTIVE IN CHAR 
) AS 
BEGIN
OPEN res FOR
    SELECT * FROM zamestnanec WHERE aktivni = p_active;
END FIND_ACTIVE_EMPLOYEES;

-- Test:
declare
l_cursor SYS_REFCURSOR;
v_zamestnanec zamestnanec%ROWTYPE;
begin
  find_active_employees(l_cursor, 'y');
  LOOP 
    FETCH l_cursor INTO  v_zamestnanec;
    EXIT WHEN l_cursor%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(v_zamestnanec.jmeno);
  END LOOP;
  CLOSE l_cursor;
end;


-- P006:
-- Procedura:
CREATE OR REPLACE PROCEDURE INC_MIN_SALARY(
    res OUT SYS_REFCURSOR ,
    P_PLAT     IN NUMBER ,
    P_MNOZSTVI IN NUMBER )
AS
BEGIN
  OPEN res FOR SELECT * FROM zamestnanec WHERE plat < p_plat FOR UPDATE;
  UPDATE zamestnanec SET plat = plat + p_mnozstvi WHERE plat < p_plat;
END INC_MIN_SALARY;

-- Test:
declare
l_cursor SYS_REFCURSOR;
v_zamestnanec zamestnanec%ROWTYPE;
begin
  inc_min_salary(l_cursor, 100000, 10000);
  LOOP 
    FETCH l_cursor INTO  v_zamestnanec;
    EXIT WHEN l_cursor%NOTFOUND;
    DBMS_OUTPUT.PUT_LINE(v_zamestnanec.jmeno);
  END LOOP;
  CLOSE l_cursor;
end;