# ============================================================
# sweetdream:equipment/staff/long_night/give —— 给一件「长夜」（传说 · 法杖）
# ------------------------------------------------------------
# 【custom_data】
#   "long_night" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["long_night"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 普攻 ｜ ✦ 主动技能 ｜ ✦ 夜原
# 【底材】recovery_compass（传说 = netherite）
#
# 【这个文件是生成的】改描述请改 .workbuddy/_new42_lore.py、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# 【外观】批 16（2026-10-18）补齐：item_model 指向 sweetdream:long_night
#   （贴图源 _gen_late_icons.py，接线 _gen_late_rp.py）。
# ============================================================
give @s recovery_compass[max_stack_size=1,item_name={text:"长夜",bold:true,color:dark_purple},lore=[{"text":"✦ 普攻","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"60","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"伤害 ","color":"gray"},{"text":"最大魔力值 ×0.025","color":"yellow"}]},{"text":" ","italic":false},{"text":"每次普攻命中了附有「夜火」的生物后，","color":"gray","italic":false},{"text":"为自身恢复 30 点魔力值（2 秒内最多一","color":"gray","italic":false},{"text":"次）。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"400","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"80 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后召唤一个术阵，并在自身位置生成","color":"gray","italic":false},{"text":"半径 6 格的“夜原”，持续 8 秒。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 夜原","color":"gold","bold":true,"italic":false},{"text":"每秒消耗其中一个生物的「夜火」并使其","color":"gray","italic":false},{"text":"附加「流火」，且其护甲值及护甲韧性","color":"gray","italic":false},{"text":"-60%。之后对其造成一次相当于自身最大","color":"gray","italic":false},{"text":"魔力值 ×0.12 的伤害。每消耗一次，则“","color":"gray","italic":false},{"text":"夜原”的后续伤害提高 8%（独立乘区）。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["long_night","staff","itemreplace"],skill:"sweetdream:long_night",tags:["liuhuo","yehuo","max_mana","debuff","consume","apply","indep_mul","summon","formation"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]},item_model="sweetdream:long_night"]
