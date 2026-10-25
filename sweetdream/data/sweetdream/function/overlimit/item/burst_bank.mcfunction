# ============================================================
# sweetdream:overlimit/item/burst_bank —— 给一块「超限·决堤」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_burst_bank :
#   进度 advancement/overlimit/burst_bank 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[82.0f]}(八芒星, 编号 82)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「决堤」能敲(见 overlimit/api/fit: 副手 zx 必须含 burst_bank 且还没敲过 ol)。
# 【状态】2026-10-23 批 J2/J3/J4 全落地: give + 图标 + oldef + apply + advancement。
# 【consumable】已挂(批 J4) —— 主手拿石头右键, 要敲的装备放副手;
#   进度 consume_item -> overlimit/apply/burst_bank -> station/api/apply 校验/改名/换描述。
#   三件套(item + advancement + apply)与 oldef 均已就位, 敲失败会退材料并说明原因。
#   敲入后由 station/api/lore_refresh 改名 + 整段换描述(名字/描述取自 oldef)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·决堤",bold:true,color:light_purple},custom_model_data={floats:[82.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"决堤","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后决堤更名为「超限·决堤」，普攻变","color":"gray","italic":false},{"text":"为：伤害 自身当前魔力值 ×0.03。主动技","color":"gray","italic":false},{"text":"能变为：当前魔力值不足 100 时无法施放。","color":"gray","italic":false},{"text":"使用后向准星方向突进，每消耗 25 点魔","color":"gray","italic":false},{"text":"力突进 1 格（最少突进 2 格、最多 18","color":"gray","italic":false},{"text":"格）。被突进路径穿过的生物受到相当于","color":"gray","italic":false},{"text":"消耗魔力值 ×0.2 的伤害，并被带向落点；","color":"gray","italic":false},{"text":"落点 3 格内的生物受到相当于消耗魔力值","color":"gray","italic":false},{"text":"×0.15 的伤害并被向外击退 2 格。落地后","color":"gray","italic":false},{"text":"2 秒内自身获得迅捷Ⅱ。之后在突进经过","color":"gray","italic":false},{"text":"的位置留下水流，在水流上的生物每秒都","color":"gray","italic":false},{"text":"会受到相当于消耗魔力值 ×0.08 的伤害，","color":"gray","italic":false},{"text":"且获得常态的缓慢Ⅰ效果，自身在水流上","color":"gray","italic":false},{"text":"时获得常态的迅捷Ⅰ效果，水流持续 12","color":"gray","italic":false},{"text":"秒。若落点脚下没有可站立的方块，则改","color":"gray","italic":false},{"text":"为原地施放并返还一半魔力值。","color":"gray","italic":false}],custom_data={zx:["ol_burst_bank"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
