$execute unless entity $(vx_uuid) run return 0

# ⑥ 消费这次机会, 并时停它 1 秒
tag @s remove zx.mv_ts
$data modify storage zx:work fz.target set value "$(vx_uuid)"
data modify storage zx:work fz.ticks set value 20
function sweetdream:lib/timestop with storage zx:work fz

# ⑦ 表现: 纹路在它身上定住
$execute at $(vx_uuid) run particle minecraft:dust{color:[0.42,0.1,0.62],scale:1.4} ~ ~1 ~ 0.4 0.5 0.4 0.01 14 normal
$execute at $(vx_uuid) run playsound minecraft:block.amethyst_block.resonate player @a ~ ~ ~ 0.6 0.6

# ⑧ 收尾
$tag $(vx_uuid) remove zx.victim
