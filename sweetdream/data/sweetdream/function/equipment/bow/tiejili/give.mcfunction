# ============================================================
# sweetdream:equipment/bow/tiejili/give —— 给一件「铁蒺藜」（稀有 · 弩）
# ------------------------------------------------------------
# 【custom_data】
#   "tiejili" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["tiejili"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 主动技能
# 【底材】crossbow（稀有 = iron）—— 本包的"阶段"只由底材判定
#
# 【这个文件是生成的】改描述请改 .workbuddy/_gen_batch17.py 的 LORE、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# 【外观】★ 尚未做 —— 所以**故意不挂 item_model**。挂上会指向不存在的
#   assets/sweetdream/items/crossbow_tiejili.json ⇒ 紫黑方块且零日志（坑 195）。
#   补外观的顺序：_gen_late_icons.py 出贴图 -> _gen_late_rp.py 接线 -> 本文件 MODEL=True。
# ============================================================
give @s crossbow[item_name={text:"铁蒺藜",bold:true,color:gray},lore=[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"150","color":"aqua"}]},{"text":" ","italic":false},{"text":"每次射击命中后，在箭矢落点撒下半径","color":"gray","italic":false},{"text":"2.5 格的蒺藜，持续 5 秒。蒺藜内的生物","color":"gray","italic":false},{"text":"每秒受到一次等同于自身基础攻击力的伤","color":"gray","italic":false},{"text":"害，并获得 2 秒缓慢Ⅱ。离开蒺藜后减速","color":"gray","italic":false},{"text":"立刻消失。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["tiejili","bow"],tags:["slow","debuff","field"]},enchantments={"sweetdream:tiejili":1},enchantment_glint_override=false,tooltip_display={hidden_components:["unbreakable","enchantments"]}]
