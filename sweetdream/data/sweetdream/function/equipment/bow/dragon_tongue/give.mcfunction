# ============================================================
# sweetdream:equipment/bow/dragon_tongue/give —— 给一件「龙舌」（弩）
# ------------------------------------------------------------
# 【custom_data】
#   "dragon_tongue" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["dragon_tongue"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【弩 = 射击触发】不加 consumable/itemreplace, 也没有冷却 -> 不加 skill。
#   射中带「夜火」的目标 -> 消其「夜火」+ 其 2 格内随机落箭雨; 箭随机落点, 命中落点处的生物
#   (落在空地则落空); 每箭 当前魔力 ×X×0.01, 箭数 X×3,
#   X = 被命中生物 6 格内「流火」/「夜火」生物数, 其中「夜火」每个记为 2。
#
# 【这个文件是生成的】改描述/数值请改 .workbuddy/_gen_batch7.py 再重跑,
#   然后跑 `python .workbuddy/lore_fmt.py --write` 让规范器重新折行。
# ★ 批 11(2026-10-12)已接上技能: 本件带附魔 sweetdream:dragon_tongue —— 弩的命中结算
#   全靠附魔的 post_attack 回调(没有右键/消耗), 所以这行不能删。外观仍待做。
# ★ 本批**不挂 item_model**（外观未做; 挂了会引用不存在的模型 -> 游戏里显示紫黑方块）。
#   外观批次再补 item_model="sweetdream:crossbow_dragon_tongue" + items/*.json + models/ + 贴图。
# ============================================================
give @s crossbow[item_name={text:"龙舌",bold:true,color:red},lore=[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"60","color":"aqua"}]},{"text":" ","italic":false},{"text":"每次射击若射击附加了「夜火」效果的生","color":"gray","italic":false},{"text":"物，则使其消除「夜火」并在其 2 格内释","color":"gray","italic":false},{"text":"放一次箭雨，箭矢随机落下并命中落点处","color":"gray","italic":false},{"text":"的生物。每根箭的伤害相当于自身当前魔","color":"gray","italic":false},{"text":"力值 ×X×0.01，箭的数量为 X×3。X 为被","color":"gray","italic":false},{"text":"命中的生物 6 格内附有「流火」或","color":"gray","italic":false},{"text":"「夜火」的生物数量，其中附有「夜火」","color":"gray","italic":false},{"text":"的每个记为 2。","color":"gray","italic":false}],unbreakable={},enchantments={"sweetdream:dragon_tongue":1},enchantment_glint_override=false,custom_data={zx:["dragon_tongue","bow"],tags:["liuhuo","yehuo","cur_mana","consume"]},tooltip_display={hidden_components:["unbreakable","enchantments"]}]
