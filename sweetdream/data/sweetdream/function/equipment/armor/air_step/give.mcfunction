# ============================================================
# sweetdream:equipment/armor/air_step/give —— 给一件「踏空」（罕见 · 靴子）
# ------------------------------------------------------------
# 【custom_data】"air_step" -> 装备 id; 判定写 custom_data~{zx:["air_step"]}
# 【机制】魔力 +50；从空中落地 → 4 格内全部生物受 基础攻击力 伤害 + 击飞 1 格，
#   自身回 10 魔力；每 10 秒最多一次。
# 【★ 落地检测 ★】不用 `@a[nbt={OnGround:1b}]`（玩家 NBT 序列化 ≈10 ms/次，卡顿坑 1）。
#   改走进度 minecraft:fall_from_height（落地那一刻抛一次，事件型、可 revoke），
#   conditions 只要 distance.y ≥ 0.5（跳一下就够，排除走台阶）。
# 【外观】尚未画。
# ============================================================
give @s netherite_boots[item_name={text:"踏空",bold:true,color:aqua},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身魔力值上限 +50。自身从空中落地时，","color":"gray","italic":false},{"text":"对自身 4 格内的全部生物造成一次相当于","color":"gray","italic":false},{"text":"自身基础攻击力的伤害，并使其击飞 1 格，","color":"gray","italic":false},{"text":"之后自身恢复 10 点魔力值。该效果每 10","color":"gray","italic":false},{"text":"秒最多触发一次。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["air_step","boots","armor"],tags:["max_mana","base_atk","dash","debuff"]},tooltip_display={hidden_components:["unbreakable"]},item_model="sweetdream:armor_air_step",equippable={slot:"feet",asset_id:"sweetdream:armor_air_step",equip_sound:"minecraft:item.armor.equip_netherite"}]
