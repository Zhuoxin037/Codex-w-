# 玩家自查: 检查监听是否已安装, 真正死亡回调与落地数量。
scoreboard players set #sr_probe_ready zx.meta 1
scoreboard players add #sr_hook zx.meta 0
scoreboard players add #sr_ok zx.meta 0
function sweetdream:equipment/axe/sacred_relic/watch
execute if items entity @s weapon.mainhand *[enchantments~[{enchantments:"sweetdream:sacred_relic"}]] run tellraw @s {text:"圣骸遗骸回调已安装",color:"green"}
execute unless items entity @s weapon.mainhand *[enchantments~[{enchantments:"sweetdream:sacred_relic"}]] run tellraw @s {text:"当前主手没有遗骸回调(请检查主/副手圣骸)",color:"yellow"}
tellraw @s [{text:"受害者回调="},{score:{name:"#sr_hook",objective:"zx.meta"}},{text:"  已生成遗骸="},{score:{name:"#sr_ok",objective:"zx.meta"}}]
scoreboard players set #sr_probe zx.meta 0
execute store result score #sr_probe zx.meta run execute if entity @e[type=minecraft:marker,tag=zx.sr_relic,distance=0..]
tellraw @s [{text:"当前维度遗骸="},{score:{name:"#sr_probe",objective:"zx.meta"}}]
