# ============================================================
# sweetdream:equipment/armor/empty_camp/give —— 给一件「空营」（史诗 · 胸甲）
# ------------------------------------------------------------
# 【custom_data】"empty_camp" -> 装备 id; 判定写 custom_data~{zx:["empty_camp"]}
# 【机制】魔力 +140；8 格内每 1 个敌对生物 → 护甲 +1 / 韧性 +0.5（最多 6 层）；
#   8 格内没有敌对生物 → 每秒回 3 魔力。
# 【★ 敌对生物口径 ★】`@e[type=!#sweetdream:no_damage,distance=..8]`，与包内其余
#   AOE 选择器一致（排除 marker/法球/领域等无伤害实体）。每秒数一次，别每刻数。
# 【外观】尚未画。
# ============================================================
give @s netherite_chestplate[item_name={text:"空营",bold:true,color:light_purple},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +140。自身 8 格内每有","color":"gray","italic":false},{"text":"1 个敌对生物，护甲值 +1、护甲韧性","color":"gray","italic":false},{"text":"+0.5（最多 6 层）。8 格内没有敌对生物","color":"gray","italic":false},{"text":"时，每秒恢复 3 点魔力值。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["empty_camp","chestplate","armor"],tags:["max_mana"]},tooltip_display={hidden_components:["unbreakable"]},item_model="sweetdream:armor_empty_camp",equippable={slot:"chest",asset_id:"sweetdream:armor_empty_camp",equip_sound:"minecraft:item.armor.equip_netherite"}]
