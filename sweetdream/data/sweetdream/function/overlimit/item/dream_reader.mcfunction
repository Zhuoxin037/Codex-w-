# ============================================================
# sweetdream:overlimit/item/dream_reader —— 给一块「超限·释梦」
# ------------------------------------------------------------
# 【custom_data】只写一个标记 ol_dream_reader :
#   进度 advancement/overlimit/dream_reader 靠它认"右键用掉了哪块超限石"。
# 【底座】recovery_compass + custom_model_data={floats:[45.0f]}(八芒星, 编号 45)。
#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 对应, 改一边要改两边。
# 【适用】只有「释梦」能敲(见 overlimit/api/fit: 副手 zx 必须含 dream_reader
#   且这件还没敲过 ol)。
# 【★ 机制落在哪(2026-10-10 实装) ★】超限版改四处 ——
#   ① 被动: 5 ×剩余时停秒数 -> **基础攻击力(最低 10) ×剩余时停秒数 ×0.5**(hit ③'');
#   ② 入梦体自毁距离: 离施法者 **10 -> 18 格**(pet_tick ②);
#   ③ 入梦体**不再"打一次就走"** —— 打完记进共享名单 `zx.dr_done`, 摘掉绑定去追下一个,
#      直到"施法者 **12 格内没有未攻击过的目标**"(pet_scan) 才自毁;
#   ④ 入梦体伤害 **×0.1 -> ×0.12**、时停 **3 -> 2 秒**(cast ⑤ / pet_hit ②)。
#   数 3 / 魔力 200 / 冷却 40 秒 **都不变**。
#   ★ 两处"自身"(18 格 / 12 格)都指**施法者**(用户 2026-10-10 确认)。
#   ★ 名单清理在 cast ⑥': 场上没有入梦体时才清(多玩家同时开着时不清, 免得抹别人的)。
# ============================================================

give @s recovery_compass[max_stack_size=1,item_name={text:"超限·释梦",bold:true,color:light_purple},custom_model_data={floats:[45.0f]},lore=[{"text":"✦ 超限石","color":"gold","bold":true,"italic":false},{"text":"","italic":false,"extra":[{"text":"适用于 ","color":"gray"},{"text":"释梦","color":"blue"},{"text":"   ·   ","color":"dark_gray"},{"text":"前置 ","color":"gray"},{"text":"尚未超限","color":"aqua"}]},{"text":" ","italic":false},{"text":"敲入后释梦更名为「超限·释梦」，被动技","color":"gray","italic":false},{"text":"能变为：攻击处于时停状态的生物时对其","color":"gray","italic":false},{"text":"额外造成相当于自身基础攻击力","color":"gray","italic":false},{"text":"（最低为 10） × 剩余时停时间 ×0.5 的","color":"gray","italic":false},{"text":"真实伤害，之后解除他的时停状态。主动","color":"gray","italic":false},{"text":"技能变为：使用后召唤 3 个“入梦体”。","color":"gray","italic":false},{"text":"“入梦体”会在离自身 18 格远或自身 12","color":"gray","italic":false},{"text":"格内没有未攻击过的目标后自毁。“入梦","color":"gray","italic":false},{"text":"体”会自动追踪离其最近的生物并对其造","color":"gray","italic":false},{"text":"成相当于释放者当前魔力值 ×0.12 的伤害，","color":"gray","italic":false},{"text":"之后使其时停 2 秒并附加「白昼梦」效果。","color":"gray","italic":false}],custom_data={zx:["ol_dream_reader"]},consumable={animation:"none",consume_seconds:0,has_consume_particles:false,sound:"block.bamboo_wood_button.click_off"}]
