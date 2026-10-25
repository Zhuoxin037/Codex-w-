# ============================================================
# sweetdream:overlimit/item/bent_ray —— 给一块「超限·折径」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_bent_ray :
#   进度 advancement/overlimit/bent_ray 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[88.0f]}(八芒星, 编号 88)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「折径」能敲(见 overlimit/api/fit: 副手 zx 必须含 bent_ray 且还没敲过 ol)。
# 【状态】2026-10-23 批 J2/J3/J4 全落地: give + 图标 + oldef + apply + advancement。
# 【consumable】已挂(批 J4) —— 主手拿石头右键, 要敲的装备放副手;
#   进度 consume_item -> overlimit/apply/bent_ray -> station/api/apply 校验/改名/换描述。
#   三件套(item + advancement + apply)与 oldef 均已就位, 敲失败会退材料并说明原因。
#   敲入后由 station/api/lore_refresh 改名 + 整段换描述(名字/描述取自 oldef)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·折径",bold:true,color:light_purple},custom_model_data={floats:[88.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"折径","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后折径更名为「超限·折径」，普攻变","color":"gray","italic":false},{"text":"为：伤害 20 每次普攻命中后使其附加","color":"gray","italic":false},{"text":"「折光」（最多三层），每层持续 10 秒。","color":"gray","italic":false},{"text":"主动技能变为：使用后对自身 8 格内最近","color":"gray","italic":false},{"text":"的生物发射光束，并对其造成一次相当于","color":"gray","italic":false},{"text":"自身最大魔力值 ×0.05+18 的伤害。若其","color":"gray","italic":false},{"text":"8 格内有附有「折光」的生物，则光束继","color":"gray","italic":false},{"text":"续射向其最近的附有「折光」的生物并消","color":"gray","italic":false},{"text":"除其「折光」，且每有一层「折光」都会","color":"gray","italic":false},{"text":"额外对除主光束锁定的生物以外离其最近","color":"gray","italic":false},{"text":"的生物射出光束。若射中的生物也附有","color":"gray","italic":false},{"text":"「折光」则也会触发本技能效果。每次射","color":"gray","italic":false},{"text":"出都会使本次伤害提高 20%（独立乘区，","color":"gray","italic":false},{"text":"不包含固定伤害，多层「折光」额外射出","color":"gray","italic":false},{"text":"的光束伤害独立计算）。以上最多重复 8","color":"gray","italic":false},{"text":"次。结束后对锁定的生物和在光束路径上","color":"gray","italic":false},{"text":"的生物造成一次相当于自身最大魔力值","color":"gray","italic":false},{"text":"×0.08 的伤害且本次伤害受到本技能的最","color":"gray","italic":false},{"text":"终增伤。","color":"gray","italic":false}],custom_data={zx:["ol_bent_ray"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
