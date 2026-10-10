# ============================================================
# sweetdream:equipment/axe/dream_reader/pet_follow —— 按 uuid 精确追"我那一只"(宏)
# ------------------------------------------------------------
# 【谁调用它】pet_tick ④a(只对**已绑定目标**的入梦体; 参数 = 目标 UUID 的四个 int)
# 【执行者】入梦体(marker)  【位置】入梦体处(由 pet_tick 的 at @s 带来)
# 【为什么用 uuid 反查, 而不是 `@e[tag=zx.dr_claim,sort=nearest]`】见 pet_tick 头注释:
#   后者会让**所有**入梦体都朝"离自己最近的那只 claim"飞 —— 目标只有一只时全追同一只。
# 【★ 本函数里每个 @e 都带 distance=(位置参数) ★】否则裸 @e 会跨维度搜索(RULES 坑 55)。
# 【目标不在了(被打死 / 被 tp 到别的维度)> 摘掉绑定, 下一刻重新认领】
#   不清的话它会一直悬停到 30 秒寿命结束。这里用 distance=0..64 锁**当前维度**,
#   所以"目标跨维度跑掉"也会被当作丢失 -> 重新认领(合理: 它追不过去)。
# 【结算用"临时标记 zx.dr_hit"中转, 不直接把选择器串进 storage】
#   pet_hit 里要 `set value "@e[...]"` 传目标; 若那个字符串里含 `nbt={...}` 的 `{}`,
#   整份 pet_hit 会**静默不加载**(RULES 坑 64 braceval)。所以改成: 这里按 uuid 挑出目标
#   打上 zx.dr_hit, pet_hit 只认 `@e[tag=zx.dr_hit,...]`。
# ============================================================

# ① 目标还在不在? 不在 -> 摘绑定(下一刻重新认领)
$execute unless entity @e[type=!#sweetdream:no_damage,nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},distance=0..64] run tag @s remove zx.dr_has
$execute unless entity @e[type=!#sweetdream:no_damage,nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},distance=0..64] run data remove entity @s data.zx.tg

# ② 重建"占位"(core/tick 每刻先清 zx.dr_claim; 已绑定的入梦体在这里把它重新盖上)
#    ★ 这一步必须发生在"未绑定的同伴认领"之前 —— core/tick 靠"分两遍跑"保证顺序。
$tag @e[type=!#sweetdream:no_damage,nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},distance=0..64] add zx.dr_claim

# ③ 朝它飞(每刻 0.65 格)
$execute at @s if entity @e[type=!#sweetdream:no_damage,nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},distance=0..64] facing entity @e[type=!#sweetdream:no_damage,nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},distance=0..64] feet run tp @s ^ ^ ^0.65

# ④ 进 1.4 格 -> 打临时标记 -> 交给 pet_hit 结算(伤害 + 时停 2 秒 + 白昼梦 + 自毁)
tag @e[tag=zx.dr_hit,distance=0..] remove zx.dr_hit
$tag @e[type=!#sweetdream:no_damage,nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},distance=..1.4] add zx.dr_hit
execute if entity @e[tag=zx.dr_hit,distance=0..] run function sweetdream:equipment/axe/dream_reader/pet_hit
tag @e[tag=zx.dr_hit,distance=0..] remove zx.dr_hit
