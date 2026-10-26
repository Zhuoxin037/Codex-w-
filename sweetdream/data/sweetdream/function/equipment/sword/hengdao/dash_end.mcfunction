# ============================================================
# sweetdream:equipment/sword/hengdao/dash_end —— 落点结算
# ------------------------------------------------------------
# 【谁调用它】dash_tick 在"走完 / 被挡住"的那一 tick
# 【执行者】施法者本人, 位置就是他停下来的地方
# 【为什么结算要放这儿, 而不是 cast 里】突进是分 12 刻走完的, cast 那一瞬间
#   人还在起点 —— 在 cast 里打伤害 = 打起点周围 2 格。所以必须等走完再算。
# 【步骤】① 拿 UUID ② 落点表现 ③ 算伤害 ④ 打范围内的全部生物
#         ⑤(超限)再打一次 + 击杀则重置冷却
#
# 【★ 超限·横刀 的差别(逐字照抄 oldef."hengdao".lore)★】
#   基础版: 对附近 **2 格**内全部生物造成**一次** 最大魔力 ×0.08。
#   超限版: 对附近 **5 格**内的全部生物造成**两次** 最大魔力 ×0.1，
#           且**若击杀生物则重置冷却时间**。
#   "碰到生物或障碍物则立即停下" 基础版的 dash_tick 已经这么做了, 不用改。
# ============================================================

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 落点表现
#   音效 id 是拿真实的 assets/minecraft/sounds.json 核对过的, 不会踩
#   "音效不存在 -> 报错截断函数"的坑; 粒子用的是本包已在用的三个。
execute at @s run particle minecraft:end_rod ~ ~1 ~ 1.0 0.4 1.0 0.05 30 normal
execute at @s run particle minecraft:enchanted_hit ~ ~1 ~ 0.6 0.6 0.6 0.1 25 normal
execute at @s run playsound minecraft:entity.player.attack.strong player @a ~ ~ ~ 0.9 0.85
execute at @s run playsound minecraft:entity.player.attack.crit player @a ~ ~ ~ 0.6 1.4

# ③ 伤害 = 自身最大魔力 ×0.08(超限版 ×0.1)
#   走框架的"最大魔力值技能倍率"通道(max_mana_mul): 基数由框架自己取面板最大魔力,
#   所以这里只要声明 max_mana_mul, 不必再先读 max_mana 塞进 base_attack。
#   ★ 超限快照读玩家身上的 zx.hd_ol(cast 里拍的) —— 这里不能再判手里那把。

data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.08,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score @s zx.hd_ol matches 1 run data modify storage manacore:in arg.max_mana_mul set value 0.1
# 「下一次技能加成」: 风行攒的风声奖励对"所有以自身最大魔力值结算的技能"生效,
#   横刀这一刀正好是最大魔力口径, 所以吃同一份。走 lib 统一处理
#   (普通乘区、乘完即删), 别在这里再写一套独立乘区的定点乘法。
function sweetdream:profession/mod_begin {book_obj:"zx.j_hd_book",sor_obj:"zx.j_hd_sor"}
function manacore:api/damage/calc
function sweetdream:profession/mod_end
# 此刻 manacore:out r.damage = 最大魔力 ×0.08 / ×0.1

# ④ 圈出落点范围内的生物(基础 2 格 / 超限 5 格), 再打
tag @e[tag=zx.hd_hit] remove zx.hd_hit
execute if score @s zx.hd_ol matches 0 run tag @e[type=!#sweetdream:no_damage,distance=..2] add zx.hd_hit
execute if score @s zx.hd_ol matches 1 run tag @e[type=!#sweetdream:no_damage,distance=..5] add zx.hd_hit

data modify storage zx:in arg set value {target:"@e[tag=zx.hd_hit]",damage:0.0}
data modify storage zx:in arg.damage set from storage manacore:out r.damage
# 【★ 打之前先点一次人数 ★】"这一波有没有打死东西"要靠**前后人数差**判断
#   (见 ⑥): 生物一死就从 @e 里消失了, 事后再去选它必然选不到, 所以必须先在
#   它还在的时候把基准数记下来。
scoreboard players set #hd_n0 zx.meta 0
execute as @e[tag=zx.hd_hit] run scoreboard players add #hd_n0 zx.meta 1
# 记一下这次范围选中了几只(0 = 选择器没选中任何生物), 给 debug/damage 排查用
execute store result score #dbg_sel zx.meta run execute if entity @e[tag=zx.hd_hit]
# 再包一层 at @s: 不管谁调用, 都保证"以落点为中心"结算
execute at @s run function sweetdream:api/damage

# ⑤ 超限: 再打一次(同一个伤害值, manacore:out 没被动过)
#    "两次"是同一 tick 连着两下 —— sweetdream:skill 在 bypasses_cooldown 标签里,
#    不会因为无敌帧吃掉第二下(见 api/damage 的注释)。
execute if score @s zx.hd_ol matches 1 if entity @e[tag=zx.hd_hit] run data modify storage zx:in arg set value {target:"@e[tag=zx.hd_hit]",damage:0.0}
execute if score @s zx.hd_ol matches 1 if entity @e[tag=zx.hd_hit] run data modify storage zx:in arg.damage set from storage manacore:out r.damage
execute if score @s zx.hd_ol matches 1 if entity @e[tag=zx.hd_hit] at @s run function sweetdream:api/damage

# ⑥ 超限: 这一下打死了吗? 死了就重置冷却
#    ★★ 2026-10-08 三修(玩家报"还是没刷新冷却")★★
#      【前两版为什么都不行】它们都依赖"**打完之后还能选中那只生物**":
#        v1 选择器谓词 `@e[tag=zx.hd_hit,nbt={Health:0.0f}]`;
#        v2 逐只 `data get entity @s Health`。
#      但生物一死就会被移出实体列表 —— 选不到的实体既进不了谓词、也进不了
#      `as @e[...]`, 于是"判死"那段**一次都没跑过**, 自然永远不刷新。
#    【现在的判法: 前后点人数】打之前记 N0(#hd_n0, 见 ④), 打完之后数
#      还活着的 N1(#hd_alive): **N1 < N0 就是有东西没了 = 打死了**。
#      这条路不要求"死掉的还能被选中", 反而正是靠"它不在了"来判定。
#    【兜底】还在场上、但血已经 <= 0 的那几刻(死亡动画期间实体可能还没被移除)
#      由 kill_check 逐只读 Health 补上 —— 两条路合起来覆盖全部情况。
scoreboard players set #hd_k zx.meta 0
execute store result score #hd_alive zx.meta run execute if entity @e[tag=zx.hd_hit]
execute if score @s zx.hd_ol matches 1 if score #hd_alive zx.meta < #hd_n0 zx.meta run scoreboard players set #hd_k zx.meta 1
execute if score @s zx.hd_ol matches 1 as @e[tag=zx.hd_hit] run function sweetdream:equipment/sword/hengdao/kill_check
execute if score @s zx.hd_ol matches 1 if score #hd_k zx.meta matches 1 run data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:hengdao"}
execute if score @s zx.hd_ol matches 1 if score #hd_k zx.meta matches 1 run data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score @s zx.hd_ol matches 1 if score #hd_k zx.meta matches 1 run function manacore:api/cooldown/reset
execute if score @s zx.hd_ol matches 1 if score #hd_k zx.meta matches 1 run tellraw @s [{"text":"超限·横刀 · 击杀, 冷却已重置","color":"light_purple"}]
execute if score @s zx.hd_ol matches 1 if score #hd_k zx.meta matches 1 run playsound minecraft:entity.player.levelup player @a ~ ~ ~ 0.7 1.6

# ⑦ 收尾: 清范围标记 + 清掉这次的超限快照(下次施法会重新拍)
tag @e[tag=zx.hd_hit] remove zx.hd_hit
scoreboard players set @s zx.hd_ol 0

scoreboard players set @s zx.j_hd_book 0
scoreboard players set @s zx.j_hd_sor 0
