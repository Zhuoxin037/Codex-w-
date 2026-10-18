# ============================================================
# sweetdream:equipment/staff/wake_bell/give —— 给一件「醒梦钟」（史诗 · 法杖）
# ------------------------------------------------------------
# 【custom_data】
#   "wake_bell" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["wake_bell"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 普攻 ｜ ✦ 主动技能
# 【底材】recovery_compass（史诗 = diamond）
#
# 【这个文件是生成的】改描述请改 .workbuddy/_new42_lore.py、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# 【外观】批 16（2026-10-18）补齐：item_model 指向 sweetdream:wake_bell
#   （贴图源 _gen_late_icons.py，接线 _gen_late_rp.py）。
# ============================================================
give @s recovery_compass[max_stack_size=1,item_name={text:"醒梦钟",bold:true,color:light_purple},lore=[{"text":"✦ 普攻","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"60","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"伤害 ","color":"gray"},{"text":"最大魔力值 ×0.02","color":"yellow"}]},{"text":" ","italic":false},{"text":"每次普攻命中后若其附有「白昼梦」，则","color":"gray","italic":false},{"text":"额外造成一次相当于自身最大魔力值","color":"gray","italic":false},{"text":"×0.02 的伤害。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"400","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"70 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后消耗自身 8 格内最多 3 个生物的","color":"gray","italic":false},{"text":"「白昼梦」，并对其造成一次相当于自身","color":"gray","italic":false},{"text":"最大魔力值 ×0.1 的真实伤害。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["wake_bell","staff","itemreplace"],skill:"sweetdream:wake_bell",tags:["dream","max_mana","true_dmg","consume"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]},item_model="sweetdream:wake_bell"]
