var action = tiled.registerAction("LOL_Validate", function(action) {
	validateMap();
})

action.text = "Validate LOL Map";
action.checkable = true;
action.shortcut = "Ctrl+K";

var action = tiled.registerAction("LOL_GeneratedIDs", function(action) {
	generateIDS();
})

action.text = "Generate unique ID's";
action.checkable = true;
action.shortcut = "Ctrl+J";

tiled.extendMenu("Map", [
    { action: "LOL_Validate", before: "AutoMap" },
    { separator: true }
]);

tiled.extendMenu("Map", [
    { action: "LOL_GeneratedIDs", before: "AutoMap" },
    { separator: true }
]);

// ===========================================================================================

let guid = () => {
    let s4 = () => {
        return Math.floor((1 + Math.random()) * 0x10000)
            .toString(16)
            .substring(1);
    }
    //return id of format 'aaaaaaaa'-'aaaa'-'aaaa'-'aaaa'-'aaaaaaaaaaaa'
    return s4() + s4() + '-' + s4() + '-' + s4() + '-' + s4() + '-' + s4() + s4() + s4();
}

function replacer(key, value) {
  if(value instanceof Map) {
    return {
      dataType: 'Map',
      value: Array.from(value.entries()), // or with spread: value: [...value]
    };
  } else {
    return value;
  }
}

function isNumeric(n) {
	if (n == 0) { return true; }
	return !isNaN(parseFloat(n)) && isFinite(n);
}

function getMapSize(x) {
    var len = 0;
    for (var count in x) {
            len++;
    }

    return len;
}


function getPlayer(map) {
	
	var buffer = '';
	
	for (var j = 0; j < map.layerCount; ++j) {

		var layer = map.layerAt(j);
	
		if (layer.isObjectLayer) {
			
			for (var i = 0; i < layer.objectCount; ++i) {
				
				var props = layer.objects[i].resolvedProperties();
				
				if (layer.objects[i].tile.type == "Player") {
					buffer += `["partyX"]=${(layer.objects[i].x/32)+1},\n`;
					buffer += `["partyY"]=${(layer.objects[i].y/32)},\n`;
					buffer += `["partyDirection"]=${layer.objects[i].resolvedProperty("direction")},\n`;
				}
				
			}		

		}
		
	}
	
	return buffer;
	
}

function getByType(id, name, map) {
		
		// first iterate through objects and store temporarily in a hashmap
		
		var data = new Array();
		
        for (var j = 0; j < map.layerCount; ++j) {
            
			var layer = map.layerAt(j);
		
			if (layer.isObjectLayer) {
		
				for (var i = 0; i < layer.objectCount; ++i) {

					var props = layer.objects[i].resolvedProperties();
					
					if (layer.objects[i].tile.type == id) {

						var x = (layer.objects[i].x/32)+1;
						var y = layer.objects[i].y/32;
						
						var obj = new Object();
						obj.x = x;
						obj.y = y;
						obj.properties = new Map()
						
						for (const key in props) {

							var value = props[key];
							
							if (!isNumeric(value)) {
								if (value && !isNumeric(value) && value.substring(0,1) == "#") {
								} else {
									value = '"' + value + '"';
								}
							} else {
								if (parseInt(value) == 0) {

								} else {
									value = value ? value : '""';
								}
							}
							
							obj.properties.set(key, value);
							
						}
					
						data.push(obj);
					
					}
					
				}		

			}

		}
			

		// no objects found
		if (data.length == 0) {
			return `${name}={},\n`;
		}
			
		// iterate through build a buffer string
		
		var buffer = `${name}=\{\n`;
		
		for(var j=0;j<data.length;j++) {
		

			buffer += `\t[${(j+1)}] = {\n`;
			
			buffer += `\t\tx=${data[j].x},\n`;
			buffer += `\t\ty=${data[j].y},\n`;
			
			buffer += `\t\tproperties={\n`;
			
			for (let [key, value] of data[j].properties) {
				
				if (value && !isNumeric(value) && value.substring(0,1) == "#") {
					// array value
					buffer += `\t\t\t${key}={\n`;

					value = value.substring(1);
					const segments = value.split(",");
					for (var i = 0; i <segments.length; ++i) {
						var t = isNumeric(segments[i]) ? segments[i] : '"' + segments[i] + '"';
						buffer += `\t\t\t\t[${(i+1)}]=${t},\n`;
					}
					buffer += `\t\t\t},\n`;
					
				} else {
					buffer += `\t\t\t${key}=${value},\n`;
				}
						
			}
			
			buffer += '\t\t}\n';
			buffer += '\t},\n';
			
		}

		buffer += '},\n';

		return buffer + "\n";
		
}

function generateIDS() {

	if (!tiled.activeAsset.isTileMap) {
		tiled.alert("Active Asset is not a TileMap", "Error");
		return false;
	}
	
	const map = tiled.activeAsset;
	
	var num = 0;
	
	for (var i = 0; i < map.layerCount; ++i) {
		
		var layer = map.layerAt(i);

		if (layer.isObjectLayer) {

			for (var j = 0; j < layer.objectCount; ++j) {
				
				var prop = layer.objects[j].resolvedProperty("id");
				
				if (layer.objects[j].tile.type != "Player") {
					tiled.log(prop.value);
					if (prop == "") {
						layer.objects[j].setProperty("id", map.property("id") + "_" + guid());
						num++;
					}
				}
			}	

		}
		
	}
	
	if (num > 0) {
		tiled.alert(`Generated ${num} ids.` , "Notificaton");	
	}
		
}

function validateMap() {
	
	if (!tiled.activeAsset.isTileMap) {
		tiled.alert("Active Asset is not a TileMap", "Error");
		return false;
	}
	
	const map = tiled.activeAsset;
	
	var result = "";
	
	for (var i = 0; i < map.layerCount; ++i) {
		
		var layer = map.layerAt(i);

		if (layer.isObjectLayer) {

			for (var j = 0; j < layer.objectCount; ++j) {
				
				var prop = layer.objects[j].resolvedProperty("id");
				
				if (!prop || prop.value == "") {
					if (layer.objects[j].tile.type != "Player") {
						const x = (layer.objects[j].x/32)+1;
						const y = layer.objects[j].y/32;
						result += `${layer.objects[j].tile.type} (${x}/${y})\n`;
						layer.objects[j].selected = true;
					}
				}
				
			}	

		}
		
	}
	

	if (result != "") {
		tiled.alert(result, "Missing ID's:");
		return false;
	}
	
	return true;
	
}

var customMapFormat = {
    name: "Lair of Lizards Area Export",
    extension: "lua",

    write: function(map, fileName) {
        
		if (!validateMap()) {
			return;
		}
		
		var buffer = '{\n';

		buffer += `["name"]="${map.property("name")}",\n`;
		buffer += `["id"]="${map.property("id")}",\n`;
		buffer += `["tileset"]="${map.property("tileset")}",\n`;
		buffer += `["mapSize"]=${map.width},\n`;

        for (var i = 0; i < map.layerCount; ++i) {
            
			var layer = map.layerAt(i);
            
			// walls
			
			if (layer.isTileLayer && layer.name == "Walls") {

				buffer += `["walls"]=\{\n`;
				
				var wasWall;
				var localbuffer = '';
				
				for (var x = 0; x < layer.width; ++x) {

					buffer += `\t[${x+1}]={\n`;

					wasWall = false;

                    for (var y = 0; y < layer.height; ++y) {

						var localbuffer = `\t\t[${y+1}]={`;
						
						wasWall = false;
						
						var tile = layer.tileAt(x, y);
						
						if (tile && tile.type == "Wall") {

							var props = layer.tileAt(x, y).resolvedProperties();
							var numProps = getMapSize(props);
							
							wasWall = numProps > 0;
							
							for (const key in props) {
								
								var value = props[key];
								
								if (!isNumeric(value)) {
									value = '"' + value + '"';
								} else {
									value = value ? value : '""';
								}
								
								localbuffer += `["${key}"]=${value},`;
							}	
							
						}
						localbuffer += '},\n';

						if (wasWall == true) {
							buffer += localbuffer;
						}
					
					}
					buffer += '\t},\n';

                }
			
				buffer += '},\n';
			
			}
			
			// boundary walls
			
			if (layer.isTileLayer && layer.name == "BoundaryWalls") {

				buffer += `["boundarywalls"]=\{\n`;
				
				var wasWall;
				var localbuffer = '';
				
				for (var x = 0; x < layer.width; ++x) {

					buffer += `\t[${x+1}]={\n`;

					wasWall = false;

                    for (var y = 0; y < layer.height; ++y) {

						var localbuffer = `\t\t[${y+1}]={`;
						
						wasWall = false;
						
						var tile = layer.tileAt(x, y);
						
						if (tile && tile.type == "Wall") {

							var props = layer.tileAt(x, y).resolvedProperties();
							var numProps = getMapSize(props);
							
							wasWall = numProps > 0;
							
							for (const key in props) {
								
								var value = props[key];
								
								if (!isNumeric(value)) {
									value = '"' + value + '"';
								} else {
									value = value ? value : '""';
								}
								
								localbuffer += `["${key}"]=${value},`;
							}	
							
						}
						localbuffer += '},\n';

						if (wasWall == true) {
							buffer += localbuffer;
						}
					
					}
					buffer += '\t},\n';

                }
			
				buffer += '},\n';
			
			}

        }

		buffer += getByType("EnemyBlocker", "enemyblockers", map);
		buffer += getByType("Enemy", "enemies", map);
		buffer += getByType("Chest", "chests", map);
		buffer += getByType("Spinner", "spinners", map);
		buffer += getByType("Portal", "portals", map);
		buffer += getByType("Well", "wells", map);
		buffer += getByType("NPC", "npcs", map);
		buffer += getByType("Trigger", "triggers", map);
		buffer += getByType("Teleporter", "teleporters", map);
		buffer += getByType("Sign", "signs", map);
		buffer += getByType("Door", "doors", map);
		buffer += getByType("StaticProp", "staticprops", map);
		buffer += getByType("Button", "buttons", map);
		buffer += getByType("LevelExit", "levelexits", map);
		buffer += getByType("BossGate", "bossgates", map);

		buffer += getPlayer(map);

		buffer += '}';

        var file = new TextFile(fileName, TextFile.WriteOnly);
        file.write(buffer);
        file.commit();
    },
}

tiled.registerMapFormat("custom", customMapFormat)