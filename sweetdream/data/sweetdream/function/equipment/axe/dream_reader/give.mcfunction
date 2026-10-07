# ============================================================
# sweetdream:equipment/axe/dream_reader/give —— 给一件「释梦」（斧）
# ------------------------------------------------------------
# 【custom_data】
#   "dream_reader" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["dream_reader"]}(部分匹配 + 独有标记)
# 【被动 + 主动】被动: 打时停目标额外 5×剩余时停秒数的真伤, 之后解除其停。
#   主动: 200 / 40 秒 -> 召唤 3 个“入梦体”。
#   “入梦体”10 格或造成伤害后自毁, 自动追最近生物 -> 当前魔力 ×0.1 + 时停 3 秒 + 白昼梦。
# 【不同入梦体不追同一个】实装要判重目标。
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch6.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ============================================================
give @s diamond_axe[item_name={text:"释梦",bold:true,color:light_purple},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"攻击处于时停状态的生物时对其额外造成","color":"gray","italic":false},{"text":"5× 剩余时停时间的真实伤害，之后解除他","color":"gray","italic":false},{"text":"的时停状态。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"200","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"40 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后召唤 3 个“入梦体”。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 入梦体","color":"gold","bold":true,"italic":false},{"text":"“入梦体”会在离自身 10 格远或对生物","color":"gray","italic":false},{"text":"造成伤害后自毁。“入梦体”会自动追踪","color":"gray","italic":false},{"text":"离其最近的生物并对其造成相当于释放者","color":"gray","italic":false},{"text":"当前魔力值 ×0.1 的伤害，之后使其时停","color":"gray","italic":false},{"text":"3 秒并附加「白昼梦」效果。（不同入梦","color":"gray","italic":false},{"text":"体不会追踪同一个目标）","color":"gray","italic":false}],unbreakable={},custom_data={zx:["dream_reader","axe","itemreplace"],skill:"sweetdream:dream_reader"},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
