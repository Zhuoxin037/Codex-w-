# ============================================================
# sweetdream:equipment/bow/sculk_echo/give —— 给一件「幽匿残响」（弩）
# ------------------------------------------------------------
# 【custom_data】
#   "sculk_echo" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["sculk_echo"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【为什么底材是弩】弩有 minecraft:shot_crossbow 进度触发器, 天然对应"每次射击";
#   弓的右键是拉弓蓄力, 做不了这个事件(和「寒鸦」同一个道理)。
# 【所以没有 consumable / itemreplace】触发靠 shot_crossbow 进度。
# 【弩上的附魔】sweetdream:sculk_echo(见 enchantment/sculk_echo.json),
#   只在"这把弩射出的箭打中生物"时回调 hook_victim 结算 —— 命中判定交给原版。
#   ⚠️ 附魔是注册表内容: 装好后要**退出世界重进**(光 /reload 不补)。
# 【"每刻"的伤害】发射路径周围 2 格那条是 along-ray 的每刻检测, 别用
#   schedule(同名 schedule 会互相顶掉, 见 RULES 坑 8)。
# 【主动技能 = 射击本身】不是右键释放 —— 触发走 minecraft:shot_crossbow,
#   所以**不加 consumable / itemreplace**; 也没有冷却 => **不加 skill 字段**。
#   (描述标题写「✦ 主动技能」但正文仍写「每次射击」, 因为就是每次射击生效。)
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch5.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ============================================================
give @s crossbow[item_model="sweetdream:crossbow_sculk_echo",item_name={text:"幽匿残响",bold:true,color:dark_aqua},lore=[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"100","color":"aqua"}]},{"text":" ","italic":false},{"text":"每次射击会额外积攒 10 点「悲鸣」","color":"gray","italic":false},{"text":"（上限 50 点）","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 悲鸣","color":"gold","bold":true,"italic":false},{"text":"每次射击后都会对被射击的生物的 2 格内","color":"gray","italic":false},{"text":"额外造成相当于自身基础攻击力 ×","color":"gray","italic":false},{"text":"「悲鸣」值 ×0.1 的伤害，同时对发射路","color":"gray","italic":false},{"text":"径周围 2 格的敌人每刻造成相当于","color":"gray","italic":false},{"text":"「悲鸣」值 ×0.1 的伤害。每 1 点","color":"gray","italic":false},{"text":"「悲鸣」会使该伤害有 1% 概率造成三倍","color":"gray","italic":false},{"text":"伤害，触发后清除全部「悲鸣」。","color":"gray","italic":false}],unbreakable={},enchantments={"sweetdream:sculk_echo":1},enchantment_glint_override=false,custom_data={zx:["sculk_echo","bow"],tags:["base_atk"]},tooltip_display={hidden_components:["unbreakable","enchantments"]}]
