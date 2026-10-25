# ============================================================
# sweetdream:equipment/axe/xiugou/give —— 给一件「锈犬」（稀有 · 斧）
# ------------------------------------------------------------
# 【custom_data】
#   "xiugou" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["xiugou"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 主动技能
# 【底材】iron_axe（稀有 = iron）—— 本包的"阶段"只由底材判定
#
# 【这个文件是生成的】改描述请改 .workbuddy/_gen_batch17.py 的 LORE、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# 【外观】★ 尚未做 —— 所以**故意不挂 item_model**。挂上会指向不存在的
#   assets/sweetdream/items/xiugou.json ⇒ 紫黑方块且零日志（坑 195）。
#   补外观的顺序：_gen_late_icons.py 出贴图 -> _gen_late_rp.py 接线 -> 本文件 MODEL=True。
# ============================================================
give @s iron_axe[item_name={text:"锈犬",bold:true,color:gold},lore=[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"90","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"32 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后在自身身前 2 格召唤“锈犬”，持","color":"gray","italic":false},{"text":"续 10 秒。锈犬每秒撕咬自身 3 格内最近","color":"gray","italic":false},{"text":"的一个生物，造成一次等同于自身基础攻","color":"gray","italic":false},{"text":"击力的伤害，最多撕咬 10 次。同一时间","color":"gray","italic":false},{"text":"只能存在一只“锈犬”，再次使用时先收","color":"gray","italic":false},{"text":"回原有的。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["xiugou","axe","itemreplace"],skill:"sweetdream:xiugou",tags:["summon","base_atk"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
