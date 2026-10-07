# ============================================================
# sweetdream:equipment/armor/spirit_sight/second —— 灵视·每秒入口
# ------------------------------------------------------------
# 【谁调用它】挂在 #manacore:event/second
# 【管什么】8 格内带通用标签的生物 -> 发光; 有则自身回 1 魔力。
#   魔力上限 +70 不在这里 -> 走 armor_mana/passive 的统一差值账本。
# 【★ 为什么是 `as @a at @s` ★】距离要以玩家为原点算, `as` 不换坐标,
#   必须先 as 再 at(见 check 规则 asnoat)。
# ============================================================

function sweetdream:lib/in_bak

execute as @a at @s run function sweetdream:equipment/armor/spirit_sight/passive

function sweetdream:lib/in_restore
