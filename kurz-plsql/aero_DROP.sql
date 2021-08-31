ALTER SESSION SET CURRENT_SCHEMA = aero;

Drop Sequence zamestnani_seq
/

Drop Sequence zamestnanec_seq
/

Drop Sequence pilot_seq
/

Drop Sequence letadlo_seq
/

Drop Sequence let_seq
/

Drop Sequence letova_linka_seq
/

Drop Sequence pasazer_seq
/

Drop Sequence destinace_seq
/


Alter table zamestnanec drop constraint pracuje_jako
/
Alter table zamestnanec drop constraint ma_nadrizeneho
/
Alter table pilot drop constraint je_zamestnan
/
Alter table let drop constraint ridi
/
Alter table zastavka drop constraint je_mistem_pristani
/
Alter table ucastnik_letu drop constraint leti_z
/
Alter table ucastnik_letu drop constraint leti_do
/
Alter table zastavka drop constraint linka_ma_zastavky
/
Alter table let drop constraint ma_rozvrh_letu
/
Alter table letadlo drop constraint je_typu
/
Alter table let drop constraint vykonavan_letadlem
/
Alter table ucastnik_letu drop constraint leti_konkretnim_letem
/
Alter table ucastnik_letu drop constraint ma_pasazery
/


Drop table ucastnik_letu
/
Drop table let
/
Drop table pasazer
/
Drop table letadlo
/
Drop table typ_letadla
/
Drop table zastavka
/
Drop table letova_linka
/
Drop table destinace
/
Drop table pilot
/
Drop table zamestnanec
/
Drop table zamestnani
/

DROP PROCEDURE reset_seq;
/
-- triggery se odstrani automaticky pri odstraneni tabulek
