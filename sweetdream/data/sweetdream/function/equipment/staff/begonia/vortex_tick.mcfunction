# ============================================================
# sweetdream:equipment/staff/begonia/vortex_tick —— 漩涡的每秒心跳
# ------------------------------------------------------------
# 【谁调用它】begonia/second(执行者 = 漩涡 item_display, at @s 位置在中心)
# 【技能原文(lore 逐字)】漩涡每秒都会将 4 格内的全部生物拉回中心一段距离，持续 8 秒。
# 【"拉回中心"怎么实现】照 whitled 的 tp 式位移, 方向朝中心走(见第 ② 步的削弱说明)。
#   中心 = @s(漩涡本体); 目标 = 4 格内、离中心 1.5 格以上的全部可伤害生物。目标格不是可替换方块就不动。
# 【★ item_display 在 #sweetdream:no_damage 里 ★】下面的圈选都走 type=!#sweetdream:no_damage,
#   所以漩涡本体天然不会被当成"要被拉动的生物"。
# ============================================================

# ① 中心 = 本漩涡
tag @e[tag=zx.bg_center,distance=0..] remove zx.bg_center
tag @s add zx.bg_center

# ② 圈范围内全部生物 -> 朝中心挪半格
#   ★ 2026-10-08 用户: "海棠的技能的吸引力弱一点, 不是说立马吸到中心, 而是吸个一格左右"。
#     ⇒ 两处都削弱:
#       ① 每次只挪 **0.5 格**(原来 1 格);
#       ② 只拉**离中心还有 1.5 格以上**的 —— 进到 1.5 格以内就松手。
#          于是它最后停在"离中心一格多一点"的位置, 不会被一路吸进中心。
#   ★ 顺便修掉老版一个毛病: 漩涡出生在「渊海」生物脚下(距离 0), 老版连它也会被
#     "朝中心挪 1 格" 顶出去 —— 距离 ~0 时朝向是退化的, 等于原地乱跳一下。
#     加了下限之后, 中心那只原地不动。
#   ★ 超限(超限·海棠): 漩涡范围扩大为 6 格 => 拉扯半径 1.51..6(基础仍 4)。
#     读自己 data.zx.bg.ol(施法那刻拍进来的快照)。
tag @e[tag=zx.bg_pull,distance=0..] remove zx.bg_pull
execute unless data entity @s data.zx.bg{ol:1b} run tag @e[type=!#sweetdream:no_damage,distance=1.51..4] add zx.bg_pull
execute if data entity @s data.zx.bg{ol:1b} run tag @e[type=!#sweetdream:no_damage,distance=1.51..6] add zx.bg_pull
execute as @e[tag=zx.bg_pull,distance=0..] at @s facing entity @e[tag=zx.bg_center,distance=0..,limit=1] feet positioned ^ ^ ^0.5 if block ~ ~ ~ #minecraft:replaceable run tp @s ~ ~ ~
tag @e[tag=zx.bg_pull,distance=0..] remove zx.bg_pull
tag @e[tag=zx.bg_center,distance=0..] remove zx.bg_center

# ③ 表现(漩涡转水)
particle minecraft:bubble ~ ~0.5 ~ 2.0 0.5 2.0 0.0 14 normal
particle minecraft:nautilus ~ ~0.5 ~ 1.0 0.4 1.0 0.05 6 normal
playsound minecraft:entity.player.swim player @a ~ ~ ~ 0.5 1.5

# ④ 倒计时; 到 0 收尾(伤害 + 清「渊海」)
scoreboard players remove @s zx.bg_t 1
execute if score @s zx.bg_t matches ..0 run function sweetdream:equipment/staff/begonia/vortex_end
