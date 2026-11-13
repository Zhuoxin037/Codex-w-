# ============================================================
# sweetdream:equipment/armor/lone_walk/give —— 给一件「独行」（史诗 · 靴子）
# ------------------------------------------------------------
# 【custom_data】"lone_walk" -> 装备 id; 判定写 custom_data~{zx:["lone_walk"]}
# 【机制】魔力 +120 / 移速 +8%；8 格内敌对 ≤2 → 技能伤害 +8%；
#   套装（空营 + 独行）：8 格内敌对数量变化 → 4 秒「临敌」（护甲 +4 / 技能伤害 +10% 独立乘区），
#   每 16 秒最多触发一次。
# 【★ 两种乘区口径 ★】
#   ① "技能伤害 +8%"（没有写独立乘区） ⇒ 走加算池（lib/dmg_add_put，三条通道各加 8）
#      = 整体 +8%，非独立。
#   ② 套装「临敌」明写独立乘区 ⇒ 走 mul_pct 乘最终 damage（同 glimmer/hook_calc）。
#   两者都在同一个 hook_calc 里按顺序做。
# 【外观】尚未画。
# ============================================================
give @s netherite_boots[item_name={text:"独行",bold:true,color:light_purple},lore=[{"text":"精器 · 靴子 · 通用","color":"aqua","bold":true,"italic":false},{"text":" ","italic":false},{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +120，移动速度 +8%。自","color":"gray","italic":false},{"text":"身 8 格内敌对生物不超过 2 个时，技能","color":"gray","italic":false},{"text":"伤害 +8%。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 套装效果","color":"gold","bold":true,"italic":false},{"text":"● 空营","color":"gray","italic":false},{"text":"● 独行","color":"gray","italic":false},{"text":" ","italic":false},{"text":"8 格内敌对生物数量变化时，获得 4 秒","color":"gray","italic":false},{"text":"「临敌」：护甲值 +4、技能伤害 +10%","color":"gray","italic":false},{"text":"（独立乘区）。每 16 秒最多触发一次。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["lone_walk","boots","armor"],rarity:"t3",tags:["max_mana","buff","indep_mul"]},tooltip_display={hidden_components:["unbreakable"]},item_model="sweetdream:armor_lone_walk",equippable={slot:"feet",asset_id:"sweetdream:armor_lone_walk",equip_sound:"minecraft:item.armor.equip_netherite"}]
