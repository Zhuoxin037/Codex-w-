# ============================================================
# sweetdream:equipment/armor/boil_trace/give —— 给一件「沸痕」（罕见 · 盔甲）
# ------------------------------------------------------------
# 【custom_data】
#   "boil_trace" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["boil_trace"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 被动技能
# 【底材】iron_chestplate（罕见 = iron）
#
# 【这个文件是生成的】改描述请改 .workbuddy/_new42_lore.py、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# 【外观】批 16（2026-10-18）补齐：item_model 指向 sweetdream:armor_boil_trace
#   （贴图源 _gen_late_icons.py，接线 _gen_late_rp.py）。
# ★ 盔甲两处一起给：item_model(背包图标) + equippable(穿戴层)。
#   equippable 一写就是**整体替换**原版组件 => slot / asset_id /
#   equip_sound 三个字段必须给全，漏一个整条 give 解析失败。
#   存量(改动前发出的)旧件由 visual/armor_icon_held 每秒补课，
#   但**背包/箱子里的存量扫不到** => 那些要重新 give。
# ============================================================
give @s iron_chestplate[item_name={text:"沸痕",bold:true,color:red},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +80，最大生命值 +4。自","color":"gray","italic":false},{"text":"身实际受到火焰或燃烧伤害后，若 4 格内","color":"gray","italic":false},{"text":"有未附有「流火」的生物，则使最近一个","color":"gray","italic":false},{"text":"生物附加「流火」并为自身恢复 4 点生命","color":"gray","italic":false},{"text":"值，之后熄灭自身身上的火焰。该效果 8","color":"gray","italic":false},{"text":"秒内最多触发一次。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["boil_trace","chestplate","armor"],tags:["liuhuo","max_hp","max_mana","heal","apply"]},tooltip_display={hidden_components:["unbreakable"]},item_model="sweetdream:armor_boil_trace",equippable={slot:"chest",asset_id:"sweetdream:armor_boil_trace",equip_sound:"minecraft:item.armor.equip_iron"}]
