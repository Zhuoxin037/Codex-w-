# ============================================================
# fallendream:equipment/armor/overflow/give —— 给一件「溢流」（罕见 · 护腿）
# ------------------------------------------------------------
# 【custom_data】"overflow" -> 装备 id; 判定写 custom_data~{zx:["overflow"]}
# 【机制】魔力 +80 / 最大生命 +4；被过量治疗后 50% 溢出量转临时生命（上限 最大生命×2）。
# 【★ 过量怎么算 ★】hook 在 lib/heal 的出口：#heal_pt（请求量）− #heal_got（实得）。
#   只覆盖本包 lib/heal 这条治疗链 —— 原版再生/瞬治满血时本来就不溢出，影响可忽略。
# 【外观】尚未画。
# ============================================================
give @s netherite_leggings[item_name={text:"溢流",bold:true,color:aqua},lore=[{"text":"异器 · 护腿 · 通用","color":"gray","bold":true,"italic":false},{"text":" ","italic":false},{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +80，最大生命值 +4。自","color":"gray","italic":false},{"text":"身被过量治疗后，将溢出治疗量的 50% 转","color":"gray","italic":false},{"text":"化为临时生命值，最多拥有相当于自身最","color":"gray","italic":false},{"text":"大生命值 ×2 的临时生命值。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["overflow","leggings","armor"],rarity:"t2",tags:["max_mana","max_hp","heal","buff"]},tooltip_display={hidden_components:["unbreakable"]},item_model="fallendream:armor_overflow",equippable={slot:"legs",asset_id:"fallendream:armor_overflow",equip_sound:"minecraft:item.armor.equip_netherite"}]
