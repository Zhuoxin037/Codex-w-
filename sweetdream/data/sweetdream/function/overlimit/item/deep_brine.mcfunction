# ============================================================
# sweetdream:overlimit/item/deep_brine —— 给一块「超限·重溟」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_deep_brine :
#   进度 advancement/overlimit/deep_brine 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[74.0f]}(八芒星, 编号 74)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「重溟」能敲(见 overlimit/api/fit: 副手 zx 必须含 deep_brine 且还没敲过 ol)。
# 【状态】2026-10-23 批 J2/J3/J4 全落地: give + 图标 + oldef + apply + advancement。
# 【consumable】已挂(批 J4) —— 主手拿石头右键, 要敲的装备放副手;
#   进度 consume_item -> overlimit/apply/deep_brine -> station/api/apply 校验/改名/换描述。
#   三件套(item + advancement + apply)与 oldef 均已就位, 敲失败会退材料并说明原因。
#   敲入后由 station/api/lore_refresh 改名 + 整段换描述(名字/描述取自 oldef)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·重溟",bold:true,color:light_purple},custom_model_data={floats:[74.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"重溟","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后重溟更名为「超限·重溟」，被动技","color":"gray","italic":false},{"text":"能变为：每次普通攻击命中了附有","color":"gray","italic":false},{"text":"「渊海」的生物后，额外造成一次相当于","color":"gray","italic":false},{"text":"自身最大魔力值 ×0.05 的伤害，并使其获","color":"gray","italic":false},{"text":"得 2 秒缓慢Ⅲ。该效果对同一个生物 3","color":"gray","italic":false},{"text":"秒内最多触发一次。主动技能变为：使用","color":"gray","italic":false},{"text":"后重击自身前方 5×4 格范围内的全部生物，","color":"gray","italic":false},{"text":"造成一次相当于自身最大魔力值 ×0.12 的","color":"gray","italic":false},{"text":"伤害。若命中了附有「渊海」的生物，则","color":"gray","italic":false},{"text":"消耗该生物的「渊海」。每消耗一个则在","color":"gray","italic":false},{"text":"其位置生成一个半径 5 格、持续 6 秒的","color":"gray","italic":false},{"text":"领域。领域内的生物每秒受到一次相当于","color":"gray","italic":false},{"text":"自身最大魔力值 ×0.03 的伤害，且持续被","color":"gray","italic":false},{"text":"大力拉向中心。领域结束时将领域内的生","color":"gray","italic":false},{"text":"物超大力的拉动一次。若领域重叠则领域","color":"gray","italic":false},{"text":"合并。领域中心为随机一个被合并的领域","color":"gray","italic":false},{"text":"的中心。合并的领域初始为半径 8 格，持","color":"gray","italic":false},{"text":"续 6 秒。每合并一个则半径 +3 格（每个","color":"gray","italic":false},{"text":"合并领域最多合并 4 个）。","color":"gray","italic":false}],custom_data={zx:["ol_deep_brine"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
