# ============================================================
# sweetdream:equipment/staff/wind_ontheground/give —— 给一把「风行于大地之上」
# ------------------------------------------------------------
# 【custom_data 三段 + skill】
#   "itemreplace"      -> 通用回手线认它(右键才触发、用完还手)
#   "wind_ontheground" -> 武器 id, 进度 equipment/staff/wind_ontheground 靠它认人
#   "staff"            -> 分类标记(剑/斧/弓/法杖/盔甲)
#   skill              -> 观测镜靠它显示冷却, 必须和 cast 里传的 skill 一致
#
# 【lore 排版】✦ 小标题 / 拼色数值行 / 灰色正文。
#   正文**按你的原文一字不改**, 只按"文字宽度"等分硬切(每行约 16~20 个汉字宽);
#   唯一的例外: 切点如果正好落在数字/英文单词中间, 会往后挪一格,
#   免得出现 "×0." / "07" 这种被切碎的东西。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_model="naturewind:staff",item_name={text:"风行于大地之上",bold:true,color:"aqua"},lore=[{"text":"✦ 普攻","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"80","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"伤害 ","color":"gray"},{"text":"当前魔力值 ×0.04","color":"yellow"}]},{"text":" ","italic":false},{"text":"每次普攻后自身获得 1 秒迅捷Ⅲ。若自身","color":"gray","italic":false},{"text":"术阵占用已满则本次攻击伤害 ×2.5。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"550","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"120 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后召唤 X 个术阵（X 为自身当前剩余","color":"gray","italic":false},{"text":"的可召唤术阵数量）。每召唤一个术阵则","color":"gray","italic":false},{"text":"自身对自身 12 格内随机一个生物的 5 格","color":"gray","italic":false},{"text":"内的全部生物造成 3 次相当于自身最大魔","color":"gray","italic":false},{"text":"力值 ×0.07 的伤害，每命中一个生物则为","color":"gray","italic":false},{"text":"自身积攒一点「风声」。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 风声","color":"gold","bold":true,"italic":false},{"text":"召唤完术阵后自身若有超过 60 点","color":"gray","italic":false},{"text":"「风声」则每超出一点都会为下一次自身","color":"gray","italic":false},{"text":"使用最大魔力值相关的技能伤害提升 1%，","color":"gray","italic":false},{"text":"之后每有一点「风声」则自身最大魔力值","color":"gray","italic":false},{"text":"提升相当于「风声」×10 的数值并对自身","color":"gray","italic":false},{"text":"5 格内的生物造成 5 次相当于自身最大魔","color":"gray","italic":false},{"text":"力值 ×0.04 的伤害，持续 20 秒。结束后","color":"gray","italic":false},{"text":"清除「风声」。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["wind_ontheground","staff","itemreplace"],skill:"sweetdream:wind_ontheground",tags:["max_mana","cur_mana","formation","buff"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
