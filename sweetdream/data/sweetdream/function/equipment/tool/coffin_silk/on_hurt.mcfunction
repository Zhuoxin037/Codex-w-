# ============================================================
# sweetdream:equipment/tool/coffin_silk/on_hurt —— 殓丝: 「殓结」兑现
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/tool/coffin_silk_hurt（entity_hurt_player）
#   （与「冰鉴」同一套受击范式）
# 【执行者】玩家（挨打的那个人）
# 【文案(lore 逐字)】✦ 殓结：下一次受到伤害后消耗「殓结」，为自身恢复最大生命值 30%
#   的生命，并获得 2 秒抗性提升Ⅱ。移走副手后「殓结」消失。
# 【★ "移走副手后消失"用的是**惰性收** ★】不另开每秒扫描：本文件每次挨打先看一眼
#   副手还是不是殓丝，不是就把标签摘掉（殓结没有任何常驻效果/图标，惰性收与即时收
#   对玩家完全等价）。同理 8 秒到期也是在这里按"到期刻"判的 —— 存的是**到期刻**
#   而不是倒计时，就不需要有人每刻/每秒去扣它（口径同 frostmirror / em_gate）。
# ============================================================

advancement revoke @s only sweetdream:equipment/tool/coffin_silk_hurt

# ① 副手不是殓丝 -> 「殓结」直接消失
execute unless items entity @s weapon.offhand *[minecraft:custom_data~{zx:["coffin_silk"]}] run tag @s remove zx.cfs_knot
execute unless entity @s[tag=zx.cfs_knot] run return 0

# ② 已经过了 8 秒 -> 也消失
scoreboard players set #cfs_due zx.meta 0
execute store result score #cfs_due zx.meta run scoreboard players get @s zx.cfs_end
execute if score #cfs_due zx.meta < #now manacore.meta run tag @s remove zx.cfs_knot
execute unless entity @s[tag=zx.cfs_knot] run return 0

# ③ 消耗「殓结」：恢复最大生命值 30% + 2 秒抗性提升Ⅱ
tag @s remove zx.cfs_knot
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
