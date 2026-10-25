# ============================================================
# sweetdream:overlimit/item/ballad —— 给一块「超限·歌谣」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_ballad :
#   进度 advancement/overlimit/ballad 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[70.0f]}(八芒星, 编号 70)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「歌谣」能敲(见 overlimit/api/fit: 副手 zx 必须含 ballad 且还没敲过 ol)。
# 【状态】2026-10-23 批 J2/J3/J4 全落地: give + 图标 + oldef + apply + advancement。
# 【consumable】已挂(批 J4) —— 主手拿石头右键, 要敲的装备放副手;
#   进度 consume_item -> overlimit/apply/ballad -> station/api/apply 校验/改名/换描述。
#   三件套(item + advancement + apply)与 oldef 均已就位, 敲失败会退材料并说明原因。
#   敲入后由 station/api/lore_refresh 改名 + 整段换描述(名字/描述取自 oldef)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·歌谣",bold:true,color:light_purple},custom_model_data={floats:[70.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"歌谣","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后歌谣更名为「超限·歌谣」，","color":"gray","italic":false},{"text":"「曲调」变为：自身使用「歌谣」时每攻","color":"gray","italic":false},{"text":"击或击杀一个生物则积攒一点「曲调」。","color":"gray","italic":false},{"text":"（最高 8 层）。主动技能变为：使用后自","color":"gray","italic":false},{"text":"身下一次攻击额外对自身 X 格内的 X 个","color":"gray","italic":false},{"text":"生物造成一次相当于自身基础攻击力 ×","color":"gray","italic":false},{"text":"（9-X）的真实伤害并时停 X 秒。然后召","color":"gray","italic":false},{"text":"唤（9-X）个“音符”，每个“音符”都会","color":"gray","italic":false},{"text":"先锁定一个不同的生物，1 秒后向锁定到","color":"gray","italic":false},{"text":"该生物的位置发射出去并对路径上的生物","color":"gray","italic":false},{"text":"造成相当于自身基础攻击力 x X 的真实伤","color":"gray","italic":false},{"text":"害，在到达该生物原先的位置后自毁。之","color":"gray","italic":false},{"text":"后清除全部「曲调」。（X 为「曲调」层","color":"gray","italic":false},{"text":"数）。","color":"gray","italic":false}],custom_data={zx:["ol_ballad"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
