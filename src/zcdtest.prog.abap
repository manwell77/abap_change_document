*&---------------------------------------------------------------------*
*& Report ZCDTEST
*&---------------------------------------------------------------------*
*&
*&---------------------------------------------------------------------*
report zcdtest.

parameters: p_oid type cdobjectv obligatory.

parameters: p_ins type xfeld radiobutton group gr1 user-command com,
            p_del type xfeld radiobutton group gr1,
            p_upd type xfeld radiobutton group gr1,
            p_mod type xfeld radiobutton group gr1.

start-of-selection.

  ##NEEDED
  data: lt_tab1 type standard table of zcdtab1,
        ls_tab1 type zcdtab1.

* insert a new record with tabkey + 1 and NEWONE, NEWTWO as field1 and field2
  if p_ins eq abap_true.
    select * from zcdtab1 into table lt_tab1 order by tabkey descending.
    read table lt_tab1 into ls_tab1 index 1.
    refresh lt_tab1. ls_tab1-mandt = sy-mandt. ls_tab1-tabkey = ls_tab1-tabkey + 1. ls_tab1-field1 = 'NEWONE'. ls_tab1-field2 = 'NEWTWO'. append ls_tab1 to lt_tab1.
    zcl_cdwrite=>insert_rows( objectid = p_oid rows = lt_tab1 ).
    write: / |@08@ { text-002 } { ls_tab1-tabkey }|.
  endif.

* delete the first record found
  if p_del eq abap_true.
    select * from zcdtab1 into table lt_tab1 order by tabkey ascending.
    if sy-subrc ne 0. write: / |@0A@ { text-001 }|. endif.
    read table lt_tab1 into ls_tab1 index 1. refresh lt_tab1. append ls_tab1 to lt_tab1.
    zcl_cdwrite=>delete_rows( objectid = p_oid rows = lt_tab1 ).
    write: / |@08@ { text-003 } { ls_tab1-tabkey }|.
  endif.

* update the last record
  if p_upd eq abap_true.
    select * from zcdtab1 into table lt_tab1 order by tabkey descending.
    if sy-subrc ne 0. write: / |@0A@ { text-004 }|. endif.
    read table lt_tab1 into ls_tab1 index 1.
    if ls_tab1-field1 ne 'ONEUPD'. ls_tab1-field1 = 'ONEUPD'. else. ls_tab1-field1 = 'UPDONE'. endif.
    if ls_tab1-field2 ne 'TWOUPD'. ls_tab1-field2 = 'TWOUPD'. else. ls_tab1-field2 = 'UPDTWO'. endif.
    refresh lt_tab1. append ls_tab1 to lt_tab1.
    zcl_cdwrite=>update_rows( objectid = p_oid rows = lt_tab1 ).
    write: / |@08@ { text-005 } { ls_tab1-tabkey }|.
  endif.

* modify the last record and insert a new one
  if p_mod eq abap_true.
    select * from zcdtab1 into table lt_tab1 order by tabkey descending.
    if sy-subrc ne 0. write: / |@0A@ { text-006 }|. endif.
    read table lt_tab1 into ls_tab1 index 1.
    if ls_tab1-field1 ne 'ONEUPD'. ls_tab1-field1 = 'ONEUPD'. else. ls_tab1-field1 = 'UPDONE'. endif.
    if ls_tab1-field2 ne 'TWOUPD'. ls_tab1-field2 = 'TWOUPD'. else. ls_tab1-field2 = 'UPDTWO'. endif.
    refresh lt_tab1. append ls_tab1 to lt_tab1.
    ls_tab1-mandt = sy-mandt. ls_tab1-tabkey = ls_tab1-tabkey + 1. ls_tab1-field1 = 'NEWONE'. ls_tab1-field2 = 'NEWTWO'. append ls_tab1 to lt_tab1.
    zcl_cdwrite=>modify_rows( objectid = p_oid rows = lt_tab1 ).
    write: / |@08@ { text-002 } { ls_tab1-tabkey }|.
    ls_tab1-tabkey = ls_tab1-tabkey - 1.
    write: / |@08@ { text-005 } { ls_tab1-tabkey }|.
  endif.
