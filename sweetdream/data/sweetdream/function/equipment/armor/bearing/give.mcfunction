# ============================================================
# sweetdream:equipment/armor/bearing/give —— 给一件「承」（史诗 · 护腿）
# ------------------------------------------------------------
# 【custom_data】"bearing" -> 装备 id; 判定写 custom_data~{zx:["bearing"]}
# 【机制】魔力 +140；每占 1 术阵位 → 护甲 +2 / 韧性 +1（最多 3 层）；术阵为空时移速 +6%。
#   套装（枢 + 承）：术阵位全满 → 8 秒「阵成」（技能伤害 +15% 独立乘区 / 技能冷却 −10%）；
#   术阵自然结束或主动归还时返还 25 魔力；每 12 秒最多进入一次。
# 【★ 实装必读 ★】
#   ① 层数 = min(zx.fm_u, 3)，每秒重算（lib/fm/read 提供），用差值账本 zx.br_a / zx.br_t
#      换档 —— `attribute … modifier add` 同 id 重复会失败，必须先 remove。
#   ② 「阵成」的"技能冷却 −10%"**不能**写 stats.cooldown_reduction：那条属性被
#      upgrade/api/cd_stat 独占（它每秒整体覆盖）。改走 cooldown_start 事件，
#      对**刚进入冷却的那个技能** reduce 掉剩余时长的 10%（见 on_cast）。
#   ③ "术阵自然结束或主动归还时返还 25 魔力" ⇒ 挂在 #manacore:event/formation_remove 上。
#   ④ 「阵成」= 从"未满"变"满"的那一刻，不是"满着就一直触发"。
# 【外观】尚未画。
# ============================================================
give @s netherite_leggings[item_name={text:"承",bold:true,color:light_purple},lore=[{"text":"精器 · 护腿 · 通用","color":"aqua","bold":true,"italic":false},{"text":" ","italic":false},{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +140。每占用 1 个术阵","color":"gray","italic":false},{"text":"位，自身护甲值 +2、护甲韧性 +1","color":"gray","italic":false},{"text":"（最多 3 层）。自身术阵为空时，移动速","color":"gray","italic":false},{"text":"度 +6%。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 套装效果","color":"gold","bold":true,"italic":false},{"text":"● 枢","color":"gray","italic":false},{"text":"● 承","color":"gray","italic":false},{"text":" ","italic":false},{"text":"术阵位全满时获得 8 秒「阵成」：技能伤","color":"gray","italic":false},{"text":"害 +15%（独立乘区），技能冷却 -10%。","color":"gray","italic":false},{"text":"术阵自然结束或被主动归还时，返还 25","color":"gray","italic":false},{"text":"点魔力值。每 12 秒最多进入一次","color":"gray","italic":false},{"text":"「阵成」。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["bearing","leggings","armor"],rarity:"t3",tags:["max_mana","formation","buff","indep_mul","cd_down"]},tooltip_display={hidden_components:["unbreakable"]},item_model="sweetdream:armor_bearing",equippable={slot:"legs",asset_id:"sweetdream:armor_bearing",equip_sound:"minecraft:item.armor.equip_netherite"}]
