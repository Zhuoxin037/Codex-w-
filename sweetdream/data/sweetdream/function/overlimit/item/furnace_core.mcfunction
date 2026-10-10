# ============================================================
# sweetdream:overlimit/item/furnace_core —— 给一块「超限·炉心」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_furnace_core :
#   进度 advancement/overlimit/furnace_core 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[49.0f]}(八芒星, 编号 49)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「炉心」能敲(见 overlimit/api/fit: 副手 zx 必须含 炉心 且还没敲过 ol)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·炉心",bold:true,color:light_purple},custom_model_data={floats:[49.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"炉心","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后炉心更名为「超限·炉心」，基础属","color":"gray","italic":false},{"text":"性变为：自身魔力值上限 +150，最大生命","color":"gray","italic":false},{"text":"值 +15，基础攻击力 +8。自身每攻击一次","color":"gray","italic":false},{"text":"处于燃烧状态的生物则积攒一层「燃灰」","color":"gray","italic":false},{"text":"（最大为 12 层）。每有一层「燃灰」则","color":"gray","italic":false},{"text":"自身魔力值上限 +30，基础攻击力 +X（X","color":"gray","italic":false},{"text":"为自身当前基础攻击力 ×0.1，最低为 4），","color":"gray","italic":false},{"text":"最大生命值 +Y（Y 为自身当前最大生命值","color":"gray","italic":false},{"text":"×0.1，最低为 7），且每秒恢复 1 点魔力","color":"gray","italic":false},{"text":"值。「燃灰」每 3 秒 -1 层。若「燃灰」","color":"gray","italic":false},{"text":"达到 12 层则「燃灰」在 12 秒内将不再","color":"gray","italic":false},{"text":"减少层数。之后自身「燃灰」层数降至 8","color":"gray","italic":false},{"text":"层。","color":"gray","italic":false}],custom_data={zx:["ol_furnace_core"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
