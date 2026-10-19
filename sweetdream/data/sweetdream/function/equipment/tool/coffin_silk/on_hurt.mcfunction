# ============================================================
# sweetdream:equipment/tool/coffin_silk/on_hurt —— 殓丝: 「殓结」兑现
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/tool/coffin_silk_hurt（entity_hurt_player）
#   （与「冰鉴」同一套受击范式）
# 【执行者】玩家（挨打的那个人）
# 【文案(lore 逐字)】✦ 殓结：下一次受到伤害后消耗「殓结」，为自身恢复最大生命值 30%
#   的生命，并获得 2 秒抗性提升Ⅱ。移走副手后「殓结」消失。
# 到期及移走副手由 keep 每刻维护，兑现前再检查一次。
# ============================================================

advancement revoke @s only sweetdream:equipment/tool/coffin_silk_hurt

# ①② 统一核验副手与严格到期边界（now >= end 即失效）。
function sweetdream:equipment/tool/coffin_silk/keep
execute unless entity @s[tag=zx.cfs_knot] run return 0

# ③ 消耗「殓结」：恢复最大生命值 30% + 2 秒抗性提升Ⅱ
tag @s remove zx.cfs_knot
scoreboard players reset @s zx.cfs_end
#   上限直接读**原版属性**（只读，合法；原版禁止的是**写**玩家 NBT）——
#   lib/heal 内部也用同一个来源算修饰符增量，同源才不会差出"面板/属性不同步"的那一截。
#   ★ R05 intovf-ok：底数 = 玩家上限(本包实测上限约 30)，×30 最多 900，
#     离 int32 的 2,147,483,647 差 6 个数量级；乘数 30 是文案里的死数字、不会动态放大。
execute store result score #heal_pt zx.meta run attribute @s minecraft:max_health get
scoreboard players set #cfs_pct zx.meta 30
scoreboard players operation #heal_pt zx.meta *= #cfs_pct zx.meta
scoreboard players operation #heal_pt zx.meta /= #100 zx.meta
function sweetdream:lib/heal
effect give @s minecraft:resistance 2 1 true

# ④ 表现
execute at @s run particle minecraft:totem_of_undying ~ ~1 ~ 0.35 0.5 0.35 0.05 14 normal
execute at @s run playsound minecraft:item.trident.return player @a ~ ~ ~ 0.6 1.4
