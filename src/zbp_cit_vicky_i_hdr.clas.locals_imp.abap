CLASS lhc_SalesOrderHdr DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR SalesOrderHdr RESULT result.
    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR SalesOrderHdr RESULT result.
    METHODS get_instance_features FOR INSTANCE FEATURES
      IMPORTING keys REQUEST requested_features FOR SalesOrderHdr RESULT result.
    METHODS create FOR MODIFY
      IMPORTING entities FOR CREATE SalesOrderHdr.
    METHODS update FOR MODIFY
      IMPORTING entities FOR UPDATE SalesOrderHdr.
    METHODS delete FOR MODIFY
      IMPORTING keys FOR DELETE SalesOrderHdr.
    METHODS read FOR READ
      IMPORTING keys FOR READ SalesOrderHdr RESULT result.
    METHODS lock FOR LOCK
      IMPORTING keys FOR LOCK SalesOrderHdr.
    METHODS rba_Salesitem FOR READ
      IMPORTING keys_rba FOR READ SalesOrderHdr\_salesitem FULL result_requested RESULT result LINK association_links.
    METHODS cba_Salesitem FOR MODIFY
      IMPORTING entities_cba FOR CREATE SalesOrderHdr\_salesitem.
    METHODS uploadExcelData FOR MODIFY
      IMPORTING keys FOR ACTION SalesOrderHdr~uploadExcelData RESULT result.
    METHODS DownloadExcel FOR MODIFY
      IMPORTING keys FOR ACTION SalesOrderHdr~DownloadExcel RESULT result.
    METHODS FillFileStatus FOR DETERMINE ON MODIFY
      IMPORTING keys FOR SalesOrderHdr~FillFileStatus.
ENDCLASS.

CLASS lhc_SalesOrderHdr IMPLEMENTATION.

  METHOD get_global_authorizations.
    IF requested_authorizations-%create = if_abap_behv=>mk-on.
      result-%create = if_abap_behv=>auth-allowed.
    ENDIF.
  ENDMETHOD.

  METHOD get_instance_authorizations.
    DATA ls_result LIKE LINE OF result.
    LOOP AT keys INTO DATA(ls_key).
      CLEAR ls_result.
      ls_result-%tky         = ls_key-%tky.
      ls_result-%update      = if_abap_behv=>auth-allowed.
      ls_result-%delete      = if_abap_behv=>auth-allowed.
      ls_result-%action-Edit = if_abap_behv=>auth-allowed.
      APPEND ls_result TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD get_instance_features.
    DATA ls_result LIKE LINE OF result.

    LOOP AT keys INTO DATA(ls_key).
      CLEAR ls_result.
      ls_result-%tky = ls_key-%tky.

      " Unconditionally enable both buttons
      ls_result-%action-uploadExcelData = if_abap_behv=>fc-o-enabled.
      ls_result-%action-DownloadExcel   = if_abap_behv=>fc-o-enabled.

      APPEND ls_result TO result.
    ENDLOOP.
  ENDMETHOD.

  METHOD lock. ENDMETHOD.

  "==========================================================
  " CREATE
  "==========================================================
  METHOD create.
    DATA ls_sales_hdr TYPE zcit_vicky_hdr.
    DATA ls_mapped    LIKE LINE OF mapped-salesorderhdr.
    DATA ls_reported  LIKE LINE OF reported-salesorderhdr.
    DATA ls_failed    LIKE LINE OF failed-salesorderhdr.
    DATA(lo_util) = zcit_utility_class=>get_instance( ).

    LOOP AT entities INTO DATA(ls_entities).
      ls_sales_hdr = CORRESPONDING #( ls_entities MAPPING FROM ENTITY ).

      IF ls_sales_hdr-salesdocument IS INITIAL.
        CLEAR ls_reported.
        ls_reported-%cid = ls_entities-%cid.
        ls_reported-%msg = new_message( id       = 'ZCIT_VICKY_MSG'
                                        number   = '001'
                                        v1       = 'Sales Document number is mandatory'
                                        severity = if_abap_behv_message=>severity-error ).
        APPEND ls_reported TO reported-salesorderhdr.
        CONTINUE.
      ENDIF.

      SELECT SINGLE salesdocument FROM zcit_vicky_hdr
        WHERE salesdocument = @ls_sales_hdr-salesdocument
        INTO @DATA(lv_exist).

      IF sy-subrc = 0.
        CLEAR ls_failed.
        ls_failed-%cid          = ls_entities-%cid.
        ls_failed-salesdocument = ls_sales_hdr-salesdocument.
        APPEND ls_failed TO failed-salesorderhdr.
        CLEAR ls_reported.
        ls_reported-%cid          = ls_entities-%cid.
        ls_reported-salesdocument = ls_sales_hdr-salesdocument.
        ls_reported-%msg = new_message( id       = 'ZCIT_VICKY_MSG'
                                        number   = '001'
                                        v1       = 'Duplicate Sales Order'
                                        severity = if_abap_behv_message=>severity-error ).
        APPEND ls_reported TO reported-salesorderhdr.
        CONTINUE.
      ENDIF.

      lo_util->set_hdr_value( EXPORTING im_sales_hdr = ls_sales_hdr
                              IMPORTING ex_created   = DATA(lv_created) ).
      IF lv_created = abap_true.
        CLEAR ls_mapped.
        ls_mapped-%cid          = ls_entities-%cid.
        ls_mapped-salesdocument = ls_sales_hdr-salesdocument.
        APPEND ls_mapped TO mapped-salesorderhdr.
        CLEAR ls_reported.
        ls_reported-%cid          = ls_entities-%cid.
        ls_reported-salesdocument = ls_sales_hdr-salesdocument.
        ls_reported-%msg = new_message( id       = 'ZCIT_VICKY_MSG'
                                        number   = '001'
                                        v1       = 'Sales Order Created Successfully'
                                        severity = if_abap_behv_message=>severity-success ).
        APPEND ls_reported TO reported-salesorderhdr.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  "==========================================================
  " UPDATE
  "==========================================================
  METHOD update.
    DATA ls_sales_hdr TYPE zcit_vicky_hdr.
    DATA ls_reported  LIKE LINE OF reported-salesorderhdr.
    DATA(lo_util) = zcit_utility_class=>get_instance( ).

    LOOP AT entities INTO DATA(ls_entities).
      ls_sales_hdr = CORRESPONDING #( ls_entities MAPPING FROM ENTITY ).
      lo_util->set_hdr_value( EXPORTING im_sales_hdr = ls_sales_hdr
                              IMPORTING ex_created   = DATA(lv_created) ).
      CLEAR ls_reported.
      ls_reported-%key = ls_entities-%key.
      IF lv_created = abap_true.
        ls_reported-%msg = new_message( id       = 'ZCIT_VICKY_MSG'
                                        number   = '001'
                                        v1       = 'Sales Order Updated Successfully'
                                        severity = if_abap_behv_message=>severity-success ).
      ELSE.
        ls_reported-%msg = new_message( id       = 'ZCIT_VICKY_MSG'
                                        number   = '001'
                                        v1       = 'Sales Order Update Failed'
                                        severity = if_abap_behv_message=>severity-error ).
      ENDIF.
      APPEND ls_reported TO reported-salesorderhdr.
    ENDLOOP.
  ENDMETHOD.

  "==========================================================
  " DELETE
  "==========================================================
  METHOD delete.
    TYPES: BEGIN OF ty_del, salesdocument TYPE vbeln, END OF ty_del.
    DATA ls_del      TYPE ty_del.
    DATA ls_reported LIKE LINE OF reported-salesorderhdr.
    DATA(lo_util) = zcit_utility_class=>get_instance( ).

    LOOP AT keys INTO DATA(ls_key).
      ls_del-salesdocument = ls_key-salesdocument.
      lo_util->set_hdr_t_deletion( EXPORTING im_sales_doc = ls_del ).
      lo_util->set_hdr_deletion_flag( EXPORTING im_so_delete = abap_true ).
      CLEAR ls_reported.
      ls_reported-salesdocument = ls_key-salesdocument.
      ls_reported-%msg = new_message( id       = 'ZCIT_VICKY_MSG'
                                      number   = '001'
                                      v1       = 'Order Deleted Successfully'
                                      severity = if_abap_behv_message=>severity-success ).
      APPEND ls_reported TO reported-salesorderhdr.
    ENDLOOP.
  ENDMETHOD.

  "==========================================================
  " READ
  "==========================================================
  METHOD read.
    DATA ls_result LIKE LINE OF result.
    LOOP AT keys INTO DATA(ls_key).
      SELECT SINGLE * FROM zcit_vicky_hdr
        WHERE salesdocument = @ls_key-salesdocument
        INTO @DATA(ls_hdr).
      IF sy-subrc = 0.
        CLEAR ls_result.
        ls_result-%tky                = ls_key-%tky.
        ls_result-SalesDocument       = ls_hdr-salesdocument.
        ls_result-SalesDocumentType   = ls_hdr-salesdocumenttype.
        ls_result-OrderReason         = ls_hdr-orderreason.
        ls_result-SalesOrganization   = ls_hdr-salesorganization.
        ls_result-DistributionChannel = ls_hdr-distributionchannel.
        ls_result-Division            = ls_hdr-division.
        ls_result-SalesOffice         = ls_hdr-salesoffice.
        ls_result-SalesGroup          = ls_hdr-salesgroup.
        ls_result-NetPrice            = ls_hdr-netprice.
        ls_result-Currency            = ls_hdr-currency.
        ls_result-ExcelAttachment     = ls_hdr-excel_attachment.
        ls_result-ExcelMimeType       = ls_hdr-excel_mimetype.
        ls_result-ExcelFileName       = ls_hdr-excel_filename.
        ls_result-FileStatus          = ls_hdr-file_status.
        ls_result-LocalCreatedBy      = ls_hdr-local_created_by.
        ls_result-LocalCreatedAt      = ls_hdr-local_created_at.
        ls_result-LocalLastChangedBy  = ls_hdr-local_last_changed_by.
        ls_result-LocalLastChangedAt  = ls_hdr-local_last_changed_at.
        APPEND ls_result TO result.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.

  "==========================================================
  " READ BY ASSOCIATION — Items
  "==========================================================
  METHOD rba_Salesitem.
    DATA ls_link LIKE LINE OF association_links.
    LOOP AT keys_rba INTO DATA(ls_key).
      SELECT * FROM zcit_vicky_itm
        WHERE salesdocument = @ls_key-salesdocument
        INTO TABLE @DATA(lt_items).
      LOOP AT lt_items INTO DATA(ls_item).
        APPEND CORRESPONDING #( ls_item ) TO result.
        CLEAR ls_link.
        ls_link-source-salesdocument   = ls_key-salesdocument.
        ls_link-target-salesdocument   = ls_item-salesdocument.
        ls_link-target-salesitemnumber = ls_item-salesitemnumber.
        APPEND ls_link TO association_links.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  "==========================================================
  " CREATE BY ASSOCIATION — Items (manual row add in UI)
  "==========================================================
  "==========================================================
  " CREATE BY ASSOCIATION — Items (manual row add in UI)
  "==========================================================
  METHOD cba_Salesitem.
    DATA ls_itm      TYPE zcit_vicky_itm.
    DATA ls_mapped   LIKE LINE OF mapped-salesorderitm.
    DATA ls_reported LIKE LINE OF reported-salesorderitm.
    DATA ls_failed   LIKE LINE OF failed-salesorderitm.
    DATA(lo_util) = zcit_utility_class=>get_instance( ).

    LOOP AT entities_cba INTO DATA(ls_cba).
      LOOP AT ls_cba-%target INTO DATA(ls_target).
        ls_itm = CORRESPONDING #( ls_target MAPPING FROM ENTITY ).

        " SAFETY NET 1: Reject if keys are missing so RAP doesn't crash
        IF ls_itm-salesdocument IS INITIAL OR ls_itm-salesitemnumber IS INITIAL.
          CLEAR ls_failed.
          ls_failed-%cid = ls_target-%cid.
          APPEND ls_failed TO failed-salesorderitm.

          CLEAR ls_reported.
          ls_reported-%cid = ls_target-%cid.
          ls_reported-%msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = 'Item Number is mandatory' ).
          APPEND ls_reported TO reported-salesorderitm.
          CONTINUE.
        ENDIF.

        SELECT SINGLE salesdocument FROM zcit_vicky_itm
          WHERE salesdocument   = @ls_itm-salesdocument
            AND salesitemnumber = @ls_itm-salesitemnumber
          INTO @DATA(lv_exist).

        IF sy-subrc <> 0.
          lo_util->set_itm_value( EXPORTING im_sales_itm = ls_itm
                                  IMPORTING ex_created   = DATA(lv_created) ).
          IF lv_created = abap_true.
            CLEAR ls_mapped.
            ls_mapped-%cid            = ls_target-%cid.
            ls_mapped-salesdocument   = ls_itm-salesdocument.
            ls_mapped-salesitemnumber = ls_itm-salesitemnumber.
            APPEND ls_mapped TO mapped-salesorderitm.

            CLEAR ls_reported.
            ls_reported-%cid          = ls_target-%cid.
            ls_reported-salesdocument = ls_itm-salesdocument.
            ls_reported-%msg = new_message_with_text( severity = if_abap_behv_message=>severity-success text = 'Item Created Successfully' ).
            APPEND ls_reported TO reported-salesorderitm.
          ENDIF.
        ELSE.
          " SAFETY NET 2: Reject Duplicate Items properly without crashing
          CLEAR ls_failed.
          ls_failed-%cid            = ls_target-%cid.
          ls_failed-salesdocument   = ls_itm-salesdocument.
          ls_failed-salesitemnumber = ls_itm-salesitemnumber.
          APPEND ls_failed TO failed-salesorderitm.

          CLEAR ls_reported.
          ls_reported-%cid          = ls_target-%cid.
          ls_reported-salesdocument = ls_itm-salesdocument.
          ls_reported-%msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = 'Duplicate Item' ).
          APPEND ls_reported TO reported-salesorderitm.
        ENDIF.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

  "==========================================================
  " ACTION — Download Excel Template
  " Safe EML Update to prevent Short Dumps
  "==========================================================
  METHOD DownloadExcel.
    TYPES: BEGIN OF ty_tmpl,
             col1 TYPE string,
             col2 TYPE string,
             col3 TYPE string,
             col4 TYPE string,
             col5 TYPE string,
           END OF ty_tmpl.
    DATA lt_tmpl   TYPE STANDARD TABLE OF ty_tmpl.
    DATA ls_tmpl   TYPE ty_tmpl.
    DATA ls_result LIKE LINE OF result.
    DATA ls_rep    LIKE LINE OF reported-salesorderhdr.

    "--- Build header row ---
    CLEAR ls_tmpl.
    ls_tmpl-col1 = 'Sales Document'.
    ls_tmpl-col2 = 'Material'.
    ls_tmpl-col3 = 'Plant'.
    ls_tmpl-col4 = 'Quantity'.
    ls_tmpl-col5 = 'Unit'.
    APPEND ls_tmpl TO lt_tmpl.

    "--- Create workbook ---
    DATA(lo_write) = xco_cp_xlsx=>document->empty( )->write_access( ).
    DATA(lo_ws)    = lo_write->get_workbook( )->worksheet->at_position( 1 ).
    DATA(lo_sel)   = xco_cp_xlsx_selection=>pattern_builder->simple_from_to(
      )->from_column( xco_cp_xlsx=>coordinate->for_alphabetic_value( 'A' )
      )->to_column(   xco_cp_xlsx=>coordinate->for_alphabetic_value( 'E' )
      )->from_row(    xco_cp_xlsx=>coordinate->for_numeric_value( 1 )
      )->get_pattern( ).

    lo_ws->select( lo_sel
      )->row_stream( )->operation->write_from( REF #( lt_tmpl ) )->execute( ).

    DATA(lv_content) = lo_write->get_file_content( ).

    "--- NEW SAFETY NET: EML UPDATE instead of Direct SQL UPDATE ---
    DATA lt_update TYPE TABLE FOR UPDATE ZCIT_VICKY_I_HDR.
    DATA ls_update LIKE LINE OF lt_update.

    LOOP AT keys INTO DATA(ls_key).
      CLEAR ls_update.
      ls_update-%tky              = ls_key-%tky. " Respects the Draft mode!
      ls_update-ExcelAttachment   = lv_content.
      ls_update-ExcelMimeType     = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet'.
      ls_update-ExcelFileName     = 'SalesOrder_Template.xlsx'.
      ls_update-FileStatus        = 'Template Downloaded'.

      " Tell RAP exactly which fields we are changing
      ls_update-%control-ExcelAttachment = if_abap_behv=>mk-on.
      ls_update-%control-ExcelMimeType   = if_abap_behv=>mk-on.
      ls_update-%control-ExcelFileName   = if_abap_behv=>mk-on.
      ls_update-%control-FileStatus      = if_abap_behv=>mk-on.

      APPEND ls_update TO lt_update.
    ENDLOOP.

    " Push the template file into the RAP Draft Buffer safely
    IF lt_update IS NOT INITIAL.
      MODIFY ENTITIES OF ZCIT_VICKY_I_HDR IN LOCAL MODE
        ENTITY SalesOrderHdr
          UPDATE FROM lt_update
        REPORTED DATA(lt_reported).
    ENDIF.

    "--- Read the newly updated Draft record and return to UI ---
    READ ENTITIES OF ZCIT_VICKY_I_HDR IN LOCAL MODE
      ENTITY SalesOrderHdr ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_hdr).

    LOOP AT lt_hdr INTO DATA(ls_hdr).
      CLEAR ls_result.
      ls_result-%tky   = ls_hdr-%tky.
      ls_result-%param = CORRESPONDING #( ls_hdr ).
      APPEND ls_result TO result.

      CLEAR ls_rep.
      ls_rep-%tky = ls_hdr-%tky.
      ls_rep-%msg = new_message_with_text(
        severity = if_abap_behv_message=>severity-success
        text     = 'Template downloaded. Fill in and upload the Excel file.' ).
      APPEND ls_rep TO reported-salesorderhdr.
    ENDLOOP.
  ENDMETHOD.

  "==========================================================
  " ACTION — Upload Excel Data
  " Safe Draft Creation + Error Protection
  "==========================================================
  "==========================================================
  " ACTION — Upload Excel Data
  " Safe Draft Creation + Error Protection
  "==========================================================
  METHOD uploadExcelData.
    TYPES: BEGIN OF ty_row,
             col1 TYPE string,
             col2 TYPE string,
             col3 TYPE string,
             col4 TYPE string,
             col5 TYPE string,
           END OF ty_row.
    DATA lt_raw    TYPE STANDARD TABLE OF ty_row.
    DATA ls_result LIKE LINE OF result.
    DATA ls_rep    LIKE LINE OF reported-salesorderhdr.

    "--- Step 1: Read header to get attachment ---
    READ ENTITIES OF ZCIT_VICKY_I_HDR IN LOCAL MODE
      ENTITY SalesOrderHdr
        FIELDS ( ExcelAttachment ) WITH CORRESPONDING #( keys )
      RESULT DATA(lt_entity).

    IF lt_entity IS INITIAL. RETURN. ENDIF.

    DATA(ls_entity)     = lt_entity[ 1 ].
    DATA(lv_attachment) = ls_entity-ExcelAttachment.

    IF lv_attachment IS INITIAL.
      LOOP AT keys INTO DATA(ls_key).
        CLEAR ls_rep.
        ls_rep-%tky = ls_key-%tky.
        ls_rep-%msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = 'No file attached. Please choose an Excel file first.' ).
        APPEND ls_rep TO reported-salesorderhdr.
      ENDLOOP.
      RETURN.
    ENDIF.

    "--- Step 2: Parse Excel ---
    DATA(lo_doc) = xco_cp_xlsx=>document->for_file_content( iv_file_content = lv_attachment )->read_access( ).
    DATA(lo_ws)  = lo_doc->get_workbook( )->worksheet->at_position( 1 ).
    DATA(lo_sel) = xco_cp_xlsx_selection=>pattern_builder->simple_from_to( )->get_pattern( ).
    DATA(lo_op)  = lo_ws->select( lo_sel )->row_stream( )->operation->write_to( REF #( lt_raw ) ).
    lo_op->set_value_transformation( xco_cp_xlsx_read_access=>value_transformation->string_value )->if_xco_xlsx_ra_operation~execute( ).

    IF lt_raw IS INITIAL.
      LOOP AT keys INTO ls_key.
        CLEAR ls_rep.
        ls_rep-%tky = ls_key-%tky.
        ls_rep-%msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = 'Excel file is empty.' ).
        APPEND ls_rep TO reported-salesorderhdr.
      ENDLOOP.
      RETURN.
    ENDIF.

    "--- Step 3: Validate & clean data ---
    DATA(ls_hdr_row) = lt_raw[ 1 ].
    IF ls_hdr_row-col1 <> 'Sales Document'.
      LOOP AT keys INTO ls_key.
        CLEAR ls_rep.
        ls_rep-%tky = ls_key-%tky.
        ls_rep-%msg = new_message_with_text( severity = if_abap_behv_message=>severity-error text = 'Wrong template! Download and use the correct template.' ).
        APPEND ls_rep TO reported-salesorderhdr.
      ENDLOOP.
      RETURN.
    ENDIF.

    DELETE lt_raw INDEX 1. " Remove header row
    DELETE lt_raw WHERE col2 IS INITIAL AND col3 IS INITIAL. " Remove blank rows

    "--- Step 4: Prepare EML updates ---
    DATA lt_update_hdr TYPE TABLE FOR UPDATE ZCIT_VICKY_I_HDR.
    DATA ls_update_hdr LIKE LINE OF lt_update_hdr.

    DATA lt_cba_items  TYPE TABLE FOR CREATE ZCIT_VICKY_I_HDR\_salesitem.
    DATA ls_cba_items  LIKE LINE OF lt_cba_items.
    DATA ls_target     LIKE LINE OF ls_cba_items-%target.

    LOOP AT keys INTO ls_key.
      " =================================================================
      " NEW FIX: Find the highest existing item number to prevent dumps
      " =================================================================
      READ ENTITIES OF ZCIT_VICKY_I_HDR IN LOCAL MODE
        ENTITY SalesOrderHdr BY \_salesitem
        FIELDS ( SalesItemnumber ) WITH VALUE #( ( %tky = ls_key-%tky ) )
        RESULT DATA(lt_existing_items).

      DATA lv_serial TYPE int2 VALUE 0.
      LOOP AT lt_existing_items INTO DATA(ls_existing).
        IF ls_existing-SalesItemnumber > lv_serial.
          lv_serial = ls_existing-SalesItemnumber.
        ENDIF.
      ENDLOOP.

      " Start numbering from the next available item!
      lv_serial += 1.
      " =================================================================

      " Prepare Header Update
      CLEAR ls_update_hdr.
      ls_update_hdr-%tky                = ls_key-%tky. " %tky keeps the draft flag!
      ls_update_hdr-FileStatus          = 'Excel Uploaded'.
      ls_update_hdr-%control-FileStatus = if_abap_behv=>mk-on.
      APPEND ls_update_hdr TO lt_update_hdr.

      " Prepare Items Creation
      CLEAR ls_cba_items.
      ls_cba_items-%tky = ls_key-%tky.

      LOOP AT lt_raw INTO DATA(ls_row).
        CLEAR ls_target.
        ls_target-%cid = 'EXCEL_' && condense( val = CONV string( lv_serial ) ).

        " Pass the Draft status to the item to avoid short dumps
        ls_target-%is_draft       = ls_key-%is_draft.

        ls_target-SalesDocument   = ls_key-SalesDocument.
        ls_target-SalesItemnumber = lv_serial.
        ls_target-Material        = ls_row-col2.
        ls_target-Plant           = ls_row-col3.

        DATA lv_raw_qty  TYPE string.
        DATA lv_raw_unit TYPE string.

        IF ls_row-col5 CO ' 0123456789.,'.
          lv_raw_qty  = ls_row-col5.
          lv_raw_unit = ls_row-col4.
        ELSE.
          lv_raw_qty  = ls_row-col4.
          lv_raw_unit = ls_row-col5.
        ENDIF.

        REPLACE ALL OCCURRENCES OF ',' IN lv_raw_qty WITH '.'.
        TRY.
            ls_target-Quantity = lv_raw_qty.
          CATCH cx_sy_conversion_error.
            ls_target-Quantity = 0.
        ENDTRY.

        ls_target-Quantityunits = to_upper( lv_raw_unit ).

        IF ls_target-Quantityunits IS INITIAL OR ls_target-Quantityunits CO ' 0123456789.,'.
          ls_target-Quantityunits = 'EA'.
        ENDIF.

        ls_target-%control-SalesDocument   = if_abap_behv=>mk-on.
        ls_target-%control-SalesItemnumber = if_abap_behv=>mk-on.
        ls_target-%control-Material        = if_abap_behv=>mk-on.
        ls_target-%control-Plant           = if_abap_behv=>mk-on.
        ls_target-%control-Quantity        = if_abap_behv=>mk-on.
        ls_target-%control-Quantityunits   = if_abap_behv=>mk-on.

        APPEND ls_target TO ls_cba_items-%target.
        lv_serial += 1. " Increment for the next row
      ENDLOOP.

      IF ls_cba_items-%target IS NOT INITIAL.
        APPEND ls_cba_items TO lt_cba_items.
      ENDIF.
    ENDLOOP.

    "--- Step 5: Push data to RAP Draft Buffer safely ---
    MODIFY ENTITIES OF ZCIT_VICKY_I_HDR IN LOCAL MODE
      ENTITY SalesOrderHdr
        UPDATE FROM lt_update_hdr
      ENTITY SalesOrderHdr
        CREATE BY \_salesitem
        FROM lt_cba_items
      REPORTED DATA(lt_reported_eml).

    "--- Step 6: Return success result back to UI ---
    DATA lv_count TYPE i.
    lv_count = lines( lt_raw ).

    READ ENTITIES OF ZCIT_VICKY_I_HDR IN LOCAL MODE
      ENTITY SalesOrderHdr ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_hdr_final).

    LOOP AT lt_hdr_final INTO DATA(ls_hdr_final).
      CLEAR ls_result.
      ls_result-%tky   = ls_hdr_final-%tky.
      ls_result-%param = CORRESPONDING #( ls_hdr_final ).
      APPEND ls_result TO result.

      CLEAR ls_rep.
      ls_rep-%tky = ls_hdr_final-%tky.
      ls_rep-%msg = new_message_with_text(
        severity = if_abap_behv_message=>severity-success
        text     = |{ lv_count } item(s) uploaded successfully!| ).
      APPEND ls_rep TO reported-salesorderhdr.
    ENDLOOP.
  ENDMETHOD.
  "==========================================================
  " DETERMINATION — FillFileStatus
  " Safe EML Update — no direct DB modification
  "==========================================================
  METHOD FillFileStatus.
    READ ENTITIES OF ZCIT_VICKY_I_HDR IN LOCAL MODE
      ENTITY SalesOrderHdr
        FIELDS ( ExcelAttachment FileStatus )
        WITH CORRESPONDING #( keys )
      RESULT DATA(lt_hdr).

    DATA lt_update TYPE TABLE FOR UPDATE ZCIT_VICKY_I_HDR.
    DATA ls_update LIKE LINE OF lt_update.

    LOOP AT lt_hdr INTO DATA(ls_hdr).
      DATA lv_status TYPE zcit_vicky_hdr-file_status.

      IF ls_hdr-ExcelAttachment IS INITIAL.
        lv_status = 'No File Selected'.
      ELSEIF ls_hdr-FileStatus = 'Excel Uploaded'.
        lv_status = 'Excel Uploaded'.
      ELSE.
        lv_status = 'File Selected'.
      ENDIF.

      " Only update if the status is actually changing to avoid infinite loops
      IF ls_hdr-FileStatus <> lv_status.
        CLEAR ls_update.
        ls_update-%tky        = ls_hdr-%tky.
        ls_update-FileStatus  = lv_status.
        " Use %control to specify which fields are being updated
        ls_update-%control-FileStatus = if_abap_behv=>mk-on.
        APPEND ls_update TO lt_update.
      ENDIF.
    ENDLOOP.

    IF lt_update IS NOT INITIAL.
      " Update the RAP buffer using EML
      MODIFY ENTITIES OF ZCIT_VICKY_I_HDR IN LOCAL MODE
        ENTITY SalesOrderHdr
          UPDATE FROM lt_update
        REPORTED DATA(lt_reported).
    ENDIF.
  ENDMETHOD.

ENDCLASS.
