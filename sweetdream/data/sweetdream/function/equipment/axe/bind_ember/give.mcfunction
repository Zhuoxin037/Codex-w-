# ============================================================
# sweetdream:equipment/axe/bind_ember/give —— 给一件「缚烬」（稀有 · 斧）
# ------------------------------------------------------------
# 【custom_data】
#   "bind_ember" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["bind_ember"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 被动技能 ｜ ✦ 主动技能
# 【底材】iron_axe（稀有 = iron）—— 本包的"阶段"只由底材判定
#
# 【这个文件是生成的】改描述请改 .workbuddy/_gen_batch18.py 的 LORE、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# 【外观】★ 尚未做 —— 所以**故意不挂 item_model**。挂上会指向不存在的
#   assets/sweetdream/items/bind_ember.json ⇒ 紫黑方块且零日志（坑 195）。
#   补外观的顺序：_gen_late_icons.py 出贴图 -> _gen_late_rp.py 接线 -> 本文件 MODEL=True。
# ============================================================
give @s iron_axe[item_name={text:"缚烬",bold:true,color:red},lore=[{"text":"✦ 被动技能","color":"gold","bold":true,"italic":false},{"text":"自身对同时附有「流火」且处于缓慢状态","color":"gray","italic":false},{"text":"的生物造成的伤害提高 50%。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"260","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"50 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后向前方劈出一道 4 格长、120 度的","color":"gray","italic":false},{"text":"扇形斧痕，对范围内全部生物造成相当于","color":"gray","italic":false},{"text":"自身基础攻击力 ×6 的伤害，并使其附加","color":"gray","italic":false},{"text":"「流火」、获得缓慢Ⅱ，持续 3 秒。每当","color":"gray","italic":false},{"text":"有生物新获得「流火」时，自身所有技能","color":"gray","italic":false},{"text":"的冷却时间减少 1 秒。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["bind_ember","axe","itemreplace"],skill:"sweetdream:bind_ember",tags:["liuhuo","apply","slow","debuff","cd_down"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},enchantments={"sweetdream:bind_ember":1},enchantment_glint_override=false,tooltip_display={hidden_components:["unbreakable","enchantments"]}]
