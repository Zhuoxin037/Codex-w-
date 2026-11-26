# ============================================================
# fallendream:equipment/axe/angel_core/ol_reuse —— 超限第三段: 窗口内再放一次(80 魔力)
# ------------------------------------------------------------
# 【谁调用】cast ⓪.6（超限档 且 zx.ac_rw > #now）
# 【执行者】施法者   【位置】玩家所在
# 【文案】"之后 6 秒内可以消耗 80 魔力值来使用技能并对自身 8 格内附加了「圣痕」的
#   生物造成两次相当于自身基础攻击力 ×3 的伤害并清除受到伤害生物的「圣痕」。"
# 【★ 不碰 500 魔力 / 不进冷却 ★】这是主技能放完后的续招，只扣 80；
#   50 秒冷却照旧在走（cast ⓪.6 已经 return 掉了主流程，不会再扣一次冷却）。
# 【★ 窗口开在 dmg2 开头（第二段结算那一刻起算 6 秒）★】
# 【★ 这次使用不关窗、也不续窗 ★】文案只给"6 秒内可以…"，没说次数。
#   现按"窗口内每次 80 魔力都能用"实现，zx.ac_rw 不动。
#   ★ 这是我按"可以"二字的取舍；要改成"整个窗口只准一次"，在 ⑥ 里加
#     `scoreboard players reset @s zx.ac_rw` 即可。
# ============================================================

# ① 有目标吗 —— 自身 8 格内带「圣痕」的（没有就整段不生效，不扣蓝）
tag @e[tag=zx.ac_r] remove zx.ac_r
execute at @s run tag @e[type=!#fallendream:no_damage,distance=0.1..8,tag=zx.status.shenghen] add zx.ac_r
execute unless entity @e[tag=zx.ac_r,distance=0..,limit=1] run tellraw @s [{"text":"附近没有附带「圣痕」的生物","color":"red"}]
execute unless entity @e[tag=zx.ac_r,distance=0..,limit=1] run return 0

# ② 扣 80 魔力（扣不动就什么都不做）
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run tag @e[tag=zx.ac_r,distance=0..] remove zx.ac_r
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",value:80.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function fallendream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足(需要 80)","color":"red"}]
execute if data storage manacore:out r{success:0b} run tag @e[tag=zx.ac_r,distance=0..] remove zx.ac_r
execute if data storage manacore:out r{success:0b} run return 0

# ③ 伤害 = 自身基础攻击力 ×3（attack_mul 通道，基数 = 面板 base_attack）
data modify storage manacore:in arg set value {uuid:"",attack_mul:3.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc

# ④ 打两次（文案"两次"）
data modify storage zx:in arg set value {target:"@e[tag=zx.ac_r,distance=0..]",read:"manacore"}
# dup-ok: 文案"两次", 这里刻意打两遍
data modify storage zx:in arg.uncapped set value 1b
execute at @s run function fallendream:internal/attack/api_skill
data modify storage zx:in arg.uncapped set value 1b
execute at @s run function fallendream:internal/attack/api_skill

# ④.5 有额外「圣痕」的: 被该武器技能锁定时重复次数 +1（= 补第 3 次）
#   ★ 只补打多出来的那一次, 不打整轮 —— "重复 2 次"对所有人仍然成立
tag @e[tag=zx.ac_r3] remove zx.ac_r3
execute as @e[tag=zx.ac_r,distance=0..] if score @s zx.sh_x matches 1.. run tag @s add zx.ac_r3
execute if entity @e[tag=zx.ac_r3,distance=0..,limit=1] run data modify storage zx:in arg set value {target:"@e[tag=zx.ac_r3,distance=0..]",read:"manacore"}
data modify storage zx:in arg.uncapped set value 1b
execute if entity @e[tag=zx.ac_r3,distance=0..,limit=1] at @s run function fallendream:internal/attack/api_skill

# ⑤ 清除"受到伤害的生物"的「圣痕」= 8 格内被打到的全部
#   ★ 必须在 ④.5 之后: 那里还要读 zx.sh_x 认"额外层"
execute at @e[tag=zx.ac_r,distance=0..] run particle minecraft:enchant ~ ~1 ~ 0.30 0.30 0.30 0.05 10 normal
tag @e[tag=zx.ac_r,distance=0..] remove zx.status.shenghen
scoreboard players reset @e[tag=zx.ac_r,distance=0..] zx.sh_t
scoreboard players reset @e[tag=zx.ac_r,distance=0..] zx.sh_x

# ⑥ 表现 + 收尾
execute at @s run particle minecraft:end_rod ~ ~1 ~ 0.70 0.50 0.70 0.05 20 normal
execute at @s run playsound minecraft:block.beacon.activate player @a ~ ~ ~ 0.80 1.50
tag @e[tag=zx.ac_r3,distance=0..] remove zx.ac_r3
tag @e[tag=zx.ac_r,distance=0..] remove zx.ac_r
