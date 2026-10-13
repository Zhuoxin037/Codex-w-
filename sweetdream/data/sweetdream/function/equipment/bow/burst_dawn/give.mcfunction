# ============================================================
# sweetdream:equipment/bow/burst_dawn/give —— 给一件「爆裂黎明」（弩）
# ------------------------------------------------------------
# 【custom_data】
#   "burst_dawn" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["burst_dawn"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【弩 = 射击触发】不加 consumable/itemreplace, 也没有冷却 -> 不加 skill。
#   799 -> 术阵 + 两个“魂灵之影”(生命 100 / 20 秒); 主力 基础攻击力 ×8 + 最大魔力 ×0.15 + 缓慢5 2 秒,
#   再补一次 50%; 之后用“魂灵之影”续轰(基础攻击力 ×4 + 最大魔力 ×0.08), 场上没有则技能结束。
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch7.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ★ 批 11(2026-10-12)已接上技能: 本件带附魔 sweetdream:burst_dawn —— 弩的命中结算
#   全靠附魔的 post_attack 回调(没有右键/消耗), 所以这行不能删。外观仍待做。
# ★ 本批**不挂 item_model**（外观未做; 挂了会引用不存在的模型 -> 游戏里显示紫黑方块）。
#   外观批次再补 item_model="sweetdream:crossbow_burst_dawn" + items/*.json + models/ + 贴图。
# ============================================================
give @s crossbow[item_name={text:"爆裂黎明",bold:true,color:gold},lore=[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"799","color":"aqua"}]},{"text":" ","italic":false},{"text":"射击后召唤一个术阵。在自身位置周围召","color":"gray","italic":false},{"text":"唤两个生命值为 100 可持续 20 秒的“魂","color":"gray","italic":false},{"text":"灵之影”，其每 3 秒都会对其 3 格内的","color":"gray","italic":false},{"text":"一个生物造成相当于其当前生命值 ×0.5","color":"gray","italic":false},{"text":"的伤害并使其获得 1 秒缓慢Ⅱ。若生物索","color":"gray","italic":false},{"text":"敌为自身，则会转移索敌至“魂灵之影”。","color":"gray","italic":false},{"text":"自身对射中的生物及其 3 格内的全部生物","color":"gray","italic":false},{"text":"造成一次相当于自身基础攻击力 ×8 + 自","color":"gray","italic":false},{"text":"身最大魔力值 ×0.15 的伤害并使生物获得","color":"gray","italic":false},{"text":"2 秒缓慢Ⅴ，之后再造成一次相当于上次","color":"gray","italic":false},{"text":"总伤害 50% 的伤害。之后自身可以使用自","color":"gray","italic":false},{"text":"身召唤的“魂灵之影”当作弹药继续进行","color":"gray","italic":false},{"text":"轰击，但是伤害变为自身基础攻击力 ×4 +","color":"gray","italic":false},{"text":"自身最大魔力值 ×0.08。场上不存在自身","color":"gray","italic":false},{"text":"召唤的“魂灵之影”后则该技能结束。","color":"gray","italic":false}],unbreakable={},enchantments={"sweetdream:burst_dawn":1},enchantment_glint_override=false,custom_data={zx:["burst_dawn","bow"],tags:["max_mana","base_atk","formation","summon","slow","debuff"]},tooltip_display={hidden_components:["unbreakable","enchantments"]}]
