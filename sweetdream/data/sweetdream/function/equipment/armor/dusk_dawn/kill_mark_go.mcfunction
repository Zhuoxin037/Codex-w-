# ============================================================
# sweetdream:equipment/armor/dusk_dawn/kill_mark_go —— 记这笔"带标签击杀"的临时上限
# ------------------------------------------------------------
# 【执行者】玩家(攻击者)   【谁调它】进度回调 kill_mark / 伤害接口 kill_mark_from_skill
# 【做四件事】
#   ① 穿着黄昏黎明之交界(部分匹配, 不然静默失效) ② 和基础账"同一次击杀只清一次账"
#   ③ 标签账 = 100(超限版 = 100×X)   ④ 按差值把面板补上
# 【★ 超限版: +100 -> +100×X ★】X = 死者身上的通用效果数量, 由调用方算好放进
#   #dd_x(进度那条路靠 find_dead 反查, 技能那条路 @s 就是死者、直接数)。
#   ★ 调用方务必先给 #dd_x 赋值 —— 没赋就是上一次的残留值, 会算出离谱的数字。
# ============================================================

execute unless items entity @s armor.feet netherite_boots[custom_data~{zx:["dusk_dawn"]}] run return fail

function sweetdream:equipment/armor/dusk_dawn/is_ol
function sweetdream:equipment/armor/dusk_dawn/kill_init

execute unless score #dd_ol zx.meta matches 1 run scoreboard players set @s zx.dd_t2 100
execute if score #dd_ol zx.meta matches 1 run scoreboard players operation @s zx.dd_t2 = #dd_x zx.meta
execute if score #dd_ol zx.meta matches 1 run scoreboard players operation @s zx.dd_t2 *= #100 zx.meta

# 时长: 原版 8 秒, 超限版 12 秒
scoreboard players set @s zx.dd_temp 8
execute if score #dd_ol zx.meta matches 1 run scoreboard players set @s zx.dd_temp 12
function sweetdream:equipment/armor/dusk_dawn/temp_apply
