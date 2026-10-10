# ============================================================
# sweetdream:equipment/armor/lightless_sea/give —— 给一件「无光海」（盔甲）
# ------------------------------------------------------------
# 【custom_data】
#   "lightless_sea" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["lightless_sea"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【套装】和「枯枝园」(withered_garden)成套, 套装效果两件都写了。
# 【基础攻击力 +1 的账本】"每影响一个生物 +1"会随目标数变化, 而且 3 秒
#   断供要**清空** —— 一定要按差值加减, 别直接 set(不然脱战也留着加成)。
# 【"暗潮"是个区域, 不是效果】范围内的缓慢Ⅱ要每刻/每秒重新施加, 否则会掉。
# 【上限】名下最多 3 片暗潮, 逻辑在 lightless_sea/cap(宏), 改上限要同步描述。
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch5.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ============================================================
give @s netherite_boots[item_name={text:"无光海",bold:true,color:dark_blue},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +200。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 暗潮","color":"gold","bold":true,"italic":false},{"text":"自身 8 格内若有缓慢效果或附加了","color":"gray","italic":false},{"text":"「渊海」效果的生物，则每秒都会使其 3","color":"gray","italic":false},{"text":"格内的全部生物获得 2 秒虚弱Ⅲ，且每影","color":"gray","italic":false},{"text":"响一个生物都会为自身回复 5 魔力值且自","color":"gray","italic":false},{"text":"身基础攻击力 +1，若自身 3 秒内没有持","color":"gray","italic":false},{"text":"续该效果则清空该加成。自身每使用一次","color":"gray","italic":false},{"text":"技能都会在自身位置生成一个半径 4 格的","color":"gray","italic":false},{"text":"“暗潮”，在“暗潮”范围内的生物将获","color":"gray","italic":false},{"text":"得常态的缓慢Ⅱ。8 秒后“暗潮”自毁。","color":"gray","italic":false},{"text":"场上最多同时存在 3 个“暗潮”，超出时","color":"gray","italic":false},{"text":"最早召唤的一个会立刻消失。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 套装效果","color":"gold","bold":true,"italic":false},{"text":"● 无光海","color":"gray","italic":false},{"text":"● 枯枝园","color":"gray","italic":false},{"text":" ","italic":false},{"text":"若“暗潮”内有“朽木”存在，则每秒都","color":"gray","italic":false},{"text":"会使“暗潮”内的全部生物受到相当于释","color":"gray","italic":false},{"text":"放者自身最大魔力值 ×0.1 的伤害，且会","color":"gray","italic":false},{"text":"被附加「渊海」效果。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["lightless_sea","boots","armor"],tags:["yuanhai","max_mana","base_atk","summon","slow","debuff","apply"]},tooltip_display={hidden_components:["unbreakable"]},item_model="sweetdream:armor_lightless_sea",equippable={slot:"feet",asset_id:"sweetdream:armor_lightless_sea",equip_sound:"minecraft:item.armor.equip_netherite"}]
