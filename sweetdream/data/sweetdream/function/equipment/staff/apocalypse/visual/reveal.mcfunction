# 由真正造成灾示的 reveal_go 调用，不能按独立秒表假播。
scoreboard players set @s zx.apv 199
# 只有三页实际全部消耗，且到了末次灾示，才展开强化双环。
execute if score @s zx.ap_on matches ..3 if score @s zx.apvc matches 3.. run scoreboard players set @s zx.apv 219
tag @s add zx.apv_active
