# ============================================================
# sweetdream:equipment/staff/sail/mark_pick —— 从属性码列表里随机挑一个并附加
# ------------------------------------------------------------
# 【谁调用它】whirl_pulse 第 ② 步; 【执行者/位置】旋风 marker
# 【入参】#sl_n zx.meta = 列表长度(调用方已保证 >= 1)
# 【做什么】#rnd % n 得下标 -> 取 data.zx.sl.m[下标] 的属性码 -> 翻成标记名 ->
#   对 5 格内生物(whirl_pulse 已圈好的 zx.sl_area)走统一入口 tag/mark。
# 【属性码】1 = 渊海 / 2 = 流火 / 3 = 白昼梦 / 4 = 噬心
# ============================================================

function sweetdream:lib/rnd
scoreboard players operation #sl_i zx.meta = #rnd zx.meta
scoreboard players operation #sl_i zx.meta %= #sl_n zx.meta

# ① 按下标取出属性码(等价于"在已有的那几种里等概率挑一个")
scoreboard players set #sl_m zx.meta 0
execute if score #sl_i zx.meta matches 0 run execute store result score #sl_m zx.meta run data get entity @s data.zx.sl.m[0]
execute if score #sl_i zx.meta matches 1 run execute store result score #sl_m zx.meta run data get entity @s data.zx.sl.m[1]
execute if score #sl_i zx.meta matches 2 run execute store result score #sl_m zx.meta run data get entity @s data.zx.sl.m[2]
execute if score #sl_i zx.meta matches 3 run execute store result score #sl_m zx.meta run data get entity @s data.zx.sl.m[3]

# ①-b 记在本旋风身上: 旋风的颜色要跟着"最近一次附着了什么"走(见 whirl_fx)
scoreboard players operation @s zx.sl_m = #sl_m zx.meta

# ② 属性码 -> 标记名
execute if score #sl_m zx.meta matches 1 run data modify storage zx:work ic.mark set value "yuanhai"
execute if score #sl_m zx.meta matches 2 run data modify storage zx:work ic.mark set value "liuhuo"
execute if score #sl_m zx.meta matches 3 run data modify storage zx:work ic.mark set value "dream"
execute if score #sl_m zx.meta matches 4 run data modify storage zx:work ic.mark set value "shixin"

# ③ 附加给 5 格内的生物(走统一入口; 会刷新租约 + 头顶图标)
data modify storage zx:work ic.target set value "@e[tag=zx.sl_area]"
function sweetdream:tag/mark with storage zx:work ic
