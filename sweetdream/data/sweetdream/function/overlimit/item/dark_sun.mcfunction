# ============================================================
# sweetdream:overlimit/item/dark_sun —— 给一块「超限·黯日」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_dark_sun :
#   进度 advancement/overlimit/dark_sun 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[78.0f]}(八芒星, 编号 78)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「黯日」能敲(见 overlimit/api/fit: 副手 zx 必须含 dark_sun 且还没敲过 ol)。
# 【状态】2026-10-23 批 J2/J3/J4 全落地: give + 图标 + oldef + apply + advancement。
# 【consumable】已挂(批 J4) —— 主手拿石头右键, 要敲的装备放副手;
#   进度 consume_item -> overlimit/apply/dark_sun -> station/api/apply 校验/改名/换描述。
#   三件套(item + advancement + apply)与 oldef 均已就位, 敲失败会退材料并说明原因。
#   敲入后由 station/api/lore_refresh 改名 + 整段换描述(名字/描述取自 oldef)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·黯日",bold:true,color:light_purple},custom_model_data={floats:[78.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"黯日","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后黯日更名为「超限·黯日」，主动技","color":"gray","italic":false},{"text":"能变为：每次射击命中生物后，额外造成","color":"gray","italic":false},{"text":"一次相当于自身最大魔力值 ×0.12 的伤害，","color":"gray","italic":false},{"text":"并使其附加「夜火」和「流火」。若其已","color":"gray","italic":false},{"text":"附有「流火」，则上述伤害提高 40%；若","color":"gray","italic":false},{"text":"该目标在命中前已附有「夜火」，则上述","color":"gray","italic":false},{"text":"伤害提高 50%（独立乘区），并向命中位","color":"gray","italic":false},{"text":"置 6 格内的其他生物释放一枚影矢。影矢","color":"gray","italic":false},{"text":"造成一次相当于自身最大魔力值 ×0.08 的","color":"gray","italic":false},{"text":"伤害，并使其附加「夜火」。","color":"gray","italic":false}],custom_data={zx:["ol_dark_sun"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
