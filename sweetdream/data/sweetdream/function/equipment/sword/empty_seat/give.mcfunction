# ============================================================
# sweetdream:equipment/sword/empty_seat/give —— 给一件「虚位」（史诗 · 剑）
# ------------------------------------------------------------
# 【custom_data】
#   "empty_seat" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["empty_seat"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 被动技能 ｜ ✦ 主动技能
# 【底材】diamond_sword（史诗 = diamond）—— 本包的"阶段"只由底材判定
#
# 【这个文件是生成的】改描述请改 .workbuddy/_gen_batch18.py 的 LORE、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# 【外观】★ 尚未做 —— 所以**故意不挂 item_model**。挂上会指向不存在的
#   assets/sweetdream/items/empty_seat.json ⇒ 紫黑方块且零日志（坑 195）。
#   补外观的顺序：_gen_late_icons.py 出贴图 -> _gen_late_rp.py 接线 -> 本文件 MODEL=True。
# ============================================================
give @s diamond_sword[item_name={text:"虚位",bold:true,color:white},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"每个空置的术阵位，使自身每次普通攻击","color":"gray","italic":false},{"text":"额外造成 4 点固定伤害。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"220","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"35 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后清空自身全部术阵位，对前方 3 格","color":"gray","italic":false},{"text":"内的全部生物造成（6 × 清空的术阵位数）","color":"gray","italic":false},{"text":"点固定伤害，并使其获得 5 秒虚弱Ⅱ。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["empty_seat","sword","itemreplace"],skill:"sweetdream:empty_seat",tags:["flat","formation","debuff"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
