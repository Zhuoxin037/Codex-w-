# ============================================================
# sweetdream:equipment/staff/bent_ray/skill —— 折径 · 主动技能(潜行右键)
# ------------------------------------------------------------
# 【谁调用它】cast ①(潜行)   【执行者】施法者
# 【技能原文】
#   ✦ 主动技能   魔力 250 · 冷却 30 秒
#   "使用后对自身 8 格内最近的生物发射光束，并对其造成一次相当于自身最大魔力值
#    ×0.04+8 的伤害。若其 5 格内有附有「折光」的生物，则光束继续射向其最近的附有
#    「折光」的生物并消除其「折光」，每次射出都会使本次伤害提高 20%（独立乘区，
#    不包含固定伤害）。以上最多重复 6 次。"
# 【★ 四要素 ★】
#   ① 触发: 潜行右键。
#   ② 范围: 首段 = 自身 8 格内最近的一只; 之后每段 = 当前目标 5 格内最近的折光者。
#   ③ 次数: 首段 + 至多 6 次连锁 = 共 7 段(用户 2026-10-17 拍板)。
#   ④ 时长: 无(全链在同一 tick 内跑完, 靠函数递归, 见 chain)。
# 【★ 通道 ★】本体 最大魔力值 ×0.04(mm) + 固定 8(custom_damage); 独立乘区 1.2^n。
# 【★ 为什么把主循环拆进 chain ★】7 段结构完全一样, 展开写会撞 check.py 的
#   「同文件相邻完全重复」; 递归 + 一个计数(#br_n)既短又不会漏段。
# 【超限·折径(2026-10-23 批 K9)】魔力 250→**350**(冷却 30 秒不变)、系数 ×0.04→**×0.05**、
#   固定值 8→**18**、连锁半径 5→**8 格**、重复上限 6→**8 次**(首段 + 8 = 9 段);
#   新增两条: ① "每有一层「折光」都会**额外**对除主光束锁定的生物以外离其最近的生物
#   射出光束(伤害独立计算)" ② "结束后对锁定的生物和在光束路径上的生物造成一次
#   相当于自身最大魔力值 ×0.08 的伤害, 且本次伤害受到**本技能的最终增伤**"。
# 【★ 分档怎么带进递归链 ★】chain 会被递归 9 次, 每次都要读"这一发是不是超限档" ⇒
#   放在**玩家身上**的 zx.br_ol(不是 meta 假名): 递归全程执行者都是施法者本人,
#   读 @s 最稳, 也不会被同刻别人的施法串掉。
# ============================================================

# ⓪.5 超限判定: 主/副手任一件是超限·折径
scoreboard players set #br_ol zx.meta 0
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["bent_ray"],ol:"bent_ray"}] run scoreboard players set #br_ol zx.meta 1
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["bent_ray"],ol:"bent_ray"}] run scoreboard players set #br_ol zx.meta 1
scoreboard players operation @s zx.br_ol = #br_ol zx.meta

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 只读检查: 冷却好没好 + 魔力(原版 250 / 超限 350)
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:bent_ray",mana:250.0}
execute if score #br_ol zx.meta matches 1 run data modify storage manacore:in arg.mana set value 350.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check

execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"折径冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if score #br_ol zx.meta matches 0 if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 250）","color":"red"}]
execute if score #br_ol zx.meta matches 1 if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 350）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 8 格内有没有目标? 一只都没有就整个不放
execute unless entity @e[type=!#sweetdream:no_damage,distance=0.1..8] run tellraw @s [{"text":"附近没有目标","color":"red"}]
execute unless entity @e[type=!#sweetdream:no_damage,distance=0.1..8] run return fail

# ④ 扣魔力(-250 / -350)
data modify storage manacore:in arg set value {uuid:"",value:250.0}
execute if score #br_ol zx.meta matches 1 run data modify storage manacore:in arg.value set value 350.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if score #br_ol zx.meta matches 0 if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足（需要 250）","color":"red"}]
execute if score #br_ol zx.meta matches 1 if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足（需要 350）","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ⑤ 记冷却 30 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:bent_ray",cooldown_seconds:30.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑥ 首段目标 = 自身 8 格内最近的一只; 链上"用过的"全部清空
tag @e[tag=zx.br_cur,distance=0..] remove zx.br_cur
tag @e[tag=zx.br_used,distance=0..] remove zx.br_used
tag @e[tag=zx.br_next,distance=0..] remove zx.br_next
execute as @e[type=!#sweetdream:no_damage,distance=0.1..8,sort=nearest,limit=1] run tag @s add zx.br_cur
tag @e[tag=zx.br_cur,distance=0..] add zx.br_used

# ⑦ 段数清零, 进链(chain 自己会打首段, 并在打完 7 段后停)
scoreboard players set #br_n zx.meta 0
function sweetdream:equipment/staff/bent_ray/chain

# ⑦.5 ★ 结束段(超限): 对"锁定的生物 + 光束路径上的生物"再来一次 ×0.08 ★
#   "结束后对锁定的生物和在光束路径上的生物造成一次相当于自身最大魔力值 x0.08 的
#    伤害, 且本次伤害受到**本技能的最终增伤**"。
#   ★ 必须排在 ⑧ 清标签**之前** —— "光束路径上的生物"就是链上打过的 zx.br_used 全体。
#   ★ 倍率用链**跑完时**的 #br_n(最终段号)取 1.2^n —— 这就是"最终增伤"。
execute if score @s zx.br_ol matches 1 run function sweetdream:equipment/staff/bent_ray/ol_end

# ⑧ 收尾: 清链上的临时标签
tag @e[tag=zx.br_cur,distance=0..] remove zx.br_cur
tag @e[tag=zx.br_used,distance=0..] remove zx.br_used
tag @e[tag=zx.br_next,distance=0..] remove zx.br_next

# ⑨ 表现
playsound minecraft:block.amethyst_block.resonate player @a ~ ~ ~ 1.0 1.4
playsound minecraft:item.trident.throw player @a ~ ~ ~ 0.8 1.6
