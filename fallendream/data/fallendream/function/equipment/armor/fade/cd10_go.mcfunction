# ============================================================
# fallendream:equipment/armor/fade/cd10_go —— 超限·息影「技能冷却 −10%」的实际做事层
# ------------------------------------------------------------
# 【执行者】玩家  【前置】cd10 已备份 manacore:work a 与 in arg
# 【★ early return 只返回本函数；cd10 的还原照常执行 ★】
# ============================================================

function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

# 读该技能本次冷却总长（cooldown_start 时已落盘）
data modify storage zx:work fd.skill set from storage manacore:ctx skill
data modify storage manacore:in arg set value {uuid:"",skill:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.skill set from storage zx:work fd.skill
function manacore:api/cooldown/get
scoreboard players set #fd_rem zx.meta 0
execute store result score #fd_rem zx.meta run data get storage manacore:out r.remaining
execute if score #fd_rem zx.meta matches ..9 run return 0

# 10% = remaining ÷ 10（整数除法，最多差 1 刻）
scoreboard players set #fd_10 zx.meta 10
scoreboard players operation #fd_rem zx.meta /= #fd_10 zx.meta

data modify storage manacore:in arg set value {uuid:"",skill:"",ticks:0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.skill set from storage zx:work fd.skill
execute store result storage manacore:in arg.ticks int 1 run scoreboard players get #fd_rem zx.meta
function manacore:api/cooldown/reduce

# ★ 这里**不**打 zx.fd_next：常驻 -10% 每次放技能都触发，若也送 +10% 伤害就变成
#   常驻增伤，偏离文案"该装备提供的减冷却**后的技能**"。只有兑现减半(cd_half)武装。
