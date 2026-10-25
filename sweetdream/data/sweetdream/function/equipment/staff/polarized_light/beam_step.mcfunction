# ============================================================
# sweetdream:equipment/staff/polarized_light/beam_step —— 光线的一步
# ------------------------------------------------------------
# 【执行者】施法玩家
# 【位置】当前走到的那一点
# 【朝向】由 beam 入口的 `facing entity <目标> eyes` 定死; 递归里**不再改向**
#   -> 每一步都沿同一条直线(同 bow/cold_crow/step 的"positioned 递归")。
# 【每一步做三件事】
#   ① 撒光点(亮核 + 一点电弧) —— 这就是"那道光线"
#   ② 照到"自己人的共鸣水晶"就给它打 zx.ch_beam 戳(共鸣每刻读 -> 触发)
#   ③ 还没到目标就再沿朝向走 0.4 格, 递归
# 【步数上限 32】0.4 × 32 = 12.8 格 —— 覆盖超限版的 12 格锁定(基础 10 格用不满);
#   没有上限时, 一旦朝向/目标异常就会一直调下去, 把该刻的命令预算
#   (65536)打满 -> 同刻后面的函数整段不跑("stopped due to limit")。
# 【"到达"判据 = zx.pl_cur】基础版在 beam ④ 打、超限版在 beam_one ① 打 ——
#   三道光版里锁定目标有 3 个, 判"哪一个到了"必须用本条自己的目标, 不能用全体。
#   ★ 判"到了"用**判定箱相交(dx/dy/dz)**, 不是 distance —— 原因见 ④ 的长注释。
# ============================================================
# 【★★ 2026-10-20 第二次卡顿修复: 本文件已**不再是宏函数** ★★】
#   原来 ② 是 `$execute as @e[…,nbt={data:{zx:{ch:{u0:$(u0)…}}}}] …`,
#   为了拼这个 NBT 选择器, 整个文件必须带宏参数、被 `with storage` 调用。
#   后果 = 每**步**一次宏调用(读 storage + 整份函数体占位符替换 + 逐行重新
#   解析命令), 一道光 25~32 步、超限三道 ≈ 90 次/刻。
#   现在 ② 只按 cry_scan 打好的计分项 zx.ch_mine 筛, 不再需要宏:
#     · 普通 function 递归 = 压栈, 函数体早已解析好;
#     · 调用方(beam / beam_one)的 `with storage zx:work pb` 也一并删掉了。
#   ★ 再加 #pl_has 闸门: 没放水晶时(绝大多数战斗)② 整行不执行。
# ============================================================

# ① 光点
particle minecraft:end_rod ~ ~ ~ 0.03 0.03 0.03 0.0 1 normal
particle minecraft:electric_spark ~ ~ ~ 0.06 0.06 0.06 0.01 1 normal

# ② 照射: 这一点 0.6 格内有"自己人的"共鸣水晶 -> 打"被光束照到"戳
#    zx.ch_mine 由 cry_scan 在**每束光开头**标好(计分项, 不碰实体 NBT);
#    #pl_has=0 时整行不跑 —— 这是本轮最大的提速点之一。
execute if score #pl_has zx.meta matches 1 run execute as @e[type=minecraft:marker,scores={zx.ch_mine=1},distance=..0.6] run scoreboard players set @s zx.ch_beam 1

# ③ 步数 +1; 到上限强制收工
scoreboard players add #pl_st zx.meta 1
execute if score #pl_st zx.meta matches 32.. run return 0

# ④ 已经够到本条目标了 -> 停
#   ★★ 这里**不能用 distance** ★★ 光线是沿"眼睛 → 目标**眼睛**"的斜线走的。走到目标
#     头上那一点时, 离它的实体坐标(脚底)还差整整一个眼高(≈1.6 格) ⇒ `distance=..0.5`
#     **永远不成立** ⇒ 递归一路走到步数上限(32 步 = 12.8 格)才停, 玩家看到的就是
#     **光束越过生物继续往前飞**(2026-10-10 用户反馈"会越过生物, 很违和")。
#   ★ 对照先例: bow/arc/wire 敢用 distance, 是因为它 `facing … **feet**`(瞄脚底);
#     bow/cold_crow/step 用的是**判定箱相交**(dx/dy/dz) —— 这一处原本两者都没照上。
#   ★ 改法和 cold_crow/step 同一套: 以这一步为中心开判定箱, 与生物的碰撞箱相交 =
#     够到。竖直给 1.6(收到的是目标**眼睛**高度, 宽一点保证矮个子也盖得到), 水平 1.0
#     —— 步距 0.4, 光点会落在离生物表面 ≤0.5 格处收住: 既不提前截断, 也不会穿过去。
execute positioned ~-0.5 ~-0.8 ~-0.5 if entity @e[scores={zx.pl_cur=1},dx=1.0,dy=1.6,dz=1.0,limit=1] run return 0

# ⑤ 沿同一朝向再走 0.4 格, 递归(普通调用 —— 本函数已无宏参数)
execute positioned ^ ^ ^0.4 run function sweetdream:equipment/staff/polarized_light/beam_step
