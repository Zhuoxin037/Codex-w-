# ============================================================
# sweetdream:overlimit/item/stellar_elegy —— 给一块「超限·群星坠落之挽歌」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_stellar_elegy :
#   进度 advancement/overlimit/stellar_elegy 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[30.0f]}(八芒星, 编号 30)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「群星坠落之挽歌」能敲(见 overlimit/api/fit: 副手 zx 必须含 stellar_elegy 且还没敲过 ol)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·群星坠落之挽歌",bold:true,color:light_purple},custom_model_data={floats:[30.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"群星坠落之挽歌","color":"blue"}]},{"text":"","italic":false,"extra":[{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后群星坠落之挽歌更名为「超限·群星","color":"gray","italic":false},{"text":"坠落之挽歌」，被动变为：自身魔力值上","color":"gray","italic":false},{"text":"限 +350，每次受到攻击后获得抗性提升Ⅲ","color":"gray","italic":false},{"text":"且每秒恢复 2% 魔力值，持续 5 秒，之后","color":"gray","italic":false},{"text":"使自身 6 格内全部带有任意一个通用效果","color":"gray","italic":false},{"text":"的生物受到一次相当于自身当前魔力值","color":"gray","italic":false},{"text":"×0.03 的伤害并使其随机附加一个效果。","color":"gray","italic":false}],custom_data={zx:["ol_stellar_elegy"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
