# ============================================================
# sweetdream:equipment/staff/stop_needle/give —— 给一件「停针」（史诗 · 法杖）
# ------------------------------------------------------------
# 【custom_data】
#   "stop_needle" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["stop_needle"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 普攻 ｜ ✦ 主动技能
# 【底材】recovery_compass（未分档：这类装备的底物没有材质档）
#
# 【这个文件是生成的】改描述请改 .workbuddy/_gen_batch18.py 的 LORE、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# 【外观】★ 尚未做 —— 所以**故意不挂 item_model**。挂上会指向不存在的
#   assets/sweetdream/items/stop_needle.json ⇒ 紫黑方块且零日志（坑 195）。
#   补外观的顺序：_gen_late_icons.py 出贴图 -> _gen_late_rp.py 接线 -> 本文件 MODEL=True。
# ============================================================
give @s recovery_compass[item_name={text:"停针",bold:true,color:light_purple},lore=[{"text":"✦ 普攻","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"60","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"伤害 ","color":"gray"},{"text":"自身最大魔力值 ×0.02","color":"yellow"}]},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"260","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"45 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后选中自身 5 格内最近的最多 5 个","color":"gray","italic":false},{"text":"生物。若选中至少 3 个，则使其时停 2","color":"gray","italic":false},{"text":"秒，每个目标使自身全部技能的冷却时间","color":"gray","italic":false},{"text":"减少 2 秒（最多 10 秒）。若不足 3 个，","color":"gray","italic":false},{"text":"则仅使自身获得 3 秒迅捷Ⅱ，不施加时停，","color":"gray","italic":false},{"text":"也不减少冷却。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["stop_needle","staff","itemreplace"],skill:"sweetdream:stop_needle",tags:["timestop","cd_down","max_mana"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]},max_stack_size=1]
