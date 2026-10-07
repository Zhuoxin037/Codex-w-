# ============================================================
# sweetdream:equipment/staff/wind_ontheground/bonus —— 风声超过 60 的奖励
# ------------------------------------------------------------
# 【谁调用它】burst_self ④(3 轮爆发打完的最后一轮)   【执行者】施法者
# 【文案】若有超过 60 点「风声」, 每超出 1 点都会让"下一次自身使用最大魔力值
#         相关的技能伤害"提升 1%。
# 【★ 2026-10-07 用户定稿: 不再存"下一次技能加成"★】
#   原来这里往 zx:data wg_bonus."<uuid>" 写一个比例, 由 lib/max_mana_bonus 在
#   下一次最大魔力值技能里乘掉、用完即删 —— 用户判定这与面板上的
#   「最大魔力值技能倍率」**功能完全重复**, 要求去掉那套独立槽位,
#   直接把增益算进通用乘区。所以现在改成:
#     zx.mm_add  += (风声 - 60)      ← 百分点(加算), 没有倒计时
#   加成由 lib/mm_add/hook_calc 在每次 api/damage/calc 时统一折进加算池的 mm 通道,
#   ⇒ 生效期间**任何**以最大魔力值结算的技能都吃得到, 不再需要每个技能自己调一行。
# 【★ 加算, 不是覆盖 ★】沿用原来的口径: 已有加成时**加上去**(不是覆盖)。
# 【★ 本文件不再是宏函数 ★】原来要按 uuid 拼 wg_bonus 路径才写成宏; 现在加成
#   存在玩家自己的计分项上, 一条 `$` 都不需要 —— 所以调用方也改成了普通调用
#   (burst_self 里不再传 with storage zx:work wg)。
# ============================================================

# ① 超出量 = 风声 - 60
scoreboard players operation #ex zx.meta = @s zx.wg_sound
scoreboard players remove #ex zx.meta 60

# ② 加进「最大魔力值技能倍率」通用乘区槽, 并把时长顶到 20 秒
#   ★ 先 `add ... 0` 保证玩家身上有这个分数 ★ —— 没有分数的玩家, 下面的
#     `operation +=` 和不等于比较都可能不成立(计分板"没分数"不等于 0)。
scoreboard players add @s zx.mm_add 0
scoreboard players operation @s zx.mm_add += #ex zx.meta

tellraw @s [{"text":"最大魔力值技能倍率 +","color":"aqua"},{"score":{"name":"#ex","objective":"zx.meta"},"color":"white"},{"text":"%","color":"aqua"},{"text":"  (合计, 加算, 下一次最大魔力值技能生效)","color":"dark_gray"}]
