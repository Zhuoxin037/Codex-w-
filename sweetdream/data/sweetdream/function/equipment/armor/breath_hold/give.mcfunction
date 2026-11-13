# ============================================================
# sweetdream:equipment/armor/breath_hold/give —— 给一件「屏息」（罕见 · 头盔）
# ------------------------------------------------------------
# 【custom_data】"breath_hold" -> 装备 id; 判定写 custom_data~{zx:["breath_hold"]}
# 【机制】魔力 +60；每 1 个空闲术阵位 → 每秒回 2 魔力；全满时改为每秒回 1 魔力。
# 【★ 空闲数 = 上限 − 占用 ★】用 lib/fm/read 每秒下发的 zx.fm_u / zx.fm_c。
#   全满（空闲 0）也给 1 点 —— 文案明写"改为"，不是 0。
# 【外观】尚未画。
# ============================================================
give @s netherite_helmet[item_name={text:"屏息",bold:true,color:aqua},lore=[{"text":"异器 · 头盔 · 通用","color":"gray","bold":true,"italic":false},{"text":" ","italic":false},{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +60。每有 1 个空闲术阵","color":"gray","italic":false},{"text":"位，自身每秒恢复 2 点魔力值。术阵位全","color":"gray","italic":false},{"text":"满时，改为每秒恢复 1 点魔力值。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["breath_hold","helmet","armor"],rarity:"t2",tags:["max_mana","formation"]},tooltip_display={hidden_components:["unbreakable"]},item_model="sweetdream:armor_breath_hold",equippable={slot:"head",asset_id:"sweetdream:armor_breath_hold",equip_sound:"minecraft:item.armor.equip_netherite"}]
