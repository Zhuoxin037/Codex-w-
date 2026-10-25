# ============================================================
# sweetdream:overlimit/item/draught —— 给一块「超限·饮鸩」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_draught :
#   进度 advancement/overlimit/draught 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[67.0f]}(八芒星, 编号 67)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「饮鸩」能敲(见 overlimit/api/fit: 副手 zx 必须含 draught 且还没敲过 ol)。
# 【状态】2026-10-23 批 J2/J3/J4 全落地: give + 图标 + oldef + apply + advancement。
# 【consumable】已挂(批 J4) —— 主手拿石头右键, 要敲的装备放副手;
#   进度 consume_item -> overlimit/apply/draught -> station/api/apply 校验/改名/换描述。
#   三件套(item + advancement + apply)与 oldef 均已就位, 敲失败会退材料并说明原因。
#   敲入后由 station/api/lore_refresh 改名 + 整段换描述(名字/描述取自 oldef)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·饮鸩",bold:true,color:light_purple},custom_model_data={floats:[67.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"饮鸩","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后饮鸩更名为「超限·饮鸩」，主动技","color":"gray","italic":false},{"text":"能变为：使用后对自身造成相当于自身最","color":"gray","italic":false},{"text":"大生命值 ×0.8 的伤害，之后获得相当于","color":"gray","italic":false},{"text":"本次伤害数值的基础攻击力加成，持续 12","color":"gray","italic":false},{"text":"秒。之后若自身的血量高于 60% 则可以再","color":"gray","italic":false},{"text":"次使用该技能，且本技能效果改为每攻击","color":"gray","italic":false},{"text":"一次生物则自身受到一次相当于自身最大","color":"gray","italic":false},{"text":"生命值 ×0.1 的真实伤害，之后使自身基","color":"gray","italic":false},{"text":"础攻击力 +10%，持续 10 秒且最多触发四","color":"gray","italic":false},{"text":"次。","color":"gray","italic":false}],custom_data={zx:["ol_draught"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
