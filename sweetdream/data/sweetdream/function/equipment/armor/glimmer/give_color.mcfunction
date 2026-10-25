# ============================================================
# sweetdream:equipment/armor/glimmer/give_color —— 随机获得一种光效
# ------------------------------------------------------------
# 【执行者】玩家(@s)
# 【★ 文案(逐字) ★】"自身若 8 秒内没有受到伤害则自身**随机**获得一种光效。"
#   ★★ 是**随机**, 不是"优先补齐缺色" ★★
#   2026-10-25 我上一版擅自改成"优先补齐"被用户否掉 —— 别再改回去。
#   随机源走 lib/rnd（自走 LCG, 与攻击节奏/坐标都脱钩）, 不是 `#gl_seq`, 因为
#   发牌间隔恒为 160 刻, 而 160 % 3 = 1 ⇒ 取模会退化成"必定轮转", 不是随机。
# 【重复怎么办】原文没说不能重复。已拥有该色 ⇒ 等于没拿到新颜色（不叠层）。
#   三色齐了（白）之后不再发牌。
# 【★ 三色 = 三个计分项, 各 0/1 ★】白 = 三个都 1。不另设"白光"状态位 ——
#   少一个状态就少一处不同步。
# ============================================================

function sweetdream:equipment/armor/glimmer/maintain

# ① 已经是白（三色齐）⇒ 不再发
execute if score @s zx.gl_r matches 1.. if score @s zx.gl_g matches 1.. if score @s zx.gl_y matches 1.. run return 0

# ② 抽 0/1/2
function sweetdream:lib/rnd
scoreboard players operation #gl_pick zx.meta = #rnd zx.meta
scoreboard players operation #gl_pick zx.meta %= #3 zx.meta

# ③ 发牌
execute if score #gl_pick zx.meta matches 0 run scoreboard players set @s zx.gl_r 1
execute if score #gl_pick zx.meta matches 1 run scoreboard players set @s zx.gl_g 1
execute if score #gl_pick zx.meta matches 2 run scoreboard players set @s zx.gl_y 1

# ④ 下一道从"现在"重新起算 8 秒
scoreboard players operation @s zx.gl_lh = #now manacore.meta

# ⑤ 表现
execute if score #gl_pick zx.meta matches 0 run particle minecraft:dust{color:[1.0,0.2,0.2],scale:1.2} ~ ~1.2 ~ 0.4 0.4 0.4 0.02 16
execute if score #gl_pick zx.meta matches 1 run particle minecraft:dust{color:[0.3,1.0,0.4],scale:1.2} ~ ~1.2 ~ 0.4 0.4 0.4 0.02 16
execute if score #gl_pick zx.meta matches 2 run particle minecraft:dust{color:[1.0,0.9,0.3],scale:1.2} ~ ~1.2 ~ 0.4 0.4 0.4 0.02 16
playsound minecraft:block.amethyst_block.chime player @s ~ ~ ~ 0.5 1.6

execute if score @s zx.gl_r matches 1 if score @s zx.gl_g matches 1 if score @s zx.gl_y matches 1 run function sweetdream:equipment/armor/glimmer/white_start
