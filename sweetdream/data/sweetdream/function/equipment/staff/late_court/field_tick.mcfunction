# ============================================================
# sweetdream:equipment/staff/late_court/field_tick —— 迟庭领域每秒一跳(执行者 = 领域 marker)
# ------------------------------------------------------------
# 【谁调用它】lib/second: execute in <维度> as @e[type=marker,tag=zx.ltc_field,distance=0..] at @s run ...
# 【每秒干什么】
#   ① 挑出"本刻在领域内、且**正带着缓慢效果**"的生物 -> 临时标签 zx.ltc_now
#   ② 把它们记进"本领域见过它带缓慢"(zx.ltc_slow 标签 + zx.ltc_fid 实例号)
#   ③ 挑出"缓慢**刚在本领域内结束**"的 -> 额外一段 + 向领域外击退(每只整次领域一次)
#   ④ 清掉"已经离开领域"的陈旧状态(离开领域后缓慢才结束的**不算数**)
#   ⑤ 对领域内**处于缓慢**的生物打一次 最大魔力值 ×0.04
#   ⑥ 计时 -1, 归零 field_end
# 【★ "整次领域最多一次"怎么判 ★】领域实例号 = 本 marker 的 UUID[0]
#   (随机 32 位整数, 两个领域撞号的概率可忽略)。
#   · zx.ltc_fid: 这只生物上一次是在**哪个领域里**被看到带缓慢的(记在生物身上);
#   · zx.ltc_end: 这只生物**已经在这个领域**里触发过"结束那一段"了(记在生物身上)。
#   两个都存实例号 ⇒ 换个领域自然不相等, 陈旧值永远匹配不上、不需要额外清理。
#   为什么用计分项不用 NBT: 目标是"生物", 将来若把玩家也放进来也**写不了玩家 NBT**(坑 162)。
# 【★ "缓慢结束了"怎么判 ★】
#   "现在带缓慢"能用**选择器** nbt={active_effects:[{id:"minecraft:slowness"}]} 判
#   (列表按"含某元素"匹配, 任意等级/时长的缓慢都算; 先例 = 无光海 passive / 枯枝园 wood_tick)。
#   但**"现在不带缓慢"没法用选择器写**(选择器 nbt 不能取反) —— 所以先把"正带缓慢"的打上
#   临时标签 zx.ltc_now, "带 zx.ltc_now 的取反"就用 `tag=!zx.ltc_now` 表达。
# 【★ 陈旧状态为什么必须清 ★】生物带着缓慢跑出领域、在外面把缓慢走完 -> 再回来时
#   它已经没有 zx.ltc_now 了, 若不清掉 zx.ltc_slow 就会被判成"缓慢刚在领域内结束",
#   白吃一段伤害。第 ④ 步只扫**带 zx.ltc_slow 的生物**(标签过滤, 不是全世界), 很便宜。
# ============================================================

# ① 本次领域的实例号 = 本 marker 的 UUID[0](store result 每刻都会重写, 不会读陈旧值)
scoreboard players add #ltc_iid zx.meta 0
execute store result score #ltc_iid zx.meta run data get entity @s UUID[0]

# ② 本刻在领域内、且正带着缓慢的生物 -> 临时标签 zx.ltc_now
#   ★ 先清一遍再打: 上一轮/上一个领域留下的残标不能带过来(同神裁/崩裂/重溟的临时标签写法)。
tag @e[tag=zx.ltc_now,distance=0..] remove zx.ltc_now
execute as @e[type=!#sweetdream:no_damage,distance=..4,nbt={active_effects:[{id:"minecraft:slowness"}]}] run tag @s add zx.ltc_now

# ③ 记进"本领域见过它带缓慢": zx.ltc_slow 标签 + zx.ltc_fid = 本领域实例号
execute as @e[tag=zx.ltc_now,distance=0..] run function sweetdream:equipment/staff/late_court/lt_seen

# ④ "缓慢刚在领域内结束"的那些 -> 额外一段 + 击退(每只整次领域最多一次)
#   【先把这一段要用的伤害与归属抄进 zx:work lte】lt_end 的执行者是那只生物,
#     读不到 marker 的 NBT —— 由这里以 marker 身份抄好, 整跳内都有效。
data modify storage zx:work lte.dmg2 set from entity @s data.zx.dmg2
data modify storage zx:work lte.u0 set from entity @s data.zx.u[0]
data modify storage zx:work lte.u1 set from entity @s data.zx.u[1]
data modify storage zx:work lte.u2 set from entity @s data.zx.u[2]
data modify storage zx:work lte.u3 set from entity @s data.zx.u[3]
#   【给本领域钉一个临时标签】lt_end 要"背离领域中心"击退, 需要知道圆心是谁。
tag @s add zx.ltc_center
#   条件: 在领域内(distance=..4) + 带 zx.ltc_slow(上次在领域里是带缓慢的)
#         + 不带 zx.ltc_now(这一秒已经没有缓慢了 = 缓慢刚结束)
#         + 实例号等于本领域(是"在本领域内"见过)
#         + 本领域还没触发过(zx.ltc_end ≠ 本领域实例号)
execute as @e[type=!#sweetdream:no_damage,distance=..4,tag=zx.ltc_slow,tag=!zx.ltc_now] if score @s zx.ltc_fid = #ltc_iid zx.meta unless score @s zx.ltc_end = #ltc_iid zx.meta run function sweetdream:equipment/staff/late_court/lt_end
tag @s remove zx.ltc_center

# ⑤ 清掉"已经离开领域"的陈旧状态(离开领域后缓慢才结束的不算数)
execute as @e[tag=zx.ltc_slow,distance=4..] if score @s zx.ltc_fid = #ltc_iid zx.meta run function sweetdream:equipment/staff/late_court/lt_leave

# ⑥ 每秒伤害: 领域内**处于缓慢**的生物(就是第 ② 步那批), 打 最大魔力值 ×0.04
data modify storage zx:work a.num set value 0.0
data modify storage zx:work a.num set from entity @s data.zx.dmg
function sweetdream:lib/num/plain
data modify storage zx:work a.target set value "@e[type=!#sweetdream:no_damage,tag=zx.ltc_now,distance=0..]"
data modify storage zx:work a.type set value "minecraft:player_attack"
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.u0 set from entity @s data.zx.u[0]
data modify storage zx:work a.u1 set from entity @s data.zx.u[1]
data modify storage zx:work a.u2 set from entity @s data.zx.u[2]
data modify storage zx:work a.u3 set from entity @s data.zx.u[3]
function sweetdream:internal/damage/with_from with storage zx:work a

# ⑦ 表现: 一圈缓缓下沉的琥珀庭光
particle minecraft:dust{color:[0.85,0.62,0.30],scale:1.4} ~ ~0.25 ~ 2.0 0.15 2.0 0.01 12 normal
particle minecraft:end_rod ~ ~0.5 ~ 1.6 0.3 1.6 0.02 8 normal

# ⑧ 计时 -1, 归零收摊
scoreboard players remove @s zx.ltc_ft 1
execute if score @s zx.ltc_ft matches ..0 run function sweetdream:equipment/staff/late_court/field_end
