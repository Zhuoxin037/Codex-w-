# ============================================================
# sweetdream:overlimit/item/flame_brokenbody —— 给一块「超限·“烈火，残躯”」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_flame_brokenbody :
#   进度 advancement/overlimit/flame_brokenbody 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[36.0f]}(八芒星, 编号 36)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「“烈火，残躯”」能敲(见 overlimit/api/fit: 副手 zx 必须含 flame_brokenbody 且还没敲过 ol)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·“烈火，残躯”",bold:true,color:light_purple},custom_model_data={floats:[36.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"“烈火，残躯”","color":"blue"}]},{"text":"","italic":false,"extra":[{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后“烈火，残躯”更名为「超限·“烈","color":"gray","italic":false},{"text":"火，残躯”」，主动技能变为：对前方","color":"gray","italic":false},{"text":"5×3 范围内的生物造成一次相当于自身最","color":"gray","italic":false},{"text":"大魔力值 ×0.1 的伤害，若攻击到的生物","color":"gray","italic":false},{"text":"附有「流火」或「夜火」则该技能冷却时","color":"gray","italic":false},{"text":"间立即结束，且若有「流火」则转化为","color":"gray","italic":false},{"text":"「夜火」，每有一个「夜火」则吸收并为","color":"gray","italic":false},{"text":"自身积攒一点「熔浆」。若释放技能时","color":"gray","italic":false},{"text":"「熔浆」大于或等于 4 层则本次技能强化","color":"gray","italic":false},{"text":"为对前方 5×3 范围内的生物造成两次相当","color":"gray","italic":false},{"text":"于自身最大魔力值 ×0.1 的伤害，之后再","color":"gray","italic":false},{"text":"对自身 6 格内的生物造成相当于自身最大","color":"gray","italic":false},{"text":"魔力值 ×0.2 的伤害，之后清除「熔浆」。","color":"gray","italic":false}],custom_data={zx:["ol_flame_brokenbody"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
