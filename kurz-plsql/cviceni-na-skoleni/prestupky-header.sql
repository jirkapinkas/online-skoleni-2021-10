--------------------------------------------------------
--  File created - Støeda-øíjen-08-2014   
--------------------------------------------------------
--------------------------------------------------------
--  DDL for Package PRESTUPKY
--------------------------------------------------------

  CREATE OR REPLACE PACKAGE "PRESTUPKY" AS

  PROCEDURE pridej(
      V_PASAZER_ID IN UCASTNIK_LETU.PASAZER_ID%TYPE ,
      V_CISLO_LETU IN UCASTNIK_LETU.CISLO_LETU%TYPE );
      
      
  PROCEDURE inc_prestupek(
      V_PASAZER_ID IN UCASTNIK_LETU.PASAZER_ID%TYPE ,
      V_CISLO_LETU IN UCASTNIK_LETU.CISLO_LETU%TYPE );

END PRESTUPKY;

