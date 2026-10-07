# ============================================================
# sweetdream:equipment/armor/lightless_sea/tide_go —— 套装伤害结算
# ------------------------------------------------------------
# 【谁调用它】tide_set(执行者 = 释放者玩家)
# 【套装判定】枯枝园(腿) + 无光海(靴)两件都在身上才生效 —— 少一件整个跳过。
# 【伤害】释放者最大魔力 ×0.1 → max_mana_mul 通道; 目标 = 暗潮 4 格内
#   (tide_tick 已圈好 zx.ls_area); 执行者是玩家 → 自动带归属。
# 【渊海】打完全部目标附加「渊海」(公共接口, 头顶出图标,
#   会被朽木的选址/源生物判定认出来 —— 套装滚雪球就是这么来的)。
# ============================================================

# ① 两件都在吗
execute unless items entity @s armor.legs *[minecraft:custom_data~{zx:["withered_garden"]}] run return 0
execute unless items entity @s armor.feet *[minecraft:custom_data~{zx:["lightless_sea"]}] run return 0

# ② 算伤害
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.1}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc

# ③ 打出去
data modify storage zx:in arg set value {target:"@e[tag=zx.ls_area]",damage:0.0,read:"manacore"}
function sweetdream:api/damage

# ④ 附加渊海
data modify storage zx:work ic set value {target:"@e[tag=zx.ls_area]",mark:"yuanhai"}
function sweetdream:tag/mark with storage zx:work ic
