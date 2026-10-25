# ============================================================
# sweetdream:overlimit/item/xiugou —— 给一块「超限·锈犬」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_xiugou :
#   进度 advancement/overlimit/xiugou 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[66.0f]}(八芒星, 编号 66)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「锈犬」能敲(见 overlimit/api/fit: 副手 zx 必须含 xiugou 且还没敲过 ol)。
# 【状态】2026-10-23 批 J2/J3/J4 全落地: give + 图标 + oldef + apply + advancement。
# 【consumable】已挂(批 J4) —— 主手拿石头右键, 要敲的装备放副手;
#   进度 consume_item -> overlimit/apply/xiugou -> station/api/apply 校验/改名/换描述。
#   三件套(item + advancement + apply)与 oldef 均已就位, 敲失败会退材料并说明原因。
#   敲入后由 station/api/lore_refresh 改名 + 整段换描述(名字/描述取自 oldef)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·锈犬",bold:true,color:light_purple},custom_model_data={floats:[66.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"锈犬","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后锈犬更名为「超限·锈犬」，主动技","color":"gray","italic":false},{"text":"能变为：使用后在自身身前 2 格召唤三只","color":"gray","italic":false},{"text":"“锈犬”，持续 10 秒。每只“锈犬”都","color":"gray","italic":false},{"text":"会追击不同的生物。锈犬每秒撕咬自身 8","color":"gray","italic":false},{"text":"格内最近的一个生物，造成一次等同于自","color":"gray","italic":false},{"text":"身基础攻击力 ×2 的伤害。“锈犬”每对","color":"gray","italic":false},{"text":"一个生物造成了 5 次伤害后则对其造成一","color":"gray","italic":false},{"text":"次相当于自身基础攻击力 ×5 的伤害，之","color":"gray","italic":false},{"text":"后使其接下来的 10 秒内被召唤物攻击时","color":"gray","italic":false},{"text":"受到的伤害 +30%。","color":"gray","italic":false}],custom_data={zx:["ol_xiugou"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
