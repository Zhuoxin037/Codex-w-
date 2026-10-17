# ============================================================
# sweetdream:equipment/staff/late_court/lt_end —— "缓慢在领域内结束"的那一只: 额外一段 + 击退
# ------------------------------------------------------------
# 【谁调用它】late_court/field_tick ④
# 【执行者】那只生物   【位置】它自己   【入参】zx:work lte {dmg2,u0..u3}(由 field_tick 抄好)
# 【技能原文】"生物的缓慢效果在领域内结束时，额外对其造成一次相当于自身基础攻击力 ×4
#   的伤害，并将其向领域外击退最多 1 格；每个生物整次领域最多触发一次该结束效果。"
# 【★ 先记账再结算 ★】第 ① 步就把 zx.ltc_end 写成"本领域实例号"并把 zx.ltc_slow 摘掉 ——
#   万一第 ③ 步的伤害/第 ④ 步的 tp 因为任何原因没跑到, 也不会变成"每跳都触发一次"。
# 【★ 击退怎么算 ★】照包内**唯一**的 tp 式击退先例(异彩 effect 三: "被击退一格"):
#   facing 到参照点 -> 沿局部坐标 ^ ^ ^-1(背离参照点) -> 目标格是可替换方块才 tp。
#   参照点 = 领域圆心(marker, 由 field_tick 打了临时标签 zx.ltc_center) ⇒ 方向就是"向领域外"。
#   · "最多 1 格" = 位移恰好是一个单位向量 × 1 格, 绝不会更多。
#   · 撞墙(目标格不是可替换方块)就**不推** —— tp 式击退唯一的硬伤, 必须挡掉,
#     免得把生物塞进方块里卡住。
# 【★ 为什么位置留在这里、身份不换 ★】这段伤害是"施法者的基础攻击力 ×4", 数值已经
#   在施放那刻算好存在 marker 里; 归属靠 u0..u3。所以不需要反查玩家再换身份。
# ============================================================

# ① 记账: 本领域对它已经触发过; 同时摘掉 zx.ltc_slow(它现在不带缓慢了)
scoreboard players operation @s zx.ltc_end = #ltc_iid zx.meta
scoreboard players set @s zx.ltc_fid 0
tag @s remove zx.ltc_slow

# ② 额外一段: 基础攻击力 ×4(施放那刻算好, 存在 zx:work lte.dmg2)
data modify storage zx:work a.num set value 0.0
data modify storage zx:work a.num set from storage zx:work lte.dmg2
function sweetdream:lib/num/plain
#   目标用 @s(就是它自己)—— with_from 会 `execute as $(target)`, 以自己为执行者刚好对上
data modify storage zx:work a.target set value "@s"
data modify storage zx:work a.type set value "minecraft:player_attack"
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.u0 set from storage zx:work lte.u0
data modify storage zx:work a.u1 set from storage zx:work lte.u1
data modify storage zx:work a.u2 set from storage zx:work lte.u2
data modify storage zx:work a.u3 set from storage zx:work lte.u3
function sweetdream:internal/damage/with_from with storage zx:work a

# ③ 向领域外击退最多 1 格(见文件头 ★ 击退怎么算 ★)
#   distance 上限写 ..6(领域半径 4 + 缓冲): 圆心必然在半径内, 留余量只为防边界
execute at @s facing entity @e[tag=zx.ltc_center,distance=..6,limit=1] feet positioned ^ ^ ^-1 if block ~ ~ ~ #minecraft:replaceable run tp @s ~ ~ ~

# ④ 表现: 琥珀色的"判决"一闪
#   ★ 必须 `at @s` ★ 本文件的命令位置继承自 field_tick(领域圆心), 不是这只生物;
#     不加 at @s 的话粒子会全部出现在圆心而不是"被判决的那只身上"。
execute at @s run particle minecraft:enchanted_hit ~ ~1 ~ 0.5 0.6 0.5 0.05 18 normal
execute at @s run particle minecraft:dust{color:[0.95,0.72,0.35],scale:1.6} ~ ~1 ~ 0.4 0.5 0.4 0.03 12 normal
playsound minecraft:block.amethyst_block.chime player @a ~ ~ ~ 0.5 0.7
