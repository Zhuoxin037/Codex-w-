# ============================================================
# sweetdream:equipment/armor/dusk_dawn/kill_mark_go —— 记这笔"带标签击杀 +100"
# ------------------------------------------------------------
# 【执行者】玩家(攻击者)   【谁调它】进度回调 kill_mark / 伤害接口 kill_mark_from_skill
# 【做四件事】
#   ① 穿着黄昏黎明之交界(部分匹配, 不然静默失效) ② 和基础账"同一次击杀只清一次账"
#   ③ 标签账 = 100   ④ 按差值把面板补上(temp_apply 只加差额, 所以重复调用无害)
# ============================================================

execute unless items entity @s armor.feet netherite_boots[custom_data~{zx:["dusk_dawn"]}] run return fail

function sweetdream:equipment/armor/dusk_dawn/kill_init
scoreboard players set @s zx.dd_t2 100
scoreboard players set @s zx.dd_temp 8
function sweetdream:equipment/armor/dusk_dawn/temp_apply
