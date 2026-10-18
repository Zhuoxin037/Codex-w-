# ============================================================
# sweetdream:equipment/staff/renew_fire/give —— 给一件「续火」（稀有 · 法杖）
# ------------------------------------------------------------
# 【custom_data】
#   "renew_fire" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["renew_fire"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 普攻 ｜ ✦ 主动技能
# 【底材】recovery_compass（稀有 = iron）
#
# 【这个文件是生成的】改描述请改 .workbuddy/_new42_lore.py、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# 【外观】批 16（2026-10-18）补齐：item_model 指向 sweetdream:renew_fire
#   （贴图源 _gen_late_icons.py，接线 _gen_late_rp.py）。
# ============================================================
give @s recovery_compass[max_stack_size=1,item_name={text:"续火",bold:true,color:gold},lore=[{"text":"✦ 普攻","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"20","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"伤害 ","color":"gray"},{"text":"5","color":"yellow"}]},{"text":" ","italic":false},{"text":"每次普攻命中后累计一次，每累计 3 次则","color":"gray","italic":false},{"text":"恢复自身 1 点生命值。切换武器后清空次","color":"gray","italic":false},{"text":"数。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"50","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"30 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后恢复自身 8 点生命值。自身生命值","color":"gray","italic":false},{"text":"为满时无法使用。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["renew_fire","staff","itemreplace"],skill:"sweetdream:renew_fire",tags:["heal"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]},item_model="sweetdream:renew_fire"]
