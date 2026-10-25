# ============================================================
# sweetdream:equipment/axe/xiugou/ol_burst —— 连击满 5 次的那一发(宏)
# ------------------------------------------------------------
# 【执行者】被咬的目标    【宏参数】sweetdream:work xg {bd,u0..u3}
# 【做什么】① 再打一次「基础攻击力 ×5」 ② 挂 10 秒「被召唤物攻击受到伤害 +30%」
# 【+30% 怎么生效】zx.svul = 剩余秒数(记在**被咬生物**身上, lib/second 每秒 -1)。
#   真正的乘区在 internal/damage/one -> vuln_summon:只对**带 sm:1b 的召唤物伤害**
#   生效, 所以玩家自己补的平A/技能不会吃到这 30%(文案写的是"被召唤物攻击时")。
# ============================================================
data modify storage zx:work a set value {target:"@s",type:"minecraft:player_attack",sm:1b}
$data modify storage zx:work a.num set value $(bd)
function sweetdream:lib/num/plain
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
$data modify storage zx:work a.u0 set value $(u0)
$data modify storage zx:work a.u1 set value $(u1)
$data modify storage zx:work a.u2 set value $(u2)
$data modify storage zx:work a.u3 set value $(u3)
function sweetdream:internal/damage/with_from with storage zx:work a

scoreboard players set @s zx.svul 10
execute at @s run particle minecraft:crit ~ ~1 ~ 0.5 0.5 0.5 0.1 24 normal
execute at @s run particle minecraft:damage_indicator ~ ~1 ~ 0.4 0.6 0.4 0.1 8 normal
execute at @s run playsound minecraft:entity.wolf.bite player @a ~ ~ ~ 1.0 0.7
