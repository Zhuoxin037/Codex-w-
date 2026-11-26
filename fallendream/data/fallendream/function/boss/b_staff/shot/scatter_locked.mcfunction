$summon minecraft:marker $(x) $(y) $(z) {Tags:["sd.bs.point"]}
$execute at @e[tag=sd.bs.sigil,scores={bs.owner=$(owner),bs.dir=-1},distance=0..,limit=1] facing entity @e[tag=sd.bs.point,distance=0..,limit=1] feet run function fallendream:boss/b_staff/fx/bolt
$execute at @e[tag=sd.bs.sigil,scores={bs.owner=$(owner),bs.dir=1},distance=0..,limit=1] facing entity @e[tag=sd.bs.point,distance=0..,limit=1] feet run function fallendream:boss/b_staff/fx/bolt
kill @e[tag=sd.bs.point,distance=0..]
