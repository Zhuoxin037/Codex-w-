# ============================================================
# sweetdream:equipment/liuguang/lock_macro —— 锁定 + 写数据 + 表现
# ------------------------------------------------------------
# 【宏参数】zx:work a {uuid, damage}
# 【执行者】施法者本人
# 【为什么标记要带自己的 UUID】标记是全局的(打在上面的生物身上)。
#   如果所有玩家共用同一个标签, 就会出现:
#     - 你放技能时把别人锁的目标一起清掉
#     - 3 秒后你那一下打到"别人锁的目标"身上去
#   所以每人用自己的 zx.lg_<uuid>, 多个玩家同时放也互不干扰。
# 【写进目标身上的东西】
#   data.zx.damage : 这一击要打多少(已经算好保底)
#   data.zx.u0..u3 : 施法者 UUID 的 4 个整数, 3 秒后用来记击杀归属
#   data.zx.lg_at  : 到点时刻(框架时钟 #now + 60), 谁到点谁结算
# 【为什么写完要置 locked】cast 靠它判断"到底锁上没有", 免得白扣蓝。
# 【注意】"再检查一次"那行不能省: 选不到实体时下一行 data modify 会报错,
#   而报错会把整个函数从这里截断。
# ============================================================

# 先清掉自己上一次没结算完的标记(先清, 再选新的)
$tag @e[tag=zx.lg_$(uuid)] remove zx.lg_$(uuid)

# 再确认一次有目标
#   【这一行没有 $(变量), 所以绝对不能加 $ 前缀】加了会报
#   "Macro without variables", 整个函数直接作废。
execute unless entity @e[type=!#sweetdream:no_damage,distance=0.1..8] run return fail

# 冻结这一次的选择: 8 格内随机一个生物
$tag @e[type=!#sweetdream:no_damage,distance=0.1..8,sort=random,limit=1] add zx.lg_$(uuid)

# 伤害 / 归属
$data modify entity @e[tag=zx.lg_$(uuid),limit=1] data.zx.damage set value $(damage)
$data modify entity @e[tag=zx.lg_$(uuid),limit=1] data.zx.u0 set from storage manacore:players "$(uuid)".u0
$data modify entity @e[tag=zx.lg_$(uuid),limit=1] data.zx.u1 set from storage manacore:players "$(uuid)".u1
$data modify entity @e[tag=zx.lg_$(uuid),limit=1] data.zx.u2 set from storage manacore:players "$(uuid)".u2
$data modify entity @e[tag=zx.lg_$(uuid),limit=1] data.zx.u3 set from storage manacore:players "$(uuid)".u3

# 到点时刻 = 现在 + 60 tick
scoreboard players operation #lg_due zx.meta = #now manacore.meta
scoreboard players add #lg_due zx.meta 60
$execute store result entity @e[tag=zx.lg_$(uuid),limit=1] data.zx.lg_at int 1 run scoreboard players get #lg_due zx.meta

# 告诉 cast"锁上了"
data modify storage zx:work a.locked set value 1b

# 锁定表现: 目标身上一圈粒子 + 音效
$execute at @e[tag=zx.lg_$(uuid),limit=1] run particle minecraft:end_rod ~ ~1 ~ 0.35 0.6 0.35 0.02 30 normal
$execute at @e[tag=zx.lg_$(uuid),limit=1] run particle minecraft:witch ~ ~1 ~ 0.4 0.8 0.4 0.01 20 normal
$execute at @e[tag=zx.lg_$(uuid),limit=1] run playsound minecraft:block.beacon.activate player @a ~ ~ ~ 0.7 1.4
