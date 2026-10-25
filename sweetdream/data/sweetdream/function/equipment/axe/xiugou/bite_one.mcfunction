# ============================================================
# sweetdream:equipment/axe/xiugou/bite_one —— 对单个目标结算一口（宏）
# ------------------------------------------------------------
# 【执行者】被咬的目标
# 【宏参数】sweetdream:work xg {dmg,u0,u1,u2,u3}
# 【投递】走 a.num → lib/num/plain → internal/damage/with_from，带攻击者归属
# 【sm:1b】"本次伤害来自召唤物" —— 超限·锈犬挂的 10 秒「被召唤物攻击 +30%」
#   只认带这个标记的伤害(判据在 internal/damage/one -> vuln_summon)。
# ============================================================
data modify storage zx:work a set value {target:"@s",type:"minecraft:player_attack",sm:1b}
$data modify storage zx:work a.num set value $(dmg)
function sweetdream:lib/num/plain
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
$data modify storage zx:work a.u0 set value $(u0)
$data modify storage zx:work a.u1 set value $(u1)
$data modify storage zx:work a.u2 set value $(u2)
$data modify storage zx:work a.u3 set value $(u3)
function sweetdream:internal/damage/with_from with storage zx:work a
particle minecraft:enchanted_hit ~ ~0.6 ~ 0.3 0.3 0.3 0.1 6 normal
