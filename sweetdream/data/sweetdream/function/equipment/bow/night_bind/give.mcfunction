# ============================================================
# sweetdream:equipment/bow/night_bind/give —— 给一件「夜缚」（稀有 · 弩）
# ------------------------------------------------------------
# 【custom_data】
#   "night_bind" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["night_bind"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 主动技能
# 【底材】crossbow（未分档：这类装备的底物没有材质档）
#
# 【这个文件是生成的】改描述请改 .workbuddy/_gen_batch18.py 的 LORE、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# 【外观】★ 尚未做 —— 所以**故意不挂 item_model**。挂上会指向不存在的
#   assets/sweetdream/items/crossbow_night_bind.json ⇒ 紫黑方块且零日志（坑 195）。
#   补外观的顺序：_gen_late_icons.py 出贴图 -> _gen_late_rp.py 接线 -> 本文件 MODEL=True。
# ============================================================
give @s crossbow[item_name={text:"夜缚",bold:true,color:dark_purple},lore=[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"80","color":"aqua"}]},{"text":" ","italic":false},{"text":"每次射击命中了附有「夜火」的生物后，","color":"gray","italic":false},{"text":"额外对其造成一次相当于自身基础攻击力","color":"gray","italic":false},{"text":"×5 的伤害，并使其获得缓慢Ⅱ，持续 4","color":"gray","italic":false},{"text":"秒；箭矢随后从其身上弹向 6 格内最近的","color":"gray","italic":false},{"text":"另一个敌对生物，造成该次额外技能伤害","color":"gray","italic":false},{"text":"数值 60% 的伤害。该效果不消耗「夜火」。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["night_bind","bow"],tags:["yehuo","slow","debuff"]},enchantments={"sweetdream:night_bind":1},enchantment_glint_override=false,tooltip_display={hidden_components:["unbreakable","enchantments"]}]
