# ============================================================
# sweetdream:equipment/staff/triad/strong_end —— 强化结束: 保留形态 + 恢复护甲
# ------------------------------------------------------------
# 【执行者】玩家 @s
# 【文案】本效果持续 15 秒; 结束后**保留当前形态**, 不再变回「很冰的斧」
#   (2026-10-22 用户定: 原来强制切回冰斧 ⇒ 热刀/重枪 只能活 15 秒, 等于白做)。
#   热刀那套"-1 护甲 / -1 韧性"是**技能结束后恢复**的 ⇒ 仍然必须在这里把 modifier 摘掉。
# ============================================================

# ① 只清强化的 15 秒计时; ★ 形态(tri_form)**不清** ★
#   ★ 为什么这里不再 rename: 形态没变 ⇒ 手上那把的外观本来就是对的, 不用刷。
#     (改名只在 next_form 真正换形态时做。)
#   ★ 但"正在投掷"的视觉收尾不能漏 —— 原来靠 rename 的第一行顺手带上, 现在显式调。
scoreboard players set @s zx.tri_strong 0
execute if entity @s[tag=zx.tv_cast] run function sweetdream:equipment/staff/triad/visual/end
tellraw @s [{"text":"「很冰的斧」: 强化结束，当前形态保留","color":"gray"}]

# ② 恢复被强化热刀削过甲的目标 —— **只恢复自己削的**
#   【为什么按实体扫、不按距离找】被削甲的目标记的是**它自己身上**的 zx.tri_hit,
#     强化结束时玩家未必还站在它旁边 ⇒ 只能按"带 tri_hit 的实体"扫一遍。
#   【为什么三个维度各写一遍】裸 @e 在 execute in 下会跨维度搜全部维度, 会重复处理。
#   【★ 2026-10-13 改: 按施法者比对, 不再扫全场】
#     旧写法只认 `scores={zx.tri_hit=1..}` 这个标记、不认是谁削的 ⇒
#     多人各拿一把三形态法杖时, A 的技能结束会把 B 刚削掉的护甲/韧性一起恢复掉。
#   【做法】削甲时(armor_break)已把 owner 的 uuid 抄到目标身上 zx.tri_u0..u3;
#     这里先把**玩家自己的** uuid 取到假玩家 #tri_o0..o3, 再逐个目标比对四个分量。
#     ★ 假玩家只在这一处当"参照值"用、不外传, 不会串号(串号只发生在"存→赋给 @s")。
execute store result score #tri_o0 zx.meta run data get entity @s UUID[0]
execute store result score #tri_o1 zx.meta run data get entity @s UUID[1]
execute store result score #tri_o2 zx.meta run data get entity @s UUID[2]
execute store result score #tri_o3 zx.meta run data get entity @s UUID[3]

execute in minecraft:overworld as @e[distance=0..,scores={zx.tri_hit=1..}] if score @s zx.tri_u0 = #tri_o0 zx.meta if score @s zx.tri_u1 = #tri_o1 zx.meta if score @s zx.tri_u2 = #tri_o2 zx.meta if score @s zx.tri_u3 = #tri_o3 zx.meta run function sweetdream:equipment/staff/triad/armor_restore
execute in minecraft:the_nether as @e[distance=0..,scores={zx.tri_hit=1..}] if score @s zx.tri_u0 = #tri_o0 zx.meta if score @s zx.tri_u1 = #tri_o1 zx.meta if score @s zx.tri_u2 = #tri_o2 zx.meta if score @s zx.tri_u3 = #tri_o3 zx.meta run function sweetdream:equipment/staff/triad/armor_restore
execute in minecraft:the_end as @e[distance=0..,scores={zx.tri_hit=1..}] if score @s zx.tri_u0 = #tri_o0 zx.meta if score @s zx.tri_u1 = #tri_o1 zx.meta if score @s zx.tri_u2 = #tri_o2 zx.meta if score @s zx.tri_u3 = #tri_o3 zx.meta run function sweetdream:equipment/staff/triad/armor_restore
