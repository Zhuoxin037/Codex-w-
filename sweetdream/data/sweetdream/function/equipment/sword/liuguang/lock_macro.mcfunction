# ============================================================
# sweetdream:equipment/sword/liuguang/lock_macro —— 锁定目标 + 记账(宏 {uuid,damage})
# ------------------------------------------------------------
# 【★ 优化建议第 2 条: 改了什么 ★】
#   以前把"这一笔的伤害/归属/到点时刻"写在**被打的那只生物身上**(data.zx.damage...),
#   而结算时又 `data remove entity @s data.zx` 把整段 data.zx 删掉 —— 那一下会**连通用标签
#   (渊海/流火/噬心…)和图标数据一起删掉**; 而且普通生物本来不该被我们塞自定义字段。
#   现在改成: 记账写在**施法者名下**的独立记录 zx:data lg."<uuid>";
#   目标只用标签 zx.lg_<uuid> 认(原版机制, 不污染生物 NBT)。
# 【记录内容】target_tag / damage / u0..u3(归属) / due(到点时刻)
# ============================================================

$tag @e[tag=zx.lg_$(uuid)] remove zx.lg_$(uuid)
execute unless entity @e[type=!#sweetdream:no_damage,distance=0.1..8] run return fail
$tag @e[type=!#sweetdream:no_damage,distance=0.1..8,sort=random,limit=1] add zx.lg_$(uuid)

scoreboard players operation #lg_due zx.meta = #now manacore.meta
scoreboard players add #lg_due zx.meta 60

$data modify storage zx:data lg."$(uuid)" set value {target_tag:"",damage:0.0,u0:0,u1:0,u2:0,u3:0,due:0}
$data modify storage zx:data lg."$(uuid)".target_tag set value "zx.lg_$(uuid)"
$data modify storage zx:data lg."$(uuid)".damage set value $(damage)
$data modify storage zx:data lg."$(uuid)".u0 set from storage manacore:players "$(uuid)".u0
$data modify storage zx:data lg."$(uuid)".u1 set from storage manacore:players "$(uuid)".u1
$data modify storage zx:data lg."$(uuid)".u2 set from storage manacore:players "$(uuid)".u2
$data modify storage zx:data lg."$(uuid)".u3 set from storage manacore:players "$(uuid)".u3
$execute store result storage zx:data lg."$(uuid)".due int 1 run scoreboard players get #lg_due zx.meta

data modify storage zx:work a.locked set value 1b
$execute at @e[tag=zx.lg_$(uuid),limit=1] run particle minecraft:end_rod ~ ~1 ~ 0.35 0.6 0.35 0.02 30 normal
$execute at @e[tag=zx.lg_$(uuid),limit=1] run particle minecraft:witch ~ ~1 ~ 0.4 0.8 0.4 0.01 20 normal
$execute at @e[tag=zx.lg_$(uuid),limit=1] run playsound minecraft:block.beacon.activate player @a ~ ~ ~ 0.7 1.4