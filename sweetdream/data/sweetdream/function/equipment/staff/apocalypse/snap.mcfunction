# ============================================================
# sweetdream:equipment/staff/apocalypse/snap —— 每刻魔力快照
# ------------------------------------------------------------
# 【谁调用它】core/tick 每刻(仅"启示录位于快捷栏"的玩家)
# 【干嘛用的】cooldown_start 观察者要算"这次技能实际消耗了多少蓝" ——
#   前置包不广播消耗值, 只能自己量: 本刻开头拍一份当前魔力(zx.ap_pre),
#   技能扣完蓝触发冷却事件时, 消耗 = 快照 - 现在的魔力。
#   #minecraft:tick 跑在实体刻之前 → 同一刻里的右键消耗一定晚于快照。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ★ 把 zx.ap_n 显式建成 0 ★
#   `if score @s zx.ap_n matches ..2` 在玩家**还没在这条计分项上有分数**时会
#   直接失败(不是当成 0) —— 那样永远记不进第一页; 而层面板那条"层数为 0
#   不显示"的守卫(matches 0)同样判不住, 观测镜上就冒出"启示 0/3 页"的幽灵段。
#   `add ... 0` = 有分数就加 0(不动), 没分数就建成 0。
#   (2026-10-05 真实事故: 七条层数计分项里只有 zx.ap_n 漏了这一句)
# ★ 每刻清一次"本刻已记过页" ★ 记页最多一页/刻, 见 spend。
scoreboard players add @s zx.ap_n 0
scoreboard players set @s zx.ap_done 0

data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get

scoreboard players set @s zx.ap_pre 0
execute store result score @s zx.ap_pre run data get storage manacore:out r.value 100
