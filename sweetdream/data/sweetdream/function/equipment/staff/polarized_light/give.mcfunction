# ============================================================
# sweetdream:equipment/staff/polarized_light/give —— 给一件「偏振光」（法杖）
# ------------------------------------------------------------
# 【custom_data】
#   "polarized_light" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["polarized_light"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【数值要和 cast 对上】普攻 魔力 10 / 伤害 6; 技能 魔力 80 / 冷却 20 秒 / 持续 5 秒。
# 【"持续发射一道光线"】是表现层(粒子/端点连线), 伤害走每秒一次的检测。
# 【模型】2026-10-10 用户批准独立16×16法杖贴图，绑定完整版资源包。
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch5.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ============================================================
give @s recovery_compass[item_model="sweetdream:polarized_light",max_stack_size=1,item_name={text:"偏振光",bold:true,color:white},lore=[{"text":"✦ 普攻","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"10","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"伤害 ","color":"gray"},{"text":"6","color":"yellow"}]},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"80","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"20 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后召唤一个术阵。之后自身持续发射","color":"gray","italic":false},{"text":"一道光线且每秒对自身 10 格内离自己最","color":"gray","italic":false},{"text":"近的一个生物造成一次相当于自身当前魔","color":"gray","italic":false},{"text":"力值 ×0.05 的伤害，且被锁定的生物获得","color":"gray","italic":false},{"text":"缓慢Ⅱ效果。该效果持续 5 秒。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["polarized_light","staff","itemreplace"],skill:"sweetdream:polarized_light",tags:["cur_mana","formation","slow","debuff"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
