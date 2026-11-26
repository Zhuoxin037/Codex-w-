$execute as @e[tag=sd.bs.body,scores={bs.id=$(owner)},distance=0..,limit=1] unless entity @s[nbt={Health:0.0f}] run tag @s add sd.bs.source
