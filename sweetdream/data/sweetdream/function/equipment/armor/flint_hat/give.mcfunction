# ============================================================
# sweetdream:equipment/armor/flint_hat/give —— 给一件「燧帽」（稀有 · 盔甲）
# ------------------------------------------------------------
# 【custom_data】
#   "flint_hat" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["flint_hat"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 被动技能 ｜ ✦ 套装效果
# 【底材】iron_helmet（稀有 = iron）
#
# 【这个文件是生成的】改描述请改 .workbuddy/_new42_lore.py、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# 【外观】批 16（2026-10-18）补齐：item_model 指向 sweetdream:armor_flint_hat
#   （贴图源 _gen_late_icons.py，接线 _gen_late_rp.py）。
# ★ 盔甲两处一起给：item_model(背包图标) + equippable(穿戴层)。
#   equippable 一写就是**整体替换**原版组件 => slot / asset_id /
#   equip_sound 三个字段必须给全，漏一个整条 give 解析失败。
#   存量(改动前发出的)旧件由 visual/armor_icon_held 每秒补课，
#   但**背包/箱子里的存量扫不到** => 那些要重新 give。
# ============================================================
give @s iron_helmet[item_name={text:"燧帽",bold:true,color:gold},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +40。普通近战命中了未","color":"gray","italic":false},{"text":"附有「流火」且仍存活的生物后，若魔力","color":"gray","italic":false},{"text":"足够，则消耗 20 魔力并使其附加","color":"gray","italic":false},{"text":"「流火」。该效果 8 秒内最多触发一次。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 套装效果","color":"gold","bold":true,"italic":false},{"text":"● 燧帽","color":"gray","italic":false},{"text":"● 烟履","color":"gray","italic":false},{"text":" ","italic":false},{"text":"自身对附有「流火」的生物造成的基础攻","color":"gray","italic":false},{"text":"击力类技能伤害提高 12%（独立乘区）。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["flint_hat","helmet","armor"],tags:["liuhuo","max_mana","base_atk","apply","indep_mul"]},tooltip_display={hidden_components:["unbreakable"]},item_model="sweetdream:armor_flint_hat",equippable={slot:"head",asset_id:"sweetdream:armor_flint_hat",equip_sound:"minecraft:item.armor.equip_iron"}]
