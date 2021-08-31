-- alter table zamestnanec add last_changed date;

declare
  type number_varray is varray(5) of number;
  ids number_varray := number_varray(1, 3, 5, 7);
  sql_command varchar(2000) := '';
  cur integer;
  rows_processed integer;
begin
  sql_command := sql_command || 'update zamestnanec set ';
  sql_command := sql_command || 'last_changed = sysdate ';
  sql_command := sql_command || 'where zamestnanec_id in ( ';
  for i in 1 .. ids.count loop
    if i = 1 then
      sql_command := sql_command || ':' || i;
    else 
      sql_command := sql_command || ', :' || i;
    end if;
  end loop;
  sql_command := sql_command || ') ';
  dbms_output.put_line('WILL EXECUTE: ' || sql_command);
  cur := dbms_sql.open_cursor;
  dbms_sql.parse(cur, sql_command, dbms_sql.native);
  for i in 1 .. ids.count loop
    dbms_sql.bind_variable(cur, '' || i, ids(i));
  end loop;
  rows_processed := dbms_sql.execute(cur);
  dbms_sql.close_cursor(cur);
end;