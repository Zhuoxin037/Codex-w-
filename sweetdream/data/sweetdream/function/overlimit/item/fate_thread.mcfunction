# ============================================================
# sweetdream:overlimit/item/fate_thread —— 给一块「超限·命缕」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_fate_thread :
#   进度 advancement/overlimit/fate_thread 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[84.0f]}(八芒星, 编号 84)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「命缕」能敲(见 overlimit/api/fit: 副手 zx 必须含 fate_thread 且还没敲过 ol)。
# 【状态】2026-10-23 批 J2/J3/J4 全落地: give + 图标 + oldef + apply + advancement。
# 【consumable】已挂(批 J4) —— 主手拿石头右键, 要敲的装备放副手;
#   进度 consume_item -> overlimit/apply/fate_thread -> station/api/apply 校验/改名/换描述。
#   三件套(item + advancement + apply)与 oldef 均已就位, 敲失败会退材料并说明原因。
#   敲入后由 station/api/lore_refresh 改名 + 整段换描述(名字/描述取自 oldef)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·命缕",bold:true,color:light_purple},custom_model_data={floats:[84.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"命缕","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后命缕更名为「超限·命缕」，普攻变","color":"gray","italic":false},{"text":"为：伤害 1 每次普攻命中后都会在其身上","color":"gray","italic":false},{"text":"留下持续 10 秒的血色丝线。期间若普攻","color":"gray","italic":false},{"text":"命中了其 8 格内的另一个生物，则对二者","color":"gray","italic":false},{"text":"分别造成一次相当于自身最大魔力值","color":"gray","italic":false},{"text":"×0.06 的伤害，并使最初的生物附加","color":"gray","italic":false},{"text":"「噬心」，之后丝线消失。主动技能变为：","color":"gray","italic":false},{"text":"使用后选中自身 12 格内最近的一个附有","color":"gray","italic":false},{"text":"「噬心」的生物，使其及 6 格内最多 6","color":"gray","italic":false},{"text":"个其他生物以绯色丝线相连，持续 12 秒。","color":"gray","italic":false},{"text":"之后再选取其 12 格内有「噬心」的最多","color":"gray","italic":false},{"text":"4 个生物并相连，本次连接可以连接上次","color":"gray","italic":false},{"text":"连接已经连接了的生物，持续 18 秒。期","color":"gray","italic":false},{"text":"间连接的生物每次受到自身造成的伤害后，","color":"gray","italic":false},{"text":"相连的其他生物分别受到一次相当于本次","color":"gray","italic":false},{"text":"伤害 ×0.5 的真实伤害。若相连的生物有","color":"gray","italic":false},{"text":"两个或以上丝线同时相连则改为受到本次","color":"gray","italic":false},{"text":"伤害 ×0.8 的真实伤害。若连接的生物中","color":"gray","italic":false},{"text":"没有「噬心」，则丝线断开；若与相连生","color":"gray","italic":false},{"text":"物的距离超过 16 格或有生物死亡，则对","color":"gray","italic":false},{"text":"应丝线断开。丝线随时间即将结束时则绷","color":"gray","italic":false},{"text":"紧一次并对连接的全部生物造成一次 10 x","color":"gray","italic":false},{"text":"连接的生物数 点固定真实伤害并使其附加","color":"gray","italic":false},{"text":"「噬心」。","color":"gray","italic":false}],custom_data={zx:["ol_fate_thread"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
