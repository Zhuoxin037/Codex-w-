# ============================================================
# sweetdream:overlimit/item/tidemark —— 给一块「超限·潮痕」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_tidemark :
#   进度 advancement/overlimit/tidemark 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[59.0f]}(八芒星, 编号 59)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「潮痕」能敲(见 overlimit/api/fit: 副手 zx 必须含 tidemark 且还没敲过 ol)。
# 【状态】2026-10-23 批 J2/J3/J4 全落地: give + 图标 + oldef + apply + advancement。
# 【consumable】已挂(批 J4) —— 主手拿石头右键, 要敲的装备放副手;
#   进度 consume_item -> overlimit/apply/tidemark -> station/api/apply 校验/改名/换描述。
#   三件套(item + advancement + apply)与 oldef 均已就位, 敲失败会退材料并说明原因。
#   敲入后由 station/api/lore_refresh 改名 + 整段换描述(名字/描述取自 oldef)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·潮痕",bold:true,color:light_purple},custom_model_data={floats:[59.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"潮痕","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后潮痕更名为「超限·潮痕」，主动技","color":"gray","italic":false},{"text":"能变为：使用后对自身前方 4×5 范围内的","color":"gray","italic":false},{"text":"生物造成一次相当于自身最大魔力值 ×0.1","color":"gray","italic":false},{"text":"的伤害，之后使受到伤害的生物附加","color":"gray","italic":false},{"text":"「渊海」，若其已有「渊海」则使其","color":"gray","italic":false},{"text":"「渊海」的持续时间提升至 30 秒。","color":"gray","italic":false}],custom_data={zx:["ol_tidemark"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
