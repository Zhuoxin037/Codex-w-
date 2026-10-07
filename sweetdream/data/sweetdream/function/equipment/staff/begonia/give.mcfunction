# ============================================================
# sweetdream:equipment/staff/begonia/give —— 给一件「海棠」（法杖）
# ------------------------------------------------------------
# 【custom_data】
#   "begonia" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["begonia"]}(部分匹配 + 独有标记)
# 【普攻 + 主动】普攻 30 / 伤害 当前魔力 ×0.02; 命中后轻微吸引其 1 格内至多 3 个生物。
#   主动 450 / 120 秒 -> 术阵; 把 16 格内最多 5 个附「渊海」的生物做成漩涡。
#   漩涡 8 秒每秒拉 4 格内生物回中心; 结束时中心生物吃 ×0.15; 之后清「渊海」。
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch6.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ============================================================
give @s recovery_compass[max_stack_size=1,item_name={text:"海棠",bold:true,color:dark_blue},lore=[{"text":"✦ 普攻","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"30","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"伤害 ","color":"gray"},{"text":"自身当前魔力 ×0.02","color":"yellow"}]},{"text":" ","italic":false},{"text":"每次普攻命中后都会使其轻微吸引一次其","color":"gray","italic":false},{"text":"1 格内的至多 3 个生物。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"450","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"120 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后召唤一个术阵。之后使自身 16 格","color":"gray","italic":false},{"text":"内的最多 5 个附有「渊海」的生物以自身","color":"gray","italic":false},{"text":"为中心生成一个漩涡。漩涡每秒都会将 4","color":"gray","italic":false},{"text":"格内的全部生物拉回中心一段距离，持续","color":"gray","italic":false},{"text":"8 秒。漩涡消失后会对处于中心的生物造","color":"gray","italic":false},{"text":"成相当于释放者最大魔力值 ×0.15 的伤害。","color":"gray","italic":false},{"text":"之后清除「渊海」。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["begonia","staff","itemreplace"],skill:"sweetdream:begonia"},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
