# ============================================================
# sweetdream:equipment/axe/deep_brine/field_hit —— 领域每秒那一下(伤害 + 拉扯)
# ------------------------------------------------------------
# 【谁调用它】field_tick ⑤: function ... with storage zx:work dbr
# 【宏参数】zx:work dbr {r}  —— r = 领域半径(普通 3 / 超限 5 / 合并后 8·11·14)
# 【执行者】领域 marker   【位置】领域中心
# 【前置】zx:work a 里的 num / type / u0..u3 已由 field_tick 备好 —— 这里只补 target。
# ------------------------------------------------------------
# 【★ "持续被拉向中心"怎么落地(照海棠漩涡 vortex_tick) ★】
#   · 只拉"离中心还有 1 格以上"的: 否则贴脸那只距离≈0、朝向退化, 会被顶得原地乱跳。
#   · 每次挪 0.5 格; 目标格不是可替换方块就不动(= 遇到障碍即停)。
#   · 圆心用临时标签 zx.db_center 钉住本 marker, 收尾立刻摘掉。
# ============================================================

# ① 目标 = 半径内的全部生物
$data modify storage zx:work a.target set value "@e[type=!#sweetdream:no_damage,distance=..$(r)]"
function sweetdream:internal/damage/with_from with storage zx:work a

# ② 朝中心拉一段(圆心 = 本 marker)
tag @e[tag=zx.db_center,distance=0..] remove zx.db_center
tag @s add zx.db_center
tag @e[tag=zx.db_pull,distance=0..] remove zx.db_pull
$tag @e[type=!#sweetdream:no_damage,distance=1.01..$(r)] add zx.db_pull
execute as @e[tag=zx.db_pull,distance=0..] at @s facing entity @e[tag=zx.db_center,distance=0..,limit=1] feet positioned ^ ^ ^0.5 if block ~ ~ ~ #minecraft:replaceable run tp @s ~ ~ ~
tag @e[tag=zx.db_pull,distance=0..] remove zx.db_pull
tag @e[tag=zx.db_center,distance=0..] remove zx.db_center
