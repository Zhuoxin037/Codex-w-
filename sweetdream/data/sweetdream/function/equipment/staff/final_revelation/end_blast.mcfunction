# ============================================================
# sweetdream:equipment/staff/final_revelation/end_blast —— 主动释放的收尾一击
# ------------------------------------------------------------
# 【谁调用它】end ②(执行者 = 施法玩家, 目标已经由 scan 打在 zx.fr_in 上)
# 【伤害】自身最大魔力 ×0.2 -> max_mana_mul 通道。
# 【表现】结束的那一下给一圈亮闪 + 钟声(和风行的收尾同一味)。
# ============================================================

# ① 拿 uuid
function sweetdream:lib/uuid

# ② 伤害: 最大魔力 ×0.2
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.2}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:in arg set value {target:"@e[tag=zx.fr_in,distance=0..]",damage:0.0,read:"manacore"}
function sweetdream:api/damage

# ③ 表现(光柱中点 = 前方 8 格)
execute positioned ^ ^ ^8 run particle minecraft:flash ~ ~ ~ 2.0 1.2 2.0 0.0 6 normal
execute positioned ^ ^ ^8 run particle minecraft:end_rod ~ ~ ~ 2.0 1.2 2.0 0.12 90 normal
execute at @s run playsound minecraft:block.bell.use player @a ~ ~ ~ 0.9 0.8
