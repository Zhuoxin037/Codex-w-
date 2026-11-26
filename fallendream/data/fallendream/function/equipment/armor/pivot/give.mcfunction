# ============================================================
# fallendream:equipment/armor/pivot/give —— 给一件「枢」（史诗 · 头盔）
# ------------------------------------------------------------
# 【custom_data】"pivot" -> 装备 id; 判定写 custom_data~{zx:["pivot"]}
# 【机制】魔力值上限 +120；术阵位上限 +1。
# 【★ 术阵位上限只能走 stats.formation_limit ★】前置包 formation/create 就是按
#   `stats.formation_limit` 判满没满 ⇒ 用 manacore:api/stats/add ±1 改它，
#   **不要**自己去数 formations 有几个（那是占用数，不是上限）。
#   差值账本 zx.pv_lim：0 = 没加 / 1 = 已加 1，穿上加、脱下减，避免重登叠加。
# 【外观】尚未画。
# ============================================================
give @s netherite_helmet[item_name={text:"枢",bold:true,color:light_purple},lore=[{"text":"精器 · 头盔 · 通用","color":"aqua","bold":true,"italic":false},{"text":" ","italic":false},{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +120。自身术阵位上限","color":"gray","italic":false},{"text":"+1。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["pivot","helmet","armor"],rarity:"t3",tags:["max_mana","formation"]},tooltip_display={hidden_components:["unbreakable"]},item_model="fallendream:armor_pivot",equippable={slot:"head",asset_id:"fallendream:armor_pivot",equip_sound:"minecraft:item.armor.equip_netherite"}]
