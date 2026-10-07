# ============================================================
# sweetdream:equipment/sword/verdict/field —— 逐个目标生成领域(宏 {uuid,dmg})
# ------------------------------------------------------------
# 【宏参数】sweetdream:work vdf {uuid,dmg}   【执行者】施法者
# 【干什么】把施放者的 UUID 四个整数查出来, 补齐进 vdf, 再对每个被选中的目标
#   (zx.vd_mark)**在其所在处**生成一个领域 marker(见 field_one)。
# 【为什么补 u0..u3】领域打出伤害时要带"击杀归属"; 用不了 UUID 文本进选择器,
#   只能用四个整数(和 internal/damage/with_from 一个路子)。
# ============================================================

$data modify storage zx:work vdf.u0 set from storage manacore:players "$(uuid)".u0
$data modify storage zx:work vdf.u1 set from storage manacore:players "$(uuid)".u1
$data modify storage zx:work vdf.u2 set from storage manacore:players "$(uuid)".u2
$data modify storage zx:work vdf.u3 set from storage manacore:players "$(uuid)".u3

# at(不是 as): 只把坐标搬到目标处, 执行者仍是施法者 —— field_one 用 ~ ~ ~ 即可
execute at @e[tag=zx.vd_mark,distance=0..] run function sweetdream:equipment/sword/verdict/field_one with storage zx:work vdf
