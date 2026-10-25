# ============================================================
# sweetdream:overlimit/item/meteor —— 给一块「超限·陨星」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_meteor :
#   进度 advancement/overlimit/meteor 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[75.0f]}(八芒星, 编号 75)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「陨星」能敲(见 overlimit/api/fit: 副手 zx 必须含 meteor 且还没敲过 ol)。
# 【状态】2026-10-23 批 J2/J3/J4 全落地: give + 图标 + oldef + apply + advancement。
# 【consumable】已挂(批 J4) —— 主手拿石头右键, 要敲的装备放副手;
#   进度 consume_item -> overlimit/apply/meteor -> station/api/apply 校验/改名/换描述。
#   三件套(item + advancement + apply)与 oldef 均已就位, 敲失败会退材料并说明原因。
#   敲入后由 station/api/lore_refresh 改名 + 整段换描述(名字/描述取自 oldef)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·陨星",bold:true,color:light_purple},custom_model_data={floats:[75.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"陨星","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后陨星更名为「超限·陨星」，被动技","color":"gray","italic":false},{"text":"能变为：每次攻击都有 15% 的概率对自身","color":"gray","italic":false},{"text":"4 格内的随机三个生物及自身攻击的生物","color":"gray","italic":false},{"text":"降下一个陨石，且对其造成相当于自身基","color":"gray","italic":false},{"text":"础攻击力 ×5 的伤害，之后使其获得 3 秒","color":"gray","italic":false},{"text":"缓慢Ⅱ效果。主动技能变为：使用后攻击","color":"gray","italic":false},{"text":"间隔大幅度缩小，且被动概率提升为 100%，","color":"gray","italic":false},{"text":"持续 12 秒。且每次攻击都有 30% 的概率","color":"gray","italic":false},{"text":"对自身 4 格内的随机一个生物及自身攻击","color":"gray","italic":false},{"text":"的生物降下一个大陨石，且对其造成相当","color":"gray","italic":false},{"text":"于自身基础攻击力 ×8 的伤害，之后使其","color":"gray","italic":false},{"text":"获得 3 秒缓慢Ⅴ效果。期间若切换主手武","color":"gray","italic":false},{"text":"器则该武器被动和主动仍旧生效。","color":"gray","italic":false}],custom_data={zx:["ol_meteor"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
