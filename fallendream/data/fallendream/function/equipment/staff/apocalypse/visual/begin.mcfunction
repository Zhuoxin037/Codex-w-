# 只在冷却、扣费成功后调用。下一刻从 100 开始入场；无页时仍有居中动作。
scoreboard players set @s zx.apvc 0
scoreboard players set @s zx.apv 99
tag @s add zx.apv_active
