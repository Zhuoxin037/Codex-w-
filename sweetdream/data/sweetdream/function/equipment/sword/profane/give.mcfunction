# ============================================================
# sweetdream:equipment/sword/profane/give —— 给一件「剖心」（传说 · 剑）
# ------------------------------------------------------------
# 【custom_data】
#   "profane" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["profane"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 被动技能 ｜ ✦ 主动技能
# 【底材】netherite_sword（传说 = netherite）—— 本包的"阶段"只由底材判定
#
# 【这个文件是生成的】改描述请改 .workbuddy/_gen_batch18.py 的 LORE、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# 【外观】★ 尚未做 —— 所以**故意不挂 item_model**。挂上会指向不存在的
#   assets/sweetdream/items/profane.json ⇒ 紫黑方块且零日志（坑 195）。
#   补外观的顺序：_gen_late_icons.py 出贴图 -> _gen_late_rp.py 接线 -> 本文件 MODEL=True。
# ============================================================
give @s netherite_sword[item_name={text:"剖心",bold:true,color:dark_red},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"每次普通攻击命中附有「噬心」的生物时，","color":"gray","italic":false},{"text":"使其「噬心」的剩余时长延长 2 秒","color":"gray","italic":false},{"text":"（最多 18 秒），并额外造成一次相当于","color":"gray","italic":false},{"text":"自身基础攻击力的伤害。该效果 5 秒内最","color":"gray","italic":false},{"text":"多触发一次。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"320","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"30 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后向准星方向斩出一道 2×5 的剖线，","color":"gray","italic":false},{"text":"对命中的全部生物造成相当于自身基础攻","color":"gray","italic":false},{"text":"击力 ×5 的伤害。若命中的生物附有","color":"gray","italic":false},{"text":"「噬心」，则清除其「噬心」，该次伤害","color":"gray","italic":false},{"text":"改为相当于自身基础攻击力 ×8，且伤害额","color":"gray","italic":false},{"text":"外提高 20%（独立乘区），并使命中的生","color":"gray","italic":false},{"text":"物 2 格内的其他生物受到该次伤害一半的","color":"gray","italic":false},{"text":"伤害。每清除一个「噬心」，自身所有技","color":"gray","italic":false},{"text":"能的冷却时间减少 2 秒。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["profane","sword","itemreplace"],skill:"sweetdream:profane",tags:["shixin","base_atk","consume","indep_mul","cd_down"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
