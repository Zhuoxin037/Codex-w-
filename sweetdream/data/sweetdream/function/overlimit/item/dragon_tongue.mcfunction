# ============================================================
# sweetdream:overlimit/item/dragon_tongue —— 给一块「超限·龙舌」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_dragon_tongue :
#   进度 advancement/overlimit/dragon_tongue 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[79.0f]}(八芒星, 编号 79)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「龙舌」能敲(见 overlimit/api/fit: 副手 zx 必须含 dragon_tongue 且还没敲过 ol)。
# 【状态】2026-10-23 批 J2/J3/J4 全落地: give + 图标 + oldef + apply + advancement。
# 【consumable】已挂(批 J4) —— 主手拿石头右键, 要敲的装备放副手;
#   进度 consume_item -> overlimit/apply/dragon_tongue -> station/api/apply 校验/改名/换描述。
#   三件套(item + advancement + apply)与 oldef 均已就位, 敲失败会退材料并说明原因。
#   敲入后由 station/api/lore_refresh 改名 + 整段换描述(名字/描述取自 oldef)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·龙舌",bold:true,color:light_purple},custom_model_data={floats:[79.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"龙舌","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后龙舌更名为「超限·龙舌」，主动技","color":"gray","italic":false},{"text":"能变为：每次射击若射击附加了「夜火」","color":"gray","italic":false},{"text":"效果的生物，则使其消除「夜火」并在其","color":"gray","italic":false},{"text":"6 格内释放一次箭雨，箭矢随机落下并命","color":"gray","italic":false},{"text":"中落点处的生物。每根箭的伤害相当于自","color":"gray","italic":false},{"text":"身当前魔力值 ×X×0.01，箭的数量为 X×3。","color":"gray","italic":false},{"text":"X 为被命中的生物 10 格内附有「流火」","color":"gray","italic":false},{"text":"或「夜火」的生物数量，其中附有","color":"gray","italic":false},{"text":"「夜火」的每个记为 2。若本次箭数量超","color":"gray","italic":false},{"text":"过 20 个则在结束后额外对范围内的生物","color":"gray","italic":false},{"text":"造成一次相当于自身当前魔力值 ×X×0.01","color":"gray","italic":false},{"text":"的伤害并使其附加「流火」。","color":"gray","italic":false}],custom_data={zx:["ol_dragon_tongue"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
