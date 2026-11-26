# ============================================================
# fallendream:equipment/sword/mana_imbue/aoe —— 超限主动的 2 格溅射
# ------------------------------------------------------------
# 【谁调】profession/delayed/hit（只有注魔超限的 jdelay 带 im_aoe:1b）
# 【文案】"之后对其 2 格内的其他生物造成相当于自身对其造成的伤害的 80%"
# 【★ 为什么按 num×0.8 而不是"实收伤害×0.8"★】这一次的 num 在施法时就算好了
#   （jdelay.num 固定），实际收多少受目标抗性影响；按 num 算才与"额外附加
#   X 次 max_mana×0.08"同一把尺子，且 X 次各 80% 累加正好等于总额 80%。
# 【★ 调用时机 = 主伤害之前★】主目标被打死后 `at @e[...]` 就选不到实体，
#   位置没了、溅射整段消失。放在前面：位置一定拿得到；用独立的节点投递，
#   with_from 自己会备份/恢复 zx:work a，不影响紧跟着的主伤害。
# 【★ 为什么先抄一份 ima_base★】aoe_one 每只目标都要重建 zx:work a，
#   若直接拿 a 当宏参数，第一只改完 a 之后第二只展开就缺 $(u0) —— 宏行缺参
#   会让整个函数调用失败（静默）。所以先把这一批的基准抄到一个专用节点，
#   循环里只读它，谁都不改。
# 【口径】`type=!#fallendream:no_damage` = 非玩家生物（与 agony / anchor /
#   angel_core 的既有 AoE 一致，不会误伤队友）。
# ============================================================

data modify storage zx:work ima_base set from storage zx:work a

# 执行位置 = 主目标脚下；把主目标临时打 tag 以便排除（含 distance 0）
$tag @e[type=!minecraft:player,distance=0..,nbt={UUID:[I;$(t0),$(t1),$(t2),$(t3)]},limit=1] add zx.im_main
execute as @e[type=!#fallendream:no_damage,tag=!zx.im_main,distance=..2] run function fallendream:equipment/sword/mana_imbue/aoe_one
tag @e[tag=zx.im_main] remove zx.im_main

# aoe_one 逐只重建过 zx:work a ⇒ 这里必须把主伤害的入参还回去
data modify storage zx:work a set from storage zx:work ima_base
data remove storage zx:work ima_base
