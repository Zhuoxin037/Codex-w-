# 真实消耗一次才计一页；第一页接在入场之后，后续页立即启动短促疾翻。
scoreboard players add @s zx.apvc 1
execute if score @s zx.apvc matches 2.. if entity @s[tag=zx.apv_active] run scoreboard players set @s zx.apv 159
