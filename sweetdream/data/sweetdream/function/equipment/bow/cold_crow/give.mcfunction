# ============================================================
# sweetdream:equipment/bow/cold_crow/give —— 给一把「寒鸦」
# ------------------------------------------------------------
# 【为什么底材是弩, 不是弓】
#   弓的右键是"拉弓蓄力", 没法当成"一次性触发"来用(也就没有'每次射击'这个事件);
#   弩有 minecraft:shot_crossbow 进度触发器, 天然对应"每次射击" —— 而且弩的
#   蓄力节奏正好配「冰凌」的层数机制。外观你以后用 Blockbench 套模型就行。
# 【所以这件没有 consumable / itemreplace】它不需要"右键消耗再还手"那一套;
#   触发靠 shot_crossbow 进度(算消耗/冰凌) + 弩上自带的附魔(判断有没有打中生物)。
# 【custom_data 两段】
#   "cold_crow" -> 武器 id
#   "bow"       -> 分类标记
#   skill       -> 观测镜靠它显示冷却, 必须和 cast 里传的 skill 一致
# 【★ 弩上那个附魔是什么 ★】
#   enchantments={levels:{"sweetdream:cold_crow":1}} = 数据包注册的附魔「霜矢」,
#   它没有任何数值效果, 只带一个 post_attack 回调: "这把弩射出的箭打中生物"时执行
#   cold_crow/hook_victim(顺带 hook_attacker 记下射手)。命中判定完全交给原版。
#   ⚠️ 附魔是**注册表**内容: 装好/改动后必须**退出世界再进**(光 /reload 不补)。
#      没注册时这条 give 会**加载失败**(日志里 "Failed to load function .../give"),
#      所以"give 不出来"= 你还没退出世界重进, 不是写法错。
#   ⚠️ 附魔名默认显示在物品说明里, 下面用 tooltip_display 把它藏掉。
# ============================================================

give @s crossbow[item_name={text:"寒鸦",bold:true,color:"aqua"},lore=[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"20 / 50 / 120 / 320","color":"aqua"}]},{"text":"","italic":false,"extra":[{"text":"（按「冰凌」层数）","color":"dark_gray"}]},{"text":" ","italic":false},{"text":"每次射击都会积攒一点「冰凌」。每次射","color":"gray","italic":false},{"text":"击都会根据弓目前的「冰凌」而改变魔力","color":"gray","italic":false},{"text":"消耗及射击效果。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 冰凌","color":"gold","bold":true,"italic":false},{"text":"● 一层：使被命中的生物冰冻 2 秒。","color":"gray","italic":false},{"text":"● 二层：使被命中的生物的 2 格内的全","color":"gray","italic":false},{"text":"   部生物冰冻 2 秒。","color":"gray","italic":false},{"text":"● 三层：使被命中的生物的 3 格内的全","color":"gray","italic":false},{"text":"   部生物冰冻 2 秒，并对其造成相当于","color":"gray","italic":false},{"text":"   自身最大魔力值 ×0.1 的伤害。","color":"gray","italic":false},{"text":"● 四层：使被命中的生物的 4 格内的全","color":"gray","italic":false},{"text":"   部生物冰冻 3 秒，并对其造成相当于","color":"gray","italic":false},{"text":"   自身最大魔力值 ×0.25 的伤害。之后","color":"gray","italic":false},{"text":"   清空全部「冰凌」。","color":"gray","italic":false}],unbreakable={},enchantments={"sweetdream:cold_crow":1},custom_data={zx:["cold_crow","bow"],skill:"sweetdream:cold_crow"},tooltip_display={hidden_components:["unbreakable","enchantments"]}]
