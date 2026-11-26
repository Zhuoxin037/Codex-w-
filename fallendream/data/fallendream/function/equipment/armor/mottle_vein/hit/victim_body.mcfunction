$execute unless entity $(vx_uuid) run return 0

# ⑥ 消费这次机会（叠加第二次的那个开关一起摘掉）
tag @s remove zx.mv_ts
tag @s remove zx.mv_ts2

# ⑥.1 圈定要被时停的一批
#   基础: 只有被打中的那一只
#   超限: 那一只 + 它周围 2 格内的生物（"及周围 2 格生物"）
#   ★ 用一个专用临时标签把它们圈起来, 交给 lib/timestop 一次性处理
#     （lib/timestop 内部是 `as $(target)`, 多目标会逐个跑; 重复时停取最长那次）
$tag $(vx_uuid) add zx.mv_tsv
$execute if items entity @s armor.legs *[minecraft:custom_data~{zx:["mottle_vein"],ol:"mottle_vein"}] at $(vx_uuid) run tag @e[type=!#fallendream:no_damage,distance=..2] add zx.mv_tsv

# ⑥.2 时停 1 秒 = 20 刻
data modify storage zx:work fz.target set value "@e[tag=zx.mv_tsv]"
data modify storage zx:work fz.ticks set value 20
function fallendream:lib/timestop with storage zx:work fz

# ⑥.3 摘掉圈人的临时标
tag @e[tag=zx.mv_tsv] remove zx.mv_tsv

# ⑦ 表现: 纹路在它身上定住
$execute at $(vx_uuid) run particle minecraft:dust{color:[0.42,0.1,0.62],scale:1.4} ~ ~1 ~ 0.4 0.5 0.4 0.01 14 normal
$execute at $(vx_uuid) run playsound minecraft:block.amethyst_block.resonate player @a ~ ~ ~ 0.6 0.6

# ⑧ 收尾
$tag $(vx_uuid) remove zx.victim
