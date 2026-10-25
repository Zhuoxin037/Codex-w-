# ============================================================
# sweetdream:equipment/sword/gousi/give —— 给一件「钩丝」（史诗 · 剑）
# ------------------------------------------------------------
# 【custom_data】
#   "gousi" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["gousi"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 主动技能
# 【底材】diamond_sword（史诗 = diamond）—— 本包的"阶段"只由底材判定
#
# 【这个文件是生成的】改描述请改 .workbuddy/_gen_batch17.py 的 LORE、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# 【外观】★ 尚未做 —— 所以**故意不挂 item_model**。挂上会指向不存在的
#   assets/sweetdream/items/gousi.json ⇒ 紫黑方块且零日志（坑 195）。
#   补外观的顺序：_gen_late_icons.py 出贴图 -> _gen_late_rp.py 接线 -> 本文件 MODEL=True。
# ============================================================
give @s diamond_sword[item_name={text:"钩丝",bold:true,color:dark_aqua},lore=[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"180","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"28 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后选中自身 8 格内最近的一个生物，","color":"gray","italic":false},{"text":"以每 0.25 秒 0.5 格的速度将其拉向自身，","color":"gray","italic":false},{"text":"最多拉动 6 格，在抵达身前 2 格或撞上","color":"gray","italic":false},{"text":"不可替换的方块时停下。拉到位置后，使","color":"gray","italic":false},{"text":"其获得 3 秒缓慢Ⅱ，并对其造成一次相当","color":"gray","italic":false},{"text":"于自身最大魔力值 ×0.12 的伤害，同时使","color":"gray","italic":false},{"text":"自身下一次以最大魔力值为基准的技能伤","color":"gray","italic":false},{"text":"害 +10%。若中途未能拉到，则改为造成一","color":"gray","italic":false},{"text":"次相当于自身最大魔力值 ×0.04 的伤害，","color":"gray","italic":false},{"text":"且不获得加成。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["gousi","sword","itemreplace"],skill:"sweetdream:gousi",tags:["attract","slow","debuff","indep_mul"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
