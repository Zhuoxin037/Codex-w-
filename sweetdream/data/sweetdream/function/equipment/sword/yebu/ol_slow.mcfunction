# ============================================================
# sweetdream:equipment/sword/yebu/ol_slow —— 超限·曳步: 缓慢Ⅰ 6 秒 / 缓慢Ⅲ 可叠至 12 秒
# ------------------------------------------------------------
# 【谁调用它】yebu/slow 开头(#yb_ol = 1 时), 执行者 = 被命中的生物
# 【文案(超限)】"每次普通攻击命中后，使其获得 6 秒缓慢Ⅰ。若其此时已处于缓慢状态，
#   则改为使其获得 3 秒缓慢Ⅲ（可叠加，最高12秒）。若其此时缓慢Ⅲ效果超过10秒则使其
#   基础移动速度-50%，持续5秒（每个生物仅一次）。"
# 【和原版的差别】原版是 4 秒 Ⅰ / 升级成 3 秒 Ⅱ(每 4 秒最多一次)。超限没有"升级冷却"，
#   而是**同一档 Ⅲ 往上叠时长**，叠满 12 秒后额外给一次 5 秒的移速惩罚。
# 【三档账本(都在计分项上, 不碰实体 NBT)】
#   zx.yb    = 当前缓慢到期刻(0 = 没记过账, 自愈)
#   zx.yb3   = 缓慢Ⅲ 的累计到期刻 —— 叠时长就叠它, 上限 now+240(=12 秒)
#   zx.ybm   = 1 = 这只生物已经吃过"移速 -50%"那一次(每生物仅一次, 永不复位)
#   zx.yb_be = 移速 -50% 的结束刻(ol_bind_sweep 每秒判到点摘属性)
# 【为什么叠时长要单独记 zx.yb3】zx.yb 在"初次 Ⅰ"里也会被写(now+120)，而 Ⅲ 的
#   叠加起点必须是**上一次 Ⅲ 的到期刻**；两个语义混用一个计分项就会在"Ⅰ 还没结束
#   就被叠 Ⅲ"时把 Ⅲ 的时长算进 Ⅰ 的余量。
# ============================================================
scoreboard players add @s zx.yb 0
scoreboard players add @s zx.yb3 0
scoreboard players add @s zx.ybm 0
scoreboard players operation #yb_now zx.meta = #now manacore.meta

# ① 已在缓慢中 -> 叠 缓慢Ⅲ
execute if score @s zx.yb > #yb_now zx.meta run function sweetdream:equipment/sword/yebu/ol_stack
execute if score @s zx.yb > #yb_now zx.meta run return 0

# ② 初次(没记过账 / 上次已经过期) -> 缓慢Ⅰ 6 秒
#   ★ 这里刻意**不写** zx.yb3: Ⅰ 不是 Ⅲ 的叠加底座, 留着上次的到期刻反而会让
#     下一次"叠 Ⅲ"从一个早就过去的时刻开始算(第一发 Ⅲ 直接变成 3 秒才对)。
effect give @s minecraft:slowness 6 0 true
scoreboard players operation @s zx.yb = #yb_now zx.meta
scoreboard players add @s zx.yb 120
execute at @s run particle minecraft:dust{color:[0.55,0.62,0.72],scale:0.9} ~ ~0.35 ~ 0.4 0.4 0.4 0.005 8 normal
