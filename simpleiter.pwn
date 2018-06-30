
// vim: set filetype=c ts=8 noexpandtab:

// simple, fast, memory-eating iter

#define Iter:%1[%2] %1[%2],%1@h[%2],%1@c=0,%1@t;const %1@m=%2

#define iter_add(%1,%2) if(!(%1@h[%2]))%1[%1@c++]=%2,%1@h[%2]=%1@c
#define iter_add_us(%1,%2) %1@t=%2;iter_add(%1,%1@t)
#define iter_remove(%1,%2); if(%1@h[%2]){if(%1@h[%2]!=%1@c--){%1[%1@h[%2]-1]=%1[%1@c];%1@h[%1[%1@c]]=%1@h[%2];}%1@h[%2]=0;}
#define iter_remove_us(%1,%2); %1@t=%2;iter_remove(%1,%1@t)
#define iter_has(%1,%2) (%1@h[%2])
#define iter_clear(%1) for(new t@%1=0;t@%1<%1@c;t@%1++){%1@h[%1[t@%1]]=0;}%1@c=0
#define iter_count(%1) (%1@c)
#define iter_random(%1) (%1[random(%1@c)])
//#define for%0\32(new%0\32%1:%2) for(new m@%1=%2@c,%1;(m@%1>0)|(m@%1>0&&(%1=%2[m@%1-1]));m@%1--)
//#define for%0\32(new%0\32%1:%2) for(new %1=%2@c-1;%1>=0;%1--)
#define for%0\32(new%0\32%1:%2) for(new %1=0;%1<%2@c;%1++)
#define iter_access(%1,%2) (%1[%2])

