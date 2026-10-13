# ============================================================
# sweetdream:equipment/staff/triad/strong_end —— 强化结束: 切回冰斧 + 恢复护甲
# ------------------------------------------------------------
# 【执行者】玩家 @s
# 【文案】本效果持续 15 秒, 结束后**切回「很冰的斧」**;
#   热刀那套"-1 护甲 / -1 韧性"是**技能结束后恢复**的 ⇒ 必须在这里把 modifier 摘掉。
# 【★ 为什么恢复要扫全场实体 ★】被削甲的目标记的是**它自己身上**的 zx.tri_hit,
#   强化结束时玩家未必还站在它旁边 ⇒ 只能按"带 tri_hit 的实体"全扫一遍摘掉。
#   (这也是把 tri_hit 记在目标身上的原因 —— 记在玩家身上就找不回是谁被削了。)
# 【为什么三个维度各写一遍】见 second 的说明: 裸 @e 会跨维度, 必须锁当前维度。
# ============================================================

# ① 切回冰斧(形态 0) —— 并把手上那把**改回**「很冰的斧」
#   ★ 改名不能漏: 强化结束时形态被强制归 0, 若不同步改名字, 手里会留着一把
#     写着「很热的刀」、实际却在按冰斧结算的武器(名字与机制不一致, 极难排查)。
scoreboard players set @s zx.tri_form 0
scoreboard players set @s zx.tri_strong 0
function sweetdream:equipment/staff/triad/rename
tellraw @s [{"text":"「很冰的斧」: 强化结束，已切回冰斧","color":"gray"}]

# ② 恢复全场被强化热刀削过甲的目标
execute in minecraft:overworld as @e[distance=0..,scores={zx.tri_hit=1..}] run function sweetdream:equipment/staff/triad/armor_restore
execute in minecraft:the_nether as @e[distance=0..,scores={zx.tri_hit=1..}] run function sweetdream:equipment/staff/triad/armor_restore
execute in minecraft:the_end as @e[distance=0..,scores={zx.tri_hit=1..}] run function sweetdream:equipment/staff/triad/armor_restore
