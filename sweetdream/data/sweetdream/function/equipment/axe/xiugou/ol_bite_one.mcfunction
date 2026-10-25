# ============================================================
# sweetdream:equipment/axe/xiugou/ol_bite_one —— 超限·锈犬对单个目标的一口(宏)
# ------------------------------------------------------------
# 【执行者】被咬的目标
# 【宏参数】sweetdream:work xg {dmg,bd,burst,u0..u3}
#   dmg   = 每口伤害(cast 时已经乘过 2 = 基础攻击力 ×2)
#   bd    = 连击满 5 次补的那一下(基础攻击力 ×5)
#   burst = 1 表示这一口之后要补
# 【sm:1b 是什么】投递参数里的"本次伤害来自召唤物"标记。锈犬的 +30% 承伤
#   (zx.svul)只认带这个标记的伤害 —— 判据在 internal/damage/one 的钩子里,
#   所以**每一条召唤物的伤害都要自己打这个标记**才有那份加成。
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

execute if data storage zx:work xg{burst:1} run function sweetdream:equipment/axe/xiugou/ol_burst with storage zx:work xg
