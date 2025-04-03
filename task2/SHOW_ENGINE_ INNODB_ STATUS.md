------------------------
LATEST DETECTED DEADLOCK
------------------------
2025-04-03 10:47:06 139785079354944
*** (1) TRANSACTION:
TRANSACTION 1944, ACTIVE 45 sec starting index read
mysql tables in use 1, locked 1
LOCK WAIT 3 lock struct(s), heap size 1128, 2 row lock(s), undo log entries 1
MySQL thread id 64, OS thread handle 139785152718400, query id 810 localhost mysqluser updating
UPDATE table1 SET marks=marks-1 WHERE id=1

*** (1) HOLDS THE LOCK(S):
RECORD LOCKS space id 3 page no 4 n bits 72 index PRIMARY of table `wp_asd`.`table1` trx id 1944 lock_mode X locks rec but not gap
Record lock, heap no 3 PHYSICAL RECORD: n_fields 5; compact format; info bits 0
 0: len 4; hex 80000002; asc     ;;
 1: len 6; hex 000000000798; asc       ;;
 2: len 7; hex 010000012d0151; asc     - Q;;
 3: len 3; hex 78797a; asc xyz;;
 4: len 4; hex 80000004; asc     ;;


*** (1) WAITING FOR THIS LOCK TO BE GRANTED:
RECORD LOCKS space id 3 page no 4 n bits 72 index PRIMARY of table `wp_asd`.`table1` trx id 1944 lock_mode X locks rec but not gap waiting
Record lock, heap no 2 PHYSICAL RECORD: n_fields 5; compact format; info bits 0
 0: len 4; hex 80000001; asc     ;;
 1: len 6; hex 000000000797; asc       ;;
 2: len 7; hex 02000001240151; asc     $ Q;;
 3: len 3; hex 616263; asc abc;;
 4: len 4; hex 80000001; asc     ;;


*** (2) TRANSACTION:
TRANSACTION 1943, ACTIVE 97 sec starting index read
mysql tables in use 1, locked 1
LOCK WAIT 3 lock struct(s), heap size 1128, 2 row lock(s), undo log entries 1
MySQL thread id 44, OS thread handle 139785153775168, query id 815 localhost root updating
UPDATE table1 SET marks=marks+1 WHERE id=2

*** (2) HOLDS THE LOCK(S):
RECORD LOCKS space id 3 page no 4 n bits 72 index PRIMARY of table `wp_asd`.`table1` trx id 1943 lock_mode X locks rec but not gap
Record lock, heap no 2 PHYSICAL RECORD: n_fields 5; compact format; info bits 0
 0: len 4; hex 80000001; asc     ;;
 1: len 6; hex 000000000797; asc       ;;
 2: len 7; hex 02000001240151; asc     $ Q;;
 3: len 3; hex 616263; asc abc;;
 4: len 4; hex 80000001; asc     ;;


*** (2) WAITING FOR THIS LOCK TO BE GRANTED:
RECORD LOCKS space id 3 page no 4 n bits 72 index PRIMARY of table `wp_asd`.`table1` trx id 1943 lock_mode X locks rec but not gap waiting
Record lock, heap no 3 PHYSICAL RECORD: n_fields 5; compact format; info bits 0
 0: len 4; hex 80000002; asc     ;;
 1: len 6; hex 000000000798; asc       ;;
 2: len 7; hex 010000012d0151; asc     - Q;;
 3: len 3; hex 78797a; asc xyz;;
 4: len 4; hex 80000004; asc     ;;

*** WE ROLL BACK TRANSACTION (2)
