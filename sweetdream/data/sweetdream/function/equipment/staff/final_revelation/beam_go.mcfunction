# ============================================================
# sweetdream:equipment/staff/final_revelation/beam_go —— 光柱每刻的跟随/续命/生成
# ------------------------------------------------------------
# 【宏参数】zx:work fu {u0,u1,u2,u3} = 施法玩家的 UUID 四 int(beam 外壳备好)
# 【执行者】施法玩家(beam 外壳原样传下来)
# 【SEL】"我的那根光柱" = item_display + tag zx.fr_beam + data.zx.fr 的 UUID 四 int
#   与我匹配(宏把数字拼进 nbt, 只能宏)。
# ============================================================

# ① 跟随: tp 到「眼睛下 0.12、前方 8 格」并继承玩家朝向(光条以此为 16 格的中点)
$execute at @s anchored eyes positioned ^ ^-0.12 ^8 run tp @e[type=item_display,tag=zx.fr_beam,distance=0..,nbt={data:{zx:{fr:{u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}}}},limit=1] ~ ~ ~ ~ ~

# ② 续命: 3 刻内没人续就自杀(core/tick 每刻 -1)
$execute at @s run scoreboard players set @e[type=item_display,tag=zx.fr_beam,distance=0..,nbt={data:{zx:{fr:{u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}}}},limit=1] zx.fr_ref 3

# ③ 我还没有光柱 -> 生成
$execute unless entity @e[type=item_display,tag=zx.fr_beam,distance=0..,nbt={data:{zx:{fr:{u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}}}},limit=1] run function sweetdream:equipment/staff/final_revelation/beam_new

# ④ 装饰: 沿光条撒极稀疏的余晖(每刻每点 1 颗, 约 3 颗/刻)。
#    ① 用同一个 ^-0.12 偏移 —— 落在光条轴线上会被摄像机投影成"看不见", 见坑 69。
#    ② 只做观感, 判定/伤害都不在这里(scan/tick 负责), 全删了机制也照常跑。
execute at @s anchored eyes positioned ^ ^-0.12 ^4 run particle minecraft:end_rod ~ ~ ~ 0.20 0.20 0.20 0.0 1 normal
execute at @s anchored eyes positioned ^ ^-0.12 ^8 run particle minecraft:end_rod ~ ~ ~ 0.20 0.20 0.20 0.0 1 normal
execute at @s anchored eyes positioned ^ ^-0.12 ^12 run particle minecraft:end_rod ~ ~ ~ 0.20 0.20 0.20 0.0 1 normal

# ⑤ 照射共鸣水晶(2026-10-09 用户: "这两个都是持续发射光束, 所以穿过水晶且可以触发")
#   光柱(长 16 / 半宽 2)扫到 **自己人的** 共鸣水晶时, 给它打一个"被光束照到"戳
#   zx.ch_beam —— 共鸣的 chime/pass_set 每刻读它, 按"自身法术穿过"那一套结算
#   (并与"法球穿过"共用同一个 0.5 秒节流)。
#   · "自己人的" = 水晶的 data.zx.ch.u0..u3 与施法者一致(与法球同一条归属判据)。
#   · 采样几何与 scan 同源: 沿视线轴摆采样球、半径 = 光柱半宽 2;
#     5 个圆心(2/5.5/9/12.5/16)间距 3.5 < 2×2 ⇒ 相邻球充分重叠(最细处约 1.9 格宽)。
#   ★ 判定留在准星轴上, **不带** ^-0.12 的视觉偏移(和 scan 一个口径, 见坑 69)。
#   ★ 这条只"打戳", 不结算、不播粒子 —— 结算全在 chime 那边, 免得两处各写一套。
$execute at @s anchored eyes positioned ^ ^ ^2 run scoreboard players set @e[type=minecraft:marker,tag=zx.ch_cry,distance=..2,nbt={data:{zx:{ch:{u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}}}}] zx.ch_beam 1
$execute at @s anchored eyes positioned ^ ^ ^5.5 run scoreboard players set @e[type=minecraft:marker,tag=zx.ch_cry,distance=..2,nbt={data:{zx:{ch:{u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}}}}] zx.ch_beam 1
$execute at @s anchored eyes positioned ^ ^ ^9 run scoreboard players set @e[type=minecraft:marker,tag=zx.ch_cry,distance=..2,nbt={data:{zx:{ch:{u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}}}}] zx.ch_beam 1
$execute at @s anchored eyes positioned ^ ^ ^12.5 run scoreboard players set @e[type=minecraft:marker,tag=zx.ch_cry,distance=..2,nbt={data:{zx:{ch:{u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}}}}] zx.ch_beam 1
$execute at @s anchored eyes positioned ^ ^ ^16 run scoreboard players set @e[type=minecraft:marker,tag=zx.ch_cry,distance=..2,nbt={data:{zx:{ch:{u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}}}}] zx.ch_beam 1
