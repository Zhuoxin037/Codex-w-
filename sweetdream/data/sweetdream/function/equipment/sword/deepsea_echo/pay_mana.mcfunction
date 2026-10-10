# ============================================================
# sweetdream:equipment/sword/deepsea_echo/pay_mana —— 重复一次要花的魔力
# ------------------------------------------------------------
# 【执行者】施法者    【出参】manacore:out r.success (由 wave_go 判)
# 【金额】基础版 110 / 超限版 80(文案: "每次重复都会消耗自身 **80** 魔力值")。
#   ★ ol 由 wave_go 每波开头写进 zx:work de.ol; 这里只是读。
# ============================================================

execute if data storage zx:work de{ol:1b} run data modify storage manacore:in arg set value {uuid:"",value:80.0}
execute unless data storage zx:work de{ol:1b} run data modify storage manacore:in arg set value {uuid:"",value:110.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
