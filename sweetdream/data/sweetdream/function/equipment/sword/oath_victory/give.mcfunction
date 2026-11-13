# ============================================================
# sweetdream:equipment/sword/oath_victory/give —— 给一件「胜利誓约」（传说 · 剑）
# ------------------------------------------------------------
# 【custom_data】"oath_victory" -> 装备 id; 判定一律写 custom_data~{zx:["oath_victory"]}
# 【被动】每次普攻命中生物后 20% 概率 +5 点临时生命值（走 lib/thp，硬上限 最大生命×2）。
#   触发口 = 进度 player_hurt_entity（只算平A），同刻去重 zx.ov_lt。
# 【主动】200 魔力 / 10 秒：突击到 5 格内生物背后 + 基础攻击力 ×5 伤害，
#   停留处展开半径 3 / 6 秒领域；自身在领域内每秒恢复 3 点生命 + 20% 最大生命的临时生命。
# 【★ 实装必读 ★】
#   ① 突击用 `at <target> rotated as <target> run tp @s ^ ^ ^-1.5` —— `at` 只换位置
#      基点、`rotated as` 只换朝向, `^` 的原点因此落在目标处、方向是目标背后。
#      **不要**读 Pos 自己算（精度差且多一次 NBT）。
#   ② 领域是地面上的区域：施法者走开就拿不到回复 ⇒ field_tick 每秒用 lib/u_by 反查
#      施法者并判 3 格距离，**不是**"给玩家挂计时"。
#   ③ 领域必须占 1 个术阵位（包内口径：领域 = 范围增益/减益）—— 但本件文案没写术阵，
#      故按「领域」实现，不登记 manacore 术阵（与神裁同款口径，见 verdict）。
# 【外观】已画（2026-10-27）。图标唯一真相来源 `.workbuddy/_gen_oath_victory_icon.py`：
#   骨架 hengdao + 分区换色（香槟金白刃 / 亮金护手 / 宝石红柄）+ 柄尾金坠。
#   三层链路：items/oath_victory.json → models/item/vanilla/oath_victory.json → 贴图。
# ============================================================
give @s netherite_sword[item_name={text:"胜利誓约",bold:true,color:gold},lore=[{"text":"秘器 · 剑 · 通用","color":"gold","bold":true,"italic":false},{"text":" ","italic":false},{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"每次普攻命中生物后，有 20% 的概率使自","color":"gray","italic":false},{"text":"身获得 5 点临时生命值。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"200","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"10 秒","color":"yellow"}]},{"text":"使用后立即突击到自身 5 格内的生物后方，","color":"gray","italic":false},{"text":"并对其造成一次相当于自身基础攻击力 ×5","color":"gray","italic":false},{"text":"的伤害。之后自身在停留处展开一个半径","color":"gray","italic":false},{"text":"3 格、持续 6 秒的领域，自身在领域内时","color":"gray","italic":false},{"text":"每秒恢复 3 点生命值并获得相当于自身最","color":"gray","italic":false},{"text":"大生命值 ×0.2 的临时生命值。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["oath_victory","sword","itemreplace"],rarity:"t4",skill:"sweetdream:oath_victory",tags:["base_atk","max_mana","max_hp","dash","field","heal","buff"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]},item_model="sweetdream:oath_victory"]
