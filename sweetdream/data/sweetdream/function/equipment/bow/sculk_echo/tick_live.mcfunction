# ============================================================
# sweetdream:equipment/bow/sculk_echo/tick_live —— 幽匿残响: 发射路径周围 2 格每刻伤
# ------------------------------------------------------------
# 【谁调它】core/tick: 对场上所有带 zx.se_live 的箭每刻跑一次。
# 【执行者】那支箭(由 core/tick 用 as @e[tag=zx.se_live] 调)
# 【文案】对发射路径周围 2 格的敌人每刻造成「悲鸣」×0.1 的伤害。
# 【数据来源】箭自己身上 data.zx.se.path_dmg / cry / u0..u3(逐箭快照)。
# 【★ 什么时候不再算(2026-10-05 改) ★】
#   ① 命中生物:  hook_victim 会摘掉 zx.se_live(见那边)。
#   ② **射到地上**: 箭一旦插住(inGround:1b)就摘掉 —— 落地后不再生效(用户要求)。
#      用 inGround 判(原版箭插进方块后这个字段变 1b), 比看 Motion 稳。
#   ③ 兜底: 箭自带倒计时(30 秒 = 600 tick), 到点也摘(射进虚空/一直飞时用)。
#   【为什么不用 schedule】同名 schedule 全局一个槽会互相顶掉(RULES 坑 8)。
# 【范围怎么圈】以箭为中心 2 格(判定箱相交, 边长 5)。
# 【概率三倍】同 fire: 每刻对范围内每只单独判定(悲鸣值 = 1% 概率)。
# 【★ 路径粒子: 坚守者的远程攻击粒子 ★】用户在箭的飞行路径上要「坚守者发射远程攻击」
#   的那个粒子 —— 就是 minecraft:sonic_boom(warden 的声波)。每刻沿箭画一颗。
# ============================================================

# ⓪ 箭插到地上(inGround) -> 立刻摘标签, 落地后不再生效
execute if entity @s[nbt={inGround:1b}] run tag @s remove zx.se_live
execute unless entity @s[tag=zx.se_live] run return 0

# ① 倒计时(箭自带 zx.se_t, 没有就从 600 起)
scoreboard players add @s zx.se_t 0
execute if score @s zx.se_t matches 0 run scoreboard players set @s zx.se_t 600
scoreboard players remove @s zx.se_t 1
execute if score @s zx.se_t matches ..0 run tag @s remove zx.se_live

# ② 数据齐不齐
execute unless data entity @s data.zx.se{ok:1b} run return 0
execute unless entity @s[tag=zx.se_live] run return 0

# ②.5 路径粒子: 坚守者的远程攻击粒子(声波), 沿箭飞行的每刻画一颗
particle minecraft:sonic_boom ~ ~ ~ 0.0 0.0 0.0 0.0 1 normal

# ③ 伤害值(×100 定点)
scoreboard players set #se_pdmg zx.meta 0
execute store result score #se_pdmg zx.meta run data get entity @s data.zx.se.path_dmg 100
execute if score #se_pdmg zx.meta matches ..0 run return 0
scoreboard players set #se_pcry zx.meta 0
execute store result score #se_pcry zx.meta run data get entity @s data.zx.se.cry

# ④ 圈范围: 以箭为中心 2 格(超限版 3 格 —— 半径写死在选择器里, 只能分两条)
# 【★ 要 distance=0.. ★】se_path 是本刻在这个维度里现打的临时标记, 清理也锁在这个维度。
# 【ol 从哪来】箭自带的逐箭快照 data.zx.se.ol(离弦时拍的); 读不到就当基础版。
scoreboard players set #se_ol zx.meta 0
execute store result score #se_ol zx.meta run data get entity @s data.zx.se.ol 1
tag @e[distance=0..,tag=zx.se_path] remove zx.se_path
execute if score #se_ol zx.meta matches 0 at @s positioned ~-2.5 ~-2.5 ~-2.5 run tag @e[type=!#sweetdream:no_damage,dx=5.0,dy=5.0,dz=5.0] add zx.se_path
execute if score #se_ol zx.meta matches 1 at @s positioned ~-3.5 ~-3.5 ~-3.5 run tag @e[type=!#sweetdream:no_damage,dx=7.0,dy=7.0,dz=7.0] add zx.se_path

# ⑤ 打伤害(带射手归属; 三倍按每刻一次统一 roll)
function sweetdream:equipment/bow/sculk_echo/path_roll
data modify storage zx:work a set value {target:"@e[tag=zx.se_path]",damage:0.0,type:"minecraft:player_attack",u0:0,u1:0,u2:0,u3:0}
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
execute store result storage zx:work a.damage double 0.01 run scoreboard players get #se_pdmg zx.meta
execute store result storage zx:work a.u0 int 1 run data get entity @s data.zx.se.u0
execute store result storage zx:work a.u1 int 1 run data get entity @s data.zx.se.u1
execute store result storage zx:work a.u2 int 1 run data get entity @s data.zx.se.u2
execute store result storage zx:work a.u3 int 1 run data get entity @s data.zx.se.u3
data modify storage zx:work a.num set from storage zx:work a.damage
function sweetdream:lib/num/plain
function sweetdream:internal/damage/with_from with storage zx:work a

# ⑥ 表现: 箭周围幽匿粒子(每刻少量, 不刷屏)
particle minecraft:sculk_charge{roll:0.0} ~ ~ ~ 2.0 0.6 2.0 0.0 1 normal

# ⑦ 收尾
# 【★ 同样要 distance=0.. ★】(注意: 上面 ⑤ 那一句里的 "@e[tag=zx.se_path]" 是写进 storage
#   的**字符串**, 由 lib 那边当选择器用, 不加 distance —— 两处别搞混)
tag @e[distance=0..,tag=zx.se_path] remove zx.se_path
