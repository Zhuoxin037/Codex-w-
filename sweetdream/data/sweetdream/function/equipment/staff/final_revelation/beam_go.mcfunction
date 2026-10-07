# ============================================================
# sweetdream:equipment/staff/final_revelation/beam_go —— 光柱每刻的跟随/续命/生成
# ------------------------------------------------------------
# 【宏参数】zx:work fu {u0,u1,u2,u3} = 施法玩家的 UUID 四 int(beam 外壳备好)
# 【执行者】施法玩家(beam 外壳原样传下来)
# 【SEL】"我的那根光柱" = item_display + tag zx.fr_beam + data.zx.fr 的 UUID 四 int
#   与我匹配(宏把数字拼进 nbt, 只能宏)。
# ============================================================

# ① 跟随: tp 到「眼睛下 0.45、前方 8 格」并继承玩家朝向(光条以此为 16 格的中点)
$execute at @s anchored eyes positioned ^ ^-0.45 ^8 run tp @e[type=item_display,tag=zx.fr_beam,distance=0..,nbt={data:{zx:{fr:{u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}}}},limit=1] ~ ~ ~ ~ ~

# ② 续命: 3 刻内没人续就自杀(core/tick 每刻 -1)
$execute at @s run scoreboard players set @e[type=item_display,tag=zx.fr_beam,distance=0..,nbt={data:{zx:{fr:{u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}}}},limit=1] zx.fr_ref 3

# ③ 我还没有光柱 -> 生成
$execute unless entity @e[type=item_display,tag=zx.fr_beam,distance=0..,nbt={data:{zx:{fr:{u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}}}},limit=1] run function sweetdream:equipment/staff/final_revelation/beam_new

# ④ 装饰: 沿光条撒极稀疏的余晖(每刻每点 1 颗, 约 3 颗/刻)。
#    ① 用同一个 ^-0.45 偏移 —— 落在光条轴线上会被摄像机投影成"看不见", 见坑 69。
#    ② 只做观感, 判定/伤害都不在这里(scan/tick 负责), 全删了机制也照常跑。
execute at @s anchored eyes positioned ^ ^-0.45 ^4 run particle minecraft:end_rod ~ ~ ~ 0.20 0.20 0.20 0.0 1 normal
execute at @s anchored eyes positioned ^ ^-0.45 ^8 run particle minecraft:end_rod ~ ~ ~ 0.20 0.20 0.20 0.0 1 normal
execute at @s anchored eyes positioned ^ ^-0.45 ^12 run particle minecraft:end_rod ~ ~ ~ 0.20 0.20 0.20 0.0 1 normal
