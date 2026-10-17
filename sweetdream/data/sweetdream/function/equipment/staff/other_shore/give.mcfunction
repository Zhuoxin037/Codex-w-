# ============================================================
# sweetdream:equipment/staff/other_shore/give —— 给一件「彼岸」（传说 · 法杖）
# ------------------------------------------------------------
# 【custom_data】
#   "other_shore" -> 装备 id, 进度 / 被动判定靠它认人
#   ★ 判定一律写成 custom_data~{zx:["other_shore"]}(部分匹配 + 独有标记)
#   ★ 语义标签 = custom_data.tags(批 A; 词表/逐件表见 .workbuddy/_tags_data.py)
# 【描述构成】✦ 普攻 ｜ ✦ 主动技能
# 【底材】recovery_compass（传说 = netherite）
#
# 【这个文件是生成的】改描述请改 .workbuddy/_new42_lore.py、改标签请改
#   .workbuddy/_tags_data.py，然后重跑本生成器 + `python .workbuddy/lore_fmt.py --write`。
# ★ 批 14（2026-10-15 用户定）**只做 give**：技能 / 进度 / updef / 超限石 /
#   外观 等留后续批次；因此**不挂 item_model**（外观未做，挂了会引用不存在的
#   模型 -> 游戏里显示紫黑方块）。物品先显示为底材的原版外观。
# ============================================================
give @s recovery_compass[max_stack_size=1,item_name={text:"彼岸",bold:true,color:dark_purple},lore=[{"text":"✦ 普攻","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"80","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"伤害 ","color":"gray"},{"text":"当前魔力值 ×0.02","color":"yellow"}]},{"text":" ","italic":false},{"text":"每次普攻命中后若其未附有「渊海」和","color":"gray","italic":false},{"text":"「噬心」，则使其附加「渊海」。若其只","color":"gray","italic":false},{"text":"附有其中一种，则有 25% 的概率使其附加","color":"gray","italic":false},{"text":"另一种。若其同时附有「渊海」和","color":"gray","italic":false},{"text":"「噬心」，则额外造成一次相当于自身最","color":"gray","italic":false},{"text":"大魔力值 ×0.03 的真实伤害。附加效果对","color":"gray","italic":false},{"text":"同一个生物 8 秒内最多触发一次。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"450","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"55 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后选择自身 8 格内最多 3 个附有","color":"gray","italic":false},{"text":"「渊海」或「噬心」的生物。若其只附有","color":"gray","italic":false},{"text":"「渊海」，则将其转化为「噬心」，并造","color":"gray","italic":false},{"text":"成一次相当于自身最大魔力值 ×0.1 的伤","color":"gray","italic":false},{"text":"害。若其只附有「噬心」，则将其转化为","color":"gray","italic":false},{"text":"「渊海」，并造成一次相当于自身最大魔","color":"gray","italic":false},{"text":"力值 ×0.08 的真实伤害。若其同时附有两","color":"gray","italic":false},{"text":"种效果，则消耗「渊海」和「噬心」，对","color":"gray","italic":false},{"text":"其造成一次相当于自身最大魔力值 ×0.2","color":"gray","italic":false},{"text":"的真实伤害，并对其 3 格内的其他生物造","color":"gray","italic":false},{"text":"成一次相当于自身最大魔力值 ×0.12 的伤","color":"gray","italic":false},{"text":"害。每消耗一组「渊海」和「噬心」，则","color":"gray","italic":false},{"text":"为自身恢复最大生命值 5% 的生命。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["other_shore","staff","itemreplace"],skill:"sweetdream:other_shore",tags:["shixin","yuanhai","max_hp","max_mana","cur_mana","true_dmg","heal","consume","apply"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
