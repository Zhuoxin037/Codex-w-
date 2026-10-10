# ============================================================
# sweetdream:overlimit/item/dionysus_helmet —— 给一块「超限·狄俄尼索斯之桂冠」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_dionysus_helmet :
#   进度 advancement/overlimit/dionysus_helmet 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[48.0f]}(八芒星, 编号 48)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「狄俄尼索斯之桂冠」能敲(见 overlimit/api/fit: 副手 zx 必须含 狄俄尼索斯之桂冠 且还没敲过 ol)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·狄俄尼索斯之桂冠",bold:true,color:light_purple},custom_model_data={floats:[48.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"狄俄尼索斯之桂冠","color":"blue"}]},{"text":"","italic":false,"extra":[{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后狄俄尼索斯之桂冠更名为「超限·狄","color":"gray","italic":false},{"text":"俄尼索斯之桂冠」，基础属性变为：自身","color":"gray","italic":false},{"text":"魔力上限 +240。自身受到伤害后有 20%","color":"gray","italic":false},{"text":"的概率会获得反胃Ⅱ和力量Ⅲ效果，之后","color":"gray","italic":false},{"text":"获得一层「酒浆」（最多 10 层），并且","color":"gray","italic":false},{"text":"自身每秒恢复 60 点魔力值，持续 3 秒。","color":"gray","italic":false},{"text":"自身攻击生物时，若自身「酒浆」达到 5","color":"gray","italic":false},{"text":"层以上则消耗 5 层「酒浆」，之后触发该","color":"gray","italic":false},{"text":"装备的被动效果且强化为获得力量Ⅴ效果，","color":"gray","italic":false},{"text":"且自身技能伤害提升 30%，之后获得一层","color":"gray","italic":false},{"text":"「酒浆」，并且自身每秒恢复 80 点魔力","color":"gray","italic":false},{"text":"值，之后每秒获得一次瞬间治疗 4，持续","color":"gray","italic":false},{"text":"5 秒（持续期间不可再次触发）。","color":"gray","italic":false}],custom_data={zx:["ol_dionysus_helmet"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
