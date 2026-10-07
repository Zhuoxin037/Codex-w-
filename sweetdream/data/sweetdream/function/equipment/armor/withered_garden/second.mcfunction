# ============================================================
# sweetdream:equipment/armor/withered_garden/second —— 枯枝园的每秒入口
# ------------------------------------------------------------
# 【谁调用它】挂在 #manacore:event/second 上(前置包每秒抛一次, 全局身份)
# 【内容】
#   · 每个玩家: 被动(魔力上限账本 + 抗性提升) —— 见 passive 头注释
#   · #now 为偶数秒时: 每只朽木跑一次 wood_tick(每 2 秒的 AoE)
# 【朽木的节拍用全局 #now % 2】所有朽木同拍打, 简单够用;
#   要各自错拍就得给每只朽木再开一个计时器, 没必要。
# ============================================================

function sweetdream:lib/in_bak

execute as @a at @s run function sweetdream:equipment/armor/withered_garden/passive

# 朽木的每 2 秒(#now 为偶数 → 每两秒轮到一次; 执行者 = 朽木本体)
scoreboard players operation #par zx.meta = #now manacore.meta
scoreboard players operation #par zx.meta %= #2 zx.meta
execute if score #par zx.meta matches 0 run execute as @e[tag=zx.gw_wood] at @s run function sweetdream:equipment/armor/withered_garden/wood_tick

function sweetdream:lib/in_restore
