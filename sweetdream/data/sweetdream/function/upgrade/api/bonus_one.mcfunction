# ============================================================
# sweetdream:upgrade/api/bonus_one —— 把**一条**升级的数值并进总账(宏 {id})
# ------------------------------------------------------------
# 【★ 2026-10-07 二改: 老三样也进分级桶 ★】
#   以前 dmg/mana/cd 在这里**无条件累加**, 只有 mm/mr/mh/mhp 走 bonus_take 的
#   "同系取最高 tier"。后果: 同一条链里只要残留两条(α+β), 那三样就相加 ——
#   玩家看到"不同等级的效果叠在一起了"(愿景 α+β = +30% 而不是 +20%)。
#   现在**全部字段**统一交给 bonus_take: 同系只认最高 tier, 不同系才相加。
#   这样连"老规则敲出来的 4 条老物品"也自动修正, 不用去洗物品数据。
# 【本函数只剩两件事】读 tier -> 读 series -> 交给分级桶, 自己不碰任何账。
#   #up_dmg/#up_mana/#up_cd 由调用方(bonus_held / bonus_armor)归零。
# ============================================================

# ---- 分级链条: 取 series 和 tier, 交给下一层宏 ----
scoreboard players set #up_tier zx.meta 0
$execute store result score #up_tier zx.meta run data get storage zx:config updef."$(id)".tier
$data modify storage zx:work up.series set from storage zx:config updef."$(id)".series
function sweetdream:upgrade/api/bonus_take with storage zx:work up
