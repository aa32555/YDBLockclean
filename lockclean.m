;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;								;
; Copyright (c) 2018 YottaDB LLC. and/or its subsidiaries.	;
; All rights reserved.						;
;								;
;	This source code contains the intellectual property	;
;	of its copyright holder(s), and is made available	;
;	under a license.  If you do not know the terms of	;
;	the license, please stop and do not read further.	;
;								;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
lockclean
	; Utility program to clean abandoned locks. those which LKE
	; reports as: PID= <pid> which is a nonexistent process.
	; $text(+0) tries a zero timeout lock acquisition which
	; cleans the abandoned lock slot.
	; Usage: mumps -run $text(+0) or do ^$text(+0)
	; There are no options or parameters.

	new i,j,io,line,lkeout
	set io=$io
	open "lke":(shell="/bin/sh":command="$ydb_dist/lke show -nocrit -all -wait":readonly)::"pipe"
	use "lke"
	; read lke output & merge lines if pid is on a separate line from lock name
	for  read line quit:$zeof  do
	. if 2=$zfind(line," ") set lkeout(i)=lkeout(i)_" Owned"_$zpiece(line,"Owned",2)
	. else  set lkeout($increment(i))=line
	use io close "lke"
	; use pattern match since "which is a nonexistent process" can be a subscript
	for j=1:1:i do:lkeout(j)?.E1"which is a nonexistent process"
	. lock +@$zpiece(lkeout(j)," Owned by",1):0 lock
	quit
