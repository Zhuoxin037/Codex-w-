# ============================================================
# sweetdream:equipment/axe/chenyuan/extra —— 有增益时额外锁定生物
# ------------------------------------------------------------
# 【执行者】施法者(位置在他身上)
# 【产出】zx.cy_x(排除已经选中的 A / B)
#   · 常态: 随机 3 只
#   · 超限: 6 格内**全部**(文案"改为对 6 格内的全部生物并释放该技能效果")
# 【★ 超限标记读 zx:work cy.ol ★】cast 写、这里读(私有键, 中间没人碰)。
# ============================================================

tag @e[tag=zx.cy_x] remove zx.cy_x
tag @e[tag=zx.cy_pool] remove zx.cy_pool
execute at @s as @e[type=!#sweetdream:no_damage,distance=0.1..6] unless entity @s[tag=zx.cy_a] unless entity @s[tag=zx.cy_b] run tag @s add zx.cy_pool
execute if data storage zx:work cy{ol:1} at @s as @e[tag=zx.cy_pool] run tag @s add zx.cy_x
execute unless data storage zx:work cy{ol:1} at @s as @e[tag=zx.cy_pool,sort=random,limit=3] run tag @s add zx.cy_x
tag @e[tag=zx.cy_pool] remove zx.cy_pool
