"! <p class="shorttext synchronized" lang="en">INSERTS/UPDATES are not allowed in Table Functions</p>
CLASS zcl_amdp_update_flights DEFINITION
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


    CLASS-METHODS: test_insert_multiple
      AMDP OPTIONS
      CDS SESSION CLIENT clnt
      IMPORTING
                VALUE(clnt)      TYPE symandt
                VALUE(it_carrid) TYPE tt_scarr
      EXPORTING VALUE(rowcount)  TYPE int4
      RAISING   cx_amdp_error .

    CLASS-METHODS: test_insert_single
      AMDP OPTIONS
      CDS SESSION CLIENT clnt
      IMPORTING
                VALUE(clnt)      TYPE symandt
                VALUE(iv_carrid) TYPE scarr-carrid
      RAISING   cx_amdp_error .


    "! <p class="shorttext synchronized" lang="en">Inserts and UPdates are not supported with Table Functions</p>
    CLASS-METHODS test_insert_single_tf FOR TABLE FUNCTION z_insertcarrier_tf.



    CLASS-METHODS: test_merge
      AMDP OPTIONS
      CDS SESSION CLIENT clnt
      IMPORTING
                VALUE(clnt)      TYPE symandt
                VALUE(it_carrid) TYPE tt_scarr
      EXPORTING VALUE(rowcount)  TYPE int4
      RAISING   cx_amdp_error .

  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_amdp_update_flights IMPLEMENTATION.


  METHOD test_insert_multiple BY DATABASE PROCEDURE
                            FOR HDB LANGUAGE SQLSCRIPT
                            USING scarr.
    Declare lv_index INTEGER;
    Declare lv_updated_rows INTEGER;

    for lv_index in 1..record_count( :it_carrid )
      do
        DECLARE lv_carrid VARCHAR( 2 ) = :it_carrid.carrid[ :lv_index ];
        insert into "SCARR"  VALUES (:clnt,:lv_carrid,'Testing','USD','http:\\test');
    end for;

    lv_updated_rows = ::ROWCOUNT;
  ENDMETHOD.

  METHOD test_merge BY DATABASE PROCEDURE
                            FOR HDB LANGUAGE SQLSCRIPT
                            USING scarr.

    MERGE INTO scarr as scarr USING :it_carrid
     ON scarr.carrid = :it_carrid.carrid
     WHEN NOT MATCHED THEN INSERT
     (
       MANDT,
       CARRID,
       CARRNAME,
       CURRCODE,
       URL
     )
     values (
     :clnt,
     :it_carrid.carrid,
     'Testing',
     'USD',
     'http:\\testerer'
     );

     rowcount = ::ROWCOUNT;
  ENDMETHOD.

  METHOD test_insert_single BY DATABASE PROCEDURE
                            FOR HDB LANGUAGE SQLSCRIPT
                            USING scarr.

    DECLARE lv_number_of_records integer;

    select count( * )
    Into lv_number_of_records
    from "SCARR"
    where carrid = :iv_carrid;
    if :lv_number_of_records  = 0
      then
         insert into "SCARR"
          (
          MANDT,
          CARRID,
          CARRNAME,
          CURRCODE,
          URL
         )
        values (
          :clnt,
          :iv_carrid,
          'Testing',
          'USD',
          'http:\\test'
          );
    end if;




  ENDMETHOD.


  METHOD test_insert_single_tf BY DATABASE FUNCTION
                            FOR HDB LANGUAGE SQLSCRIPT
                            USING scarr.

    declare lv_number_of_records integer;

    select count( * )
    Into lv_number_of_records
    from "SCARR"
    where carrid = :p_carrid;
*Inserts or updates are not supported in the Table functions
    if :lv_number_of_records  = 0
      then
*        insert into "SCARR"
*         (
*         MANDT,
*         CARRID,
*         CARRNAME,
*         CURRCODE,
*         URL
*        )
*       values (
*         :clnt,
*         :iv_carrid,
*         'Testing',
*         'USD',
*         'http:\\test'
*         );
    end if;

     lt_data = select
                        s.mandt,
                        s.carrid,
                        s.carrname,
                        s.currcode,
                        s.url
                    from scarr as s
                  where s.mandt = :p_mandt
                 AND s.carrid = :p_carrid;

     RETURN :lt_data;
  ENDMETHOD.


ENDCLASS.