data merge entity @s[type=minecraft:vindicator] {"Tags":["sd.bs.body","sd.bs.newbody"],"NoAI":1b,"Silent":1b,"PersistenceRequired":1b,"CanPickUpLoot":0b,"DeathLootTable":"minecraft:empty","CustomName":{"text":"白蓝持杖者"},"Health":600f,"attributes":[{"id":"minecraft:max_health","base":600f},{"id":"minecraft:armor","base":0f},{"id":"minecraft:armor_toughness","base":0f},{"id":"minecraft:attack_damage","base":0f},{"id":"minecraft:scale","base":1.7f}],"active_effects":[{"id":"minecraft:invisibility","duration":-1,"amplifier":0,"show_particles":0b,"show_icon":0b}]}
scoreboard players operation @s bs.id = #serial bs.id
tp @s ~ ~ ~ ~ 0
function fallendream:boss/b_staff/init
