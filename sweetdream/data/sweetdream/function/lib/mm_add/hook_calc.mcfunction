# ============================================================
# sweetdream:lib/mm_add/hook_calc —— 「最大魔力值技能倍率」通用加成(加算型 hook)
# ------------------------------------------------------------
# @calc: add     ← 加算型: 只往加算池里写百分比, 由 lib/dmg_add_apply 统一乘
# 【谁调用它】#manacore:event/damage_calc —— 排在 lib/dmg_add_apply **之前**
#   (加算型 hook 写在 apply 之后 = 那份百分比永远不会被算上, 静默失效)。
# 【它管的是谁】风行「风声」/ 忘川彼岸套装 / 无效 给的"最大魔力值技能加成",
#   存在玩家自己的计分项 zx.mm_add(百分点) 上。
# 【★ 什么时候失效 ★】没有倒计时 —— 拿到就一直挂着, 直到自身打出一次以最大
#   魔力值结算的技能为止(2026-10-08 用户定稿, 回到 lore"下一次"的原义)。
#   消费动作在本函数最后一步交给 lib/mm_add/take(附各部分说明)。
# 【★ 2026-10-07 用户定稿: 为什么改成这样 ★】
#   原来"风声加成"和面板上的「最大魔力值技能倍率」是**两套并行的东西**:
#   前者攒在 zx:data wg_bonus."<uuid>" 里、由 lib/max_mana_bonus 在"下一次
#   最大魔力值技能"里乘一下然后删掉 —— 功能上和"技能倍率加 X%"完全重复。
#   用户要求: 去掉那套独立槽位, 让加成直接进「最大魔力值技能倍率」这条通用乘区。
#   于是它变成和共振/漫步冥河/炽天使**同一条流水线**的加算 hook:
#     · 任何武器、任何以最大魔力值结算的技能都自动吃到(不再需要每个技能自己调一行);
#     · 也和共振(+10%/阵)、漫步(+30%) 一样"先合并、再乘一次"(加算, 不是独立乘区)。
# 【★ 为什么只写 mm 通道 ★】文案限定"最大魔力值相关的技能" —— 写进 mm 通道后,
#   加算只作用在 mm **分量**上(D01 口径 B): 没走 mm 通道的技能 seg_mm = 0,
#   攻击力类 / 当前魔力类技能吃不到。
# 【★ 已知边界 ★】和另外几个通道 hook 一样, 只有"施法那一刻 @s 就是玩家"的
#   技能才吃得到(威霆的术阵落雷 bolt_go 是以 marker 为执行者算伤害的,
#   那一处吃不到这份加成)。见 RULES「mm 通用加成」条目。
# ============================================================

# ⓪ 不是玩家(法球 / 箭 / 命令方块在算伤害) -> 不参与
execute unless entity @s[type=minecraft:player] run return 0

# ① 没有加成(0 / 还没建过这个分数) -> 不参与
execute unless score @s zx.mm_add matches 1.. run return 0

# ② 写进加算池的 mm 通道
execute store result storage zx:work put.pct int 1 run scoreboard players get @s zx.mm_add
data modify storage zx:work put.ch set value "mm"
function sweetdream:lib/dmg_add_put with storage zx:work put

# ③【消费】走到这里的每一次 mm 结算都算"打出了那一次技能" —— 把加成吃掉。
#    ★ zx.mm_hold = 只读标记 ★ 挂着它的结算(忘川彼岸被动 / 风声回响)照常吃到加成,
#      但不清零 —— 前者是 lore 写明的"不会消耗增幅", 后者是用户定的口径。
execute unless entity @s[tag=zx.mm_hold] run function sweetdream:lib/mm_add/take
