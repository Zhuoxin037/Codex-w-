# ============================================================
# sweetdream:equipment/tool/coffin_silk/held —— 判"这个玩家副手持着殓丝"
# ------------------------------------------------------------
# 【谁调用它】coffin_silk/on_true_hit（反查出造成这次真伤的玩家之后）
# 【执行者】那个玩家   【入参】**无**（玩家身份已经由调用方用 UUID 反查好）
#   【出参】#cfs_held zx.meta = 1b
# 【为什么不写成一行 if entity】真伤可能在**别的上下文**里打出（技能、召唤物），
#   那时 @s 不是玩家; 只能靠 ob 里的 UUID 反查(先例: sacred_relic/skill_kill)。
# ============================================================

execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["coffin_silk"]}] run scoreboard players set #cfs_held zx.meta 1
