# ============================================================
# sweetdream:equipment/armor/intent/give —— 给一件「蓄意」（史诗 · 胸甲）
# ------------------------------------------------------------
# 【custom_data】"intent" -> 装备 id; 判定写 custom_data~{zx:["intent"]}
# 【机制】魔力 +150 / 最大生命 +20%；每使用 50 魔力 → +2 临时生命（单技能可重复触发）；
#   临时生命清空后 5 秒抗性提升Ⅱ + 迅捷Ⅲ，每 12 秒最多一次。
# 【★ 账本 ★】zx.it_sum（毫魔力点）由 lib/mana/pay 记账，**独立于剖面的 zx.pm_sum** ——
#   两件可同时穿，共用一份账本会互相饿死（见 lib/mana/pay 头注释）。
# 【★ "临时生命清空"怎么判 ★】lib/thp/tick 每秒比对真实吸收值，归零时会调本件的
#   on_empty（见 equipment/armor/intent/on_empty）。不要在 second 里重复检测。
# 【外观】尚未画。
# ============================================================
give @s netherite_chestplate[item_name={text:"蓄意",bold:true,color:light_purple},lore=[{"text":"精器 · 胸甲 · 通用","color":"aqua","bold":true,"italic":false},{"text":" ","italic":false},{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +150，最大生命值 +20%。","color":"gray","italic":false},{"text":"自身每使用 50 点魔力值，便获得 2 点临","color":"gray","italic":false},{"text":"时生命值（单次技能可重复触发）。自身","color":"gray","italic":false},{"text":"临时生命值清空后，获得 5 秒抗性提升Ⅱ","color":"gray","italic":false},{"text":"和迅捷Ⅲ；该效果每 12 秒最多触发一次。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["intent","chestplate","armor"],rarity:"t3",tags:["max_mana","max_hp","cur_mana","buff","heal"]},tooltip_display={hidden_components:["unbreakable"]},item_model="sweetdream:armor_intent",equippable={slot:"chest",asset_id:"sweetdream:armor_intent",equip_sound:"minecraft:item.armor.equip_netherite"}]
