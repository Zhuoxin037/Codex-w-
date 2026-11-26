data merge entity @s {"Tags":["sd.bs.bone","sd.bs.part.neck","sd.bs.unbound"],"item":{"id":"minecraft:stick","count":1,"components":{"minecraft:item_model":"fallendream_boss:b_staff/neck"}},"item_display":"none","billboard":"fixed","view_range":1f,"width":3f,"height":4f,"shadow_radius":0f,"interpolation_duration":1,"teleport_duration":0,"transformation":{"translation":[0.0078125f,2.755281f,0.025f],"scale":[0f,0f,0f],"left_rotation":[0f,1f,0f,0f],"right_rotation":[0f,0f,0f,1f]}}
scoreboard players operation @s bs.id = #serial bs.id
function fallendream:boss/b_staff/part/bind
