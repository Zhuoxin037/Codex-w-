# ============================================================
# sweetdream:tag/icon_go —— 保证图标存在, 并摆到"眼睛上方"
# ------------------------------------------------------------
# 【宏参数】zx:work ic {id, key}    【执行者】被标记的生物
# 【为什么用 anchored eyes】每只生物高矮不同(鸡 / 僵尸 / 坚守者),
#   用"眼睛锚点"再往上抬, 图标就永远在它头顶上方, 不会插进身体里。
# ============================================================

$execute unless entity @e[tag=zx.icon_$(id),limit=1] run function sweetdream:tag/icon_spawn with storage zx:work ic
$execute at @s anchored eyes run tp @e[tag=zx.icon_$(id),limit=1] ~ ~1.0 ~
