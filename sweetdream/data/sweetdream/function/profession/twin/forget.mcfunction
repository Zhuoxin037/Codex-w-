data remove entity @s AngryAt
data remove entity @s Brain.memories."minecraft:angry_at"
data remove entity @s Brain.memories."minecraft:attack_target"
data remove entity @s Brain.memories."minecraft:universal_anger"
data remove entity @s Brain.memories."minecraft:nearest_attackable"

execute if entity @s[tag=sd.fb.body] run function sweetdream:profession/twin/boss_forget
execute if entity @s[tag=sd.kn.body] run function sweetdream:profession/twin/boss_forget
execute if entity @s[tag=sd.hk.body] run function sweetdream:profession/twin/boss_forget
