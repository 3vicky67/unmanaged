CLASS zcit_clear_db DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zcit_clear_db IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.
    " 1. Wipe the Active Tables
    DELETE FROM zcit_vicky_hdr.
    DELETE FROM zcit_vicky_itm.

    " 2. Wipe the Draft Tables (This is where the corrupted data is hiding!)
    DELETE FROM zcit_vicky_hdr_d.
    DELETE FROM zcit_vicky_itm_d.

    COMMIT WORK.

    out->write( 'Database wiped successfully! Active and Draft tables are completely empty.' ).
  ENDMETHOD.
ENDCLASS.
