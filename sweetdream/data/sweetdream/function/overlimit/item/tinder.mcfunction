# ============================================================
# sweetdream:overlimit/item/tinder —— 给一块「超限·火种」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_tinder :
#   进度 advancement/overlimit/tinder 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[54.0f]}(八芒星, 编号 54)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「火种」能敲(见 overlimit/api/fit: 副手 zx 必须含 tinder 且还没敲过 ol)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·火种",bold:true,color:light_purple},custom_model_data={floats:[54.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"火种","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后火种更名为「超限·火种」，基础属","color":"gray","italic":false},{"text":"性变为：「火种」为燃烧状态时，攻击生","color":"gray","italic":false},{"text":"物时将会对其 3 格内的全部生物造成相当","color":"gray","italic":false},{"text":"于自身最大魔力值 ×0.1 的伤害，之后使","color":"gray","italic":false},{"text":"未处于燃烧状态的生物燃烧 5 秒并熄灭该","color":"gray","italic":false},{"text":"武器，且使附有「夜火」的生物额外受到","color":"gray","italic":false},{"text":"一次伤害。为熄灭状态时，攻击生物后会","color":"gray","italic":false},{"text":"对自身造成相当于自身最大生命值 ×0.3","color":"gray","italic":false},{"text":"的伤害并使「火种」变为燃烧状态。手持","color":"gray","italic":false},{"text":"时，若自身魔力值大于 400 且「火种」为","color":"gray","italic":false},{"text":"熄灭状态则消耗 350 点魔力值并使","color":"gray","italic":false},{"text":"「火种」变为燃烧状态。","color":"gray","italic":false}],custom_data={zx:["ol_tinder"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
