# ============================================================
# sweetdream:equipment/bow/arc/give —— 给一件「电弧」（弩）
# ------------------------------------------------------------
# 【custom_data】
#   "arc" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["arc"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【弩 = 射击触发】不加 consumable/itemreplace, 也没有冷却 -> 不加 skill。
# 【附魔】sweetdream:arc(见 enchantment/arc.json), 命中生物时回调 hook_victim。
#   ⚠️ 附魔是注册表内容: 装好后要**退出世界重进**(光 /reload 不补)。
# 【机制】每次射击给目标「电刺」; 两个带电刺的生物 6 格内 -> 拉一道 1 格宽电线, 沿途 + 双方
#   吃 基础攻击力 ×2 + 当前魔力 ×0.03, 之后移除「电刺」。
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch6.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ============================================================
give @s crossbow[item_model="sweetdream:crossbow_arc",item_name={text:"电弧",bold:true,color:aqua},lore=[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"30","color":"aqua"}]},{"text":" ","italic":false},{"text":"每次射击都会对被攻击的生物附加","color":"gray","italic":false},{"text":"「电刺」效果。若附有「电刺」的生物 6","color":"gray","italic":false},{"text":"格内有另一个附有「电刺」的生物，则立","color":"gray","italic":false},{"text":"即在他们之间产生一道 1 格宽的电线并对","color":"gray","italic":false},{"text":"沿途的生物及他们自身造成一次相当于自","color":"gray","italic":false},{"text":"身基础攻击力 ×2+ 当前魔力值 ×0.03 的","color":"gray","italic":false},{"text":"伤害，之后移除「电刺」。","color":"gray","italic":false}],unbreakable={},enchantments={"sweetdream:arc":1},enchantment_glint_override=false,custom_data={zx:["arc","bow"],tags:["lightning","cur_mana","base_atk"]},tooltip_display={hidden_components:["unbreakable","enchantments"]}]
