# ============================================================
# sweetdream:equipment/armor/empty_pillow/give —— 给一件「空枕」（稀有 · 盔甲）
# ------------------------------------------------------------
# 【custom_data】
#   "empty_pillow" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["empty_pillow"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 被动技能 ｜ ✦ 静息
# 【底材】iron_helmet（稀有 = iron）
#
# 【这个文件是生成的】改描述请改 .workbuddy/_new42_lore.py、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# 【外观】批 16（2026-10-18）补齐：item_model 指向 sweetdream:armor_empty_pillow
#   （贴图源 _gen_late_icons.py，接线 _gen_late_rp.py）。
# ★ 盔甲两处一起给：item_model(背包图标) + equippable(穿戴层)。
#   equippable 一写就是**整体替换**原版组件 => slot / asset_id /
#   equip_sound 三个字段必须给全，漏一个整条 give 解析失败。
#   存量(改动前发出的)旧件由 visual/armor_icon_held 每秒补课，
#   但**背包/箱子里的存量扫不到** => 那些要重新 give。
# ============================================================
give @s iron_helmet[item_name={text:"空枕",bold:true,color:light_purple},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +50。自身连续 4 秒没有","color":"gray","italic":false},{"text":"造成伤害后，获得「静息」。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 静息","color":"gold","bold":true,"italic":false},{"text":"下一次攻击生物时，若目标未附有","color":"gray","italic":false},{"text":"「白昼梦」则使其附加「白昼梦」，之后","color":"gray","italic":false},{"text":"清除「静息」。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["empty_pillow","helmet","armor"],tags:["dream","max_mana","consume","apply"]},tooltip_display={hidden_components:["unbreakable"]},item_model="sweetdream:armor_empty_pillow",equippable={slot:"head",asset_id:"sweetdream:armor_empty_pillow",equip_sound:"minecraft:item.armor.equip_iron"}]
