# ============================================================
# sweetdream:equipment/axe/skyvault/dive_tick —— 天穹俯冲: 每刻推进一步
# ------------------------------------------------------------
# 【谁调用它】sweetdream:core/tick:
#   execute as @a[tag=zx.sv_dive] at @s run function ...
# 【执行者/位置】俯冲中的玩家本人
# 【怎么"朝准星方向"】用局部坐标 ^ ^ ^2 —— 它带俯仰角, 视角压得越低冲得越垂直。
#   (横刀突进要的是水平, 所以那边特意 rotated ~ 0 把俯仰角归零; 这里恰恰要俯仰角。)
# 【什么时候停】下面四条任意一条成立就调 impact 结算:
#   ① 前两格要撞到非可替换方块(墙/地)  ② 前两格 2 格内有生物
#   ③ 安全步数 zx.sv_step 用尽          ④ 脚下方块不是可替换的(落地)
#   ★ 四条都排在"前进"之前 ★ —— 先判再走, 免得一头扎进方块里(落地那条尤其重要)。
#   每次跑完都判一次是否还在俯冲, 结算过的这一 tick 就不再前进。
# ============================================================

scoreboard players remove @s zx.sv_step 1

# ① 前探两步会撞墙 -> 结算(探针距离和实际步长一致, 免得一头扎进方块里)
execute if entity @s[tag=zx.sv_dive] positioned ^ ^ ^2 unless block ~ ~ ~ #minecraft:replaceable run function sweetdream:equipment/axe/skyvault/impact
# ② 前方两步内有生物 -> 结算
execute if entity @s[tag=zx.sv_dive] positioned ^ ^ ^2 if entity @e[type=!#sweetdream:no_damage,distance=..2] run function sweetdream:equipment/axe/skyvault/impact
# ③ 步数用尽 -> 结算(防止在地洞里无限冲)
execute if entity @s[tag=zx.sv_dive] if score @s zx.sv_step matches ..0 run function sweetdream:equipment/axe/skyvault/impact
# ④ 落地 -> 结算
execute if entity @s[tag=zx.sv_dive] unless block ~ ~-0.3 ~ #minecraft:replaceable run function sweetdream:equipment/axe/skyvault/impact
# 还没结算 -> 沿视线前进
execute if entity @s[tag=zx.sv_dive] run tp @s ^ ^ ^2
