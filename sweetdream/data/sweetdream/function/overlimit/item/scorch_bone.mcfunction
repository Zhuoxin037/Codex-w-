# ============================================================
# sweetdream:overlimit/item/scorch_bone —— 给一块「超限·焦骨」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_scorch_bone :
#   进度 advancement/overlimit/scorch_bone 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[73.0f]}(八芒星, 编号 73)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「焦骨」能敲(见 overlimit/api/fit: 副手 zx 必须含 scorch_bone 且还没敲过 ol)。
# 【状态】2026-10-23 批 J2/J3/J4 全落地: give + 图标 + oldef + apply + advancement。
# 【consumable】已挂(批 J4) —— 主手拿石头右键, 要敲的装备放副手;
#   进度 consume_item -> overlimit/apply/scorch_bone -> station/api/apply 校验/改名/换描述。
#   三件套(item + advancement + apply)与 oldef 均已就位, 敲失败会退材料并说明原因。
#   敲入后由 station/api/lore_refresh 改名 + 整段换描述(名字/描述取自 oldef)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·焦骨",bold:true,color:light_purple},custom_model_data={floats:[73.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"焦骨","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后焦骨更名为「超限·焦骨」，主动技","color":"gray","italic":false},{"text":"能变为：攻击 6 格内最近一个目标，造成","color":"gray","italic":false},{"text":"相当于自身基础攻击力 ×8 的伤害，并对","color":"gray","italic":false},{"text":"其周围 4 格造成最大魔力 ×0.08 伤害并","color":"gray","italic":false},{"text":"附加「流火」。若受到伤害的生物拥有","color":"gray","italic":false},{"text":"「流火」，则将其「流火」转化为","color":"gray","italic":false},{"text":"「夜火」，并返还本次技能所消耗魔力的","color":"gray","italic":false},{"text":"50%；若受到伤害的生物原本已经拥有","color":"gray","italic":false},{"text":"「夜火」，则改为将范围伤害提高至相当","color":"gray","italic":false},{"text":"于自身最大魔力 ×0.12 并返还本次技能所","color":"gray","italic":false},{"text":"消耗魔力的 80%。","color":"gray","italic":false}],custom_data={zx:["ol_scorch_bone"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
