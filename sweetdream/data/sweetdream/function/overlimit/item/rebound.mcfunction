# ============================================================
# sweetdream:overlimit/item/rebound —— 给一块「超限·回锋」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_rebound :
#   进度 advancement/overlimit/rebound 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[58.0f]}(八芒星, 编号 58)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「回锋」能敲(见 overlimit/api/fit: 副手 zx 必须含 rebound 且还没敲过 ol)。
# 【状态】2026-10-23 批 J2/J3/J4 全落地: give + 图标 + oldef + apply + advancement。
# 【consumable】已挂(批 J4) —— 主手拿石头右键, 要敲的装备放副手;
#   进度 consume_item -> overlimit/apply/rebound -> station/api/apply 校验/改名/换描述。
#   三件套(item + advancement + apply)与 oldef 均已就位, 敲失败会退材料并说明原因。
#   敲入后由 station/api/lore_refresh 改名 + 整段换描述(名字/描述取自 oldef)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·回锋",bold:true,color:light_purple},custom_model_data={floats:[58.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"回锋","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后回锋更名为「超限·回锋」，","color":"gray","italic":false},{"text":"「断刃」变为：每次攻击时若有 80 及以","color":"gray","italic":false},{"text":"上魔力则消耗 50 魔力值并为自身附加一","color":"gray","italic":false},{"text":"层「断刃」（最多 4 层）。主动技能变为：","color":"gray","italic":false},{"text":"对自身前方 3×5 格内的生物造成相当于自","color":"gray","italic":false},{"text":"身基础攻击力 ×2 的伤害。若有「断刃」","color":"gray","italic":false},{"text":"则消耗全部「断刃」且每有一层则重复一","color":"gray","italic":false},{"text":"次以上效果且该技能倍率翻倍一次。","color":"gray","italic":false}],custom_data={zx:["ol_rebound"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
