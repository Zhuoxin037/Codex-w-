# ============================================================
# sweetdream:equipment/staff/thunderrod/give —— 给一件「引雷针」（法杖 · 过渡）
# ------------------------------------------------------------
# 【custom_data】
#   "thunderrod" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["thunderrod"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(词表/逐件表见 .workbuddy/_tags_data.py)
# 【数值要和实现对上】普攻 魔力 20 / 伤害 1; 命中 1 秒后在命中点落雷;
#   主动技能 魔力 150 / 冷却 35 秒(8 格内至多 3 个目标各落一道雷)。
#   ★ 2026-10-13 起**不再有自身伤害**(原"当前魔力 ×0.03 / ×0.05"砍掉:
#     落点 2 格选不到人 + 普攻 0.5 秒一发会超模, 用户拍板)。
# 【★ 差异化 ★】现有闪电(负离子 / 超•负•荷 / 威霆)全是"随机 N 个目标"或
#   "每秒随机一个"; 引雷针是**你打谁劈谁** —— 落点由玩家指定, 法杖里唯一一件。
# 【为什么是过渡】低倍率、机制单一直白、无需前置(打谁劈谁, 不用铺状态)。
# ★ 本批**不挂 item_model**(批 12 外观未做; 挂了会引用不存在的模型 -> 紫黑方块)。
# 【手写文件】不是 _gen_batch*.py 的产物, 别被生成器覆盖。
# ============================================================
give @s recovery_compass[max_stack_size=1,item_name={text:"引雷针",bold:true,color:yellow},lore=[{"text":"✦ 普攻","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"20","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"伤害 ","color":"gray"},{"text":"1","color":"yellow"}]},{"text":" ","italic":false},{"text":"每次普攻命中后，1 秒后在目标所在位置","color":"gray","italic":false},{"text":"降下一道闪电。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"150","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"35 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后对自身 8 格内至多 3 个生物各降","color":"gray","italic":false},{"text":"下一道闪电。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["thunderrod","staff","itemreplace"],skill:"sweetdream:thunderrod",tags:["lightning","debuff"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
