# ============================================================
# fallendream:equipment/axe/death_bell/reward —— 钟声达标奖励
# ------------------------------------------------------------
# 【谁调用它】dom_one ⑨（原版 = 命中次数 ≥5；超限 = 不同生物 ≥3）
# 【执行者】施法者
# 【做什么】返还 80 魔力值 + 冷却 -10 秒 + 一句提示
# 【为什么抽成函数】两个达标口径各一行调用，奖励内容一模一样；写在 dom_one 里
#   要复制六行带条件的 mana/add / cooldown/reduce，改一次数值就得改两处。
# ============================================================

data modify storage manacore:in arg set value {uuid:"",value:80.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/add

data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:death_bell",ticks:200}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/reduce

tellraw @s [{"text":"钟声回响（返还 80 魔力 / 冷却 -10 秒）","color":"aqua"}]
