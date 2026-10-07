# ============================================================
# sweetdream:equipment/bow/bone_erode/give —— 给一件「蚀骨」（弩）
# ------------------------------------------------------------
# 【custom_data】
#   "bone_erode" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["bone_erode"]}(部分匹配 + 独有标记)
# 【衍生物】幽匿残响那条线的副产物, 也能直接 give 出来测。
# 【百分比消耗】消耗的是"本次射击所消耗的魔力值"的 20% —— 注意这是
#   **按比例**扣, 不是固定 20 点, 别写成常数。
# 【弩上的附魔】sweetdream:bone_erode(见 enchantment/bone_erode.json),
#   命中生物时回调 hook_victim 结算。⚠️ 装好后要**退出世界重进**。
# 【主动技能 = 射击本身】不是右键释放 —— 触发走 minecraft:shot_crossbow,
#   所以**不加 consumable / itemreplace**; 也没有冷却 => **不加 skill 字段**。
#   (描述标题写「✦ 主动技能」但正文仍写「每次射击」, 因为就是每次射击生效。)
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch5.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ============================================================
give @s crossbow[item_name={text:"蚀骨",bold:true,color:gray},lore=[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"20%","color":"aqua"}]},{"text":" ","italic":false},{"text":"每次射击都会对被射击的生物的 2 格内的","color":"gray","italic":false},{"text":"全部生物造成相当于本次射击所消耗的魔","color":"gray","italic":false},{"text":"力值 ×0.4 的伤害。","color":"gray","italic":false}],unbreakable={},enchantments={"sweetdream:bone_erode":1},custom_data={zx:["bone_erode","bow"]},tooltip_display={hidden_components:["unbreakable","enchantments"]}]
