# ============================================================
# sweetdream:equipment/axe/meteor/tick —— 熔星形态: 每刻检查是否还握着陨星
# ------------------------------------------------------------
# 【谁调用它】sweetdream:core/tick:
#   execute as @a[scores={zx.mt_on=1..}] run function ...
# 【文案】"期间若切换主手武器则该效果失效" —— 放每刻而不是每秒, 换手要立刻生效,
#   免得被当成"换完还能白嫖半秒"。开销只在形态开着的人身上。
# ============================================================

# 超限·陨星(批 K6): 文案"期间若切换主手武器则该武器被动和主动仍旧生效"
#   ⇒ 形态开着且有 mt_keep 就不查主手。★ 只有**触发键**(cast)判手持, 结算侧一律不判。
execute if score @s zx.mt_keep matches 1 run return 0
execute unless items entity @s weapon.mainhand diamond_axe[custom_data~{zx:["meteor"]}] run function sweetdream:equipment/axe/meteor/end
