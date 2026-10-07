# ============================================================
# sweetdream:equipment/staff/chime/second —— 共鸣的每秒入口
# ------------------------------------------------------------
# 【谁调用它】挂在 #manacore:event/second 上(前置包每秒抛一次, 服务器身份)
# 【内容】
#   · 每颗"共鸣水晶": 8 秒到期 -> 自毁(crystal_end)
#   · 每颗"共鸣水晶": #now 为偶数秒时打一发(crystal_tick) —— = 文案的"每 2 秒"
# 【为什么用 #now % 2 而不是各自计时】所有水晶同拍打, 和朽木(wood_tick)同款,
#   简单够用; 要各自错拍就得再给每颗水晶一个计时器, 没必要。
# 【★ 裸 @e 在这里是安全的】event/second 每秒只跑一次(不是"每维度各跑一次"),
#   裸 @e 会跨维度搜索, 每颗水晶恰好被处理一次。
# ============================================================

function sweetdream:lib/in_bak

# ① 8 秒到期 -> 自毁(★ at @s 不能省: crystal_end 的粒子要用水晶坐标)
execute as @e[tag=zx.ch_cry] at @s if score @s zx.ch_end <= #now manacore.meta run function sweetdream:equipment/staff/chime/crystal_end

# ② 每 2 秒 -> 每颗水晶打一发
scoreboard players operation #ch_par zx.meta = #now manacore.meta
scoreboard players operation #ch_par zx.meta %= #2 zx.meta
execute if score #ch_par zx.meta matches 0 run execute as @e[tag=zx.ch_cry] at @s run function sweetdream:equipment/staff/chime/crystal_tick

function sweetdream:lib/in_restore
