# ============================================================
# sweetdream:overlimit/item/myriad —— 给一块「超限·万念」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_myriad :
#   进度 advancement/overlimit/myriad 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[29.0f]}(八芒星, 编号 29)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「万念」能敲(见 overlimit/api/fit: 副手 zx 必须含 myriad 且还没敲过 ol)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·万念",bold:true,color:light_purple},custom_model_data={floats:[29.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"万念","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后万念更名为「超限·万念」，主动技","color":"gray","italic":false},{"text":"能变为：使用后切换为【千散】并对自身","color":"gray","italic":false},{"text":"3 格内的全部生物造成一次相当于自身当","color":"gray","italic":false},{"text":"前魔力值 ×0.1 的伤害。若攻击到生物则","color":"gray","italic":false},{"text":"召唤一个半径为 5 格持续 6 秒的领域。","color":"gray","italic":false},{"text":"之后若自身处于领域中且攻击生物 5 次后","color":"gray","italic":false},{"text":"则有 2 秒时间可以释放一次特殊技能。本","color":"gray","italic":false},{"text":"次技能的效果为将【千散】切换回","color":"gray","italic":false},{"text":"【万念】并对领域内的生物使用一次","color":"gray","italic":false},{"text":"【千散】的主动技能效果。若原本就为","color":"gray","italic":false},{"text":"【万念】则改为使用一次【万念】的主动","color":"gray","italic":false},{"text":"技能且本次伤害提高为相当于自身最大魔","color":"gray","italic":false},{"text":"力值 ×0.12。若自身没有选择释放此次特","color":"gray","italic":false},{"text":"殊技能则召唤一个相等的领域，之后召唤","color":"gray","italic":false},{"text":"一个“剑魂”。","color":"gray","italic":false}],custom_data={zx:["ol_myriad"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
