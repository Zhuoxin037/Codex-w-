# ============================================================
# sweetdream:equipment/staff/sail/mask_build —— 把 zx.sl_mask 展开成"属性码列表"
# ------------------------------------------------------------
# 【谁调用它】sail/skill 第 ⑨ 步; 【执行者】施法玩家
# 【做什么】读玩家身上 zx.sl_mask(位掩码), 往 zx:work sl.m 里吐一串"属性码":
#   1 = 渊海 / 2 = 流火 / 3 = 白昼梦 / 4 = 噬心
#   同时把条数记进 #sl_n zx.meta(旋风每次脉冲从这串里随机挑一个)。
# 【为什么展开成列表】"随机一种"要求**在已有的那几种里**等概率挑;
#   直接对 4 种里瞎挑会让"只有 1 种的生物"概率错误(挑到没有的就白触发)。
# ============================================================

scoreboard players set #sl_n zx.meta 0
scoreboard players operation #sl_b zx.meta = @s zx.sl_mask

# bit0 -> 渊海(码 1)
scoreboard players operation #sl_c zx.meta = #sl_b zx.meta
scoreboard players operation #sl_c zx.meta %= #2 zx.meta
execute if score #sl_c zx.meta matches 1 run data modify storage zx:work sl.m append value 1
execute if score #sl_c zx.meta matches 1 run scoreboard players add #sl_n zx.meta 1
scoreboard players operation #sl_b zx.meta /= #2 zx.meta

# bit1 -> 流火(码 2)
scoreboard players operation #sl_c zx.meta = #sl_b zx.meta
scoreboard players operation #sl_c zx.meta %= #2 zx.meta
execute if score #sl_c zx.meta matches 1 run data modify storage zx:work sl.m append value 2
execute if score #sl_c zx.meta matches 1 run scoreboard players add #sl_n zx.meta 1
scoreboard players operation #sl_b zx.meta /= #2 zx.meta

# bit2 -> 白昼梦(码 3)
scoreboard players operation #sl_c zx.meta = #sl_b zx.meta
scoreboard players operation #sl_c zx.meta %= #2 zx.meta
execute if score #sl_c zx.meta matches 1 run data modify storage zx:work sl.m append value 3
execute if score #sl_c zx.meta matches 1 run scoreboard players add #sl_n zx.meta 1
scoreboard players operation #sl_b zx.meta /= #2 zx.meta

# bit3 -> 噬心(码 4)
scoreboard players operation #sl_c zx.meta = #sl_b zx.meta
scoreboard players operation #sl_c zx.meta %= #2 zx.meta
execute if score #sl_c zx.meta matches 1 run data modify storage zx:work sl.m append value 4
execute if score #sl_c zx.meta matches 1 run scoreboard players add #sl_n zx.meta 1
