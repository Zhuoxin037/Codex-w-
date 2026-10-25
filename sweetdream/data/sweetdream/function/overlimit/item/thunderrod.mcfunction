# ============================================================
# sweetdream:overlimit/item/thunderrod —— 给一块「超限·引雷针」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_thunderrod :
#   进度 advancement/overlimit/thunderrod 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[87.0f]}(八芒星, 编号 87)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「引雷针」能敲(见 overlimit/api/fit: 副手 zx 必须含 thunderrod 且还没敲过 ol)。
# 【状态】2026-10-23 批 J2/J3/J4 全落地: give + 图标 + oldef + apply + advancement。
# 【consumable】已挂(批 J4) —— 主手拿石头右键, 要敲的装备放副手;
#   进度 consume_item -> overlimit/apply/thunderrod -> station/api/apply 校验/改名/换描述。
#   三件套(item + advancement + apply)与 oldef 均已就位, 敲失败会退材料并说明原因。
#   敲入后由 station/api/lore_refresh 改名 + 整段换描述(名字/描述取自 oldef)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·引雷针",bold:true,color:light_purple},custom_model_data={floats:[87.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"引雷针","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后引雷针更名为「超限·引雷针」，普","color":"gray","italic":false},{"text":"攻变为：伤害 1 每次普攻命中后，1 秒后","color":"gray","italic":false},{"text":"在目标所在位置降下两道闪电。主动技能","color":"gray","italic":false},{"text":"变为：使用后对自身 8 格内至多 7 个生","color":"gray","italic":false},{"text":"物各降下三道闪电，且本次闪电伤害额外","color":"gray","italic":false},{"text":"附加相当于自身最大魔力值 x 0.1 的伤害。","color":"gray","italic":false},{"text":"之后在 5 秒内若有生物被闪电命中 3 次","color":"gray","italic":false},{"text":"则自身下一次使用技能时会额外附加一次","color":"gray","italic":false},{"text":"本技能的主动技能，该增益持续 12 秒。","color":"gray","italic":false}],custom_data={zx:["ol_thunderrod"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
