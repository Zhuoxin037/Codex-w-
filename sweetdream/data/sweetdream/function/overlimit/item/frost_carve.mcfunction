# ============================================================
# sweetdream:overlimit/item/frost_carve —— 给一块「超限·剜霜」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_frost_carve :
#   进度 advancement/overlimit/frost_carve 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[69.0f]}(八芒星, 编号 69)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「剜霜」能敲(见 overlimit/api/fit: 副手 zx 必须含 frost_carve 且还没敲过 ol)。
# 【状态】2026-10-23 批 J2/J3/J4 全落地: give + 图标 + oldef + apply + advancement。
# 【consumable】已挂(批 J4) —— 主手拿石头右键, 要敲的装备放副手;
#   进度 consume_item -> overlimit/apply/frost_carve -> station/api/apply 校验/改名/换描述。
#   三件套(item + advancement + apply)与 oldef 均已就位, 敲失败会退材料并说明原因。
#   敲入后由 station/api/lore_refresh 改名 + 整段换描述(名字/描述取自 oldef)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·剜霜",bold:true,color:light_purple},custom_model_data={floats:[69.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"剜霜","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后剜霜更名为「超限·剜霜」，主动技","color":"gray","italic":false},{"text":"能变为：使用后重击前方 4×3 格范围内的","color":"gray","italic":false},{"text":"生物，造成一次相当于自身基础攻击力 ×6","color":"gray","italic":false},{"text":"的伤害，之后使未处于冰冻状态的生物被","color":"gray","italic":false},{"text":"冰冻 3 秒，已处于冰冻状态的生物解除冰","color":"gray","italic":false},{"text":"冻，并额外受到一次相当于自身基础攻击","color":"gray","italic":false},{"text":"力 ×3 的伤害。若本次至少解除了两个生","color":"gray","italic":false},{"text":"物的冰冻，则为自身恢复最大生命值 20%","color":"gray","italic":false},{"text":"的生命，之后为自身附加 3 层持续 12 秒","color":"gray","italic":false},{"text":"的「披霜」。自身每受到一次伤害则自身","color":"gray","italic":false},{"text":"消耗一层「披霜」并使攻击自己的生物及","color":"gray","italic":false},{"text":"其 3 格内的全部生物冰冻 2 秒。","color":"gray","italic":false}],custom_data={zx:["ol_frost_carve"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
