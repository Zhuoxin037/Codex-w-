# ============================================================
# sweetdream:equipment/sword/liuguang/ol_lock —— 锁定 4 只 + 缓慢 3 + 记账(宏 {uuid,damage})
# ------------------------------------------------------------
# 【★ "其中一个必定是最近的一只"怎么保证 ★】
#   分两步挑: 先 sort=nearest 挑 1 只打标签, 再 sort=random 挑 3 只**排除掉
#   已经带标签的**(tag=!zx.lgo_<uuid>)。@e[sort=random] 每次求值都会重挑,
#   所以挑完必须立刻落成标签 —— 不冻结的话后面每一步都可能作用在别人身上。
# 【记账写在哪】和原版流光一样写在**施法者名下**的 zx:data lgo."<uuid>",
#   目标身上只有原版标签(不污染生物 NBT, 也不会误删通用标签)。
#   伤害只记一份(基础值), "翻倍"是结算时按每只自己带不带流火/夜火现判的。
# 【缓慢给几秒】结算在 3 秒后, 给 4 秒留一点余量, 免得最后一刻状态掉了。
# ============================================================

# 清掉上一次可能残留的标记
$tag @e[tag=zx.lgo_$(uuid)] remove zx.lgo_$(uuid)

# ① 最近的一只(必定入选)
$execute at @s run tag @e[type=!#sweetdream:no_damage,distance=0.1..10,sort=nearest,limit=1] add zx.lgo_$(uuid)
# ② 再随机 3 只(排除已选中的)
$execute at @s run tag @e[type=!#sweetdream:no_damage,distance=0.1..10,tag=!zx.lgo_$(uuid),sort=random,limit=3] add zx.lgo_$(uuid)
$execute unless entity @e[tag=zx.lgo_$(uuid),limit=1] run return fail

# ③ 锁定期间: 缓慢 3(等级 3 = amplifier 2), 4 秒
$effect give @e[tag=zx.lgo_$(uuid)] minecraft:slowness 4 2 true

# ④ 记账: 到期时刻 = 现在 + 60 tick(3 秒)
scoreboard players operation #lg_due zx.meta = #now manacore.meta
scoreboard players add #lg_due zx.meta 60

$data modify storage zx:data lgo."$(uuid)" set value {damage:0.0,u0:0,u1:0,u2:0,u3:0,due:0}
$data modify storage zx:data lgo."$(uuid)".damage set value $(damage)
$data modify storage zx:data lgo."$(uuid)".u0 set from storage manacore:players "$(uuid)".u0
$data modify storage zx:data lgo."$(uuid)".u1 set from storage manacore:players "$(uuid)".u1
$data modify storage zx:data lgo."$(uuid)".u2 set from storage manacore:players "$(uuid)".u2
$data modify storage zx:data lgo."$(uuid)".u3 set from storage manacore:players "$(uuid)".u3
$execute store result storage zx:data lgo."$(uuid)".due int 1 run scoreboard players get #lg_due zx.meta

data modify storage zx:work a.locked set value 1b

# ⑤ 表现: 先照搬**原版流光的锁定光**(end_rod + witch, 不许擅自换掉),
#    再叠一层超限自己的白闪 —— 4 只各自放一份, 所以这里不能加 limit=1
#    (加了就只剩一只有光, 看着像没锁上)。
$execute at @e[tag=zx.lgo_$(uuid)] run particle minecraft:end_rod ~ ~1 ~ 0.35 0.6 0.35 0.02 30 normal
$execute at @e[tag=zx.lgo_$(uuid)] run particle minecraft:witch ~ ~1 ~ 0.4 0.8 0.4 0.01 20 normal
$execute at @e[tag=zx.lgo_$(uuid)] run particle minecraft:flash ~ ~1 ~ 0.15 0.5 0.15 0.01 8 normal
$execute at @e[tag=zx.lgo_$(uuid)] run particle minecraft:flame ~ ~1 ~ 0.25 0.6 0.25 0.01 10 normal
playsound minecraft:block.beacon.activate player @a ~ ~ ~ 0.8 1.5
