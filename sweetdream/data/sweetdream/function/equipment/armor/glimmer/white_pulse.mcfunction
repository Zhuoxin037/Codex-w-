# ============================================================
# sweetdream:equipment/armor/glimmer/white_pulse —— 白：每 3 秒的群体「白昼梦」
# ------------------------------------------------------------
# 【执行者】玩家(@s)（已确认白色状态 = 三色齐）
# 【★ 文案(逐字) ★】"……每 3 秒对自身 5 格内的随机 4 个生物附加「白昼梦」
#   并使其时停 1 秒。"
# 【★ 3 秒 = 60 刻, 节流记"下次可触发的时刻" ★】不用每刻 -1 的倒计时:
#   那要多一个计分项 + 每刻一次减法, 而这里每秒只被调一次。
# 【★ 随机 4 个 ★】`sort=random, limit=4` 由原版选择器负责, 不需要自己抽。
# ============================================================

# ① 3 秒节流
execute if score @s zx.gl_cd > #now manacore.meta run return 0
scoreboard players operation @s zx.gl_cd = #now manacore.meta
scoreboard players operation @s zx.gl_cd += #60 manacore.meta

# ② 圈人（5 格内随机 4 个, 不含玩家与非活体）
execute at @s run tag @e[type=!#sweetdream:no_damage, type=!minecraft:player, distance=..5, sort=random, limit=4] add zx.gl_p4

# ②.5 这些「白昼梦」是**玩家自己附加出去的** ⇒ 每只给玩家攒一层「回光」(迟暮)
#   ★ 为什么不能指望 lib/dream_check 兜住: 下面 ③ 把执行身份换成了怪物,
#     white_one 里调 tag/mark 时 @s 已经是被施加的那只, 玩家身份丢了。
#     所以白光这一路必须在这里**显式**补, 按实际被圈中的只数补。
#   ★ 层数写进 #ld_gn, 由 gain_n 消费并归零。
#   ★ `execute if entity` 匹配 0 只时是**失败**, store result 不会写分数 ⇒
#     必须先手工清零, 否则会读到上一炮的旧值（多给层数）。
scoreboard players set #gl_n zx.meta 0
execute store result score #gl_n zx.meta run execute if entity @e[tag=zx.gl_p4, distance=0..]
execute if score #gl_n zx.meta matches 1.. if items entity @s armor.legs *[minecraft:custom_data~{zx:["late_dusk"]}] run scoreboard players operation #ld_gn zx.meta = #gl_n zx.meta
execute if score #gl_n zx.meta matches 1.. if items entity @s armor.legs *[minecraft:custom_data~{zx:["late_dusk"]}] run function sweetdream:equipment/armor/late_dusk/gain_n

# ③ 逐个：附加白昼梦 + 时停 1 秒
execute as @e[tag=zx.gl_p4, distance=0..] at @s run function sweetdream:equipment/armor/glimmer/white_one

# ④ 表现 + 收尾
execute at @s run particle minecraft:dust{color:[1.0,1.0,1.0],scale:2.0} ~ ~1.2 ~ 3.0 4.0 3.0 0.05 40
execute at @s run playsound minecraft:block.beacon.activate player @s ~ ~ ~ 0.5 1.8
tag @e[tag=zx.gl_p4, distance=0..] remove zx.gl_p4
