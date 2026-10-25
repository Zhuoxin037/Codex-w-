# ============================================================
# sweetdream:overlimit/item/chenyuan —— 给一块「超限·沉渊」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_chenyuan :
#   进度 advancement/overlimit/chenyuan 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[71.0f]}(八芒星, 编号 71)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「沉渊」能敲(见 overlimit/api/fit: 副手 zx 必须含 chenyuan 且还没敲过 ol)。
# 【状态】2026-10-23 批 J2/J3/J4 全落地: give + 图标 + oldef + apply + advancement。
# 【consumable】已挂(批 J4) —— 主手拿石头右键, 要敲的装备放副手;
#   进度 consume_item -> overlimit/apply/chenyuan -> station/api/apply 校验/改名/换描述。
#   三件套(item + advancement + apply)与 oldef 均已就位, 敲失败会退材料并说明原因。
#   敲入后由 station/api/lore_refresh 改名 + 整段换描述(名字/描述取自 oldef)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·沉渊",bold:true,color:light_purple},custom_model_data={floats:[71.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"沉渊","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后沉渊更名为「超限·沉渊」，被动技","color":"gray","italic":false},{"text":"能变为：每次攻击带有缓慢效果的生物时","color":"gray","italic":false},{"text":"都会使该武器技能冷却 -1 秒。若自身魔","color":"gray","italic":false},{"text":"力值高于 300 则额外消耗 50 魔力值并使","color":"gray","italic":false},{"text":"其附加「渊海」效果，若其已附加则改为","color":"gray","italic":false},{"text":"为自身恢复 80 魔力值并使自身下一次释","color":"gray","italic":false},{"text":"放技能最大魔力值相关的技能时伤害 +10%","color":"gray","italic":false},{"text":"（不可叠加）。主动技能变为：使用后使","color":"gray","italic":false},{"text":"自身 6 格内随机一个生物及另一附加了","color":"gray","italic":false},{"text":"「渊海」效果的生物获得 3 秒缓慢Ⅳ效果，","color":"gray","italic":false},{"text":"之后对其造成相当于释放者自身当前魔力","color":"gray","italic":false},{"text":"值 ×0.08 的伤害。若自身有给自身最大魔","color":"gray","italic":false},{"text":"力值相关技能的增益则改为对 6 格内的全","color":"gray","italic":false},{"text":"部生物并释放该技能效果，且本次攻击伤","color":"gray","italic":false},{"text":"害改为最大魔力值 ×0.1。","color":"gray","italic":false}],custom_data={zx:["ol_chenyuan"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
