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
   <property name="visible" type="int" value="1"/>
  </properties>
 </tile>
 <tile id="7" type="Enemy">
  <properties>
   <property name="attack" type="int" value="1"/>
   <property name="defence" type="int" value="1"/>
   <property name="experience" type="int" value="10"/>
   <property name="gold" type="int" value="5"/>
   <property name="health" type="int" value="100"/>
   <property name="health_max" type="int" value="100"/>
   <property name="id" value=""/>
   <property name="loot" value=""/>
   <property name="name" value="Fire ant"/>
   <property name="sound_attack" value="ant-attack"/>
   <property name="sound_die" value="ant-die"/>
   <property name="sound_move" value="ant-move"/>
   <property name="state" type="int" value="1"/>
   <property name="type" type="int" value="0"/>
   <property name="wanderer" type="int" value="0"/>
  </properties>
 </tile>
 <tile id="8" type="Enemy">
  <properties>
   <property name="attack" type="int" value="1"/>
   <property name="defence" type="int" value="1"/>
   <property name="experience" type="int" value="10"/>
   <property name="gold" type="int" value="5"/>
   <property name="health" type="int" value="100"/>
   <property name="health_max" type="int" value="100"/>
   <property name="id" value=""/>
   <property name="loot" value=""/>
   <property name="name" value="Fire ant"/>
   <property name="sound_attack" value="ant-attack"/>
   <property name="sound_die" value="ant-die"/>
   <property name="sound_move" value="ant-move"/>
   <property name="state" type="int" value="1"/>
   <property name="type" type="int" value="1"/>
   <property name="wanderer" type="int" value="0"/>
  </properties>
 </tile>
 <tile id="9" type="Enemy">
  <properties>
   <property name="attack" type="int" value="1"/>
   <property name="defence" type="int" value="1"/>
   <property name="experience" type="int" value="10"/>
   <property name="gold" type="int" value="5"/>
   <property name="health" type="int" value="100"/>
   <property name="health_max" type="int" value="100"/>
   <property name="id" value=""/>
   <property name="loot" value=""/>
   <property name="name" value="Fire ant"/>
   <property name="sound_attack" value="ant-attack"/>
   <property name="sound_die" value="ant-die"/>
   <property name="sound_move" value="ant-move"/>
   <property name="state" type="int" value="1"/>
   <property name="type" type="int" value="2"/>
   <property name="wanderer" type="int" value="0"/>
  </properties>
 </tile>
 <tile id="13" type="NPC">
  <properties>
   <property name="criterias" value=""/>
   <property name="experience" type="int" value="0"/>
   <property name="gold" type="int" value="0"/>
   <property name="id" value=""/>
   <property name="imageid" value=""/>
   <property name="loot" value=""/>
   <property name="name" value=""/>
   <property name="questdelivertext" value=""/>
   <property name="questdonetext" value=""/>
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
   <property name="id" value=""/>
   <property name="keyid" value=""/>
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
   <property name="direction" type="int" value="3"/>
   <property name="id" value=""/>
   <property name="state" type="int" value="1"/>
   <property name="type" type="int" value="2"/>
  </properties>
 </tile>
 <tile id="20" type="Door">
  <properties>
   <property name="direction" type="int" value="3"/>
   <property name="id" value=""/>
   <property name="keyid" value=""/>
   <property name="state" type="int" value="1"/>
   <property name="type" type="int" value="1"/>
  </properties>
 </tile>
 <tile id="21" type="Door">
  <properties>
   <property name="direction" type="int" value="3"/>
   <property name="id" value=""/>
   <property name="state" type="int" value="1"/>
   <property name="targetarea" value=""/>
   <property name="targetdir" type="int" value="0"/>
   <property name="targetx" type="int" value="0"/>
   <property name="targety" type="int" value="0"/>
   <property name="type" type="int" value="2"/>
  </properties>
 </tile>
 <tile id="23" type="Sign"/>
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
</tileset>
