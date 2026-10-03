# ============================================================
# sweetdream:upgrade/api/lore_mark_go —— 把最高 tier 写进本系的桶(宏 {ser})
# ------------------------------------------------------------
# 【临时量】#up_t = 当前这条的 tier(上层刚取好)
# 【桶不存在就是 0】data get 读不到时 store 不执行 → 分数会留着上一次的值,
#   所以进来先把 #up_b 归零(项目里踩过好几次的同一个坑)。
# ============================================================

scoreboard players set #up_b zx.meta 0
$execute store result score #up_b zx.meta run data get storage zx:work mkt."$(ser)"
execute if score #up_t zx.meta <= #up_b zx.meta run return 0
$execute store result storage zx:work mkt."$(ser)" int 1 run scoreboard players get #up_t zx.meta
