# ============================================================
# sweetdream:equipment/armor/heart_vein/pump_tick —— 「泵动」每刻
# ------------------------------------------------------------
# 【谁调用它】core/tick 三维度: `as @e[tag=zx.hv_pump,distance=0..] at @s run …`
# 【执行者】带「泵动」的那只生物
# 【文案】"附有「泵动」的生物每移动一格都会使其受到一次相当于其最大生命值 ×0.05
#   的伤害，之后使其获得 1 秒缓慢Ⅳ效果。"
# 【★ 为什么不复用 lib/step ★】lib/step 是**玩家位移技能**的判据（窗口/续期/
#   撒点全耦合在里面, 且只服务踏灰・雨迹）。泵动要的是"**每只生物**逐刻比位移",
#   独立写一份更短也更可控。
# 【★ 0.5 秒闸门（设计稿补的边界, 必加）★】不加的话一只被击退 / 高速冲撞的怪
#   一秒能触发十几次, 而伤害按**最大生命比例**结算 ⇒ Boss 会被瞬间打穿。
# 【★ 位移判据 = 与"上一次结算时的锚点"比, 不是与上一刻比 ★】
#   与上一刻比的话, 走得慢的怪永远凑不满一格（一秒 20 刻 × 0.04 格 = 0.8 格）,
#   走得快的又会每刻都触发 —— 语义就变成"速度税"而不是"移动税"了。
# 【三轴钳位】|d| ≤ 30000 ⇒ 三轴平方和 ≤ 2.7e9 … 只两轴已经 1.8e9, 三轴会超
#   INT32_MAX ⇒ 这里**每轴先夹 20000**（200² ×3 = 1.2e9 < 2^31）。
# ============================================================

# ① 倒计时: 到点收工（摘标签 + 清分数）
scoreboard players remove @s zx.hv_t 1
execute if score @s zx.hv_t matches ..0 run return run function sweetdream:equipment/armor/heart_vein/pump_end

# ② 闸门倒数（0.5 秒 = 10 刻）
scoreboard players remove @s zx.hv_gate 1

# ③ 当前坐标（×100）
execute store result score #hv_cx zx.meta run data get entity @s Pos[0] 100
execute store result score #hv_cy zx.meta run data get entity @s Pos[1] 100
execute store result score #hv_cz zx.meta run data get entity @s Pos[2] 100

# ④ 与锚点的差值 + 钳位
scoreboard players operation #hv_dx zx.meta = #hv_cx zx.meta
scoreboard players operation #hv_dx zx.meta -= @s zx.hv_px
scoreboard players operation #hv_dy zx.meta = #hv_cy zx.meta
scoreboard players operation #hv_dy zx.meta -= @s zx.hv_py
scoreboard players operation #hv_dz zx.meta = #hv_cz zx.meta
scoreboard players operation #hv_dz zx.meta -= @s zx.hv_pz
execute if score #hv_dx zx.meta matches 20000.. run scoreboard players set #hv_dx zx.meta 20000
execute if score #hv_dx zx.meta matches ..-20000 run scoreboard players set #hv_dx zx.meta -20000
execute if score #hv_dy zx.meta matches 20000.. run scoreboard players set #hv_dy zx.meta 20000
execute if score #hv_dy zx.meta matches ..-20000 run scoreboard players set #hv_dy zx.meta -20000
execute if score #hv_dz zx.meta matches 20000.. run scoreboard players set #hv_dz zx.meta 20000
execute if score #hv_dz zx.meta matches ..-20000 run scoreboard players set #hv_dz zx.meta -20000

# ⑤ 平方和（1 格 = 100 ⇒ 阈值 100² = 10000）
scoreboard players operation #hv_d zx.meta = #hv_dx zx.meta
scoreboard players operation #hv_d zx.meta *= #hv_dx zx.meta
scoreboard players operation #hv_dt zx.meta = #hv_dy zx.meta
scoreboard players operation #hv_dt zx.meta *= #hv_dy zx.meta
scoreboard players operation #hv_d zx.meta += #hv_dt zx.meta
scoreboard players operation #hv_dt zx.meta = #hv_dz zx.meta
scoreboard players operation #hv_dt zx.meta *= #hv_dz zx.meta
scoreboard players operation #hv_d zx.meta += #hv_dt zx.meta

# ⑥ 移动满一格 且 闸门已开 ⇒ 结算一次
execute if score #hv_d zx.meta matches 10000.. unless score @s zx.hv_gate matches 1.. run function sweetdream:equipment/armor/heart_vein/pump_step
