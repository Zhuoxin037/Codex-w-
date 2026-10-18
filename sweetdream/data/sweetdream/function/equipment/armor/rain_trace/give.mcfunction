# ============================================================
# sweetdream:equipment/armor/rain_trace/give —— 给一件「雨迹」（罕见 · 盔甲）
# ------------------------------------------------------------
# 【custom_data】
#   "rain_trace" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["rain_trace"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 被动技能
# 【底材】iron_boots（罕见 = iron）
#
# 【这个文件是生成的】改描述请改 .workbuddy/_new42_lore.py、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# 【外观】批 16（2026-10-18）补齐：item_model 指向 sweetdream:armor_rain_trace
#   （贴图源 _gen_late_icons.py，接线 _gen_late_rp.py）。
# ★ 盔甲两处一起给：item_model(背包图标) + equippable(穿戴层)。
#   equippable 一写就是**整体替换**原版组件 => slot / asset_id /
#   equip_sound 三个字段必须给全，漏一个整条 give 解析失败。
#   存量(改动前发出的)旧件由 visual/armor_icon_held 每秒补课，
#   但**背包/箱子里的存量扫不到** => 那些要重新 give。
# ============================================================
give @s iron_boots[item_name={text:"雨迹",bold:true,color:dark_aqua},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +50。自身主动技能完成","color":"gray","italic":false},{"text":"实际位移后，在位移过的地方留下持续 5","color":"gray","italic":false},{"text":"秒的水迹。之后对在水迹处持续停留 2 秒","color":"gray","italic":false},{"text":"的生物附加「渊海」，并使其受到一次相","color":"gray","italic":false},{"text":"当于释放者基础攻击力 ×2 的伤害。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["rain_trace","boots","armor"],tags:["yuanhai","max_mana","base_atk","dash","apply"]},tooltip_display={hidden_components:["unbreakable"]},item_model="sweetdream:armor_rain_trace",equippable={slot:"feet",asset_id:"sweetdream:armor_rain_trace",equip_sound:"minecraft:item.armor.equip_iron"}]
