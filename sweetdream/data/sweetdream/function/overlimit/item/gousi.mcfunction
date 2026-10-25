# ============================================================
# sweetdream:overlimit/item/gousi —— 给一块「超限·钩丝」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_gousi :
#   进度 advancement/overlimit/gousi 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[64.0f]}(八芒星, 编号 64)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「钩丝」能敲(见 overlimit/api/fit: 副手 zx 必须含 gousi 且还没敲过 ol)。
# 【状态】2026-10-23 批 J2/J3/J4 全落地: give + 图标 + oldef + apply + advancement。
# 【consumable】已挂(批 J4) —— 主手拿石头右键, 要敲的装备放副手;
#   进度 consume_item -> overlimit/apply/gousi -> station/api/apply 校验/改名/换描述。
#   三件套(item + advancement + apply)与 oldef 均已就位, 敲失败会退材料并说明原因。
#   敲入后由 station/api/lore_refresh 改名 + 整段换描述(名字/描述取自 oldef)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·钩丝",bold:true,color:light_purple},custom_model_data={floats:[64.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"钩丝","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后钩丝更名为「超限·钩丝」，主动技","color":"gray","italic":false},{"text":"能变为：使用后选中自身 8 格内最近的三","color":"gray","italic":false},{"text":"个生物，以每 0.25 秒 0.8 格的速度将其","color":"gray","italic":false},{"text":"拉向自身，期间使其获得常态的缓慢Ⅰ效","color":"gray","italic":false},{"text":"果。在抵达身前 2 格或撞上不可替换的方","color":"gray","italic":false},{"text":"块时停下。拉到位置后，使其获得 5 秒缓","color":"gray","italic":false},{"text":"慢Ⅱ，并对其造成一次相当于自身最大魔","color":"gray","italic":false},{"text":"力值 ×0.12 的伤害，同时每拉到一个都会","color":"gray","italic":false},{"text":"使自身下三次技能伤害 +10%（独立乘区）。","color":"gray","italic":false},{"text":"若中途未能拉到，则改为造成一次相当于","color":"gray","italic":false},{"text":"自身最大魔力值 ×0.08 的伤害，且使自身","color":"gray","italic":false},{"text":"下一次技能伤害 +10%。","color":"gray","italic":false}],custom_data={zx:["ol_gousi"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
