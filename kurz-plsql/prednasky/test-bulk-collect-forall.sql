
-- 1. create table
create table test_bulk_source (num number); 
create table test_bulk_target (num number); 

-- 2. insert test data
declare
  maximum integer := 1000000;
begin
  FOR i IN 1..maximum LOOP
    insert into test_bulk_source values (dbms_random.random);
  END LOOP;
  commit;
end;

-- 3A. copy data using insert ... select statement  (operation took on my computer 0,3 seconds!!!)
declare
  time_start number;
begin
  execute immediate 'truncate table test_bulk_target';
  time_start := dbms_utility.get_time();
  insert into test_bulk_target select num from test_bulk_source where num > 500000;
  commit;
  dbms_output.put_line('operation took: ' || (dbms_utility.get_time() - time_start) / 100 || ' seconds');
end;

-- 3B. copy data using for-loop (operation took on my computer 30 seconds)
declare
  time_start number;
begin
  execute immediate 'truncate table test_bulk_target';
  time_start := dbms_utility.get_time();
  for num_rec in (select num from test_bulk_source where num > 500000)
  loop
    insert into test_bulk_target values (num_rec.num);
  end loop;
  commit;
  dbms_output.put_line('operation took: ' || (dbms_utility.get_time() - time_start) / 100 || ' seconds');
end;

-- 3C. copy data using bulk-collect-forall (operation took on my computer 0,5 seconds!!!)
declare
  time_start number;
  cursor c is select num from test_bulk_source where num > 500000;
  type number_collection is table of number;
  numbers number_collection;
begin
  execute immediate 'truncate table test_bulk_target';
  time_start := dbms_utility.get_time();
  open c;
  fetch c bulk collect into numbers;
  forall i in numbers.first .. numbers.last
    insert into test_bulk_target values(numbers(i));
  close c;
  commit;
  dbms_output.put_line('operation took: ' || (dbms_utility.get_time() - time_start) / 100 || ' seconds');
end;

-- 3D. explicit cursor
declare
  time_start number;
  cursor c is select num from test_bulk_source where num > 500000;
  num number;
begin
  execute immediate 'truncate table test_bulk_target';
  time_start := dbms_utility.get_time();
  open c;
  loop
    fetch c into num;
    insert into test_bulk_target values (num);
    EXIT WHEN c%NOTFOUND;
  end loop;
  close c;
  commit;
  dbms_output.put_line('operation took: ' || (dbms_utility.get_time() - time_start) / 100 || ' seconds');
end;
