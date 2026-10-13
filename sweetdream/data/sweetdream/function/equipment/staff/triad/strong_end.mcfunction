# ============================================================
# sweetdream:equipment/staff/triad/strong_end —— 强化结束: 切回冰斧 + 恢复护甲
# ------------------------------------------------------------
# 【执行者】玩家 @s
# 【文案】本效果持续 15 秒, 结束后**切回「很冰的斧」**;
#   热刀那套"-1 护甲 / -1 韧性"是**技能结束后恢复**的 ⇒ 必须在这里把 modifier 摘掉。
# 【★ 为什么要扫实体、而不是按距离找 ★】被削甲的目标记的是**它自己身上**的 zx.tri_hit,
#   强化结束时玩家未必还站在它旁边 ⇒ 只能按"带 tri_hit 的实体"扫一遍。
#   (这也是把 tri_hit 记在目标身上的原因 —— 记在玩家身上就找不回是谁被削了。)
# 【★ 但只恢复**自己**削的那几只 ★】扫出来的目标还要再比对 owner
#   (zx.tri_u0..u3 == 本玩家的 UUID), 否则多人各拿一把时, A 的技能结束会把
#   B 刚削掉的护甲/韧性一起恢复掉(2026-10-13 用户拍板改成按施法者区分)。
# 【为什么三个维度各写一遍】见 second 的说明: 裸 @e 会跨维度, 必须锁当前维度。
# ============================================================

# ① 切回冰斧(形态 0) —— 并把手上那把**改回**「很冰的斧」
#   ★ 改名不能漏: 强化结束时形态被强制归 0, 若不同步改名字, 手里会留着一把
#     写着「很热的刀」、实际却在按冰斧结算的武器(名字与机制不一致, 极难排查)。
scoreboard players set @s zx.tri_form 0
scoreboard players set @s zx.tri_strong 0
function sweetdream:equipment/staff/triad/rename
tellraw @s [{"text":"「很冰的斧」: 强化结束，已切回冰斧","color":"gray"}]

# ② 恢复被强化热刀削过甲的目标 —— **只恢复自己削的**
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
