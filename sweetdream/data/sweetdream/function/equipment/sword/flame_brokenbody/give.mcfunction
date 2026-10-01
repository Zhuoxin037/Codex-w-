# ============================================================
# sweetdream:equipment/sword/flame_brokenbody/give —— 给一把「烈火，残躯」
# ------------------------------------------------------------
# 【custom_data 三段 + skill】
#   "itemreplace"      -> 通用回手线认它(右键才触发、用完还手)
#   "flame_brokenbody" -> 武器 id, 进度 equipment/sword/flame_brokenbody 靠它认人
#   "sword"            -> 分类标记(剑)
#   skill              -> 观测镜靠它显示冷却, 必须和 cast 里传的 skill 一致
# 【lore 排版】✦ 小标题 / 拼色数值行 / 灰色正文; 正文按文字宽度硬切, 不为标点换行。
# 【做技能时的两个提醒】
#   ① "冷却时间立即结束" 用 manacore:api/cooldown/reset;
#   ② 「熔浆」是这把武器专属的层数(像风行的「风声」), 建议记在玩家自己的计分项上,
#      别塞进那五个通用标签里。
# ============================================================

give @s netherite_sword[item_name={text:"烈火，残躯",bold:true,color:"red"},lore=[{"text":"✦ 主动技能","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"魔力 ","color":"gray"},{"text":"350","color":"aqua"},{"text":"   ·   ","color":"dark_gray"},{"text":"冷却 ","color":"gray"},{"text":"12 秒","color":"yellow"}]},{"text":" ","italic":false},{"text":"使用后对前方5*3范围内的生物造成","color":"gray","italic":false},{"text":"一次相当于自身最大魔力值*0.1的伤","color":"gray","italic":false},{"text":"害，若攻击到的生物附有「夜火」则","color":"gray","italic":false},{"text":"该技能冷却时间立即结束，且每有一","color":"gray","italic":false},{"text":"个「夜火」则吸收并为自身积攒一点","color":"gray","italic":false},{"text":"「熔浆」。","color":"gray","italic":false},{"text":" ","italic":false},{"text":"✦ 熔浆","color":"gold","bold":true,"italic":false},{"text":"若自身释放技能时「熔浆」大于或等于","color":"gray","italic":false},{"text":"4层则本次技能强化为对前方5*3范围内","color":"gray","italic":false},{"text":"的生物造成两次相当于自身最大魔力值","color":"gray","italic":false},{"text":"*0.1的伤害，之后再对自身6格内的生","color":"gray","italic":false},{"text":"物造成相当于自身最大魔力值*0.2的伤","color":"gray","italic":false},{"text":"害，之后清除「熔浆」。","color":"gray","italic":false}],unbreakable={},custom_data={zx:["flame_brokenbody","sword","itemreplace"],skill:"sweetdream:flame_brokenbody"},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"},tooltip_display={hidden_components:["unbreakable"]}]
