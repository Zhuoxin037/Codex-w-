# ============================================================
# sweetdream:equipment/staff/cage_day/give —— 给一件「囚昼」（史诗 · 法杖）
# ------------------------------------------------------------
# 【custom_data】
#   "cage_day" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["cage_day"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 普攻 ｜ ✦ 主动技能
# 【底材】recovery_compass（未分档：这类装备的底物没有材质档）
#
# 【这个文件是生成的】改描述请改 .workbuddy/_gen_batch18.py 的 LORE、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# 【外观】★ 尚未做 —— 所以**故意不挂 item_model**。挂上会指向不存在的
#   assets/sweetdream/items/cage_day.json ⇒ 紫黑方块且零日志（坑 195）。
#   补外观的顺序：_gen_late_icons.py 出贴图 -> _gen_late_rp.py 接线 -> 本文件 MODEL=True。
# ============================================================
give @s recovery_compass[item_name={text:"囚昼",bold:true,color:dark_purple},lore=[{"text":"✦ 普攻","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"60","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"伤害 ","color":"gray"},{"text":"自身最大魔力值 ×0.025","color":"yellow"}]},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"240","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"45 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"潜行时使用后，选中自身 8 格内最近的一","color":"gray","italic":false},{"text":"个敌对生物，使其附加「白昼梦」，持续","color":"gray","italic":false},{"text":"8 秒，并对其 5 格内的全部生物造成相当","color":"gray","italic":false},{"text":"于自身最大魔力值 ×0.12 的伤害。若选中","color":"gray","italic":false},{"text":"的生物已附有「白昼梦」，则该次伤害提","color":"gray","italic":false},{"text":"高 30%，并将其「白昼梦」扩散给 5 格内","color":"gray","italic":false},{"text":"最近的另外三个生物。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["cage_day","staff","itemreplace"],skill:"sweetdream:cage_day",tags:["dream","apply","base_atk","debuff","max_mana"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]},max_stack_size=1]
