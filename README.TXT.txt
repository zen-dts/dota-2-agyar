Dota Agyarorszag projekt @Zen_Dota

A Prompt c. txt-ben lehet ötleteket összedobni, hogy mely herok hogyan nézzenek ki, kinek mi a kedvenc / signature hőse.
Bármi megvalósítható abilityket tekintve, de eleinte inkáb kis változásokban gondolkodjunk, hogy egy beta verzio minel elobb kesz legyen.

Fő fokusz: spellek, herok leírása tematikusan | képességek hanganyag hozzárendelése

Ha van kedved spelleket tweakelni, annak két módja van:

1. DataDriven (Game/scripts/npc/dota_custom_abilities)
Ide lehet importalni egy adott abilityt teljes egészében és a hozzátartozó számokat (cd, manacost, castpoint, dmg, modifierek stb.) megváltoztatni. Külön kérés: semmi ne legyen túl imba, hiszen nem ez a lényege a gamenek, s akkor borul az egész balance.
-- Egy heronak egy spellnél lehet 5 szintje jelenleg, ne legyen több, mert imba
-- Ha 20%-ot rádobunk egy adott hero spelljének sebzésére, akkor legyen feltolva vagy a cd vagy a manacost h balanszos maradjon

2. LUA language (Game/scripts/vscripts/[...])
Ha tudsz programozni, vagy van kedved tanulni nyugodtan írj:
Discord: ZenDTS#4904
GitHub: zen-dts
FB: daniel.t.stirling

A luafájlokban alapoktól kezdve fel lehet építeni egy adott spellt, vagy ha már valaki azt valaha elkészítette, azt érdemes importálni és az alapján eljárni. Ennek segítségével sok mindent meg lehet érteni, hogy hogyan kell gondolkozni egy spell felépítésénél. Erre segítségedre lehet a GitHub.com.
Programok amiket érdemes használni:
Code - Visual Code Editor
Github - Github Desktop Version
Hanganyag változtatás - Audacity
Modellezés - Dota 2 Tools Particle Editor

A DataDriven txt file-ok a fő kontrollerek, szóval, ha egy új spellt hozol létre lua-ban, a DD txt-ben azt le kell referálnod (alapkönyvtárnak veszi a vscriptet, így "ScriptFile"	"abilities/[map_name]/[spell_name]")

