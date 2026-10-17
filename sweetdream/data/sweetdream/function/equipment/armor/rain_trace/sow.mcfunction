# ============================================================
# sweetdream:equipment/armor/rain_trace/sow —— 雨迹：在脚下撒**一个**水迹点
# ------------------------------------------------------------
# 【谁调用它】① lib/step ①（位移已确认，每刻一次）
#             ② step_moved（刚确认位移的那一刻立刻补一次，起手不延迟）
#             ③ step_finish（窗口到期再补一次，收尾那一步不丢）
# 【执行者】玩家
# 【技能原文（lore 逐字）】
#   "自身魔力值上限 +50。自身主动技能完成实际位移后，在位移过的地方留下持续 5 秒
#    的水迹。之后对在水迹处持续停留 2 秒的生物附加「渊海」，并使其受到一次相当于
#    释放者基础攻击力 ×2 的伤害。"
#
# 【★ 2026-10-17 重写：为什么从"插值撒 5 点"改成"逐刻就地撒 1 点" ★】
#   旧版每 5 刻用"上一段末端 → 当刻位置"插值出 5 个点。用户实测无息只覆盖前 3 格，
#   根因是这条链路对"段内掉头"完全无解：无息是"去 8 格再闪回"，插值段的两个端点
#   一个在去程、一个在回程，撒出来的点会横穿场地；再加上 5 刻节流一旦错位就整段丢。
#   逐刻就地撒就没有这个问题 —— 玩家每一步都在自己脚下留点，轨迹天然正确。
#
# 【距离判据 0.45 格（45）】为什么要这个而不是每刻都撒：
#   · 站着不动 / 被卡住时不该无限堆点（5 秒内最多 100 个实体）；
#   · 无息去程每刻 0.5 格 > 0.45 ⇒ 每刻都撒，水迹连成带；
#   · 无息回程每刻 2 格 ⇒ 也每刻都撒（相邻点 2 格，判定半径 1.6 仍连得上）；
#   · 正常走路（每秒 4.3 格 ≈ 每刻 0.2 格）放完技能会走得慢，靠 0.45 抽稀。
#   竖直阈值单独放宽到 0.6 格：上下台阶/跳一下不该额外堆点。
#
# 【★ 水迹本体是 item_display（不是 marker）★】
#   用户反馈"看不见，不知道有没有成功" ⇒ 现在每个点是带自定义模型的水洼
#   （资源包 sweetdream:rain_puddle），平铺贴地、5 秒后自毁。
#   逻辑判定仍然只看 `@e[tag=zx.rt_dot,distance=..1.6]`，和显示无关。
# ============================================================

# ① 穿着门控（本函数每刻都会被调用，没穿就立刻退出）
execute unless items entity @s armor.feet *[minecraft:custom_data~{zx:["rain_trace"]}] run return 0

# ② 当前坐标（×100，与 rt_lx/ly/lz 同一单位）
execute store result score #rt_x zx.meta run data get entity @s Pos[0] 100
execute store result score #rt_y zx.meta run data get entity @s Pos[1] 100
execute store result score #rt_z zx.meta run data get entity @s Pos[2] 100

# ③ 距离判据：任一轴离"上一个水迹点"≥ 0.45 格（竖直 0.6）才撒
#   ★ 任一轴成立即可 —— 斜着走时两轴各 0.3 格、合起来 0.42 格也会被算作"挪了"，
#     水迹只会更密一点，不会有"该撒没撒"的洞（宁可密不可漏）。
scoreboard players set #rt_ok zx.meta 0
scoreboard players operation #rt_d zx.meta = #rt_x zx.meta
scoreboard players operation #rt_d zx.meta -= @s zx.rt_lx
execute if score #rt_d zx.meta matches 45.. run scoreboard players set #rt_ok zx.meta 1
execute if score #rt_d zx.meta matches ..-45 run scoreboard players set #rt_ok zx.meta 1
scoreboard players operation #rt_d zx.meta = #rt_z zx.meta
scoreboard players operation #rt_d zx.meta -= @s zx.rt_lz
execute if score #rt_d zx.meta matches 45.. run scoreboard players set #rt_ok zx.meta 1
execute if score #rt_d zx.meta matches ..-45 run scoreboard players set #rt_ok zx.meta 1
scoreboard players operation #rt_d zx.meta = #rt_y zx.meta
scoreboard players operation #rt_d zx.meta -= @s zx.rt_ly
execute if score #rt_d zx.meta matches 60.. run scoreboard players set #rt_ok zx.meta 1
execute if score #rt_d zx.meta matches ..-60 run scoreboard players set #rt_ok zx.meta 1
execute unless score #rt_ok zx.meta matches 1 run return 0

# ④ 伤害值 = 释放者基础攻击力 ×2（×100 单位算，落 storage 时转 double）
#   ★ 每个点都现算一次 ★ 文案是"相当于释放者基础攻击力 ×2"，按"踩到它的那一刻"
#     的释放者属性结算更符合直觉；每个点都是独立的，谁踩到都吃自己那份数值。
execute store result score #rt_dmg zx.meta run attribute @s minecraft:attack_damage get 100
scoreboard players set #rt_x2 zx.meta 2
scoreboard players operation #rt_dmg zx.meta *= #rt_x2 zx.meta

# ⑤ 水迹模板（所有权 + 伤害）—— dot_spawn 的宏参数
data modify storage zx:rain dot set value {dmg:0.0d,u0:0,u1:0,u2:0,u3:0}
execute store result storage zx:rain dot.dmg double 0.01 run scoreboard players get #rt_dmg zx.meta
data modify storage zx:rain dot.u0 set from entity @s UUID[0]
data modify storage zx:rain dot.u1 set from entity @s UUID[1]
data modify storage zx:rain dot.u2 set from entity @s UUID[2]
data modify storage zx:rain dot.u3 set from entity @s UUID[3]

# ⑥ 在脚下生成一个水迹点（执行位置仍是玩家自己，见 dot_spawn 的说明）
function sweetdream:equipment/armor/rain_trace/dot_spawn with storage zx:rain dot

# ⑦ 记账：上一个水迹点 = 当前坐标（下一次距离判据的基准）
scoreboard players operation @s zx.rt_lx = #rt_x zx.meta
scoreboard players operation @s zx.rt_ly = #rt_y zx.meta
scoreboard players operation @s zx.rt_lz = #rt_z zx.meta
