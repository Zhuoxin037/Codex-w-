# ============================================================
# sweetdream:equipment/axe/anchor/hit —— 沉锚 · 被动(攻击命中时 10% 触发)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/axe/anchor_hit(player_hurt_entity)
# 【执行者】动手的玩家
# 【被动原文(必须和这里对上)】
#   "每次攻击时都有10%的概率将自身前方一格内的生物击飞一格并对其造成相当于
#    自身最大魔力值*0.06的伤害。"
# 【四要素】① 触发 = 攻击命中; ② 范围 = 自身**前方 1 格内**的生物; ③ 次数 = 每次攻击掷一次 10%;
#   ④ 时长 = —(瞬发)。
# 【★ 满蓄力闸 ★】全包统一口径(2026-10-10): 没蓄满力那一发平A不触发武器被动。
# 【★ 同刻去重 ★】一次挥砍命中多只时会触发多个 player_hurt_entity -> 按 #now 去重
#   (zx.an_lt, 口径同 td_lt / cr_lt), 保证"每次攻击"只掷一次骰子。
# 【数值改哪】概率 = predicate chance_10; 范围 = 采样点的 distance;
#   击飞初速 = ⑦ 的 Motion 的 y 分量(0.36 ≈ 1 格);
#   倍率 0.06 = 下面的 max_mana_mul。
# ============================================================

advancement revoke @s only sweetdream:equipment/axe/anchor_hit

# 武器门控: 主手或副手是沉锚
execute unless items entity @s weapon.mainhand diamond_axe[custom_data~{zx:["anchor"]}] unless items entity @s weapon.offhand diamond_axe[custom_data~{zx:["anchor"]}] run return 0

# 满蓄力闸
function sweetdream:lib/atk_charge
execute unless score @s zx.atk_ok matches 1 run return 0

# 同刻去重(一记平A只掷一次)
execute if score @s zx.an_lt = #now manacore.meta run return 0
scoreboard players operation @s zx.an_lt = #now manacore.meta

# 10% 概率
execute unless predicate sweetdream:chance_10 run return 0

# ⑤ 前方 1 格内的生物(俯仰归零, 免得打到脚前地面)
tag @e[tag=zx.an_t] remove zx.an_t
execute rotated ~ 0 positioned ^ ^ ^1 run tag @e[type=!#sweetdream:no_damage,distance=..1] add zx.an_t
execute unless entity @e[tag=zx.an_t,distance=0..,limit=1] run return 0

# ⑥ 伤害 = 自身最大魔力 ×0.06
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.06}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:in arg set value {target:"@e[tag=zx.an_t,distance=0..]",damage:0.0}
data modify storage zx:in arg.damage set from storage manacore:out r.damage
function sweetdream:api/damage

# ⑦ 向上击飞(2026-10-12 用户拍板: "往上击飞"; 背离施法者的那叫"击退", 不要)
#   ★ 为什么这里能用 Motion(而 iridescent/eff_3 特意不用它) —— 那件要的是"朝某个方向"的冲量,
#     Motion 写不出"朝向"; 这里方向是固定的"正上方", 直接给一个向上初速度最自然,
#     而且用的就是原版"击退"那套物理(自己走抛物线、受重力落回)。
#   ★ 时序安全: player_hurt_entity 的奖励函数跑在原版 hurt()(内含那次击退) **之后** ⇒
#     这里覆盖 Motion 不会被原版那次顶掉。
#   ★ 0.36 的初速度 ≈ 弹起 1 格(与文案"击飞一格"对上; 玩家跳跃初速 0.42 约 1.25 格)。
execute as @e[tag=zx.an_t,distance=0..] run data modify entity @s Motion set value [0.0d,0.36d,0.0d]

# 表现 + 收尾
execute at @e[tag=zx.an_t,distance=..16,limit=1,sort=nearest] run particle minecraft:cloud ~ ~0.3 ~ 0.3 0.2 0.3 0.02 8 normal
execute at @s run playsound minecraft:entity.player.attack.strong player @a ~ ~ ~ 0.5 1.4
tag @e[tag=zx.an_t,distance=0..] remove zx.an_t
function sweetdream:equipment/axe/anchor/visual/passive
