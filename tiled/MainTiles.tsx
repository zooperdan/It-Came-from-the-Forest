<?xml version="1.0" encoding="UTF-8"?>
<tileset version="1.8" tiledversion="1.8.2" name="MainTiles" tilewidth="32" tileheight="32" tilecount="256" columns="16">
 <image source="MainTiles.png" width="512" height="512"/>
 <tile id="0" type="Wall">
  <properties>
   <property name="type" type="int" value="1"/>
  </properties>
 </tile>
 <tile id="1" type="Wall">
  <properties>
   <property name="type" type="int" value="2"/>
  </properties>
 </tile>
 <tile id="2" type="Player">
  <properties>
   <property name="direction" type="int" value="0"/>
  </properties>
 </tile>
 <tile id="3" type="Player">
  <properties>
   <property name="direction" type="int" value="1"/>
  </properties>
 </tile>
 <tile id="4" type="Player">
  <properties>
   <property name="direction" type="int" value="2"/>
  </properties>
 </tile>
 <tile id="5" type="Player">
  <properties>
   <property name="direction" type="int" value="3"/>
  </properties>
 </tile>
 <tile id="6" type="StaticProp">
  <properties>
   <property name="atlasid" value=""/>
   <property name="direction" type="int" value="2"/>
   <property name="id" value=""/>
   <property name="name" value=""/>
   <property name="state" type="int" value="1"/>
   <property name="text" value=""/>
   <property name="visible" type="int" value="1"/>
  </properties>
 </tile>
 <tile id="7" type="Enemy">
  <properties>
   <property name="antsacs" type="int" value="0"/>
   <property name="attack" type="int" value="5"/>
   <property name="defence" type="int" value="5"/>
   <property name="gold" type="int" value="0"/>
   <property name="health" type="int" value="25"/>
   <property name="health_max" type="int" value="25"/>
   <property name="id" value=""/>
   <property name="imageid" value="ant"/>
   <property name="loot" value=""/>
   <property name="name" value="Young fire ant"/>
   <property name="sound_attack" value="ant-attack"/>
   <property name="sound_die" value="ant-die"/>
   <property name="sound_move" value="ant-move"/>
   <property name="sound_scream" value="ant-scream"/>
   <property name="state" type="int" value="1"/>
   <property name="type" type="int" value="0"/>
   <property name="wanderer" type="int" value="0"/>
  </properties>
 </tile>
 <tile id="8" type="Enemy">
  <properties>
   <property name="attack" type="int" value="15"/>
   <property name="defence" type="int" value="15"/>
   <property name="experience" type="int" value="10"/>
   <property name="gold" type="int" value="0"/>
   <property name="health" type="int" value="100"/>
   <property name="health_max" type="int" value="100"/>
   <property name="id" value=""/>
   <property name="imageid" value="ant"/>
   <property name="loot" value=""/>
   <property name="name" value="Fire ant"/>
   <property name="sound_attack" value="ant-attack"/>
   <property name="sound_die" value="ant-die"/>
   <property name="sound_move" value="ant-move"/>
   <property name="sound_scream" value="ant-scream"/>
   <property name="state" type="int" value="1"/>
   <property name="type" type="int" value="1"/>
   <property name="wanderer" type="int" value="0"/>
  </properties>
 </tile>
 <tile id="9" type="Enemy">
  <properties>
   <property name="attack" type="int" value="40"/>
   <property name="defence" type="int" value="20"/>
   <property name="experience" type="int" value="10"/>
   <property name="gold" type="int" value="0"/>
   <property name="health" type="int" value="250"/>
   <property name="health_max" type="int" value="250"/>
   <property name="id" value=""/>
   <property name="imageid" value="ant"/>
   <property name="loot" value=""/>
   <property name="name" value="Fire ant soldier"/>
   <property name="sound_attack" value="ant-attack"/>
   <property name="sound_die" value="ant-die"/>
   <property name="sound_move" value="ant-move"/>
   <property name="sound_scream" value="ant-scream"/>
   <property name="state" type="int" value="1"/>
   <property name="type" type="int" value="2"/>
   <property name="wanderer" type="int" value="0"/>
  </properties>
 </tile>
 <tile id="10" type="Enemy">
  <properties>
   <property name="antsacs" type="int" value="0"/>
   <property name="attack" type="int" value="3"/>
   <property name="defence" type="int" value="1"/>
   <property name="gold" type="int" value="0"/>
   <property name="health" type="int" value="25"/>
   <property name="health_max" type="int" value="25"/>
   <property name="id" value=""/>
   <property name="imageid" value="rat"/>
   <property name="loot" value=""/>
   <property name="name" value="Rat"/>
   <property name="sound_attack" value="rat-attack"/>
   <property name="sound_die" value="rat-die"/>
   <property name="sound_move" value="rat-move"/>
   <property name="sound_scream" value="rat-scream"/>
   <property name="state" type="int" value="1"/>
   <property name="type" type="int" value="0"/>
   <property name="wanderer" type="int" value="0"/>
  </properties>
 </tile>
 <tile id="13" type="NPC">
  <properties>
   <property name="criterias" value=""/>
   <property name="gold" type="int" value="0"/>
   <property name="id" value=""/>
   <property name="imageid" value=""/>
   <property name="init_vars" value=""/>
   <property name="loot" value=""/>
   <property name="name" value=""/>
   <property name="questdelivertext" value=""/>
   <property name="questdonetext" value=""/>
   <property name="sound" value=""/>
   <property name="state" type="int" value="1"/>
   <property name="text" value=""/>
   <property name="vars" value=""/>
   <property name="visible" type="int" value="1"/>
  </properties>
 </tile>
 <tile id="14" type="Spinner">
  <properties>
   <property name="id" value=""/>
   <property name="state" type="int" value="1"/>
  </properties>
 </tile>
 <tile id="15" type="Trigger">
  <properties>
   <property name="id" value=""/>
   <property name="state" type="int" value="1"/>
   <property name="text" value=""/>
   <property name="vars" value=""/>
  </properties>
 </tile>
 <tile id="16" type="Chest">
  <properties>
   <property name="answer" value=""/>
   <property name="gold" type="int" value="0"/>
   <property name="id" value=""/>
   <property name="keyid" value=""/>
   <property name="loot" value=""/>
   <property name="riddle" value=""/>
   <property name="state" type="int" value="1"/>
  </properties>
 </tile>
 <tile id="17" type="Portal">
  <properties>
   <property name="direction" type="int" value="3"/>
   <property name="id" value=""/>
   <property name="state" type="int" value="1"/>
   <property name="targetdir" type="int" value="0"/>
   <property name="targetx" type="int" value="0"/>
   <property name="targety" type="int" value="0"/>
   <property name="visible" type="int" value="1"/>
  </properties>
 </tile>
 <tile id="18" type="Sign">
  <properties>
   <property name="id" value=""/>
   <property name="state" type="int" value="1"/>
   <property name="type" type="int" value="1"/>
  </properties>
 </tile>
 <tile id="19" type="Well">
  <properties>
   <property name="counter" type="int" value="0"/>
   <property name="counter_max" type="int" value="100"/>
   <property name="direction" type="int" value="3"/>
   <property name="id" value=""/>
   <property name="state" type="int" value="1"/>
   <property name="type" type="int" value="2"/>
  </properties>
 </tile>
 <tile id="20" type="Teleporter">
  <properties>
   <property name="id" value=""/>
   <property name="state" type="int" value="1"/>
   <property name="targetdir" type="int" value="0"/>
   <property name="targetx" type="int" value="0"/>
   <property name="targety" type="int" value="0"/>
  </properties>
 </tile>
 <tile id="21" type="Door">
  <properties>
   <property name="direction" type="int" value="3"/>
   <property name="id" value=""/>
   <property name="keyid" value=""/>
   <property name="state" type="int" value="1"/>
   <property name="targetarea" value=""/>
   <property name="targetdir" type="int" value="0"/>
   <property name="targetx" type="int" value="0"/>
   <property name="targety" type="int" value="0"/>
   <property name="type" type="int" value="2"/>
  </properties>
 </tile>
 <tile id="22" type="Button">
  <properties>
   <property name="id" value=""/>
   <property name="state" type="int" value="1"/>
   <property name="type" type="int" value="1"/>
   <property name="vars" value=""/>
  </properties>
 </tile>
 <tile id="23" type="LevelExit">
  <properties>
   <property name="direction" type="int" value="3"/>
   <property name="id" value=""/>
   <property name="state" type="int" value="1"/>
   <property name="targetarea" value=""/>
   <property name="targetdir" type="int" value="0"/>
   <property name="targetx" type="int" value="0"/>
   <property name="targety" type="int" value="0"/>
  </properties>
 </tile>
 <tile id="32" type="Wall">
  <properties>
   <property name="type" type="int" value="3"/>
  </properties>
 </tile>
 <tile id="33" type="EnemyBlocker">
  <properties>
   <property name="id" value=""/>
  </properties>
 </tile>
 <tile id="34" type="StaticProp">
  <properties>
   <property name="atlasid" value="city-props"/>
   <property name="direction" type="int" value="2"/>
   <property name="id" value=""/>
   <property name="name" value="city-garden"/>
   <property name="state" type="int" value="1"/>
   <property name="visible" type="int" value="1"/>
  </properties>
 </tile>
 <tile id="35" type="StaticProp">
  <properties>
   <property name="atlasid" value="common-props"/>
   <property name="direction" type="int" value="2"/>
   <property name="gold" type="int" value="0"/>
   <property name="id" value=""/>
   <property name="name" value="barrels"/>
   <property name="state" type="int" value="1"/>
   <property name="visible" type="int" value="1"/>
  </properties>
 </tile>
 <tile id="36" type="Door">
  <properties>
   <property name="direction" type="int" value="0"/>
   <property name="id" value=""/>
   <property name="keyid" value=""/>
   <property name="state" type="int" value="1"/>
   <property name="type" type="int" value="1"/>
   <property name="vendor" value=""/>
  </properties>
 </tile>
 <tile id="37" type="Door">
  <properties>
   <property name="direction" type="int" value="1"/>
   <property name="id" value=""/>
   <property name="keyid" value=""/>
   <property name="state" type="int" value="1"/>
   <property name="type" type="int" value="1"/>
   <property name="vendor" value=""/>
  </properties>
 </tile>
 <tile id="38" type="Door">
  <properties>
   <property name="direction" type="int" value="2"/>
   <property name="id" value=""/>
   <property name="keyid" value=""/>
   <property name="state" type="int" value="1"/>
   <property name="type" type="int" value="1"/>
   <property name="vendor" value=""/>
  </properties>
 </tile>
 <tile id="39" type="Door">
  <properties>
   <property name="direction" type="int" value="3"/>
   <property name="id" value=""/>
   <property name="keyid" value=""/>
   <property name="state" type="int" value="1"/>
   <property name="type" type="int" value="1"/>
   <property name="vendor" value=""/>
  </properties>
 </tile>
</tileset>
