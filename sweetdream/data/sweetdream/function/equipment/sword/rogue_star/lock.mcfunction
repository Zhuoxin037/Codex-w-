# ============================================================
# sweetdream:equipment/sword/rogue_star/lock —— 锁定 3 个目标 + 记账(宏 {uuid,damage})
# ------------------------------------------------------------
# 【宏参数】sweetdream:work a {uuid,damage}   【执行者】施法者
# 【记在哪】施法者名下的独立记录 zx:data rs."<uuid>" —— 不往被打的生物身上塞自定义字段
#   (老写法会把生物 NBT 弄脏, 而且清理时会连通用标签一起删; 见流光 lock_macro 的教训)。
#   目标只用**原版标签** zx.rs_<uuid> 认。
# 【记录内容】damage / u0..u3(归属) / due(到点时刻 = #now + 60)
# 【为什么随机挑完要立刻打标签】@e[sort=random] 每次求值都会重挑 —— 不冻结成标签的话,
#   后面每一步都可能作用在别人身上。
# ============================================================

# 清掉上一轮残留(理论上由 hit_due 清过; 这里是"中途被打断"的兜底)
$tag @e[tag=zx.rs_$(uuid)] remove zx.rs_$(uuid)

# 锁定: 10 格内就近取目标(③ 已保证至少 1 个)
#   【基础版】只锁 3 个 —— 文案: "锁定自身 10 格范围内的 **3 个**生物"
#   【超限版】锁定**全部** —— 文案: "锁定自身 10 格范围内的**全部**生物"
#   ★ 两条只差一个 limit, 靠宏入参 ol 分流; 不写 limit 就是"范围内全部"。
$execute if data storage zx:work a{ol:0b} run tag @e[type=!#sweetdream:no_damage,distance=0.1..10,sort=nearest,limit=3] add zx.rs_$(uuid)
$execute if data storage zx:work a{ol:1b} run tag @e[type=!#sweetdream:no_damage,distance=0.1..10,sort=nearest] add zx.rs_$(uuid)

# 到点时刻: 现在 + 60 tick(3 秒)。存进记录, 由 lib/second 每秒扫。
scoreboard players operation #rs_due zx.meta = #now manacore.meta
scoreboard players add #rs_due zx.meta 60

# 记账(施法者名下)。ol 要带到 3 秒后的 hit_due —— 它决定"打一次还是两次"。
$data modify storage zx:data rs."$(uuid)" set value {damage:0.0,u0:0,u1:0,u2:0,u3:0,due:0,ol:0b}
$execute if data storage zx:work a{ol:1b} run data modify storage zx:data rs."$(uuid)".ol set value 1b
$data modify storage zx:data rs."$(uuid)".damage set value $(damage)
$data modify storage zx:data rs."$(uuid)".u0 set from storage manacore:players "$(uuid)".u0
$data modify storage zx:data rs."$(uuid)".u1 set from storage manacore:players "$(uuid)".u1
$data modify storage zx:data rs."$(uuid)".u2 set from storage manacore:players "$(uuid)".u2
$data modify storage zx:data rs."$(uuid)".u3 set from storage manacore:players "$(uuid)".u3
$execute store result storage zx:data rs."$(uuid)".due int 1 run scoreboard players get #rs_due zx.meta

# 告诉 cast "锁上了"
data modify storage zx:work a.locked set value 1b

# 表现: 每个被锁目标头顶一柱星光 + 一声钟响
$execute at @e[tag=zx.rs_$(uuid)] run particle minecraft:end_rod ~ ~1 ~ 0.35 0.6 0.35 0.02 30 normal
$execute at @e[tag=zx.rs_$(uuid)] run particle minecraft:witch ~ ~1 ~ 0.4 0.8 0.4 0.01 20 normal
$execute at @e[tag=zx.rs_$(uuid)] run playsound minecraft:block.beacon.activate player @a ~ ~ ~ 0.7 1.4
