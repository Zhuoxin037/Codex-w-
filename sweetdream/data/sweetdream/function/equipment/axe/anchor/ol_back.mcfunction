# ============================================================
# sweetdream:equipment/axe/anchor/ol_back —— 超限·沉锚: 回到原处
# ------------------------------------------------------------
# 【谁调用它】anchor/cast ⓪.5(4 秒窗口内又按了一次右键)
# 【执行者】施法者(玩家)  【位置】他此刻所在处
# 【做什么】把 cast ⑦.5 钉下的锚点 marker 找出来, 把自己传回去, 然后收掉 marker。
# 【★ 为什么用 marker 不用存坐标 ★】
#   宏 `$tp @s $(x) $(y) $(z)` 里 x 是 NBT 的 double, 替换出来带 `d` 后缀(如 `12.0d`),
#   tp 的坐标参数不认那个后缀 ⇒ 整条命令解析失败、静默不传送。
#   钉一个 marker 之后只用 `execute at <marker> run tp @s ~ ~ ~`, 没有格式化问题。
# 【★ 认人靠 UUID[0] ★】marker 上 zx.anc_own = 施法者 UUID 的第 0 个 int;
#   返回时再算一次自己的 UUID[0] 去比 —— 多人同时在 4 秒窗口里施法也不会串。
# 【★ 窗口计时是玩家的 zx.anc_back(秒) ★】本函数第一行就清 0, 所以调用方
#   必须先用假玩家拍快照再判(cast ⓪.5 已经那么写了)。
# ============================================================

# ⓪ 关窗口 + 收掉可能还在的牵引/飞锚表现
scoreboard players set @s zx.anc_back 0
execute if score @s zx.an_pull matches 1.. run function sweetdream:equipment/axe/anchor/cancel
execute if entity @s[tag=zx.av_cast] run function sweetdream:equipment/axe/anchor/visual/end

# ① 找出自己那个锚点
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
execute store result score #anc_u zx.meta run data get entity @s UUID[0]
tag @e[type=marker,tag=zx.anc_org,distance=0..] remove zx.anc_ok
execute as @e[type=marker,tag=zx.anc_org,distance=0..] if score @s zx.anc_own = #anc_u zx.meta run tag @s add zx.anc_ok
execute unless entity @e[tag=zx.anc_ok,distance=0..,limit=1] run return 0

# ② 传回原处(锚点所在位置就是施法那一刻脚底)
execute at @e[tag=zx.anc_ok,distance=0..,limit=1] run particle minecraft:cloud ~ ~0.5 ~ 0.4 0.6 0.4 0.05 18 normal
execute at @e[tag=zx.anc_ok,distance=0..,limit=1] run playsound minecraft:entity.enderman.teleport player @a ~ ~ ~ 0.9 1.1
execute at @e[tag=zx.anc_ok,distance=0..,limit=1] run tp @s ~ ~ ~
execute at @s run particle minecraft:cloud ~ ~0.5 ~ 0.4 0.6 0.4 0.05 18 normal
execute at @s run playsound minecraft:block.beacon.deactivate player @a ~ ~ ~ 0.6 1.5

# ③ 收尾
execute as @e[tag=zx.anc_ok,distance=0..] run kill @s
tag @e[type=marker,tag=zx.anc_ok,distance=0..] remove zx.anc_ok
