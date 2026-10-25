# ============================================================
# sweetdream:overlimit/item/cage_day —— 给一块「超限·囚昼」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_cage_day :
#   进度 advancement/overlimit/cage_day 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[85.0f]}(八芒星, 编号 85)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「囚昼」能敲(见 overlimit/api/fit: 副手 zx 必须含 cage_day 且还没敲过 ol)。
# 【状态】2026-10-23 批 J2/J3/J4 全落地: give + 图标 + oldef + apply + advancement。
# 【consumable】已挂(批 J4) —— 主手拿石头右键, 要敲的装备放副手;
#   进度 consume_item -> overlimit/apply/cage_day -> station/api/apply 校验/改名/换描述。
#   三件套(item + advancement + apply)与 oldef 均已就位, 敲失败会退材料并说明原因。
#   敲入后由 station/api/lore_refresh 改名 + 整段换描述(名字/描述取自 oldef)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·囚昼",bold:true,color:light_purple},custom_model_data={floats:[85.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"囚昼","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后囚昼更名为「超限·囚昼」，普攻变","color":"gray","italic":false},{"text":"为：伤害 自身最大魔力值 ×0.025。主动","color":"gray","italic":false},{"text":"技能变为：选中自身 8 格内最近的一个敌","color":"gray","italic":false},{"text":"对生物，使其附加「白昼梦」，持续 20","color":"gray","italic":false},{"text":"秒，并对其 8 格内的全部生物造成相当于","color":"gray","italic":false},{"text":"自身最大魔力值 ×0.12 的伤害。若选中的","color":"gray","italic":false},{"text":"生物已附有「白昼梦」，则该次伤害提高","color":"gray","italic":false},{"text":"50%（独立乘区），并将其「白昼梦」扩散","color":"gray","italic":false},{"text":"给 5 格内的生物。扩散到的生物若已经有","color":"gray","italic":false},{"text":"「白昼梦」则改为时停 3 秒且「白昼梦」","color":"gray","italic":false},{"text":"的持续时间延长至 25 秒。","color":"gray","italic":false}],custom_data={zx:["ol_cage_day"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
