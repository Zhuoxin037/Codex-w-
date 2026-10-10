# 48 帧施法（2.4 秒），只有 zx.de_cast 标记的玩家参与。
# 最后一帧独占一个同步刻；计数到 49 才复位，避免末帧被同刻覆盖。
scoreboard players operation #decast zx.meta = @s zx.de_cast
execute if score @s zx.de_cast matches 0..47 if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["deepsea_echo"]}] run item modify entity @s weapon.mainhand sweetdream:deepsea/cast_frame
execute if score @s zx.de_cast matches 0..47 if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["deepsea_echo"]}] run item modify entity @s weapon.offhand sweetdream:deepsea/cast_frame
# 原有粒子时间轴保持 0..31；第 20 刻仍对应第一波水链，不拉伸技能计时。
execute if score @s zx.de_cast matches 0..31 at @s run function sweetdream:equipment/sword/deepsea_echo/anim/fx
scoreboard players add @s zx.de_cast 1
execute if score @s zx.de_cast matches 49.. run function sweetdream:equipment/sword/deepsea_echo/anim/end
