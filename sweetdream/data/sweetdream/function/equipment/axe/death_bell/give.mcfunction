# ============================================================
# sweetdream:equipment/axe/death_bell/give —— 给一件「丧铃」（罕见 · 斧）
# ------------------------------------------------------------
# 【custom_data】
#   "death_bell" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["death_bell"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 主动技能
# 【底材】iron_axe（罕见 = iron）
#
# 【这个文件是生成的】改描述请改 .workbuddy/_new42_lore.py、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# 【外观】批 16（2026-10-18）补齐：item_model 指向 sweetdream:death_bell
#   （贴图源 _gen_late_icons.py，接线 _gen_late_rp.py）。
# ============================================================
give @s iron_axe[item_name={text:"丧铃",bold:true,color:dark_gray},lore=[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"130","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"35 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后向前方 4 格内重击，对范围内全部","color":"gray","italic":false},{"text":"生物造成一次相当于自身最大魔力值 ×0.1","color":"gray","italic":false},{"text":"的伤害。若命中了附有「白昼梦」的生物，","color":"gray","italic":false},{"text":"则消耗其中最近一个生物的「白昼梦」，","color":"gray","italic":false},{"text":"之后对其 4 格内最多 5 个其他生物释放","color":"gray","italic":false},{"text":"两次钟声，每次都会造成相当于自身最大","color":"gray","italic":false},{"text":"魔力值 ×0.08 的伤害并使其获得 3 秒虚","color":"gray","italic":false},{"text":"弱Ⅱ。若钟声影响了至少 5 个生物，则返","color":"gray","italic":false},{"text":"还自身 80 魔力值并减少 10 秒冷却时间。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["death_bell","axe","itemreplace"],skill:"sweetdream:death_bell",tags:["dream","max_mana","debuff","consume","cd_down"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]},item_model="sweetdream:death_bell"]
