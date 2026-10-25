# ============================================================
# sweetdream:equipment/armor/glimmer/self_speed —— 自身移速档位（黄 +20% / 白 +30%）
# ------------------------------------------------------------
# 【执行者】玩家(@s)
# 【★ 文案(逐字) ★】黄「自身移动速度 +20%」；白「……自身移动速度 +30%」
# 【★ 字面量禁区 ★】`attribute ... modifier add` 的数值只能是命令行**字面量**,
#   吃不了计分项 ⇒ 两档各写一条, 不许写成 `0.2 * 档位`。
# 【★ 挂过才摘 ★】remove 不存在的 modifier 会失败并截断整段 ⇒ 用账本 zx.gl_spd:
#   0 = 没挂 / 1 = 已挂 +20% / 2 = 已挂 +30%。
#   档位没变就一个命令都不发（每秒一次的路径上省掉两次 attribute 调用）。
# ============================================================

# ① 目标档位
scoreboard players set #gl_s zx.meta 0
execute if score @s zx.gl_y matches 1.. run scoreboard players set #gl_s zx.meta 1
execute if score @s zx.gl_r matches 1.. if score @s zx.gl_g matches 1.. if score @s zx.gl_y matches 1.. run scoreboard players set #gl_s zx.meta 2

# ② 档位没变 ⇒ 收工
execute if score #gl_s zx.meta = @s zx.gl_spd run return 0

# ③ 摘旧档
execute if score @s zx.gl_spd matches 1.. run attribute @s minecraft:movement_speed modifier remove sweetdream:gl_spd
scoreboard players set @s zx.gl_spd 0

# ④ 挂新档
execute if score #gl_s zx.meta matches 1 run attribute @s minecraft:movement_speed modifier add sweetdream:gl_spd 0.2 add_multiplied_total
execute if score #gl_s zx.meta matches 2 run attribute @s minecraft:movement_speed modifier add sweetdream:gl_spd 0.3 add_multiplied_total
scoreboard players operation @s zx.gl_spd = #gl_s zx.meta
