class ZCL_CDWRITE definition
  public
  final
  create public .

public section.

  class-methods INSERT_ROWS
    importing
      value(OBJECTID) type CDOBJECTV
      value(ROWS) type ZCDTAB1_T .
  class-methods UPDATE_ROWS
    importing
      value(OBJECTID) type CDOBJECTV
      value(ROWS) type ZCDTAB1_T .
  class-methods DELETE_ROWS
    importing
      value(OBJECTID) type CDOBJECTV
      value(ROWS) type ZCDTAB1_T .
  class-methods MODIFY_ROWS
    importing
      value(OBJECTID) type CDOBJECTV
      value(ROWS) type ZCDTAB1_T .
protected section.
private section.
ENDCLASS.



CLASS ZCL_CDWRITE IMPLEMENTATION.


  method delete_rows.

    data: lt_cdtxt type standard table of cdtxt,
          lt_db    type standard table of zcdtab1,
          lt_new   type standard table of yzcdtab1,
          lt_old   type standard table of yzcdtab1,
          ls_old   type yzcdtab1,
          ##NEEDED
          ls_db    type zcdtab1,
          ls_row   type zcdtab1.

*   nothing to delete
    if rows is initial. return. endif.

*   get current
    select * from zcdtab1 into table lt_db for all entries in rows where tabkey eq rows-tabkey.

*   perform db operation
    delete zcdtab1 from table rows.

*   prepare records to delete
    loop at rows into ls_row.
*     doesn't exist -> no deletion
      read table lt_db into ls_db with key tabkey = ls_row-tabkey.
      if sy-subrc ne 0. continue. endif.
      move-corresponding ls_row to ls_old. ls_old-kz = 'D'. append ls_old to lt_old.
    endloop.

*   write cd: exceptions to zero (at worst no cd written)
    call function 'ZCDTAB1_WRITE_DOCUMENT'
      exporting
        objectid                = objectid
        tcode                   = sy-tcode
        utime                   = sy-uzeit
        udate                   = sy-datum
        username                = sy-uname
        object_change_indicator = 'D'
        planned_or_real_changes = 'R'
        no_change_pointers      = 'X'
        upd_icdtxt_zcdtab1      = 'D'
        upd_zcdtab1             = 'D'
      tables
        icdtxt_zcdtab1          = lt_cdtxt
        xzcdtab1                = lt_new
        yzcdtab1                = lt_old
      exceptions
        error_message           = 0
        others                  = 0.

  endmethod.


  method insert_rows.

    data: lt_cdtxt type standard table of cdtxt,
          lt_new   type standard table of yzcdtab1,
          lt_old   type standard table of yzcdtab1,
          lt_db    type standard table of zcdtab1,
          ##NEEDED
          ls_db    type zcdtab1,
          ls_new   type yzcdtab1,
          ls_row   type zcdtab1.

*   nothing to insert
    if rows is initial. return. endif.

*   get db
    select * from zcdtab1 into table lt_db for all entries in rows where tabkey eq rows-tabkey.

*   perform db operation
    insert zcdtab1 from table rows.

*   prepare rows to insert
    loop at rows into ls_row.
*     found -> not insert
      read table lt_db into ls_db with key tabkey = ls_row-tabkey.
      if sy-subrc eq 0. continue. endif.
      move-corresponding ls_row to ls_new. ls_new-kz = 'I'. append ls_new to lt_new.
    endloop.

*   write cd: exceptions to zero (at worst no cd written)
    call function 'ZCDTAB1_WRITE_DOCUMENT'
      exporting
        objectid                = objectid
        tcode                   = sy-tcode
        utime                   = sy-uzeit
        udate                   = sy-datum
        username                = sy-uname
        object_change_indicator = 'I'
        planned_or_real_changes = 'R'
        no_change_pointers      = 'X'
        upd_icdtxt_zcdtab1      = 'I'
        upd_zcdtab1             = 'I'
      tables
        icdtxt_zcdtab1          = lt_cdtxt
        xzcdtab1                = lt_new
        yzcdtab1                = lt_old
      exceptions
        error_message           = 0
        others                  = 0.

  endmethod.


  method modify_rows.

    data: lt_cdtxt type standard table of cdtxt,
          lt_rows  type standard table of zcdtab1,
          lt_new   type standard table of yzcdtab1,
          lt_ins   type standard table of yzcdtab1,
          lt_old   type standard table of yzcdtab1,
          ls_old   type yzcdtab1,
          ls_ins   type yzcdtab1,
          ls_new   type yzcdtab1,
          ##NEEDED
          ls_roz   type zcdtab1,
          ls_row   type zcdtab1.

*   nothing to modify
    if rows is initial. return. endif.

*   get current entries
    select * from zcdtab1 into table lt_rows for all entries in rows where tabkey eq rows-tabkey.

*   perform db operation
    modify zcdtab1 from table rows.

*   prepare old
    loop at lt_rows into ls_row. move-corresponding ls_row to ls_old. ls_old-kz = 'U'. append ls_old to lt_old. endloop.

*   prepare new and to insert
    loop at rows into ls_row.
      read table lt_rows into ls_roz with key tabkey = ls_row-tabkey.
      if sy-subrc ne 0. move-corresponding ls_row to ls_ins. ls_ins-kz = 'I'. append ls_ins to lt_ins. continue. endif.
      move-corresponding ls_row to ls_new. ls_new-kz = 'U'. append ls_new to lt_new.
    endloop.

*   sort
    sort: lt_new by tabkey, lt_old by tabkey.

*   write cd: exceptions to zero (at worst no cd written)
    call function 'ZCDTAB1_WRITE_DOCUMENT'
      exporting
        objectid                = objectid
        tcode                   = sy-tcode
        utime                   = sy-uzeit
        udate                   = sy-datum
        username                = sy-uname
        object_change_indicator = 'U'
        planned_or_real_changes = 'R'
        no_change_pointers      = 'X'
        upd_icdtxt_zcdtab1      = 'U'
        upd_zcdtab1             = 'U'
      tables
        icdtxt_zcdtab1          = lt_cdtxt
        xzcdtab1                = lt_new
        yzcdtab1                = lt_old
      exceptions
        error_message           = 0
        others                  = 0.

    if lt_ins is initial. return. endif.

    refresh: lt_old.

    call function 'ZCDTAB1_WRITE_DOCUMENT'
      exporting
        objectid                = objectid
        tcode                   = sy-tcode
        utime                   = sy-uzeit
        udate                   = sy-datum
        username                = sy-uname
        object_change_indicator = 'I'
        planned_or_real_changes = 'R'
        no_change_pointers      = 'X'
        upd_icdtxt_zcdtab1      = 'I'
        upd_zcdtab1             = 'I'
      tables
        icdtxt_zcdtab1          = lt_cdtxt
        xzcdtab1                = lt_ins
        yzcdtab1                = lt_old
      exceptions
        error_message           = 0
        others                  = 0.

  endmethod.


  method update_rows.

    data: lt_cdtxt type standard table of cdtxt,
          lt_rows  type standard table of zcdtab1,
          lt_new   type standard table of yzcdtab1,
          lt_old   type standard table of yzcdtab1,
          ls_new   type yzcdtab1,
          ls_old   type yzcdtab1,
          ##NEEDED
          ls_roz   type zcdtab1,
          ls_row   type zcdtab1.

*   nothing to update
    if rows is initial. return. endif.

*   get current db entries
    select * from zcdtab1 into table lt_rows for all entries in rows where tabkey eq rows-tabkey.

*   perform db operation
    update zcdtab1 from table rows.

*   prepare old entries
    loop at lt_rows into ls_row.
*     doesn't exist -> no update
      read table rows into ls_roz with key tabkey = ls_row-tabkey.
      if sy-subrc ne 0. continue. endif.
      move-corresponding ls_row to ls_old. ls_old-kz = 'U'. append ls_old to lt_old.
    endloop.

*   prepare new and discard not existent
    loop at rows into ls_row.
*     doesn't exist -> no update
      read table lt_rows into ls_roz with key tabkey = ls_row-tabkey.
      if sy-subrc ne 0. continue. endif.
      move-corresponding ls_row to ls_new. ls_new-kz = 'U'. append ls_new to lt_new.
    endloop.

*   write cd: exceptions to zero (at worst no cd written)
    call function 'ZCDTAB1_WRITE_DOCUMENT'
      exporting
        objectid                = objectid
        tcode                   = sy-tcode
        utime                   = sy-uzeit
        udate                   = sy-datum
        username                = sy-uname
        object_change_indicator = 'U'
        planned_or_real_changes = 'R'
        no_change_pointers      = 'X'
        upd_icdtxt_zcdtab1      = 'U'
        upd_zcdtab1             = 'U'
      tables
        icdtxt_zcdtab1          = lt_cdtxt
        xzcdtab1                = lt_new
        yzcdtab1                = lt_old
      exceptions
        error_message           = 0
        others                  = 0.

  endmethod.
ENDCLASS.
