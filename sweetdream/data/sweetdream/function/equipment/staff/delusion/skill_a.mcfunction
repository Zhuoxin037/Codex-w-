# ============================================================
# sweetdream:equipment/staff/delusion/skill_a —— 惑梦分支 A(锁定者已在时停里)
# ------------------------------------------------------------
# 【谁调用它】skill 第 ⑦ 步(执行者 = 施法玩家)
# 【内容】对锁定者 5 格内的全部生物造成一次相当于自身最大魔力值 ×0.1 的伤害,
#   并时停 3 秒。
# 【伤害口径】最大魔力值 → max_mana_mul 通道; 执行者是玩家 → api/damage 自动带归属。
# ============================================================

# ① 圈目标: 以锁定者为中心 5 格(标签先清再圈, 免得混进上一发的残留)
tag @e[tag=zx.dl_area] remove zx.dl_area
execute at @e[tag=zx.dl_lock,limit=1] run tag @e[type=!#sweetdream:no_damage,distance=..5] add zx.dl_area

# ② 算伤害: 最大魔力 ×0.1
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.1}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc

# ③ 打出去
data modify storage zx:in arg set value {target:"@e[tag=zx.dl_area]",damage:0.0,read:"manacore"}
function sweetdream:api/damage

# ④ 时停 3 秒(60 tick)
data modify storage zx:work fz set value {target:"@e[tag=zx.dl_area]",ticks:60}
function sweetdream:lib/timestop with storage zx:work fz
