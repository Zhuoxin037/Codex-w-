# ============================================================
# sweetdream:overlimit/item/pour_sack —— 给一块「超限·倾囊」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_pour_sack :
#   进度 advancement/overlimit/pour_sack 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[81.0f]}(八芒星, 编号 81)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「倾囊」能敲(见 overlimit/api/fit: 副手 zx 必须含 pour_sack 且还没敲过 ol)。
# 【状态】2026-10-23 批 J2/J3/J4 全落地: give + 图标 + oldef + apply + advancement。
# 【consumable】已挂(批 J4) —— 主手拿石头右键, 要敲的装备放副手;
#   进度 consume_item -> overlimit/apply/pour_sack -> station/api/apply 校验/改名/换描述。
#   三件套(item + advancement + apply)与 oldef 均已就位, 敲失败会退材料并说明原因。
#   敲入后由 station/api/lore_refresh 改名 + 整段换描述(名字/描述取自 oldef)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·倾囊",bold:true,color:light_purple},custom_model_data={floats:[81.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"倾囊","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后倾囊更名为「超限·倾囊」，普攻变","color":"gray","italic":false},{"text":"为：伤害 16。主动技能变为：当前魔力值","color":"gray","italic":false},{"text":"不足 100 时无法施放。使用后把消耗的魔","color":"gray","italic":false},{"text":"力压成一枚钉子射出，命中 10 格内最近","color":"gray","italic":false},{"text":"的一个生物，每 5 点消耗魔力转化为 1.5","color":"gray","italic":false},{"text":"点固定伤害。若本次消耗的魔力不低于","color":"gray","italic":false},{"text":"120，则再对其 5 格内的全部生物造成相","color":"gray","italic":false},{"text":"等的固定伤害。之后自身对生物造成固定","color":"gray","italic":false},{"text":"伤害时都会额外对其造成相当于本次转化","color":"gray","italic":false},{"text":"伤害的固定伤害，持续 8 秒。","color":"gray","italic":false}],custom_data={zx:["ol_pour_sack"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
