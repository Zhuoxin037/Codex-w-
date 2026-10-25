# ============================================================
# sweetdream:equipment/staff/pour_sack/give —— 给一件「倾囊」（稀有 · 法杖）
# ------------------------------------------------------------
# 【custom_data】
#   "pour_sack" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["pour_sack"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 普攻 ｜ ✦ 主动技能
# 【底材】recovery_compass（未分档：这类装备的底物没有材质档）
#
# 【这个文件是生成的】改描述请改 .workbuddy/_gen_batch18.py 的 LORE、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# 【外观】★ 尚未做 —— 所以**故意不挂 item_model**。挂上会指向不存在的
#   assets/sweetdream/items/pour_sack.json ⇒ 紫黑方块且零日志（坑 195）。
#   补外观的顺序：_gen_late_icons.py 出贴图 -> _gen_late_rp.py 接线 -> 本文件 MODEL=True。
# ============================================================
give @s recovery_compass[item_name={text:"倾囊",bold:true,color:yellow},lore=[{"text":"✦ 普攻","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"60","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"伤害 ","color":"gray"},{"text":"12","color":"yellow"}]},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"当前魔力值的 40%","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"20 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"当前魔力值不足 60 时无法施放。使用后","color":"gray","italic":false},{"text":"把消耗的魔力压成一枚钉子射出，命中 10","color":"gray","italic":false},{"text":"格内最近的一个生物，每 5 点消耗魔力转","color":"gray","italic":false},{"text":"化为 1 点固定伤害。若本次消耗的魔力不","color":"gray","italic":false},{"text":"低于 120，则再对其 2 格内的全部生物造","color":"gray","italic":false},{"text":"成一半的固定伤害。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["pour_sack","staff","itemreplace"],skill:"sweetdream:pour_sack",tags:["cur_mana","flat"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]},max_stack_size=1]
