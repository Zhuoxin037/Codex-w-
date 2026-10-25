# ============================================================
# sweetdream:overlimit/item/reverse_string —— 给一块「超限·逆弦」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_reverse_string :
#   进度 advancement/overlimit/reverse_string 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[77.0f]}(八芒星, 编号 77)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「逆弦」能敲(见 overlimit/api/fit: 副手 zx 必须含 reverse_string 且还没敲过 ol)。
# 【状态】2026-10-23 批 J2/J3/J4 全落地: give + 图标 + oldef + apply + advancement。
# 【consumable】已挂(批 J4) —— 主手拿石头右键, 要敲的装备放副手;
#   进度 consume_item -> overlimit/apply/reverse_string -> station/api/apply 校验/改名/换描述。
#   三件套(item + advancement + apply)与 oldef 均已就位, 敲失败会退材料并说明原因。
#   敲入后由 station/api/lore_refresh 改名 + 整段换描述(名字/描述取自 oldef)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·逆弦",bold:true,color:light_purple},custom_model_data={floats:[77.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"逆弦","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后逆弦更名为「超限·逆弦」，主动技","color":"gray","italic":false},{"text":"能变为：每次射击命中生物后，额外造成","color":"gray","italic":false},{"text":"一次相当于自身基础攻击力 ×2 的伤害。","color":"gray","italic":false},{"text":"若自身当前魔力值不高于最大魔力值的","color":"gray","italic":false},{"text":"30%，则该段技能伤害提高 200%","color":"gray","italic":false},{"text":"（独立乘区）；若强化段击杀了生物，则","color":"gray","italic":false},{"text":"返还本次消耗的 50% 魔力。","color":"gray","italic":false}],custom_data={zx:["ol_reverse_string"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
