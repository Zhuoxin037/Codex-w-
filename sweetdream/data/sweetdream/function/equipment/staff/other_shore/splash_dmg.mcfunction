# ============================================================
# sweetdream:equipment/staff/other_shore/splash_dmg —— 双状态者 3 格内的 ×0.12 溅射
# ------------------------------------------------------------
# 【谁调用它】both_go ⑤   【执行者】施法者(玩家)   【位置】施法者处
# 【入参】zx.os_splash = 圈出来的"其他生物"(已排除双状态者自己)
# 【★ 为什么单独一个文件 ★】both_go 里已经有"消耗 + 真伤"两段, 再来一段
#   calc + api/damage 会让一个文件里同时出现 max_mana_mul 0.2 / 0.12 两组数,
#   改数值时容易改错行; 拆开后"0.12 只出现在这里"。
# ============================================================

# ① 算 ×0.12
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.12}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc

# ② 打(普通伤害: 吃护甲/保护, 与"真实伤害"那两段区分)
data modify storage zx:in arg set value {target:"@e[tag=zx.os_splash,distance=0..]",damage:0.0}
data modify storage zx:in arg.damage set from storage manacore:out r.damage
execute at @s run function sweetdream:api/damage
