# 满血改为: 下一次技能伤害 +8%, 可叠加。
# 用全包通用的 zx.mm_add 一次性槽(lib/mm_add/hook_calc 已挂 damage_calc, 无需新 hook):
# 每次 +8 个百分点可累加, 到下一次最大魔力值技能由 lib/mm_add/take 一次性消费。
scoreboard players add @s zx.mm_add 0
scoreboard players add @s zx.mm_add 8
