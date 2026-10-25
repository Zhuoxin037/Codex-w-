# ============================================================
# sweetdream:equipment/sword/chengxing/give —— 给一件「秤星」（传说 · 剑）
# ------------------------------------------------------------
# 【custom_data】
#   "chengxing" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["chengxing"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 被动技能
# 【底材】netherite_sword（传说 = netherite）—— 本包的"阶段"只由底材判定
#
# 【这个文件是生成的】改描述请改 .workbuddy/_gen_batch17.py 的 LORE、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# 【外观】★ 尚未做 —— 所以**故意不挂 item_model**。挂上会指向不存在的
#   assets/sweetdream/items/chengxing.json ⇒ 紫黑方块且零日志（坑 195）。
#   补外观的顺序：_gen_late_icons.py 出贴图 -> _gen_late_rp.py 接线 -> 本文件 MODEL=True。
# ============================================================
give @s netherite_sword[item_name={text:"秤星",bold:true,color:gold},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"每次普通攻击额外附带一次固定伤害，数","color":"gray","italic":false},{"text":"值为（自身护甲韧性 + 自身护甲值）×2，","color":"gray","italic":false},{"text":"该伤害不受任何加成影响。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["chengxing","sword","itemreplace"],tags:["flat","base_atk"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
