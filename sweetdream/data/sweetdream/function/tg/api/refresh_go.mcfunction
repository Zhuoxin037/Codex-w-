# ============================================================
# sweetdream:tg/api/refresh_go —— refresh 的宏片: 把 tge."<id>" 抄成物品的 tags
#   由 tg/api/refresh 调(此时中转架上就那件装备)。
# ============================================================
$data modify entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".tags set from storage zx:config tge."$(id)"
