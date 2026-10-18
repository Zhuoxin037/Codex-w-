# ============================================================
# sweetdream:equipment/sword/blood_loss/give —— 给一件「失血」（史诗 · 剑）
# ------------------------------------------------------------
# 【custom_data】
#   "blood_loss" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["blood_loss"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 心血 ｜ ✦ 主动技能
# 【底材】diamond_sword（史诗 = diamond）
#
# 【这个文件是生成的】改描述请改 .workbuddy/_new42_lore.py、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# 【外观】批 16（2026-10-18）补齐：item_model 指向 sweetdream:blood_loss
#   （贴图源 _gen_late_icons.py，接线 _gen_late_rp.py）。
# ============================================================
give @s diamond_sword[item_name={text:"失血",bold:true,color:dark_red},lore=[{"text":"✦ 心血","color":"gold","bold":true,"italic":false},{"text":"「心血」最多 3 层。普通近战命中了附有","color":"gray","italic":false},{"text":"「噬心」且仍存活的生物后，消耗其","color":"gray","italic":false},{"text":"「噬心」，并为自身积攒 1 层「心血」。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"120","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"24 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后消耗全部「心血」，对准星前方 5","color":"gray","italic":false},{"text":"格内一个生物造成一次相当于自身最大生","color":"gray","italic":false},{"text":"命值 ×0.35×X 的真实伤害，并为自身恢复","color":"gray","italic":false},{"text":"最大生命值 5%×X 的生命。X 为本次消耗","color":"gray","italic":false},{"text":"的「心血」层数。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["blood_loss","sword","itemreplace"],skill:"sweetdream:blood_loss",tags:["shixin","max_hp","true_dmg","heal","consume"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]},item_model="sweetdream:blood_loss"]
