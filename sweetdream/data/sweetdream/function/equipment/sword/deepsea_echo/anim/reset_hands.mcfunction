# 每秒兜底只改 floats[1]=48，不清待机水波相位，不打断施法中的玩家。
execute unless entity @s[tag=zx.de_cast] if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["deepsea_echo"]}] run item modify entity @s weapon.mainhand sweetdream:deepsea/cast_idle
execute unless entity @s[tag=zx.de_cast] if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["deepsea_echo"]}] run item modify entity @s weapon.offhand sweetdream:deepsea/cast_idle
