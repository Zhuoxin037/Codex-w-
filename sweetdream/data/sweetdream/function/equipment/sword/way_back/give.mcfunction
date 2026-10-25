# ============================================================
# sweetdream:equipment/sword/way_back/give —— 给一件「归途」（史诗 · 剑）
# ------------------------------------------------------------
# 【custom_data】
#   "way_back" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["way_back"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 主动技能
# 【底材】diamond_sword（史诗 = diamond）—— 本包的"阶段"只由底材判定
#
# 【这个文件是生成的】改描述请改 .workbuddy/_gen_batch18.py 的 LORE、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# 【外观】★ 尚未做 —— 所以**故意不挂 item_model**。挂上会指向不存在的
#   assets/sweetdream/items/way_back.json ⇒ 紫黑方块且零日志（坑 195）。
#   补外观的顺序：_gen_late_icons.py 出贴图 -> _gen_late_rp.py 接线 -> 本文件 MODEL=True。
# ============================================================
give @s diamond_sword[item_name={text:"归途",bold:true,color:gold},lore=[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"240","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"40 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后在脚下放下一盏“归途灯”，持续","color":"gray","italic":false},{"text":"20 秒（冷却时间从放下灯时开始计算）。","color":"gray","italic":false},{"text":"期间再次使用该技能，立即瞬移回“归途","color":"gray","italic":false},{"text":"灯”处，并恢复这 20 秒内自身所受到伤","color":"gray","italic":false},{"text":"害的 50%（最多恢复最大生命值的 40%）。","color":"gray","italic":false},{"text":"若灯存在期间自身生命值从未低于 50%，","color":"gray","italic":false},{"text":"则瞬移后额外获得 3 秒迅捷Ⅱ。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["way_back","sword","itemreplace"],skill:"sweetdream:way_back",tags:["summon","dash","heal"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
