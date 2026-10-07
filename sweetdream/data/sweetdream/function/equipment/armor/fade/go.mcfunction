# ============================================================
# sweetdream:equipment/armor/fade/go —— 息影·兑现: 手持装备冷却 -10 秒 + 回 50 魔力
# ------------------------------------------------------------
# 【执行者】玩家(刚满"10 秒没再放技能")
# 【技能原文(lore 逐字)】
#   "…则使当前手持装备冷却时间 -10 秒且自身恢复 50 魔力值。"
# 【口径】
#   · "当前手持装备" = 主手那件自带 custom_data.skill 的装备(观测镜/面板也是
#     认这个字段, 见 tool/look/render_go)。主手没有 skill 就只回魔, 冷却那条跳过。
#   · 只对**正在冷却**的技能生效(api/cooldown/reduce 的口径), 没在冷却就等于没减。
# 【★ 先 uuid 后写公共输入口 ★】两条 api 都要 manacore:in arg.uuid。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ① 当前手持装备冷却 -10 秒
execute if data entity @s SelectedItem.components."minecraft:custom_data".skill run function sweetdream:equipment/armor/fade/cd_reduce

# ② 自身恢复 50 魔力值
data modify storage manacore:in arg set value {uuid:"",value:50.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/add

# ③ 一点反馈(看得见才好测)
execute at @s run particle minecraft:reverse_portal ~ ~1 ~ 0.35 0.5 0.35 0.02 18 normal
execute at @s run playsound minecraft:entity.allay.item_throw player @s ~ ~ ~ 0.5 1.2
