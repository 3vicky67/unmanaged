CLASS zcit_utility_class DEFINITION
  PUBLIC
  FINAL
  CREATE PRIVATE.

  PUBLIC SECTION.

    TYPES: BEGIN OF ty_sales_hdr,
             salesdocument TYPE vbeln,
           END OF ty_sales_hdr.

    TYPES: BEGIN OF ty_sales_item,
             salesdocument   TYPE vbeln,
             salesitemnumber TYPE int2,
           END OF ty_sales_item.

    TYPES: tt_sales_hdr  TYPE STANDARD TABLE OF ty_sales_hdr,
           tt_sales_item TYPE STANDARD TABLE OF ty_sales_item,
           tt_vicky_hdr  TYPE STANDARD TABLE OF zcit_vicky_hdr,
           tt_vicky_itm  TYPE STANDARD TABLE OF zcit_vicky_itm.

    CLASS-METHODS get_instance
      RETURNING VALUE(ro_instance) TYPE REF TO zcit_utility_class.

    METHODS:
      "--- Header CRUD ---
      set_hdr_value
        IMPORTING im_sales_hdr TYPE zcit_vicky_hdr
        EXPORTING ex_created   TYPE abap_boolean,
      get_hdr_value
        EXPORTING ex_sales_hdr TYPE tt_vicky_hdr,

      "--- Item manual CRUD ---
      set_itm_value
        IMPORTING im_sales_itm TYPE zcit_vicky_itm
        EXPORTING ex_created   TYPE abap_boolean,
      get_itm_value
        EXPORTING ex_sales_itm TYPE tt_vicky_itm,

      "--- Header deletion ---
      set_hdr_t_deletion
        IMPORTING im_sales_doc TYPE ty_sales_hdr,
      get_hdr_t_deletion
        EXPORTING ex_sales_docs TYPE tt_sales_hdr,
      set_hdr_deletion_flag
        IMPORTING im_so_delete TYPE abap_boolean,
      get_deletion_flags
        EXPORTING ex_so_hdr_del TYPE abap_boolean,

      "--- Item deletion ---
      set_itm_t_deletion
        IMPORTING im_sales_itm_info TYPE ty_sales_item,
      get_itm_t_deletion
        EXPORTING ex_sales_info TYPE tt_sales_item,

      "--- Excel upload buffer (replaces all items for a sales doc) ---
      set_excel_upload_items
        IMPORTING im_salesdocument TYPE vbeln
                  im_items         TYPE tt_vicky_itm,
      get_excel_upload_items
        EXPORTING ex_salesdocument  TYPE vbeln
                  ex_items          TYPE tt_vicky_itm,
      get_excel_upload_flag
        EXPORTING ex_excel_uploaded TYPE abap_boolean,

      "--- Cleanup all buffers ---
      cleanup_buffer.

  PRIVATE SECTION.
    CLASS-DATA:
      gt_sales_hdr_buff   TYPE tt_vicky_hdr,
      gt_sales_itm_buff   TYPE tt_vicky_itm,
      gt_sales_hdr_t_buff TYPE tt_sales_hdr,
      gt_sales_itm_t_buff TYPE tt_sales_item,
      gv_so_delete        TYPE abap_boolean,
      gv_excel_salesdoc   TYPE vbeln,
      gt_excel_items_buff TYPE tt_vicky_itm,
      gv_excel_uploaded   TYPE abap_boolean,
      mo_instance         TYPE REF TO zcit_utility_class.

ENDCLASS.

CLASS zcit_utility_class IMPLEMENTATION.

  METHOD get_instance.
    IF mo_instance IS INITIAL.
      CREATE OBJECT mo_instance.
    ENDIF.
    ro_instance = mo_instance.
  ENDMETHOD.

  METHOD set_hdr_value.
    APPEND im_sales_hdr TO gt_sales_hdr_buff.
    ex_created = abap_true.
  ENDMETHOD.

  METHOD get_hdr_value.
    ex_sales_hdr = gt_sales_hdr_buff.
  ENDMETHOD.

  METHOD set_itm_value.
    IF im_sales_itm IS NOT INITIAL.
      APPEND im_sales_itm TO gt_sales_itm_buff.
      ex_created = abap_true.
    ENDIF.
  ENDMETHOD.

  METHOD get_itm_value.
    ex_sales_itm = gt_sales_itm_buff.
  ENDMETHOD.

  METHOD set_hdr_t_deletion.
    APPEND im_sales_doc TO gt_sales_hdr_t_buff.
  ENDMETHOD.

  METHOD get_hdr_t_deletion.
    ex_sales_docs = gt_sales_hdr_t_buff.
  ENDMETHOD.

  METHOD set_hdr_deletion_flag.
    gv_so_delete = im_so_delete.
  ENDMETHOD.

  METHOD get_deletion_flags.
    ex_so_hdr_del = gv_so_delete.
  ENDMETHOD.

  METHOD set_itm_t_deletion.
    APPEND im_sales_itm_info TO gt_sales_itm_t_buff.
  ENDMETHOD.

  METHOD get_itm_t_deletion.
    ex_sales_info = gt_sales_itm_t_buff.
  ENDMETHOD.

  METHOD set_excel_upload_items.
    gv_excel_salesdoc   = im_salesdocument.
    gt_excel_items_buff = im_items.
    gv_excel_uploaded   = abap_true.
  ENDMETHOD.

  METHOD get_excel_upload_items.
    ex_salesdocument = gv_excel_salesdoc.
    ex_items         = gt_excel_items_buff.
  ENDMETHOD.

  METHOD get_excel_upload_flag.
    ex_excel_uploaded = gv_excel_uploaded.
  ENDMETHOD.

  METHOD cleanup_buffer.
    CLEAR: gt_sales_hdr_buff,
           gt_sales_itm_buff,
           gt_sales_hdr_t_buff,
           gt_sales_itm_t_buff,
           gv_so_delete,
           gv_excel_salesdoc,
           gt_excel_items_buff,
           gv_excel_uploaded.
  ENDMETHOD.

ENDCLASS.

