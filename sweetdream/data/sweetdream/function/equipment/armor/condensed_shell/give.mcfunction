# ============================================================
# sweetdream:equipment/armor/condensed_shell/give —— 给一件「凝壳」（史诗 · 盔甲）
# ------------------------------------------------------------
# 【custom_data】
#   "condensed_shell" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["condensed_shell"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 被动技能 ｜ ✦ 领域
# 【底材】diamond_chestplate（史诗 = diamond）
#
# 【这个文件是生成的】改描述请改 .workbuddy/_new42_lore.py、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# 【外观】批 16（2026-10-18）补齐：item_model 指向 sweetdream:armor_condensed_shell
#   （贴图源 _gen_late_icons.py，接线 _gen_late_rp.py）。
# ★ 盔甲两处一起给：item_model(背包图标) + equippable(穿戴层)。
#   equippable 一写就是**整体替换**原版组件 => slot / asset_id /
#   equip_sound 三个字段必须给全，漏一个整条 give 解析失败。
#   存量(改动前发出的)旧件由 visual/armor_icon_held 每秒补课，
#   但**背包/箱子里的存量扫不到** => 那些要重新 give。
# ============================================================
give @s diamond_chestplate[item_name={text:"凝壳",bold:true,color:aqua},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +160。受到伤害后，若魔","color":"gray","italic":false},{"text":"力足够且术阵位有空缺，则消耗 80 魔力","color":"gray","italic":false},{"text":"并占用 1 个术阵位，在自身位置生成半径","color":"gray","italic":false},{"text":"3 格、持续 4 秒的领域。该效果 20 秒内","color":"gray","italic":false},{"text":"不可再次触发。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 领域","color":"gold","bold":true,"italic":false},{"text":"生物首次进入本次领域时冰冻 1 秒，每名","color":"gray","italic":false},{"text":"生物整次领域最多触发一次冰冻。领域每","color":"gray","italic":false},{"text":"秒对其中的生物造成一次相当于自身基础","color":"gray","italic":false},{"text":"攻击力 ×4 的伤害。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["condensed_shell","chestplate","armor"],tags:["max_mana","base_atk","debuff","freeze","field","formation"]},tooltip_display={hidden_components:["unbreakable"]},item_model="sweetdream:armor_condensed_shell",equippable={slot:"chest",asset_id:"sweetdream:armor_condensed_shell",equip_sound:"minecraft:item.armor.equip_diamond"}]
