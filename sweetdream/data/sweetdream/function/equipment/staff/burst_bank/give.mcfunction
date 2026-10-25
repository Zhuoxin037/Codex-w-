# ============================================================
# sweetdream:equipment/staff/burst_bank/give —— 给一件「决堤」（史诗 · 法杖）
# ------------------------------------------------------------
# 【custom_data】
#   "burst_bank" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["burst_bank"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 普攻 ｜ ✦ 主动技能
# 【底材】recovery_compass（未分档：这类装备的底物没有材质档）
#
# 【这个文件是生成的】改描述请改 .workbuddy/_gen_batch18.py 的 LORE、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# 【外观】★ 尚未做 —— 所以**故意不挂 item_model**。挂上会指向不存在的
#   assets/sweetdream/items/burst_bank.json ⇒ 紫黑方块且零日志（坑 195）。
#   补外观的顺序：_gen_late_icons.py 出贴图 -> _gen_late_rp.py 接线 -> 本文件 MODEL=True。
# ============================================================
give @s recovery_compass[item_name={text:"决堤",bold:true,color:aqua},lore=[{"text":"✦ 普攻","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"80","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"伤害 ","color":"gray"},{"text":"自身当前魔力值 ×0.03","color":"yellow"}]},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"当前魔力值的 50%","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"25 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"当前魔力值不足 100 时无法施放。使用后","color":"gray","italic":false},{"text":"向准星方向突进，每消耗 25 点魔力突进","color":"gray","italic":false},{"text":"1 格（最少突进 2 格、最多 15 格）。被","color":"gray","italic":false},{"text":"突进路径穿过的生物受到相当于消耗魔力","color":"gray","italic":false},{"text":"值 ×0.12 的伤害，并被带向落点；落点 3","color":"gray","italic":false},{"text":"格内的生物受到相当于消耗魔力值 ×0.06","color":"gray","italic":false},{"text":"的伤害并被向外击退 2 格。落地后 2 秒","color":"gray","italic":false},{"text":"内自身获得迅捷Ⅱ。若落点脚下没有可站","color":"gray","italic":false},{"text":"立的方块，则改为原地施放并返还一半魔","color":"gray","italic":false},{"text":"力值。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["burst_bank","staff","itemreplace"],skill:"sweetdream:burst_bank",tags:["cur_mana","dash","debuff"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]},max_stack_size=1]
