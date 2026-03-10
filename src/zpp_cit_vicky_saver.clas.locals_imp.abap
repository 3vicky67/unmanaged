CLASS lsc_ZCIT_VICKY_I_HDR DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS finalize          REDEFINITION.
    METHODS check_before_save REDEFINITION.
    METHODS save              REDEFINITION.
    METHODS cleanup           REDEFINITION.
    METHODS cleanup_finalize  REDEFINITION.
ENDCLASS.

CLASS lsc_ZCIT_VICKY_I_HDR IMPLEMENTATION.

  METHOD finalize. ENDMETHOD.

  METHOD check_before_save. ENDMETHOD.

  METHOD save.
    DATA(lo_util) = zcit_utility_class=>get_instance( ).

    "Get all buffers
    lo_util->get_hdr_value(       IMPORTING ex_sales_hdr  = DATA(lt_sales_hdr) ).
    lo_util->get_itm_value(       IMPORTING ex_sales_itm  = DATA(lt_sales_itm) ).
    lo_util->get_hdr_t_deletion(  IMPORTING ex_sales_docs = DATA(lt_del_hdr) ).
    lo_util->get_itm_t_deletion(  IMPORTING ex_sales_info = DATA(lt_del_itm) ).
    lo_util->get_deletion_flags(  IMPORTING ex_so_hdr_del = DATA(lv_hdr_del_flag) ).
    lo_util->get_excel_upload_flag( IMPORTING ex_excel_uploaded = DATA(lv_excel_uploaded) ).

    "1. Save / update header records
    IF lt_sales_hdr IS NOT INITIAL.
      MODIFY zcit_vicky_hdr FROM TABLE @lt_sales_hdr.
    ENDIF.

    "2. Save / update manually created item records
    IF lt_sales_itm IS NOT INITIAL.
      MODIFY zcit_vicky_itm FROM TABLE @lt_sales_itm.
    ENDIF.

    "3. Handle header / item deletions
    IF lv_hdr_del_flag = abap_true.
      "Full order deletion — remove header AND all items
      LOOP AT lt_del_hdr INTO DATA(ls_del_hdr).
        DELETE FROM zcit_vicky_hdr WHERE salesdocument = @ls_del_hdr-salesdocument.
        DELETE FROM zcit_vicky_itm WHERE salesdocument = @ls_del_hdr-salesdocument.
      ENDLOOP.
    ELSE.
      "Individual header deletions
      LOOP AT lt_del_hdr INTO ls_del_hdr.
        DELETE FROM zcit_vicky_hdr WHERE salesdocument = @ls_del_hdr-salesdocument.
      ENDLOOP.
      "Individual item deletions
      LOOP AT lt_del_itm INTO DATA(ls_del_itm).
        DELETE FROM zcit_vicky_itm
          WHERE salesdocument   = @ls_del_itm-salesdocument
            AND salesitemnumber = @ls_del_itm-salesitemnumber.
      ENDLOOP.
    ENDIF.

    "4. Excel upload — delete ALL existing items for the doc, then insert new ones
    IF lv_excel_uploaded = abap_true.
      lo_util->get_excel_upload_items(
        IMPORTING ex_salesdocument = DATA(lv_excel_doc)
                  ex_items         = DATA(lt_excel_items) ).

      IF lv_excel_doc IS NOT INITIAL AND lt_excel_items IS NOT INITIAL.
        "Delete existing items for this sales document
        DELETE FROM zcit_vicky_itm WHERE salesdocument = @lv_excel_doc.

        "Insert all new items from Excel in one statement
        INSERT zcit_vicky_itm FROM TABLE @lt_excel_items.
      ENDIF.
    ENDIF.

  ENDMETHOD.

  METHOD cleanup.
    zcit_utility_class=>get_instance( )->cleanup_buffer( ).
  ENDMETHOD.

  METHOD cleanup_finalize. ENDMETHOD.

ENDCLASS.
