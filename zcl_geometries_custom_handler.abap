CLASS zcl_geometries_custom_handler DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES: tt_actual_geometries TYPE STANDARD TABLE OF zcustom_actual_geometries_v WITH DEFAULT KEY.
    INTERFACES if_rap_query_provider .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcl_geometries_custom_handler IMPLEMENTATION.
  METHOD if_rap_query_provider~select.
**Here We need to do query on the CDS View to get the data
    DATA:lt_actual_geometries TYPE tt_actual_geometries.
    DATA(lv_entity_id) =  io_request->get_entity_id( ).


*    TRY.

    CASE lv_entity_id.
      WHEN 'ZCUSTOM_ACTUAL_GEOMETRIES_V'.
        IF io_request->is_data_requested( ).

          DATA(lt_req_elements) = io_request->get_requested_elements( ).
          DATA(lv_req_elements) = concat_lines_of( table = lt_req_elements sep = `, ` ).

**parameters
          DATA(lt_parameters) = io_request->get_parameters( ).

*Filter
          DATA(lo_filter) = io_request->get_filter( ).




          DATA(lv_sql_filter) = lo_filter->get_as_sql_string( ).
*       where clause
          DATA(lv_where_clause_string) = cl_abap_dyn_prg=>escape_quotes_str( lv_sql_filter ).


          TRY.
              DATA(lt_filter) = lo_filter->get_as_ranges( ).

** if filter is empty raise a business exception

**raise exception if no filters specified
              DATA(lv_gps_quality) = VALUE #( lt_filter[ name = to_upper( 'GPSQUALITY' ) ]-range[ 1 ]-low OPTIONAL ).
              IF lv_gps_quality IS INITIAL.

                MESSAGE e001(ukm_commons_msg) INTO cl_ukm_commons_auxiliary=>sv_message.

                DATA(lv_) = cx_ukm_commons=>convert_message_to_bapiret( ).

* Raise exception
                RAISE EXCEPTION NEW lcx_business_exception( textid = VALUE #( LET ls_message = cx_ukm_commons=>convert_message_to_bapiret( ) IN
                                                                             msgid = ls_message-id
                                                                             msgno = ls_message-number
                                                                             attr1 = ls_message-message_v1
                                                                             attr2 = ls_message-message_v2
                                                                             attr3 = ls_message-message_v3
                                                                             attr4 = ls_message-message_v4 ) ).

              ENDIF.
            CATCH cx_rap_query_request_changed cx_rap_query_response_changed cx_rap_query_filter_no_range INTO DATA(lo_x_rap_query).
* Forward exception
              RAISE EXCEPTION NEW lcx_business_exception( textid   = VALUE #( LET ls_message = cx_ukm_commons=>convert_exception_to_bapiret( lo_x_rap_query ) IN
                                                                             msgid = ls_message-id
                                                                             msgno = ls_message-number
                                                                             attr1 = ls_message-message_v1
                                                                             attr2 = ls_message-message_v2
                                                                             attr3 = ls_message-message_v3
                                                                             attr4 = ls_message-message_v4 )
                                                          previous = lo_x_rap_query ).
          ENDTRY.


**sort elements
          DATA(lt_sort_elements) = io_request->get_sort_elements( ).

** Get the search expression
          DATA(lv_search_expression) = io_request->get_search_expression( ).


*              cv_where_clause = COND string( WHEN cv_where_clause IS INITIAL
*                                                     THEN lv_search_sql
*                                                     ELSE |( { cv_where_clause } AND ( { lv_search_sql } ) )| ).


*              DATA(lv_next_year) = CONV dats( cl_abap_context_info=>get_system_date( ) + 365 ) .
*              DATA(lv_par_filter) = | BEGIN_DATE >= '{ cl_abap_dyn_prg=>escape_quotes( VALUE #( lt_parameters[ parameter_name = 'P_START_DATE' ]-value
*              DEFAULT cl_abap_context_info=>get_system_date( ) ) ) }'| &&
*              | AND | &&
*              | END_DATE <= '{ cl_abap_dyn_prg=>escape_quotes( VALUE #( lt_parameters[ parameter_name = 'P_END_DATE' ]-value DEFAULT lv_next_year ) ) }'| .
*

*Added for search only
*              IF  NOT lv_search_expression IS INITIAL.
*                DATA(lv_search_filter) =  | GPSQUALITY = { lv_search_expression } | .
*                lv_sql_filter = |({ lv_sql_filter } AND  { lv_search_filter }  )| .
*              ENDIF.

**Set the paging
          DATA(lv_page_size) = io_request->get_paging( )->get_page_size( ).

          DATA(lv_offset) = io_request->get_paging( )->get_offset( ).
          DATA(lv_max_rows) = COND #(  WHEN lv_page_size EQ if_rap_query_paging=>page_size_unlimited THEN 0
                                       ELSE lv_page_size
                                     ).


*Query the cds table built on top of table function!
* Notice the p_where parameter passing the where clause- lv_sql_filter
          SELECT (lv_req_elements)
*          FROM zc_get_actual_geometries_v( p_where = @lv_where_clause_string )
          FROM zi_get_actual_geometries( p_where = @lv_where_clause_string )
          ORDER BY ('primary key')
           INTO CORRESPONDING FIELDS OF TABLE @lt_actual_geometries
          OFFSET @lv_offset UP TO  @lv_max_rows ROWS.

***fill response
          io_response->set_data( it_data = lt_actual_geometries ).

***Set the number of records requested!
          IF io_request->is_total_numb_of_rec_requested( ).
            SELECT COUNT( * )
           FROM zi_get_actual_geometries( p_where = @lv_sql_filter )
            INTO @DATA(lv_travel_count).

**fill response
            io_response->set_total_number_of_records( lv_travel_count ).
          ENDIF.




        ENDIF.



      WHEN OTHERS.

    ENDCASE.

*      CATCH cx_root INTO DATA(lo_exception).
*        DATA(lv_error_text) = lo_exception->get_text(  ).
*
*    ENDTRY.



  ENDMETHOD.



ENDCLASS.