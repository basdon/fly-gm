
/* vim: set filetype=c ts=8 noexpandtab: */

/* global */
#define MAX_PLAYERS (50)
#ifdef MAX_PLAYER_NAME
#assert MAX_PLAYER_NAME == 24
#else
#define MAX_PLAYER_NAME (24)
#endif
#ifdef INVALID_PLAYER_ID
#assert INVALID_PLAYER_ID == 0xFFFF
#else
#define INVALID_PLAYER_ID (0xFFFF)
#endif
#ifdef MAX_VEHICLES
#assert MAX_VEHICLES == 2000
#else
#define MAX_VEHICLES (2000)
#endif

#define ECOL_INFO "{3498db}"
#define ECOL_WARN "{e84c3d}"
#define ECOL_SUCC "{2cc36b}"
#define ECOL_DIALOG_CAPTION "{d2d2d2}"
#define ECOL_DIALOG_TEXT "{a9c4e4}"
#define ECOL_DIALOG_BUTTON "{c8c8c8}"
#define ECOL_MISSION "{ff9900}"

#define WARN "! "
#define INFO "* "
#define SUCC "+ "

/* airport.c / airport.pwn */
#define MAX_AIRPORT_NAME (24)
/* dialog.c / dialog.pwn */
#define LIMIT_DIALOG_CAPTION (64)
#define LIMIT_DIALOG_TEXT (4096)
/* button len limit is not defined */
#define LIMIT_DIALOG_BUTTON (32)

/* login.c / login.pwn */
#define PW_HASH_LENGTH (65) /* including zero term */
#define MONEY_DEFAULTAMOUNT 15000

/* game_sa.c / game_sa.pwn, global */
#define MODEL_LANDSTAL (400)
#define MODEL_BRAVURA (401)
#define MODEL_BUFFALO (402)
#define MODEL_LINERUN (403)
#define MODEL_PEREN (404)
#define MODEL_SENTINEL (405)
#define MODEL_DUMPER (406)
#define MODEL_FIRETRUK (407)
#define MODEL_TRASH (408)
#define MODEL_STRETCH (409)
#define MODEL_MANANA (410)
#define MODEL_INFERNUS (411)
#define MODEL_VOODOO (412)
#define MODEL_PONY (413)
#define MODEL_MULE (414)
#define MODEL_CHEETAH (415)
#define MODEL_AMBULAN (416)
#define MODEL_LEVIATHN (417)
#define MODEL_MOONBEAM (418)
#define MODEL_ESPERANT (419)
#define MODEL_TAXI (420)
#define MODEL_WASHING (421)
#define MODEL_BOBCAT (422)
#define MODEL_MRWHOOP (423)
#define MODEL_BFINJECT (424)
#define MODEL_HUNTER (425)
#define MODEL_PREMIER (426)
#define MODEL_ENFORCER (427)
#define MODEL_SECURICA (428)
#define MODEL_BANSHEE (429)
#define MODEL_PREDATOR (430)
#define MODEL_BUS (431)
#define MODEL_RHINO (432)
#define MODEL_BARRACKS (433)
#define MODEL_HOTKNIFE (434)
#define MODEL_ARTICT1 (435)
#define MODEL_PREVION (436)
#define MODEL_COACH (437)
#define MODEL_CABBIE (438)
#define MODEL_STALLION (439)
#define MODEL_RUMPO (440)
#define MODEL_RCBANDIT (441)
#define MODEL_ROMERO (442)
#define MODEL_PACKER (443)
#define MODEL_MONSTER (444)
#define MODEL_ADMIRAL (445)
#define MODEL_SQUALO (446)
#define MODEL_SEASPAR (447)
#define MODEL_PIZZABOY (448)
#define MODEL_TRAM (449)
#define MODEL_ARTICT2 (450)
#define MODEL_TURISMO (451)
#define MODEL_SPEEDER (452)
#define MODEL_REEFER (453)
#define MODEL_TROPIC (454)
#define MODEL_FLATBED (455)
#define MODEL_YANKEE (456)
#define MODEL_CADDY (457)
#define MODEL_SOLAIR (458)
#define MODEL_TOPFUN (459)
#define MODEL_SKIMMER (460)
#define MODEL_PCJ600 (461)
#define MODEL_FAGGIO (462)
#define MODEL_FREEWAY (463)
#define MODEL_RCBARON (464)
#define MODEL_RCRAIDER (465)
#define MODEL_GLENDALE (466)
#define MODEL_OCEANIC (467)
#define MODEL_SANCHEZ (468)
#define MODEL_SPARROW (469)
#define MODEL_PATRIOT (470)
#define MODEL_QUAD (471)
#define MODEL_COASTG (472)
#define MODEL_DINGHY (473)
#define MODEL_HERMES (474)
#define MODEL_SABRE (475)
#define MODEL_RUSTLER (476)
#define MODEL_ZR350 (477)
#define MODEL_WALTON (478)
#define MODEL_REGINA (479)
#define MODEL_COMET (480)
#define MODEL_BMX (481)
#define MODEL_BURRITO (482)
#define MODEL_CAMPER (483)
#define MODEL_MARQUIS (484)
#define MODEL_BAGGAGE (485)
#define MODEL_DOZER (486)
#define MODEL_MAVERICK (487)
#define MODEL_VCNMAV (488)
#define MODEL_RANCHER (489)
#define MODEL_FBIRANCH (490)
#define MODEL_VIRGO (491)
#define MODEL_GREENWOO (492)
#define MODEL_JETMAX (493)
#define MODEL_HOTRING (494)
#define MODEL_SANDKING (495)
#define MODEL_BLISTAC (496)
#define MODEL_POLMAV (497)
#define MODEL_BOXVILLE (498)
#define MODEL_BENSON (499)
#define MODEL_MESA (500)
#define MODEL_RCGOBLIN (501)
#define MODEL_HOTRINA (502)
#define MODEL_HOTRINB (503)
#define MODEL_BLOODRA (504)
#define MODEL_RNCHLURE (505)
#define MODEL_SUPERGT (506)
#define MODEL_ELEGANT (507)
#define MODEL_JOURNEY (508)
#define MODEL_BIKE (509)
#define MODEL_MTBIKE (510)
#define MODEL_BEAGLE (511)
#define MODEL_CROPDUST (512)
#define MODEL_STUNT (513)
#define MODEL_PETRO (514)
#define MODEL_RDTRAIN (515)
#define MODEL_NEBULA (516)
#define MODEL_MAJESTIC (517)
#define MODEL_BUCCANEE (518)
#define MODEL_SHAMAL (519)
#define MODEL_HYDRA (520)
#define MODEL_FCR900 (521)
#define MODEL_NRG500 (522)
#define MODEL_COPBIKE (523)
#define MODEL_CEMENT (524)
#define MODEL_TOWTRUCK (525)
#define MODEL_FORTUNE (526)
#define MODEL_CADRONA (527)
#define MODEL_FBITRUCK (528)
#define MODEL_WILLARD (529)
#define MODEL_FORKLIFT (530)
#define MODEL_TRACTOR (531)
#define MODEL_COMBINE (532)
#define MODEL_FELTZER (533)
#define MODEL_REMINGTN (534)
#define MODEL_SLAMVAN (535)
#define MODEL_BLADE (536)
#define MODEL_FREIGHT (537)
#define MODEL_STREAK (538)
#define MODEL_VORTEX (539)
#define MODEL_VINCENT (540)
#define MODEL_BULLET (541)
#define MODEL_CLOVER (542)
#define MODEL_SADLER (543)
#define MODEL_FIRELA (544)
#define MODEL_HUSTLER (545)
#define MODEL_INTRUDER (546)
#define MODEL_PRIMO (547)
#define MODEL_CARGOBOB (548)
#define MODEL_TAMPA (549)
#define MODEL_SUNRISE (550)
#define MODEL_MERIT (551)
#define MODEL_UTILITY (552)
#define MODEL_NEVADA (553)
#define MODEL_YOSEMITE (554)
#define MODEL_WINDSOR (555)
#define MODEL_MONSTERA (556)
#define MODEL_MONSTERB (557)
#define MODEL_URANUS (558)
#define MODEL_JESTER (559)
#define MODEL_SULTAN (560)
#define MODEL_STRATUM (561)
#define MODEL_ELEGY (562)
#define MODEL_RAINDANC (563)
#define MODEL_RCTIGER (564)
#define MODEL_FLASH (565)
#define MODEL_TAHOMA (566)
#define MODEL_SAVANNA (567)
#define MODEL_BANDITO (568)
#define MODEL_FREIFLAT (569)
#define MODEL_STREAKC (570)
#define MODEL_KART (571)
#define MODEL_MOWER (572)
#define MODEL_DUNERIDE (573)
#define MODEL_SWEEPER (574)
#define MODEL_BROADWAY (575)
#define MODEL_TORNADO (576)
#define MODEL_AT400 (577)
#define MODEL_DFT30 (578)
#define MODEL_HUNTLEY (579)
#define MODEL_STAFFORD (580)
#define MODEL_BF400 (581)
#define MODEL_NEWSVAN (582)
#define MODEL_TUG (583)
#define MODEL_PETROTR (584)
#define MODEL_EMPEROR (585)
#define MODEL_WAYFARER (586)
#define MODEL_EUROS (587)
#define MODEL_HOTDOG (588)
#define MODEL_CLUB (589)
#define MODEL_FREIBOX (590)
#define MODEL_ARTICT3 (591)
#define MODEL_ANDROM (592)
#define MODEL_DODO (593)
#define MODEL_RCCAM (594)
#define MODEL_LAUNCH (595)
#define MODEL_COPCARLA (596)
#define MODEL_COPCARSF (597)
#define MODEL_COPCARVG (598)
#define MODEL_COPCARRU (599)
#define MODEL_PICADOR (600)
#define MODEL_SWATVAN (601)
#define MODEL_ALPHA (602)
#define MODEL_PHOENIX (603)
#define MODEL_GLENSHIT (604)
#define MODEL_SADLSHIT (605)
#define MODEL_BAGBOXA (606)
#define MODEL_BAGBOXB (607)
#define MODEL_TUGSTAIR (608)
#define MODEL_BOXBURG (609)
#define MODEL_FARMTR1 (610)
#define MODEL_UTILTR1 (611)

#define MODEL_TOTAL (611-400)

/* panel.pwn zones.c ... */
#define VEL_VER 2 /* change this when anything changes */
/* VEL_MAX = 0.66742320819112627986348122866894 */
#define VEL_TO_KPH_VAL (180.20426) /* VEL_MAX * 270 */
#define VEL_TO_KTS_VAL (96.77661) /* VEL_MAX * 145 */
#define VEL_TO_MPS_VAL (50.05674) /* (KPH / 3.6) */
#define VEL_TO_KFPM_VAL (9.8536894) /* K feet per minute (MPS * 3.28084 * 60 / 1000) */
#define VEL_TO_KFPMA_VAL (5.630679) /* some adjustment (KFPM / 1.75) */

/* missions.c / missions.pwn */

#define PASSENGER_MISSIONTYPES (1 | 2 | 4 | 8192)

#define MISSION_STAGE_CREATE	1
#define MISSION_STAGE_PRELOAD	2
#define MISSION_STAGE_LOAD	4
#define MISSION_STAGE_FLIGHT	8
#define MISSION_STAGE_UNLOAD	16

#define MISSION_STATE_INPROGRESS 1
#define MISSION_STATE_ABANDONED  2
#define MISSION_STATE_CRASHED    4
#define MISSION_STATE_FINISHED   8
#define MISSION_STATE_DECLINED   16
#define MISSION_STATE_DIED       32

#define MISSION_ENTERCHECKPOINTRES_LOAD 1
#define MISSION_ENTERCHECKPOINTRES_UNLOAD 2
#define MISSION_ENTERCHECKPOINTRES_ERR 3

#define MISSION_CANCEL_FINE (5000)

#define MISSION_WEATHERBONUS_RAINY (1250)
#define MISSION_WEATHERBONUS_FOGGY (2250)
#define MISSION_WEATHERBONUS_SANDSTORM (3250)

#define MISSION_WEATHERBONUS_DEVIATION (500)

/* nav.c ... */
#define NAV_NONE 0
#define NAV_ADF 1
#define NAV_VOR 2
#define NAV_ILS 4

#define RESULT_ADF_OFF 0
#define RESULT_ADF_ON 1
#define RESULT_ADF_ERR 2

#define RESULT_VOR_OFF 0
#define RESULT_VOR_ON 1
#define RESULT_VOR_ERR 2

#define RESULT_ILS_OFF 0
#define RESULT_ILS_ON 1
#define RESULT_ILS_NOVOR 2
#define RESULT_ILS_NOILS 3

/* prefs.c / prefs.pwn */
#define PREF_ENABLE_PM 1
#define PREF_SHOW_MISSION_MSGS 2
#define PREF_CONSTANT_WORK 4

#define DEFAULTPREFS (PREF_ENABLE_PM | PREF_SHOW_MISSION_MSGS)

/* timecyc.c / timecyc.pwn */
#define NEXT_WEATHER_POSSIBILITIES (35)

#define WEATHER_LA_EXTRASUNNY 0
#define WEATHER_LA_SUNNY 1
#define WEATHER_LA_EXTRASUNNYSMOG 2
#define WEATHER_LA_SUNNYSMOG 3
#define WEATHER_LA_CLOUDY 4
#define WEATHER_SF_SUNNY 5
#define WEATHER_SF_EXTRASUNNY 6
#define WEATHER_SF_CLOUDY 7
#define WEATHER_SF_RAINY 8
#define WEATHER_SF_FOGGY 9
#define WEATHER_LV_SUNNY 10
#define WEATHER_LV_EXTRASUNNY 11
#define WEATHER_LV_CLOUDY 12
#define WEATHER_CS_EXTRASUNNY 13
#define WEATHER_CS_SUNNY 14
#define WEATHER_CS_CLOUDY 15
#define WEATHER_CS_RAINY 16
#define WEATHER_DE_EXTRASUNNY 17
#define WEATHER_DE_SUNNY 18
#define WEATHER_DE_SANDSTORMS 19
#define WEATHER_UNDERWATER 20
#define WEATHERS 21

#define WEATHER_INVALID 255
