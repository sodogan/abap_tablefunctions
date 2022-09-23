CLASS zcl_amdp_get_flights DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: BEGIN OF ty_sflight,
             mandt     TYPE sy-mandt,
             carrid    TYPE sflight-carrid,
             connid    TYPE sflight-connid,
             fldate    TYPE sflight-fldate,
             price     TYPE sflight-price,
             planetype TYPE sflight-planetype,
           END OF ty_sflight.
    TYPES: tt_scarr TYPE STANDARD TABLE OF scarr WITH DEFAULT KEY.
    TYPES: tt_string TYPE STANDARD TABLE OF string_s WITH DEFAULT KEY.
    TYPES: tt_sflight TYPE STANDARD TABLE OF ty_sflight WITH DEFAULT KEY.
    INTERFACES if_amdp_marker_hdb .
    CLASS-METHODS: find_planetype FOR TABLE FUNCTION z_findcarrier_tf.
    CLASS-METHODS: get_flights IMPORTING VALUE(iv_mandt)     TYPE sy-mandt
                                         VALUE(iv_planetype) TYPE s_planetpp
                               EXPORTING VALUE(et_data)      TYPE tt_sflight.
    CLASS-METHODS: test_apply_filter IMPORTING VALUE(iv_where)   TYPE string
                                     EXPORTING VALUE(flight_tab) TYPE sflight_tab2
                                     RAISING   cx_amdp_error .
    CLASS-METHODS: test_catch_sql_errors
      AMDP OPTIONS
      CDS SESSION CLIENT clnt
      IMPORTING
                VALUE(clnt)      TYPE symandt
                VALUE(it_carrid) TYPE tt_scarr
      RAISING   cx_amdp_error .



  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_amdp_get_flights IMPLEMENTATION.
  METHOD get_flights BY DATABASE PROCEDURE
  FOR HDB LANGUAGE SQLSCRIPT
  OPTIONS READ-ONLY
  USING sflight.


    et_data = select S.MANDT,
                     S.CARRID,
                     S.CONNID,
                     S.FLDATE,
                     S.PRICE,
                     S.PLANETYPE
                 from sflight as S
               where S.mandt = :iv_mandt
              AND S.planetype LIKE  '%' || upper( iv_planetype ) || '%';


  ENDMETHOD.
  METHOD test_catch_sql_errors BY DATABASE PROCEDURE
                            FOR HDB LANGUAGE SQLSCRIPT
                            USING scarr .
    BEGIN
       DECLARE lv_index INTEGER;

        --DECLARE MYCOND CONDITION FOR SQL_ERROR_CODE 10001;
        --DECLARE EXIT HANDLER FOR MYCOND
            --INSERT INTO ERROR_LOG VALUES(::SQL_ERROR_CODE, ::SQL_ERROR_MESSAGE,CURRENT_TIMESTAMP);
            --SELECT ::SQL_ERROR_CODE, ::SQL_ERROR_MESSAGE  FROM DUMMY;
           DECLARE errCode INT;
           DECLARE errMsg VARCHAR(5000);

        BEGIN AUTONOMOUS TRANSACTION
          DECLARE EXIT HANDLER FOR SQLEXCEPTION
              BEGIN AUTONOMOUS TRANSACTION
                  errCode= ::SQL_ERROR_CODE;
                  errMsg=  ::SQL_ERROR_MESSAGE ;
               SELECT ::SQL_ERROR_CODE, ::SQL_ERROR_MESSAGE  FROM DUMMY;
              END;

       for lv_index in 1..record_count( :it_carrid )
         do
          DECLARE lv_carrid VARCHAR( 2 ) = :it_carrid.carrid[ :lv_index ];

          insert into "SCARR"  VALUES (:clnt,:lv_carrid,'Testing','USD','http:\\test');
        end for;
      END;
    END;

  ENDMETHOD.
  METHOD test_apply_filter BY DATABASE PROCEDURE
                            FOR HDB LANGUAGE SQLSCRIPT
                            OPTIONS READ-ONLY
                             USING sflight.

**how do we filter a table -storage
        lt_data = APPLY_FILTER("SFLIGHT", :iv_where) ;


   IF NOT IS_EMPTY(:lt_data) THEN
     flight_tab = select *
                 from
                :lt_data;
   end if;



  ENDMETHOD.


  METHOD find_planetype  BY DATABASE FUNCTION FOR HDB
                            LANGUAGE SQLSCRIPT
                            OPTIONS READ-ONLY
                            USING SFLIGHT.

    lt_data = select
                       S.MANDT,
                       S.CARRID,
                       S.CONNID,
                       S.FLDATE,
                       S.PRICE,
                       S.PLANETYPE
                   from sflight as S
                 where S.mandt = :p_mandt
                AND S.planetype LIKE  '%' || upper( :p_planetype ) || '%';

    RETURN :lt_data;

  ENDMETHOD.


ENDCLASS.