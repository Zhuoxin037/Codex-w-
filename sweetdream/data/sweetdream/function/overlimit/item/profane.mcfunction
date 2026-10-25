# ============================================================
# sweetdream:overlimit/item/profane —— 给一块「超限·剖心」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_profane :
#   进度 advancement/overlimit/profane 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[62.0f]}(八芒星, 编号 62)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「剖心」能敲(见 overlimit/api/fit: 副手 zx 必须含 profane 且还没敲过 ol)。
# 【状态】2026-10-23 批 J2/J3/J4 全落地: give + 图标 + oldef + apply + advancement。
# 【consumable】已挂(批 J4) —— 主手拿石头右键, 要敲的装备放副手;
#   进度 consume_item -> overlimit/apply/profane -> station/api/apply 校验/改名/换描述。
#   三件套(item + advancement + apply)与 oldef 均已就位, 敲失败会退材料并说明原因。
#   敲入后由 station/api/lore_refresh 改名 + 整段换描述(名字/描述取自 oldef)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·剖心",bold:true,color:light_purple},custom_model_data={floats:[62.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"剖心","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后剖心更名为「超限·剖心」，被动技","color":"gray","italic":false},{"text":"能变为：每次普通攻击命中附有「噬心」","color":"gray","italic":false},{"text":"的生物时，使其「噬心」的剩余时长延长","color":"gray","italic":false},{"text":"3 秒（最多 24 秒），并额外造成一次相","color":"gray","italic":false},{"text":"当于自身基础攻击力的伤害。主动技能变","color":"gray","italic":false},{"text":"为：使用后向准星方向斩出一道 2×8 的剖","color":"gray","italic":false},{"text":"线，对命中的全部生物造成相当于自身基","color":"gray","italic":false},{"text":"础攻击力 ×5 的伤害。若命中的生物附有","color":"gray","italic":false},{"text":"「噬心」，则清除其「噬心」，该次伤害","color":"gray","italic":false},{"text":"改为相当于自身基础攻击力 ×8，且伤害额","color":"gray","italic":false},{"text":"外提高 50%（独立乘区），并使命中的生","color":"gray","italic":false},{"text":"物 2 格内的其他生物受到相等的伤害。每","color":"gray","italic":false},{"text":"清除一个「噬心」，自身所有技能的冷却","color":"gray","italic":false},{"text":"时间减少 3 秒。若本次清除的「噬心」数","color":"gray","italic":false},{"text":"量大于 5 个则使该武器前面的武器冷却时","color":"gray","italic":false},{"text":"间减少 10 秒。","color":"gray","italic":false}],custom_data={zx:["ol_profane"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
