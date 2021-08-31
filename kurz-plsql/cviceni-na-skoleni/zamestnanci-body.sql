--------------------------------------------------------
--  File created - Støeda-øíjen-08-2014   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package Body ZAMESTNANCI
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE BODY "ZAMESTNANCI" AS

  procedure zalohuj AS
    cursor zam_cur is select zamestnanec.jmeno, zamestnanec.prijmeni, zamestnanec.zamestnanec_id from zamestnanec 
    left join zamestnanci_bac
    on zamestnanec.zamestnanec_id = zamestnanci_bac.id
    where datum_ukonceni is not null
    and zamestnanci_bac.id is null;
    type zam_rec_type is record (jmeno zamestnanec.jmeno%type, 
                                 prijmeni zamestnanec.prijmeni%type, 
                                zamestnanec_id zamestnanec.zamestnanec_id%type);
    zam_rec zam_rec_type;
  BEGIN
-- pomoci CURSOR-FOR-LOOP
--    for zam_rec in zam_cur
--    loop
--      dbms_output.put_line('budu zalohovat: ' || zam_rec.jmeno || ' ' || zam_rec.prijmeni);
--      insert into zamestnanci_bac (id, jmeno, prijmeni) values (zam_rec.zamestnanec_id, zam_rec.jmeno, zam_rec.prijmeni);
--    end loop;

-- pomoci explicitniho kurzoru
    open zam_cur;
    loop
      fetch zam_cur into zam_rec;
      exit when zam_cur%notfound;
      dbms_output.put_line('budu zalohovat: ' || zam_rec.jmeno || ' ' || zam_rec.prijmeni);
      insert into zamestnanci_bac (id, jmeno, prijmeni) values (zam_rec.zamestnanec_id, zam_rec.jmeno, zam_rec.prijmeni);
    end loop;
    close zam_cur;
  END zalohuj;

END ZAMESTNANCI;
