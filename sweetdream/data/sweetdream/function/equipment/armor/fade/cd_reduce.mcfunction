# ============================================================
# sweetdream:equipment/armor/fade/cd_reduce —— 息影: 主手装备冷却 -10 秒
# ------------------------------------------------------------
# 【执行者】玩家(主手确实带着 custom_data.skill)
# 【前置】已跑过 lib/uuid(拿 zx:data self.uuid)
# 【为什么拆出来】主手没有技能时整段跳过, 不往公共输入口写半成品参数。
# ============================================================

data modify storage manacore:in arg set value {uuid:"",skill:"",seconds:10.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.skill set from entity @s SelectedItem.components."minecraft:custom_data".skill
function manacore:api/cooldown/reduce
