IF NOT EXIST out MKDIR out
DEL /Q out
pawncc -(- -;- -p -d0 -O1 -v2 -oout/basdon.amx basdon.pwn
IF EXIST basdon.xml DEL basdon.xml
