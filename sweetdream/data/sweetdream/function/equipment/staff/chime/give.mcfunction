# ============================================================
# sweetdream:equipment/staff/chime/give —— 给一件「共鸣」（法杖）
# ------------------------------------------------------------
# 【custom_data】
#   "chime" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["chime"]}(部分匹配 + 独有标记)
# 【普攻 + 主动】普攻 12 / 伤害 7。主动 140 / 40 秒 -> 术阵 + 原地“共鸣水晶”。
#   “共鸣水晶”每 2 秒打 6 格内一个生物 ×0.03; 法术穿过时 3 格内全体 ×0.05; 8 秒自毁。
# 【模型】法杖不写 item_model(只有 naturewind:staff 一个模型, 写了会串外观)。
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch6.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ============================================================
give @s recovery_compass[max_stack_size=1,item_name={text:"共鸣",bold:true,color:aqua},lore=[{"text":"✦ 普攻","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"12","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"伤害 ","color":"gray"},{"text":"7","color":"yellow"}]},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"140","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"40 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后召唤一个术阵。之后在原地生成一","color":"gray","italic":false},{"text":"个“共鸣水晶”。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 共鸣水晶","color":"gold","bold":true,"italic":false},{"text":"每 2 秒都会对其 6 格内的一个生物造成","color":"gray","italic":false},{"text":"一次相当于自身最大魔力值 ×0.03 的伤害。","color":"gray","italic":false},{"text":"自身释放的法术穿过“共鸣水晶”时会立","color":"gray","italic":false},{"text":"即对其 3 格内的全部生物造成一次相当于","color":"gray","italic":false},{"text":"自身最大魔力值 ×0.05 的伤害。“共鸣水","color":"gray","italic":false},{"text":"晶”8 秒后自毁。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["chime","staff","itemreplace"],skill:"sweetdream:chime"},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
