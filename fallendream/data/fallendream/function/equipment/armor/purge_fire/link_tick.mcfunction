# ============================================================
# fallendream:equipment/armor/purge_fire/link_tick —— 涤火(超限)：8 秒观察窗口（每秒一次）
# ------------------------------------------------------------
# 【谁调它】lib/second —— 三维度各一遍 `as @e[tag=zx.pf_watch]`
# 【执行者】被标记的那只生物
# 【文案(逐字)】"通过该装备消耗了「流火」和「夜火」的生物若在 8 秒内被附加了
#   「流火」，则额外附加上「夜火」并使其在该「流火」或「夜火」的持续时间内受到的
#   伤害 +20%…"
# 【为什么用"每秒扫一遍"而不是在 tag/mark_one 上加钩子】
#   tag/mark_one 是全包最热的公共件（每次附着都过），为一件装备塞一条判定不值当;
#   而窗口只有 8 秒、判据只看"有没有流火", 每秒一次完全够。
# 【状态】zx.pf_watch(标签) + zx.pf_w_end(到期刻, 打在这只生物身上)
#   ★ 到期就整组摘掉 —— 不留标签在白名单里空转。
# ============================================================

# ① 窗口过期 -> 收掉观察
execute unless score @s zx.pf_w_end > #now manacore.meta run tag @s remove zx.pf_watch
execute unless score @s zx.pf_w_end > #now manacore.meta run scoreboard players set @s zx.pf_w_end 0
execute unless entity @s[tag=zx.pf_watch] run return 0

# ② 窗口内真的被贴上了「流火」而还没有「夜火」-> 兑现
execute if entity @s[tag=zx.status.liuhuo,tag=!zx.status.yehuo] run function fallendream:equipment/armor/purge_fire/link_do
