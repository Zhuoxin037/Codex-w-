# ============================================================
# sweetdream:overlimit/item/apocalypse —— 给一块「超限·启示录」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_apocalypse :
#   进度 advancement/overlimit/apocalypse 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[83.0f]}(八芒星, 编号 83)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「启示录」能敲(见 overlimit/api/fit: 副手 zx 必须含 apocalypse 且还没敲过 ol)。
# 【状态】2026-10-23 批 J2/J3/J4 全落地: give + 图标 + oldef + apply + advancement。
# 【consumable】已挂(批 J4) —— 主手拿石头右键, 要敲的装备放副手;
#   进度 consume_item -> overlimit/apply/apocalypse -> station/api/apply 校验/改名/换描述。
#   三件套(item + advancement + apply)与 oldef 均已就位, 敲失败会退材料并说明原因。
#   敲入后由 station/api/lore_refresh 改名 + 整段换描述(名字/描述取自 oldef)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·启示录",bold:true,color:light_purple},custom_model_data={floats:[83.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"启示录","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后启示录更名为「超限·启示录」，普","color":"gray","italic":false},{"text":"攻变为：伤害 最大魔力值 ×0.03。","color":"gray","italic":false},{"text":"「启示」变为：该武器位于快捷栏时，自","color":"gray","italic":false},{"text":"身每次释放主动技能时若该技能消耗了至","color":"gray","italic":false},{"text":"少 100 魔力，则「启示录」记录该技能消","color":"gray","italic":false},{"text":"耗的魔力值并获得一页「启示」，最多记","color":"gray","italic":false},{"text":"录 4 页。每个技能单次最多产生一页。主","color":"gray","italic":false},{"text":"动技能变为：使用后召唤一个术阵，并每","color":"gray","italic":false},{"text":"隔 4 秒就依次消耗一层「启示」。","color":"gray","italic":false},{"text":"「灾示」变为：每消耗一页，每隔 3 秒发","color":"gray","italic":false},{"text":"生一次「灾示」：对自身 8 格内全部生物","color":"gray","italic":false},{"text":"造成相当于该页记录魔力值 ×0.8 的伤害。","color":"gray","italic":false},{"text":"若该页记录的技能消耗魔力超过 500，则","color":"gray","italic":false},{"text":"本次「灾示」额外使目标获得 10 秒发光","color":"gray","italic":false},{"text":"与虚弱Ⅱ且本次伤害提高 30%","color":"gray","italic":false},{"text":"（独立乘区）。若至少消耗了三页启示，","color":"gray","italic":false},{"text":"则所有「灾示」伤害提高 50%，且在技能","color":"gray","italic":false},{"text":"释放完成后对自身 6 格内的生物附加 4","color":"gray","italic":false},{"text":"秒的缓慢Ⅴ效果。","color":"gray","italic":false}],custom_data={zx:["ol_apocalypse"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
