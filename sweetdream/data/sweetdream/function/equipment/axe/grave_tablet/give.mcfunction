# ============================================================
# sweetdream:equipment/axe/grave_tablet/give —— 给一件「断碑」（传说 · 斧）
# ------------------------------------------------------------
# 【custom_data】
#   "grave_tablet" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["grave_tablet"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 主动技能
# 【底材】netherite_axe（传说 = netherite）—— 本包的"阶段"只由底材判定
#
# 【这个文件是生成的】改描述请改 .workbuddy/_gen_batch18.py 的 LORE、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# 【外观】★ 尚未做 —— 所以**故意不挂 item_model**。挂上会指向不存在的
#   assets/sweetdream/items/grave_tablet.json ⇒ 紫黑方块且零日志（坑 195）。
#   补外观的顺序：_gen_late_icons.py 出贴图 -> _gen_late_rp.py 接线 -> 本文件 MODEL=True。
# ============================================================
give @s netherite_axe[item_name={text:"断碑",bold:true,color:dark_gray},lore=[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"300","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"45 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后向准星方向砸出一道长 6 格的裂口，","color":"gray","italic":false},{"text":"对裂口上及两侧 1.5 格内的全部生物造成","color":"gray","italic":false},{"text":"相当于自身基础攻击力 ×4 的真实伤害。","color":"gray","italic":false},{"text":"若目标护甲值不低于 15，该次伤害提高","color":"gray","italic":false},{"text":"80%。每命中一个生物，本技能的冷却时间","color":"gray","italic":false},{"text":"减少 6 秒，单次最多减少 30 秒。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["grave_tablet","axe","itemreplace"],skill:"sweetdream:grave_tablet",tags:["true_dmg","base_atk","cd_down"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
