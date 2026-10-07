# ============================================================
# sweetdream:equipment/staff/chime/pass_set —— "法术穿过"判定 + 结算(宏)
# ------------------------------------------------------------
# 【宏参数】u0..u3(释放者 UUID 四 int)   【执行者】水晶 marker   【位置】水晶处
# 【判据】水晶 1.5 格内存在一颗 **释放者自己的、还没触发过** 的法球:
#   · "自己人的" = 球的 data.u0..u3 与释放者一致;
#   · "还没触发过" = 球不带 zx.ch_pass(每颗球对每颗水晶只触发一次)。
#   ★ 为什么给球打戳而不是 kill 球: 球还要继续飞、还要打它自己的命中伤害,
#     这里只是"穿过水晶"的附加效果, 不能把球收掉。
# 【★ 位置口径 ★】本函数由 pass_check 在"as 水晶 at @s"的链上调用 —— 坐标 = 水晶。
#   所以这里所有 distance=..1.5 / ..3 的圆心都是水晶, 不用再 at 一次。
# 【★ 为什么先把 3 格内生物圈成标签再结算 ★】被调函数 pass_go 是在
#   "as 释放者" 的链上跑的(坐标会被保留, 但 check 规则 asnoat 看不出这一点),
#   所以让它按**标签**取目标(不与坐标相关), 就不会被误判/真判错。
# ============================================================

# ① 真有自己人的法球进来时, 才重圈"水晶 3 格内全部生物"
$execute if entity @e[tag=zx.ball,distance=..1.5,nbt={data:{u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}},tag=!zx.ch_pass] run tag @e[tag=zx.ch_p] remove zx.ch_p
$execute if entity @e[tag=zx.ball,distance=..1.5,nbt={data:{u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}},tag=!zx.ch_pass] run tag @e[type=!#sweetdream:no_damage,distance=..3] add zx.ch_p

# ② 给那颗球打"已触发"戳(每颗球对每颗水晶只触发一次)
$execute as @e[tag=zx.ball,distance=..1.5,nbt={data:{u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}},tag=!zx.ch_pass] run tag @s add zx.ch_pass

# ③ 反查释放者, 交给他结算(执行者=玩家 -> 归属正确)
$execute as @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] if entity @e[tag=zx.ch_p,limit=1] run function sweetdream:equipment/staff/chime/pass_go

# ④ 表现(水晶被法术激发的环; 执行者/坐标仍是水晶)
execute if entity @e[tag=zx.ch_p,limit=1] run particle minecraft:enchant ~ ~0.6 ~ 0.6 0.6 0.6 0.4 24 normal
execute if entity @e[tag=zx.ch_p,limit=1] run particle minecraft:end_rod ~ ~0.6 ~ 0.8 0.8 0.8 0.02 16 normal
execute if entity @e[tag=zx.ch_p,limit=1] run playsound minecraft:block.amethyst_block.resonate player @a ~ ~ ~ 0.7 1.5
