# ============================================================
# sweetdream:overlimit/item/arc —— 给一块「超限·电弧」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_arc :
#   进度 advancement/overlimit/arc 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[53.0f]}(八芒星, 编号 53)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「电弧」能敲(见 overlimit/api/fit: 副手 zx 必须含 arc 且还没敲过 ol)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·电弧",bold:true,color:light_purple},custom_model_data={floats:[53.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"电弧","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后电弧更名为「超限·电弧」，基础属","color":"gray","italic":false},{"text":"性变为：每次射击都会对被攻击的生物附","color":"gray","italic":false},{"text":"加「电刺」效果。若附有「电刺」的生物","color":"gray","italic":false},{"text":"8 格内有另一个附有「电刺」的生物，则","color":"gray","italic":false},{"text":"每秒都会在他们之间产生一道 3 格宽的电","color":"gray","italic":false},{"text":"线并对沿途的生物及他们自身 1 格内的全","color":"gray","italic":false},{"text":"部生物造成一次相当于自身基础攻击力","color":"gray","italic":false},{"text":"×2+ 当前魔力值 ×0.03 的伤害并召唤闪电，","color":"gray","italic":false},{"text":"持续 3 秒。之后移除「电刺」。","color":"gray","italic":false}],custom_data={zx:["ol_arc"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
