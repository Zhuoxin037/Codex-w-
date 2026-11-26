tag @e[tag=zx.fs_seen,distance=0..] remove zx.fs_seen
tag @e[tag=zx.fs_v,distance=0..] add zx.fs_seen
tag @s add zx.fs_seen
scoreboard players set #fs_budget zx.meta 6
scoreboard players set #fs_cap zx.meta 6
function fallendream:equipment/bow/feather_sleep/chain with storage zx:work fs
