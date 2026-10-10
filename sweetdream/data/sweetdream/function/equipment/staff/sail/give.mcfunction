# ============================================================
# sweetdream:equipment/staff/sail/give —— 给一件「风帆」（法杖）
# ------------------------------------------------------------
# 【custom_data】
#   "sail" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["sail"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【普攻 + 主动】普攻 80 / 伤害 1; 每次普攻后记录"最近一个生物"身上的渊海/流火/白昼梦/噬心。
#   主动 500 / 100 秒 -> 在被记录生物处生成旋风, 持续 15 秒。
#   旋风每 3 秒吸引 5 格内生物 + 附加"记录到的随机一种属性"。
#   期间可再按一次技能把该旋风召唤到身边(成功则本技能冷却 -3 秒)。
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch6.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ============================================================
give @s recovery_compass[max_stack_size=1,item_model="sail:staff",custom_model_data={floats:[0.0f,0.0f]},item_name={text:"风帆",bold:true,color:white},lore=[{"text":"✦ 普攻","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"80","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"伤害 ","color":"gray"},{"text":"1","color":"yellow"}]},{"text":" ","italic":false},{"text":"每次普攻后都会记录离自身最近的一个生","color":"gray","italic":false},{"text":"物上所拥有的「渊海」、「流火」、","color":"gray","italic":false},{"text":"「白昼梦」、「噬心」。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"500","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"100 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后在被自身记录的生物处生成一个“","color":"gray","italic":false},{"text":"旋风”。“旋风”每 3 秒都会吸引一次其","color":"gray","italic":false},{"text":"5 格内的生物并使其附加被自身记录的生","color":"gray","italic":false},{"text":"物的随机一种属性。期间自身可以再次使","color":"gray","italic":false},{"text":"用技能来将该“旋风”召唤至自身处，持","color":"gray","italic":false},{"text":"续 15 秒。若自身召唤了该“旋风”则技","color":"gray","italic":false},{"text":"能缩短 3 秒。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["sail","staff","itemreplace"],skill:"sweetdream:sail",tags:["yuanhai","liuhuo","dream","shixin","attract","apply","summon"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
