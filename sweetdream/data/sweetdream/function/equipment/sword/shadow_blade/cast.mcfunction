# ============================================================
# sweetdream:equipment/sword/shadow_blade/cast —— 影刃: 瞬移突袭
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/sword/shadow_blade 的奖励函数(右键消耗时, 玩家身份)
# 【文案】消耗 120 魔力 / 冷却 40 秒。
#   使用后立即瞬移至自身 10 格内离自身最近的一个生物, 并对其造成
#   "自身基础伤害 ×2"的伤害。若使用此武器在 5 秒内击杀敌人, 则刷新冷却并返还 60 魔力。
# 【命中窗口怎么记】不轮询 —— 施法时把"窗口结束时刻" = 框架时钟 #now + 100(5 秒)
#   写进自己的 zx.sb_end; 击杀进度那边只要 `if score @s zx.sb_end > #now` 就是"窗口内"。
#   好处: 窗口过期自己就失效(now 一直在走), 不需要每秒的定时器, 也没有 schedule 顶掉的问题。
# 【为什么要先确认有目标】没目标就整个不放(不扣蓝、不进冷却) —— 和流光一致。
# 【瞬移用 tp @s ~ ~ ~】执行位置已经被 at 挪到目标身上, 所以 ~ ~ ~ 就是目标的位置。
# ============================================================

# ⓪ 撤销自己的进度(不撤的话只有第一次右键会触发)
advancement revoke @s only sweetdream:equipment/sword/shadow_blade

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ①b 【超限】手里这把是不是超限版 —— 决定伤害倍率(×2 / ×8)
#     和击杀那一支(见 kill ①b)各判一次: 放技能时和击杀时手里可能已经不是同一把,
#     所以不复用同一个快照。
function sweetdream:equipment/sword/shadow_blade/is_ol
# ★★ 施法快照(2026-10-08 修) ★★
#   旧注释写的是"放技能时和击杀时各判一次, 不复用快照" —— 那是错的:
#   超限·影刃的击杀兑现**就是**发生在换武器之后(文案: 用别的武器击杀减它的冷却),
#   那时手里根本不是影刃, is_ol 必然判 0 ⇒ 整支兑现走不到(玩家报"被动未生效")。
#   所以这里把"施法这一刻"的结果存进玩家 zx.sb_ol, kill 那边读快照。
#   (和万念 zx.mq_ol / 横刀 zx.hd_ol / 引梦镰 zx.sd_ol 同一套口径。)
scoreboard players add @s zx.sb_ol 0
scoreboard players set @s zx.sb_ol 0
execute if score #sb_ol zx.meta matches 1 run scoreboard players set @s zx.sb_ol 1

# ② 只读检查: 冷却 + 魔力 120
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:shadow_blade",mana:120.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"影刃冷却中, 还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足(需要 120)","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 有目标吗? 没有就整个不放
#    distance=0.1..10 的下界把自己排除掉(自己到自己是 0 格)
execute unless entity @e[type=!#sweetdream:no_damage,distance=0.1..10] run tellraw @s [{"text":"附近没有目标","color":"red"}]
execute unless entity @e[type=!#sweetdream:no_damage,distance=0.1..10] run return fail

# ④ 扣魔力 120
data modify storage manacore:in arg set value {uuid:"",value:120.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足(需要 120)","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ⑤ 起冷却 40 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:shadow_blade",cooldown_seconds:40.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑥ 锁定"10 格内最近的一只"并冻结成标签
#    【为什么先打标签】@e[sort=nearest] 每次求值都会重新挑, 不冻结的话
#    "瞬移的落点"和"挨打的那只"可能不是同一只。
tag @e[tag=zx.sb_t] remove zx.sb_t
execute at @s run tag @e[type=!#sweetdream:no_damage,distance=0.1..10,sort=nearest,limit=1] add zx.sb_t

# ⑦ 瞬移到目标身上(执行位置 = 目标位置)
execute at @e[tag=zx.sb_t,limit=1] run tp @s ~ ~ ~

# ⑧ ★ 先开"5 秒内击杀"窗口, 再打伤害 ★
#    【为什么窗口必须在伤害之前】技能这一下若直接把目标打死, 击杀进度回调会在
#    伤害那一刻(同一条命令里)就被触发 —— 那个回调靠读 zx.sb_end 判断"算不算窗口内"。
#    以前窗口写在伤害之后, 回调读到的还是旧值/0 -> 刷新冷却 + 返蓝静默不生效
#    (玩家反馈"技能直接击杀时不刷新")。
scoreboard players operation @s zx.sb_end = #now manacore.meta
scoreboard players add @s zx.sb_end 100

# ⑨ 伤害 = 基础攻击力 ×2(基础版) / ×8(超限版)
#    走框架的"基础攻击力倍率"通道(attack_mul): 基数 = 面板 base_attack(含主手武器)。
execute if score #sb_ol zx.meta matches 1 run data modify storage manacore:in arg set value {uuid:"",attack_mul:8.0,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
execute unless score #sb_ol zx.meta matches 1 run data modify storage manacore:in arg set value {uuid:"",attack_mul:2.0,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:in arg set value {target:"@e[tag=zx.sb_t,limit=1]",read:"manacore"}
function sweetdream:api/damage

# ⑩ 兜底: 技能这一下直接把目标打死了 -> 主动走一次击杀奖励
#    (不指望"击杀进度回调"一定在技能伤害这条路上触发; 两条路都调 kill, 而 kill
#     第 ⑥ 步会 reset zx.sb_end, 所以先跑的那条把窗口一关, 后跑的那条读到 0 就自然
#     跳过 —— 不会返两次魔力。)
execute unless entity @e[tag=zx.sb_t,limit=1] run function sweetdream:equipment/sword/shadow_blade/kill

# ⑪ 表现
execute at @s run particle minecraft:soul_fire_flame ~ ~1 ~ 0.5 0.8 0.5 0.02 20 normal
execute at @s run particle minecraft:large_smoke ~ ~1 ~ 0.4 0.5 0.4 0.02 12 normal
execute at @s run playsound minecraft:entity.enderman.teleport player @a ~ ~ ~ 0.8 1.3
execute at @s run playsound minecraft:entity.player.attack.crit player @a ~ ~ ~ 0.8 1.5

tag @e[tag=zx.sb_t] remove zx.sb_t
