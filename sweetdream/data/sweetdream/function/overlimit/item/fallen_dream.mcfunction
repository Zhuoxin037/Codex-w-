# ============================================================
# sweetdream:overlimit/item/fallen_dream —— 给一块「超限·堕梦」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_fallen_dream :
#   进度 advancement/overlimit/fallen_dream 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[86.0f]}(八芒星, 编号 86)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「堕梦」能敲(见 overlimit/api/fit: 副手 zx 必须含 fallen_dream 且还没敲过 ol)。
# 【状态】2026-10-23 批 J2/J3/J4 全落地: give + 图标 + oldef + apply + advancement。
# 【consumable】已挂(批 J4) —— 主手拿石头右键, 要敲的装备放副手;
#   进度 consume_item -> overlimit/apply/fallen_dream -> station/api/apply 校验/改名/换描述。
#   三件套(item + advancement + apply)与 oldef 均已就位, 敲失败会退材料并说明原因。
#   敲入后由 station/api/lore_refresh 改名 + 整段换描述(名字/描述取自 oldef)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·堕梦",bold:true,color:light_purple},custom_model_data={floats:[86.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"堕梦","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后堕梦更名为「超限·堕梦」，普攻变","color":"gray","italic":false},{"text":"为：伤害 最大魔力值 ×0.03 每次普攻命","color":"gray","italic":false},{"text":"中后若其处于「白昼梦」效果则本次伤害","color":"gray","italic":false},{"text":"变为真实伤害。之后有 20% 的概率额外使","color":"gray","italic":false},{"text":"其时停 1 秒。主动技能变为：使用后召唤","color":"gray","italic":false},{"text":"一个术阵。之后使自身 8 格内的全部生物","color":"gray","italic":false},{"text":"附加「白昼梦」效果，若其未处于时停状","color":"gray","italic":false},{"text":"态则使其时停 4 秒，若其处于时停状态则","color":"gray","italic":false},{"text":"使其时停时间 +3 秒。之后使其在接下来","color":"gray","italic":false},{"text":"的时停时间内每秒受到一次相当于使用者","color":"gray","italic":false},{"text":"当前魔力值 ×0.05 的伤害。当生物受到超","color":"gray","italic":false},{"text":"过 6 次本次伤害后则后续对其的伤害提升","color":"gray","italic":false},{"text":"为相当于使用者当前魔力值 ×0.08 的伤害。","color":"gray","italic":false}],custom_data={zx:["ol_fallen_dream"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
