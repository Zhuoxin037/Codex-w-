# ============================================================
# sweetdream:equipment/armor/glimmer/clear —— 失去全部光效
# ------------------------------------------------------------
# 【执行者】玩家(@s)
# 【★ 文案(逐字) ★】"自身生命值减少后则失去全部光效。"
#   ★★ 是**全部**, 不是"碎一道" ★★ —— 上一版(碎光/棱镜残片)是我自编的, 已作废。
# 【三件事】① 三色归零; ② 摘掉自身的移速 modifier; ③ 8 秒计时从这一刻重算。
# 【★ "挂过才摘" ★】remove 一个不存在的 modifier 会**失败并截断整行所在函数**,
#   所以必须先看账本 zx.gl_spd（0=没挂 / 1=+20% / 2=+30%）。
#   敌人身上的减速不在这里摘 —— 它们靠 zx.gl_slt 倒计时自己到期（见 foe_slow）。
# ============================================================

# ① 三色全清
scoreboard players set @s zx.gl_r 0
scoreboard players set @s zx.gl_g 0
scoreboard players set @s zx.gl_y 0

# ② 摘自身移速加成
execute if score @s zx.gl_spd matches 1.. run attribute @s minecraft:movement_speed modifier remove sweetdream:gl_spd
scoreboard players set @s zx.gl_spd 0

# ③ 重新起算 8 秒
scoreboard players operation @s zx.gl_lh = #now manacore.meta

# ④ 表现：光片碎散
particle minecraft:end_rod ~ ~1.2 ~ 0.6 0.6 0.6 0.08 14
particle minecraft:dust{color:[0.8,0.8,0.9],scale:1.4} ~ ~1.2 ~ 0.5 0.5 0.5 0.03 18
playsound minecraft:block.glass.break player @s ~ ~ ~ 0.6 1.4

scoreboard players set @s zx.gl_wt 0
scoreboard players set @s zx.gl_cd 0
scoreboard players set @s zx.gl_hacc 0
