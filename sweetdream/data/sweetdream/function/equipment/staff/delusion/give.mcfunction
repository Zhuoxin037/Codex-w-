# ============================================================
# sweetdream:equipment/staff/delusion/give —— 给一件「惑梦」（法杖）
# ------------------------------------------------------------
# 【custom_data】
#   "delusion" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["delusion"]}(部分匹配 + 独有标记)
# 【数值要和 cast 对上】普攻 魔力 20; 技能 魔力 300 / 冷却 60 秒。
# 【两段分支】先看锁定的那只"在不在时停里"再决定走哪一段,
#   注意别写成"先时停 2 秒再看"(那样第二段的判定永远成立)。
# 【模型】**故意不写 item_model** —— 写了就会变成「风行于大地之上」
#   (包里只有 naturewind:staff 一个法杖模型)。用户 2026-10-05 定:
#   法杖就长成 recovery_compass 追溯指针的原版样子, 四根一样也没关系,
#   等以后自己画好模型再单独加 item_model 这一项。
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch5.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ============================================================
give @s recovery_compass[max_stack_size=1,item_name={text:"惑梦",bold:true,color:light_purple},lore=[{"text":"✦ 普攻","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"20","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"伤害 ","color":"gray"},{"text":"最大魔力值 ×0.02","color":"yellow"}]},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"300","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"60 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后召唤一个术阵。之后锁定 8 格内离","color":"gray","italic":false},{"text":"自身最近的一个生物，之后使其 3 格内的","color":"gray","italic":false},{"text":"全部生物时停 2 秒。若锁定的生物处于时","color":"gray","italic":false},{"text":"停状态则改为使其 5 格内的全部生物受到","color":"gray","italic":false},{"text":"一次相当于自身最大魔力值 ×0.1 的伤害","color":"gray","italic":false},{"text":"并时停 3 秒。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["delusion","staff","itemreplace"],skill:"sweetdream:delusion"},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
