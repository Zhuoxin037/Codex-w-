# ============================================================
# internal/mana/regen_apply —— 恢复量收尾与应用
# ------------------------------------------------------------
# 【宏参数】manacore:work.entry {uuid}
# 【步骤】
#   ① 抛 #manacore:event/mana_regen(此时 #regen 已算好)
#      —— 外部包可以直接 修改 #regen 来干预本次恢复(契约: 读写
#      scoreboard #regen, manacore.math)
#   ② 乘恢复倍率: #regen(x1000) x 倍率(x100) / 100
#      倍率降成 x100 是为了躲开 32 位溢出(两个 x1000 相乘会到 x1000000)。
#   ③ 禁止恢复: flags.no_regen=1b(永久) 或 regen_ban_end > #now(限时)
#      -> 本次恢复直接归零
#   ④ 夹取: current_mana + #regen, 上限 max_mana, 下限 0
#   ⑤ 写回 double
# 【注意】禁止恢复只影响"自动恢复"; 用 api/mana/add 或 regen/force 依旧
#         可以加魔力(那是主动行为, 不属于"恢复")。
# ============================================================
# 事件钩子: 允许外部直接读写 #regen (manacore.math) 修改本次恢复量
$data modify storage manacore:ctx uuid set value "$(uuid)"
data modify storage manacore:ctx reason set value "regen"
function #manacore:event/mana_regen

# 恢复倍率
$execute store result score #mult manacore.math run data get storage manacore:players "$(uuid)".stats.mana_regen_multiplier 100
scoreboard players operation #regen manacore.math *= #mult manacore.math
scoreboard players operation #regen manacore.math /= #100 manacore.meta

# 禁止恢复标记 / 恢复封锁到期时间
$execute if data storage manacore:players "$(uuid)".flags{no_regen:1b} run scoreboard players set #regen manacore.math 0
$execute store result score #bend manacore.math run data get storage manacore:players "$(uuid)".flags.regen_ban_end
execute if score #bend manacore.math > #now manacore.meta run scoreboard players set #regen manacore.math 0

# 应用并夹取到 [0, max_mana]
$execute store result score #cur manacore.math run data get storage manacore:players "$(uuid)".stats.current_mana 1000
$execute store result score #max manacore.math run data get storage manacore:players "$(uuid)".stats.max_mana 1000
scoreboard players operation #cur manacore.math += #regen manacore.math
execute if score #cur manacore.math > #max manacore.math run scoreboard players operation #cur manacore.math = #max manacore.math
execute if score #cur manacore.math matches ..0 run scoreboard players operation #cur manacore.math = #zero manacore.meta
$execute store result storage manacore:players "$(uuid)".stats.current_mana double 0.001 run scoreboard players get #cur manacore.math
