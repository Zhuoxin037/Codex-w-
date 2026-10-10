# ============================================================
# sweetdream:overlimit/item/deepsea_echo —— 给一块「超限·深海的回响」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_deepsea_echo :
#   进度 advancement/overlimit/deepsea_echo 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[34.0f]}(八芒星, 编号 34)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「深海的回响」能敲(见 overlimit/api/fit: 副手 zx 必须含 deepsea_echo 且还没敲过 ol)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·深海的回响",bold:true,color:light_purple},custom_model_data={floats:[34.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"深海的回响","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后深海的回响更名为「超限·深海的回","color":"gray","italic":false},{"text":"响」，被动变为：在自身物品栏里时，自","color":"gray","italic":false},{"text":"身获得常态水下呼吸 1。主动技能变为：","color":"gray","italic":false},{"text":"使用后标记 12 格内离自身最近的一个生","color":"gray","italic":false},{"text":"物并使其附加「渊海」。1 秒后对其 4 格","color":"gray","italic":false},{"text":"范围内的全部生物造成相当于自身当前魔","color":"gray","italic":false},{"text":"力值 ×0.18 的伤害，之后标记受到伤害的","color":"gray","italic":false},{"text":"生物并重复，但每次重复都会消耗自身 80","color":"gray","italic":false},{"text":"魔力值，重复 2 次后结束。结束后若该技","color":"gray","italic":false},{"text":"能攻击到了附加了「渊海」的生物则再重","color":"gray","italic":false},{"text":"复一次，本次重复不消耗魔力值，之后该","color":"gray","italic":false},{"text":"生物不再能触发该被动。之后该技能每攻","color":"gray","italic":false},{"text":"击到附加了「渊海」的生物都会重复一次。","color":"gray","italic":false}],custom_data={zx:["ol_deepsea_echo"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
