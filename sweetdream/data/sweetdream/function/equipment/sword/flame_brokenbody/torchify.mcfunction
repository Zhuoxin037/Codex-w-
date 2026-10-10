# ============================================================
# sweetdream:equipment/sword/flame_brokenbody/torchify —— 超限·烈火残躯: 「流火」→「夜火」
# ------------------------------------------------------------
# 【原文(逐字)】"…若攻击到的生物附有「流火」或「夜火」则该技能冷却时间立即结束，
#   且若有「流火」则转化为「夜火」，每有一个「夜火」则吸收并为自身积攒一点「熔浆」。"
# 【★ 是"转化", 不是"消耗" ★】所以**故意不走** lib/mark_consume ——
#   走它的话穿了「永恒」的目标会被把「流火」补回来, 等于白嫖(和火炬石同一条口径,
#   见 upgrade/api/torch 的注释)。这里直调 unmark + mark, 一次性替换。
# 【执行者】玩家   【前置】圈里的生物已打上 zx.fb_hit(见 cast ⑤)
# 【为什么先转化再计数】转化完它们就是「夜火」了, 后面 night 数夜火时
#   自然会把这些也算进熔浆 —— 和文案"每有一个「夜火」…积攒一点熔浆"对得上。
# ============================================================

# ① 圈出这一批里带「流火」的
tag @e[tag=zx.fb_torch] remove zx.fb_torch
execute as @e[tag=zx.fb_hit] if entity @s[tag=zx.status.liuhuo] run tag @s add zx.fb_torch

# ② 摘「流火」→ 挂「夜火」
execute if entity @e[tag=zx.fb_torch] run data modify storage zx:work ic set value {target:"@e[tag=zx.fb_torch]",mark:"liuhuo"}
execute if entity @e[tag=zx.fb_torch] run function sweetdream:tag/unmark with storage zx:work ic
execute if entity @e[tag=zx.fb_torch] run data modify storage zx:work ic set value {target:"@e[tag=zx.fb_torch]",mark:"yehuo"}
execute if entity @e[tag=zx.fb_torch] run function sweetdream:tag/mark with storage zx:work ic

# ③ 表现
execute at @e[tag=zx.fb_torch] run particle minecraft:soul_fire_flame ~ ~1 ~ 0.4 0.6 0.4 0.03 16 normal
execute at @e[tag=zx.fb_torch] run playsound minecraft:block.fire.extinguish player @a ~ ~ ~ 0.6 1.5

tag @e[tag=zx.fb_torch] remove zx.fb_torch
