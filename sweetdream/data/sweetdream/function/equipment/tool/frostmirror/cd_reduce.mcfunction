# ============================================================
# sweetdream:equipment/tool/frostmirror/cd_reduce —— 冰鉴: 主手装备冷却 -1 秒
# ------------------------------------------------------------
# 【执行者】玩家(主手确实带着 custom_data.skill)
# 【前置】已跑过 lib/uuid(拿 zx:data self.uuid)
# 【为什么拆出来】主手没有技能时整段跳过, 不往公共输入口写半成品参数
#   (与 armor/fade/cd_reduce 同一形态, 只是 10 秒 -> 1 秒)。
# 【为什么只对正在冷却的技能生效】api/cooldown/reduce 自带这个口径 ——
#   没在冷却就等于没减, 不会出现"提前存着以后用"的记账。
# ============================================================

data modify storage manacore:in arg set value {uuid:"",skill:"",seconds:1.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.skill set from entity @s SelectedItem.components."minecraft:custom_data".skill
function manacore:api/cooldown/reduce
