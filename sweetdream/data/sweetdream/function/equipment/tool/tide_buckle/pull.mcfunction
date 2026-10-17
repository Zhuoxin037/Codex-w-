# ============================================================
# sweetdream:equipment/tool/tide_buckle/pull —— 回潮扣: 把被消耗者周围的生物拉近
# ------------------------------------------------------------
# 【谁调用它】lib/on_consume_go（技能消耗掉「渊海」之后）
# 【执行者】消耗者（玩家）   【宏参数】zx:work mc {target, mark, by, src}
# 【文案(lore 逐字)】持于副手时，自身技能消耗一个生物的「渊海」后，将其 2 格内最多
#   2 个其他生物向其拉近最多 0.75 格。
# 【★ 圆心 = 被消耗掉「渊海」的那一只 ★】所以要读 mc.target（字符串选择器）——
#   这也是本件必须走宏叶子的原因（非宏函数拼不出选择器）。
# 【位移手法】用包内既有的那一招（海棠漩涡 / 沉锚同款）：
#   `at @s facing entity <圆心> feet positioned ^ ^ ^N if block ~ ~ ~ #minecraft:replaceable
#    run tp @s ~ ~ ~` —— facing 定死朝向，^ ^ ^N 沿朝向走 N 格；
#   ★ `if block … #minecraft:replaceable` 就是文案里的"遇到障碍即停"（撞墙就不动）。
# ============================================================

# ① 副手必须是回潮扣
execute unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["tide_buckle"]}] run return 0

# ② 被消耗掉渊海的那一只还在吗（这一下可能已经把它打死了 -> 没有圆心，收工）
$execute unless entity $(target) run return 0

# ③ 圈"它 2 格内最多 2 个其他生物"（distance 从 0.01 起，天然排除它自己）
tag @e[tag=zx.tb_pull,distance=0..] remove zx.tb_pull
$execute at $(target) run tag @e[type=!#sweetdream:no_damage,distance=0.01..2,sort=nearest,limit=2] add zx.tb_pull

# ④ 逐只拉近最多 0.75 格（撞到不可替换的方块就停）
$execute as @e[tag=zx.tb_pull,distance=0..] at @s facing entity $(target) feet positioned ^ ^ ^0.75 if block ~ ~ ~ #minecraft:replaceable run tp @s ~ ~ ~

# ⑤ 表现 + 收尾
$execute at $(target) run particle minecraft:bubble_pop ~ ~0.6 ~ 0.7 0.5 0.7 0.02 10 normal
tag @e[tag=zx.tb_pull,distance=0..] remove zx.tb_pull
