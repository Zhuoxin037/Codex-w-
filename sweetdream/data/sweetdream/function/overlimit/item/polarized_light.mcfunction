# ============================================================
# sweetdream:overlimit/item/polarized_light —— 给一块「超限·偏振光」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_polarized_light :
#   进度 advancement/overlimit/polarized_light 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[47.0f]}(八芒星, 编号 47)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「偏振光」能敲(见 overlimit/api/fit: 副手 zx 必须含 偏振光 且还没敲过 ol)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·偏振光",bold:true,color:light_purple},custom_model_data={floats:[47.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"偏振光","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后偏振光更名为「超限·偏振光」，基","color":"gray","italic":false},{"text":"础属性变为：使用后召唤一个术阵。之后","color":"gray","italic":false},{"text":"自身持续发射三道光线并每 0.5 秒对自身","color":"gray","italic":false},{"text":"12 格内离自己最近的三个生物造成一次相","color":"gray","italic":false},{"text":"当于自身当前魔力值 ×0.05 的伤害，且被","color":"gray","italic":false},{"text":"锁定的生物获得缓慢三效果。该效果持续","color":"gray","italic":false},{"text":"5 秒。","color":"gray","italic":false}],custom_data={zx:["ol_polarized_light"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
