/*
Created		27.8.2009
Modified		2.9.2009
Project		Aerolinky
Model		Aerolinky
Company		Seico s.r.o.
Author		Radek Beran
Version		1.0
Database		Oracle 10g 
*/

-- Create User

drop user aero cascade;
create user aero identified by aero;
grant all privileges to aero;

ALTER SESSION SET CURRENT_SCHEMA = aero;

-- Create Tables section


Create table zamestnani (
	zamestnani_id Number(3,0) NOT NULL ,
	nazev_pozice Varchar2 (64 CHAR) NOT NULL ,
	popis_prace Varchar2 (128),
 Constraint pk_zamestnani primary key (zamestnani_id) 
) 
/

Create table zamestnanec (
	zamestnanec_id Number(7,0) NOT NULL ,
	zamestnani_id Number(3,0) NOT NULL ,
	nadrizeny Number(7,0),
	jmeno Varchar2 (32 CHAR) NOT NULL ,
	prijmeni Varchar2 (32 CHAR) NOT NULL ,
	plat Number(6,0) Constraint zamestnanec_plat_chk Check (plat > 8000 ) ,
	datum_nastupu Date NOT NULL ,
	datum_ukonceni Date,
	aktivni Char (1) Default 'n' NOT NULL  Constraint zamestnanec_aktivni_chk Check (aktivni IN ('y', 'n') ) ,
 Constraint pk_zamestnanec primary key (zamestnanec_id) 
) 
/

Create table pilot (
	pilot_id Number(4,0) NOT NULL ,
	zamestnanec_id Number(7,0) NOT NULL ,
	hodnost Varchar2 (30) Default 'Trainee' NOT NULL  Constraint pilot_hodnost_chk Check (hodnost IN ('Trainee', 'First Officer', 'Senior First Officer', 'Captain', 'Senior Captain', 'Instructor') ) ,
 Constraint pk_pilot primary key (pilot_id) 
) 
/

Create table destinace (
	destinace_id Number(10,0) NOT NULL ,
	nazev Varchar2 (30 CHAR) NOT NULL  UNIQUE ,
 Constraint pk_destinace primary key (destinace_id) 
) 
/

Create table letova_linka (
	cislo_letove_linky Number(4,0) NOT NULL ,
	nazev Varchar2 (64),
 Constraint pk_letova_linka primary key (cislo_letove_linky) 
) 
/

Create table zastavka (
	cislo_letove_linky Number(4,0) NOT NULL ,
	poradi_zastavky Number(3,0) NOT NULL  Constraint zastavka_poradi_zastavky_chk Check (poradi_zastavky >= 0 ) ,
	km_od_minule_zastavky Number(5,0) NOT NULL  Constraint zastavka_km_od_minule_zastavky Check (km_od_minule_zastavky >= 0 ) ,
	pravidelny_cas_odletu Date NOT NULL ,
	destinace_id Number(10,0) NOT NULL ,
 Constraint pk_zastavka primary key (cislo_letove_linky,poradi_zastavky) 
) 
/

Create table typ_letadla (
	typ_letadla_id Varchar2 (14 CHAR) NOT NULL ,
	nazev Varchar2 (32 CHAR) NOT NULL ,
	pocet_mist Number(3,0) NOT NULL  Constraint typ_letadla_pocet_mist_chk Check (pocet_mist > 0 ) ,
 Constraint pk_typ_letadla primary key (typ_letadla_id) 
) 
/

Create table letadlo (
	letadlo_id Number(6,0) NOT NULL ,
	typ_letadla_id Varchar2 (14) NOT NULL ,
	datum_porizeni Date NOT NULL ,
	porizovaci_cena Number(12,0) Constraint letadlo_porizovaci_cena_chk Check (porizovaci_cena > 0 ) ,
 Constraint pk_letadlo primary key (letadlo_id) 
) 
/

Create table pasazer (
	pasazer_id Number(15,0) NOT NULL ,
	jmeno Varchar2 (32 CHAR) NOT NULL ,
	prijmeni Varchar2 (32 CHAR) NOT NULL ,
	problematicky Char (1) Default 'n' NOT NULL  Constraint pasazer_problematicky_chk Check (problematicky IN ('y', 'n') ) ,
 Constraint pk_pasazer primary key (pasazer_id) 
) 
/

Create table let (
	cislo_letu Varchar2 (14 CHAR) NOT NULL ,
	pilot_id Number(4,0) NOT NULL ,
	letadlo_id Number(6,0) NOT NULL ,
	cislo_letove_linky Number(4,0) NOT NULL ,
	cas_odletu Date NOT NULL ,
 Constraint pk_let primary key (cislo_letu) 
) 
/

Create table ucastnik_letu (
	cislo_letu Varchar2 (14) NOT NULL ,
	pasazer_id Number(15,0) NOT NULL ,
	odkud Number(10,0) NOT NULL ,
	kam Number(10,0) NOT NULL ,
	cena Number(7,2) Constraint ucastnik_letu_cena_chk Check (cena IS NULL OR cena >= 0 ) ,
	pocet_prestupku Number(2,0) Default 0 NOT NULL  Constraint ucastnik_letu_pocet_prestupku_ Check (pocet_prestupku >= 0 ) ,
 Constraint pk_ucastnik_letu primary key (cislo_letu,pasazer_id) 
) 
/


-- Create Indexes section


-- Create Foreign keys section
Create Index IX_pracuje_jako ON zamestnanec (zamestnani_id)
/
Alter table zamestnanec add Constraint pracuje_jako foreign key (zamestnani_id) references zamestnani (zamestnani_id) 
/
Create Index IX_ma_nadrizeneho ON zamestnanec (nadrizeny)
/
Alter table zamestnanec add Constraint ma_nadrizeneho foreign key (nadrizeny) references zamestnanec (zamestnanec_id) 
/
Create Index IX_je_zamestnan ON pilot (zamestnanec_id)
/
Alter table pilot add Constraint je_zamestnan foreign key (zamestnanec_id) references zamestnanec (zamestnanec_id) 
/
Create Index IX_ridi ON let (pilot_id)
/
Alter table let add Constraint ridi foreign key (pilot_id) references pilot (pilot_id) 
/
Create Index IX_je_mistem_pristani ON zastavka (destinace_id)
/
Alter table zastavka add Constraint je_mistem_pristani foreign key (destinace_id) references destinace (destinace_id) 
/
Create Index IX_leti_z ON ucastnik_letu (odkud)
/
Alter table ucastnik_letu add Constraint leti_z foreign key (odkud) references destinace (destinace_id) 
/
Create Index IX_leti_do ON ucastnik_letu (kam)
/
Alter table ucastnik_letu add Constraint leti_do foreign key (kam) references destinace (destinace_id) 
/
Create Index IX_linka_ma_zastavky ON zastavka (cislo_letove_linky)
/
Alter table zastavka add Constraint linka_ma_zastavky foreign key (cislo_letove_linky) references letova_linka (cislo_letove_linky) 
/
Create Index IX_ma_rozvrh_letu ON let (cislo_letove_linky)
/
Alter table let add Constraint ma_rozvrh_letu foreign key (cislo_letove_linky) references letova_linka (cislo_letove_linky) 
/
Create Index IX_je_typu ON letadlo (typ_letadla_id)
/
Alter table letadlo add Constraint je_typu foreign key (typ_letadla_id) references typ_letadla (typ_letadla_id) 
/
Create Index IX_vykonavan_letadlem ON let (letadlo_id)
/
Alter table let add Constraint vykonavan_letadlem foreign key (letadlo_id) references letadlo (letadlo_id) 
/
Create Index IX_leti_konkretnim_letem ON ucastnik_letu (pasazer_id)
/
Alter table ucastnik_letu add Constraint leti_konkretnim_letem foreign key (pasazer_id) references pasazer (pasazer_id) 
/
Create Index IX_ma_pasazery ON ucastnik_letu (cislo_letu)
/
Alter table ucastnik_letu add Constraint ma_pasazery foreign key (cislo_letu) references let (cislo_letu) 
/


-- Create Views section


-- Create Sequences section

CREATE SEQUENCE zamestnani_seq
START WITH 1
INCREMENT BY 1
NOMAXVALUE
CACHE 20
NOORDER
NOCYCLE;
/

CREATE SEQUENCE zamestnanec_seq
START WITH 1
INCREMENT BY 1
NOMAXVALUE
CACHE 20
NOORDER
NOCYCLE;
/

CREATE SEQUENCE pilot_seq
START WITH 1
INCREMENT BY 1
NOMAXVALUE
CACHE 20
NOORDER
NOCYCLE;
/

CREATE SEQUENCE letadlo_seq
START WITH 1
INCREMENT BY 1
NOMAXVALUE
CACHE 20
NOORDER
NOCYCLE;
/

CREATE SEQUENCE let_seq
START WITH 1
INCREMENT BY 1
NOMAXVALUE
CACHE 20
NOORDER
NOCYCLE;
/

CREATE SEQUENCE letova_linka_seq
START WITH 1
INCREMENT BY 1
NOMAXVALUE
CACHE 20
NOORDER
NOCYCLE;
/

CREATE SEQUENCE pasazer_seq
START WITH 1
INCREMENT BY 1
NOMAXVALUE
CACHE 20
NOORDER
NOCYCLE;
/

CREATE SEQUENCE destinace_seq
START WITH 1
INCREMENT BY 1
NOMAXVALUE
CACHE 20
NOORDER
NOCYCLE;
/


/* Trigger for sequence zamestnani_seq for table zamestnani attribute zamestnani_id */
Create or replace trigger t_zamestnani_seq before insert
on zamestnani for each row
begin
	SELECT zamestnani_seq.nextval INTO :new.zamestnani_id FROM dual;
end;
/
Create or replace trigger t_zamestnani_seq_upd after update of zamestnani_id
on zamestnani for each row
begin
	RAISE_APPLICATION_ERROR(-20010,'Cannot update column zamestnani_id in table zamestnani as it uses sequence.');
end;
/
 
/* Trigger for sequence pilot_seq for table pilot attribute pilot_id */
Create or replace trigger t_pilot_seq before insert
on pilot for each row
begin
	SELECT pilot_seq.nextval INTO :new.pilot_id FROM dual;
end;
/
Create or replace trigger t_pilot_seq_upd after update of pilot_id
on pilot for each row
begin
	RAISE_APPLICATION_ERROR(-20010,'Cannot update column pilot_id in table pilot as it uses sequence.');
end;
/
 
/* Trigger for sequence letadlo_seq for table letadlo attribute letadlo_id */
Create or replace trigger t_letadlo_seq before insert
on letadlo for each row
begin
	SELECT letadlo_seq.nextval INTO :new.letadlo_id FROM dual;
end;
/
Create or replace trigger t_letadlo_seq_upd after update of letadlo_id
on letadlo for each row
begin
	RAISE_APPLICATION_ERROR(-20010,'Cannot update column letadlo_id in table letadlo as it uses sequence.');
end;
/
 
/* Trigger for sequence pasazer_seq for table pasazer attribute pasazer_id */
Create or replace trigger t_pasazer_seq before insert
on pasazer for each row
begin
	SELECT pasazer_seq.nextval INTO :new.pasazer_id FROM dual;
end;
/
Create or replace trigger t_pasazer_seq_upd after update of pasazer_id
on pasazer for each row
begin
	RAISE_APPLICATION_ERROR(-20010,'Cannot update column pasazer_id in table pasazer as it uses sequence.');
end;
/
 
/* Trigger for sequence letova_linka_seq for table letova_linka attribute cislo_letove_linky */
Create or replace trigger t_letova_linka_seq before insert
on letova_linka for each row
begin
	SELECT letova_linka_seq.nextval INTO :new.cislo_letove_linky FROM dual;
end;
/
Create or replace trigger t_letova_linka_seq_upd after update of cislo_letove_linky
on letova_linka for each row
begin
	RAISE_APPLICATION_ERROR(-20010,'Cannot update column cislo_letove_linky in table letova_linka as it uses sequence.');
end;
/
 
/* Trigger for sequence zamestnanec_seq for table zamestnanec attribute zamestnanec_id */
CREATE OR REPLACE TRIGGER t_zamestnanec_seq BEFORE INSERT
ON zamestnanec FOR EACH ROW
BEGIN
	SELECT zamestnanec_seq.NEXTVAL INTO :new.zamestnanec_id FROM dual;
END;
/
CREATE OR REPLACE TRIGGER t_zamestnanec_seq_upd AFTER UPDATE 
OF zamestnanec_id ON zamestnanec FOR EACH ROW
BEGIN
	RAISE_APPLICATION_ERROR(-20010,'Cannot update column zamestnanec_id in table zamestnanec as it uses sequence.');
END;
/
 
/* Trigger for sequence destinace_seq for table destinace attribute destinace_id */
Create or replace trigger t_destinace_seq before insert
on destinace for each row
begin
	SELECT destinace_seq.nextval INTO :new.destinace_id FROM dual;
end;
/
Create or replace trigger t_destinace_seq_upd after update of destinace_id
on destinace for each row
begin
	RAISE_APPLICATION_ERROR(-20010,'Cannot update column destinace_id in table destinace as it uses sequence.');
end;
/

-- Create Triggers from referential integrity section


-- Create user Triggers section


-- Create Table comments section

Comment on table zamestnani is 'Zamestnani (pozice) zamestnance'
/
Comment on table zamestnanec is 'Zamestnanec aerolinek'
/
Comment on table pilot is 'Pilot aerolinek'
/
Comment on table destinace is 'Letova destinace - typicky mesto, primorske stredisko, cil vojenske operace'
/
Comment on table letova_linka is 'Letova linka/letovy rad'
/
Comment on table zastavka is 'Zastavka na letove lince'
/
Comment on table typ_letadla is 'Typ (model) letadla'
/
Comment on table letadlo is 'Konkretni letadlo aerolinek'
/
Comment on table pasazer is 'Cestujici, ktery vyuziva sluzeb aerolinek'
/
Comment on table let is 'Informace o konkretnim letu, na kterem dane letadlo ridi dany pilot podle daneho letoveho radu'
/
Comment on table ucastnik_letu is 'Ucast pasazera na konkretnim letu'
/

-- Create Attribute comments section

Comment on column zamestnani.zamestnani_id is 'Identifikator zamestnani - pracovni pozice'
/
Comment on column zamestnani.nazev_pozice is 'Nazev pozice'
/
Comment on column zamestnani.popis_prace is 'Popis prace'
/
Comment on column zamestnanec.zamestnanec_id is 'Identifikacni cislo zamestnance'
/
Comment on column zamestnanec.zamestnani_id is 'Identifikacni cislo zamestnani (pozice)'
/
Comment on column zamestnanec.nadrizeny is 'Identifikacni cislo nadrizeneho zamestnance'
/
Comment on column zamestnanec.jmeno is 'Jmeno zamestnance'
/
Comment on column zamestnanec.prijmeni is 'Prijmeni zamestnance'
/
Comment on column zamestnanec.plat is 'Plat zamestnance'
/
Comment on column zamestnanec.datum_nastupu is 'Datum nastupu do prace'
/
Comment on column zamestnanec.datum_ukonceni is 'Datum ukonceni pracovniho pomeru v pripade, ze zamestnanec uz nepracuje, nebo NULL'
/
Comment on column zamestnanec.aktivni is 'Je zamestnanec aktivni pro vykon sve prace? Tj. neni nemocny, na dovolene, propusteny.'
/
Comment on column pilot.pilot_id is 'Identifikacni cislo pilota'
/
Comment on column pilot.zamestnanec_id is 'Odkaz na zamestnanecke udaje'
/
Comment on column pilot.hodnost is 'Hodnost pilota'
/
Comment on column destinace.destinace_id is 'Identifikator destinace'
/
Comment on column destinace.nazev is 'Nazev mesta/strediska/uzemi'
/
Comment on column letova_linka.cislo_letove_linky is 'Cislo letove linky'
/
Comment on column letova_linka.nazev is 'Nazev letove linky (napr. Praha - Londyn)'
/
Comment on column zastavka.cislo_letove_linky is 'Cislo letove linky/letoveho radu'
/
Comment on column zastavka.poradi_zastavky is 'Poradi zastavky v ramci letove linky (0, 1, 2, ...). 0 pro pocatecni misto odletu.'
/
Comment on column zastavka.km_od_minule_zastavky is 'Pocet kilometru vzdusnou carou od minule zastavky'
/
Comment on column zastavka.pravidelny_cas_odletu is 'Pravidelny cas odletu (bez konkretniho data)'
/
Comment on column zastavka.destinace_id is 'Identifikator destinace'
/
Comment on column typ_letadla.typ_letadla_id is 'Kod typu letadla'
/
Comment on column typ_letadla.nazev is 'Nazev typu letadla'
/
Comment on column typ_letadla.pocet_mist is 'Pocet mist v letadle'
/
Comment on column letadlo.letadlo_id is 'Identifikacni cislo letadla'
/
Comment on column letadlo.typ_letadla_id is 'Kod typu letadla'
/
Comment on column letadlo.datum_porizeni is 'Datum porizeni letadla'
/
Comment on column letadlo.porizovaci_cena is 'Porizovaci cena letadla'
/
Comment on column pasazer.pasazer_id is 'Identifikacni cislo cestujiciho'
/
Comment on column pasazer.jmeno is 'Jmeno cestujiciho'
/
Comment on column pasazer.prijmeni is 'Prijmeni cestujiciho'
/
Comment on column pasazer.problematicky is 'Priznak, zda je pasazer problematicky (ma prestupky z minulych letu)'
/
Comment on column let.cislo_letu is 'Cislo letu, obsahuje kod aerolinek a poradove cislo letu'
/
Comment on column let.pilot_id is 'Identifikacni cislo pilota'
/
Comment on column let.letadlo_id is 'Identifikacni cislo letadla'
/
Comment on column let.cislo_letove_linky is 'Identifikacni cislo linky/letoveho radu'
/
Comment on column let.cas_odletu is 'Planovany datum a cas odletu konkretniho letu'
/
Comment on column ucastnik_letu.cislo_letu is 'Identifikacni cislo letu'
/
Comment on column ucastnik_letu.pasazer_id is 'Identifikacni cislo pasazera'
/
Comment on column ucastnik_letu.odkud is 'Identifikator destinace, odkud pasazer leti'
/
Comment on column ucastnik_letu.kam is 'Identifikator destinace, kam pasazer leti'
/
Comment on column ucastnik_letu.cena is 'Cena, kterou pasazer zaplatil za letenku a palivo'
/
Comment on column ucastnik_letu.pocet_prestupku is 'Pocet zavaznejsich prestupku pasazera behem letu'
/

-- After section
/* Trigger kontrolujici spravnost casoveho intervalu <datum_nastupu, 
datum_ukonceni> */
CREATE OR REPLACE TRIGGER t_zamestnanec_int_prace BEFORE INSERT
ON zamestnanec FOR EACH ROW
BEGIN
  IF :NEW.datum_nastupu IS NOT NULL AND :NEW.datum_ukonceni IS NOT NULL 
  AND :NEW.datum_nastupu >= :NEW.datum_ukonceni THEN
    -- cislo aplikacni chyby muze byt od -20000 do -20999
    RAISE_APPLICATION_ERROR(-20100, 'Neplatny casovy interval.');
  END IF;
END;
/

/* Trigger kontrolujici spravnost casoveho intervalu <datum_nastupu, 
datum_ukonceni> */
CREATE OR REPLACE TRIGGER t_zamestnanec_int_prace_upd BEFORE UPDATE
ON zamestnanec FOR EACH ROW
BEGIN
  IF :NEW.datum_nastupu IS NOT NULL AND :NEW.datum_ukonceni IS NOT NULL 
  AND :NEW.datum_nastupu >= :NEW.datum_ukonceni THEN
    -- cislo aplikacni chyby muze byt od -20000 do -20999
    RAISE_APPLICATION_ERROR(-20100, 'Neplatny casovy interval.');
  END IF;
END;
/

/* Trigger kontrolujici neaktivitu zamestnance pri zadanem datu 
ukonceni prace */
CREATE OR REPLACE TRIGGER t_zamestnanec_aktivita BEFORE INSERT
ON zamestnanec FOR EACH ROW
BEGIN
  IF :NEW.datum_ukonceni IS NOT NULL AND :NEW.aktivni = 'y' THEN
    RAISE_APPLICATION_ERROR(-20101, 'Zamestnanec s ukoncenym pracovnim pomerem nemuze byt aktivni.');
  END IF;
END;
/

/* Trigger kontrolujici neaktivitu zamestnance pri zadanem datu 
ukonceni prace */
CREATE OR REPLACE TRIGGER t_zamestnanec_aktivita_upd BEFORE UPDATE
ON zamestnanec FOR EACH ROW
BEGIN
  IF :NEW.datum_ukonceni IS NOT NULL AND :NEW.aktivni = 'y' THEN
    RAISE_APPLICATION_ERROR(-20101, 'Zamestnanec s ukoncenym pracovnim pomerem nemuze byt aktivni.');
  END IF;
END;
/

/* Trigger kontrolujici max. pocet cestujicich ucastnicich se letu */
CREATE OR REPLACE TRIGGER t_ucastnik_letu_max_cest BEFORE INSERT
ON ucastnik_letu FOR EACH ROW
DECLARE
  pocet_cestujicich INT;
  pocet_mist_v_letadle INT;
BEGIN
  SELECT COUNT(pasazer_id) INTO pocet_cestujicich 
  FROM ucastnik_letu
  WHERE cislo_letu = :NEW.cislo_letu;
  
  SELECT tl.pocet_mist INTO pocet_mist_v_letadle 
  FROM typ_letadla tl, letadlo l, let lt
  WHERE tl.typ_letadla_id = l.typ_letadla_id AND l.letadlo_id = lt.letadlo_id
  AND lt.cislo_letu = :NEW.cislo_letu;

  IF pocet_cestujicich >= pocet_mist_v_letadle THEN
    RAISE_APPLICATION_ERROR(-20102, 'Nelze pridat cestujiciho. V letadle uz neni misto.');
  END IF;
END;
/

/* Trigger kontrolujici interval <datum porizeni letadla, cas odletu> */
CREATE OR REPLACE TRIGGER t_let_int_porizeni_casodl BEFORE INSERT
ON let FOR EACH ROW
DECLARE 
  datum_porizeni_letadla DATE;
BEGIN
  SELECT datum_porizeni INTO datum_porizeni_letadla FROM letadlo
  WHERE letadlo_id = :NEW.letadlo_id;

  IF datum_porizeni_letadla > :NEW.cas_odletu THEN
    RAISE_APPLICATION_ERROR(-20103, 'Letadlo nemuze odletat v zadanou dobu, v tu dobu jeste neni koupeno.');
  END IF;
END;
/

/* Trigger kontrolujici interval <datum porizeni letadla, cas odletu> */
CREATE OR REPLACE TRIGGER t_let_int_porizeni_casodl_upd BEFORE UPDATE
ON let FOR EACH ROW
DECLARE 
  datum_porizeni_letadla DATE;
BEGIN
  SELECT datum_porizeni INTO datum_porizeni_letadla FROM letadlo
  WHERE letadlo_id = :NEW.letadlo_id;

  IF datum_porizeni_letadla > :NEW.cas_odletu THEN
    RAISE_APPLICATION_ERROR(-20103, 'Letadlo nemuze odletat v zadanou dobu, v tu dobu jeste neni koupeno.');
  END IF;
END;
/

/* Trigger kontrolujici zda jsou na lince zvoleneho letu pozadovane zastavky
odkud, kam */
CREATE OR REPLACE TRIGGER t_ucastnik_letu_exist_zast BEFORE INSERT
ON ucastnik_letu FOR EACH ROW
DECLARE 
  existuji_zastavky CHAR(1) DEFAULT 'n';
BEGIN
  SELECT 'y' INTO existuji_zastavky FROM DUAL 
    WHERE :NEW.odkud IN (
      SELECT z.destinace_id FROM let l, zastavka z 
      WHERE l.cislo_letove_linky = z.cislo_letove_linky 
      AND l.cislo_letu = :NEW.cislo_letu)
    AND :NEW.kam IN (
      SELECT z.destinace_id FROM let l, zastavka z 
      WHERE l.cislo_letove_linky = z.cislo_letove_linky 
      AND l.cislo_letu = :NEW.cislo_letu)
    AND (
      SELECT MIN(z.poradi_zastavky) FROM let l, zastavka z 
      WHERE l.cislo_letove_linky = z.cislo_letove_linky
      AND l.cislo_letu = :NEW.cislo_letu AND z.destinace_id = :NEW.odkud)
      < (
      SELECT MAX(z.poradi_zastavky) FROM let l, zastavka z 
      WHERE l.cislo_letove_linky = z.cislo_letove_linky
      AND l.cislo_letu = :NEW.cislo_letu AND z.destinace_id = :NEW.kam)
    AND ROWNUM = 1;

  IF existuji_zastavky = 'n' THEN
    RAISE_APPLICATION_ERROR(-20104, 'Zastavky, kde chce cestujici nastupovat/vystupovat na vybranem letu neexistuji, nebo jsou ve spatnem poradi.');
  END IF;
END;
/

/* Trigger kontrolujici zda jsou na lince zvoleneho letu pozadovane zastavky
odkud, kam */
CREATE OR REPLACE TRIGGER t_ucastnik_letu_exist_zast_upd BEFORE UPDATE
ON ucastnik_letu FOR EACH ROW
DECLARE 
  existuji_zastavky CHAR(1) DEFAULT 'n';
BEGIN
  SELECT 'y' INTO existuji_zastavky FROM DUAL 
    WHERE :NEW.odkud IN (
      SELECT z.destinace_id FROM let l, zastavka z 
      WHERE l.cislo_letove_linky = z.cislo_letove_linky 
      AND l.cislo_letu = :NEW.cislo_letu)
    AND :NEW.kam IN (
      SELECT z.destinace_id FROM let l, zastavka z 
      WHERE l.cislo_letove_linky = z.cislo_letove_linky 
      AND l.cislo_letu = :NEW.cislo_letu)
    AND (
      SELECT MIN(z.poradi_zastavky) FROM let l, zastavka z 
      WHERE l.cislo_letove_linky = z.cislo_letove_linky
      AND l.cislo_letu = :NEW.cislo_letu AND z.destinace_id = :NEW.odkud)
      < (
      SELECT MAX(z.poradi_zastavky) FROM let l, zastavka z 
      WHERE l.cislo_letove_linky = z.cislo_letove_linky
      AND l.cislo_letu = :NEW.cislo_letu AND z.destinace_id = :NEW.kam)
    AND ROWNUM = 1;

  IF existuji_zastavky = 'n' THEN
    RAISE_APPLICATION_ERROR(-20104, 'Zastavky, kde chce cestujici nastupovat/vystupovat na vybranem letu neexistuji, nebo jsou ve spatnem poradi.');
  END IF;
END;
/

/* Trigger kontrolujici interval <datum nastoupeni pilota, cas odletu> */
CREATE OR REPLACE TRIGGER t_let_int_nastuppil_casodl BEFORE INSERT
ON let FOR EACH ROW
DECLARE 
  datum_nastupu_pilota DATE;
BEGIN
  SELECT datum_nastupu INTO datum_nastupu_pilota FROM zamestnanec z,
  pilot p WHERE z.zamestnanec_id = p.zamestnanec_id 
  AND p.pilot_id = :NEW.pilot_id;

  IF datum_nastupu_pilota > :NEW.cas_odletu THEN
    RAISE_APPLICATION_ERROR(-20105, 'Letadlo nemuze odletat v dobu, kdy jeste pilot nenastoupil do prace.');
  END IF;
END;
/

/* Trigger kontrolujici interval <datum nastoupeni pilota, cas odletu> */
CREATE OR REPLACE TRIGGER t_let_int_nastuppil_casodl_upd BEFORE UPDATE
ON let FOR EACH ROW
DECLARE 
  datum_nastupu_pilota DATE;
BEGIN
  SELECT datum_nastupu INTO datum_nastupu_pilota FROM zamestnanec z,
  pilot p WHERE z.zamestnanec_id = p.zamestnanec_id 
  AND p.pilot_id = :NEW.pilot_id;

  IF datum_nastupu_pilota > :NEW.cas_odletu THEN
    RAISE_APPLICATION_ERROR(-20105, 'Letadlo nemuze odletat v dobu, kdy jeste pilot nenastoupil do prace.');
  END IF;
END;
/

/* Procedura resetujici zadanou sekvenci na nasledujici cislo 1 */
CREATE OR REPLACE PROCEDURE reset_seq(p_seq_name IN VARCHAR2) IS
  l_val number;
BEGIN
  EXECUTE IMMEDIATE
  'SELECT ' || p_seq_name || '.NEXTVAL FROM DUAL' INTO l_val;
  EXECUTE IMMEDIATE
  'ALTER SEQUENCE ' || p_seq_name || ' INCREMENT BY -' || l_val || ' MINVALUE 0';
  EXECUTE IMMEDIATE
  'SELECT ' || p_seq_name || '.NEXTVAL FROM DUAL' INTO l_val;
  EXECUTE IMMEDIATE
  'ALTER SEQUENCE ' || p_seq_name || ' INCREMENT BY 1 MINVALUE 0';
END;
/

/* tabulka s kalendarem */
 create table calendar as (
 SELECT TO_NUMBER (TO_CHAR (mydate, 'yyyymmdd')) AS date_key,
       mydate AS date_time_start,
       mydate + 1 - 1/86400 AS date_time_end,
       TO_CHAR (mydate, 'dd-MON-yyyy') AS date_value,
       TO_NUMBER (TO_CHAR (mydate, 'D')) AS day_of_week_number,
       TO_CHAR (mydate, 'Day') AS day_of_week_desc,
       TO_CHAR (mydate, 'DY') AS day_of_week_sdesc,
       CASE WHEN TO_NUMBER (TO_CHAR (mydate, 'D')) IN (1, 7) THEN 1
            ELSE 0
       END AS weekend_flag,
       TO_NUMBER (TO_CHAR (mydate, 'W')) AS week_in_month_number,
       TO_NUMBER (TO_CHAR (mydate, 'WW')) AS week_in_year_number,
       TRUNC(mydate, 'w') AS week_start_date,
       TRUNC(mydate, 'w') + 7 - 1/86400 AS week_end_date,
       TO_NUMBER (TO_CHAR (mydate, 'IW')) AS iso_week_number,
       TRUNC(mydate, 'iw') AS iso_week_start_date,
       TRUNC(mydate, 'iw') + 7 - 1/86400 AS iso_week_end_date,
       TO_NUMBER (TO_CHAR (mydate, 'DD')) AS day_of_month_number,
       TO_CHAR (mydate, 'MM') AS month_value,
       TO_CHAR (mydate, 'Month') AS month_desc,
       TO_CHAR (mydate, 'MON') AS month_sdesc,
       TRUNC (mydate, 'mm') AS month_start_date,
       LAST_DAY (TRUNC (mydate, 'mm')) + 1 - 1/86400 AS month_end_date,
       TO_NUMBER ( TO_CHAR( LAST_DAY (TRUNC (mydate, 'mm')), 'DD')) AS days_in_month,
       CASE WHEN mydate = LAST_DAY (TRUNC (mydate, 'mm')) THEN 1
            ELSE 0
       END AS last_day_of_month_flag,
       TRUNC (mydate) - TRUNC (mydate, 'Q') + 1 AS day_of_quarter_number,
       TO_CHAR (mydate, 'Q') AS quarter_value,
       'Q' || TO_CHAR (mydate, 'Q') AS quarter_desc,
       TRUNC (mydate, 'Q') AS quarter_start_date,
       ADD_MONTHS (TRUNC (mydate, 'Q'), 3) - 1/86400 AS quarter_end_date,
       ADD_MONTHS (TRUNC (mydate, 'Q'), 3) - TRUNC (mydate, 'Q') AS days_in_quarter,
       CASE WHEN mydate = ADD_MONTHS (TRUNC (mydate, 'Q'), 3) - 1 THEN 1
            ELSE 0
       END AS last_day_of_quarter_flag,
       TO_NUMBER (TO_CHAR (mydate, 'DDD')) AS day_of_year_number,
       TO_CHAR (mydate, 'yyyy') AS year_value,
       'YR' || TO_CHAR (mydate, 'yyyy') AS year_desc,
       'YR' || TO_CHAR (mydate, 'yy') AS year_sdesc,
       TRUNC (mydate, 'Y') AS year_start_date,
       ADD_MONTHS (TRUNC (mydate, 'Y'), 12) - 1/86400 AS year_end_date,
       ADD_MONTHS (TRUNC (mydate, 'Y'), 12) - TRUNC (mydate, 'Y') AS days_in_year
  FROM ( SELECT to_date('1.1.1980', 'DD.MM.YYYY') - 1 + LEVEL AS mydate
           FROM dual
         CONNECT BY LEVEL <= (SELECT   TRUNC (ADD_MONTHS (SYSDATE, 1440), 'yy')
                                     - TRUNC (ADD_MONTHS (SYSDATE, -12), 'yy')
                                FROM DUAL
                             )
                             ));
/

/* rozsireni tabulky zamestnanec o sloupec pohlavi */
alter table zamestnanec add (pohlavi char(1) default 'm' not null);
/

alter table zamestnanec add constraint pohlavi_m_f check (pohlavi in ('m', 'f'));
/

