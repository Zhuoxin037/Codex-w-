# ============================================================
# sweetdream:equipment/armor/styx_walk/hook_calc —— 漫步冥河之上: 暗海内技能伤害 +30%
# ------------------------------------------------------------
# @calc: add     ← 这是"加算"型 hook: 只往加算池里写百分比, 由 lib/dmg_add_apply 统一乘
# 【谁调用它】#manacore:event/damage_calc —— 前置包在每次 api/damage/calc
#   算完之后抛的事件(和共振 resonance/hook_calc 同一条路)。
# 【执行者就是施法者本人】skill -> calc -> 事件这一路 function 不改 @s,
#   所以这里能直接查 armor.head / 用 at @s 定位。
# 【文案】"自身在“暗海”内使用关于最大魔力值的技能时技能伤害 +30%。"
# 【★ 只吃"最大魔力值"这条通道 ★】
#   文案限定"关于最大魔力值的技能" ⇒ 只往加算池的 mm 通道写 30。
#   加算只作用在 mm **分量**上(D01 口径 B, 见 lib/dmg_add_apply): 没走 mm 通道的
#   技能 seg_mm = 0 ⇒ 攻击力类 / 当前魔力类技能吃不到。这里不做判断, 只负责贡献。
# 【★★ 加算, 不是独立乘区 ★★(2026-10-06 改)】
#   文案没写"独立乘区" ⇒ 按普通加算处理。写进池子后与共振(+10%/阵)等相加:
#     ×(1 + 0.1n + 0.3)   ← 正确
#   (旧写法是"直接乘 r.damage ×1.30" = 独立乘区, 和共振叠起来会是 ×1.43。)
# 【"在暗海内"怎么判】自身 3 格内有暗海实体(item_display, tag=zx.sea) —— 半径最大就是 3 格,
#   取 3 是"站在最大那片暗海的边上"的近似(半径 2 的次级片会多算进边上 1 格,
#   属可接受的宽判; 要精确就得把 r 也读出来比, 收益不值这个复杂度)。
# ============================================================

# ⓪ 不是玩家(damage_calc 被法球/箭这类调用时) -> 不参与
execute unless entity @s[type=minecraft:player] run return 0

# ① 没戴漫步冥河 -> 不参与
execute unless items entity @s armor.head *[minecraft:custom_data~{zx:["styx_walk"]}] run return 0

# ② 自身 3 格内没有暗海 -> 不参与(用 at @s 强制以玩家自身为基准, 不依赖上游位置)
execute at @s unless entity @e[tag=zx.sea,distance=..3,limit=1] run return 0

# ③ 写进加算池: mm 通道 +30%
data modify storage zx:work put.pct set value 30
data modify storage zx:work put.ch set value "mm"
function sweetdream:lib/dmg_add_put with storage zx:work put
