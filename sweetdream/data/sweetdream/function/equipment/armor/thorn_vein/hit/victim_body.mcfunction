$execute unless entity $(vx_uuid) run return 0
$execute as $(vx_uuid) if entity @s[tag=zx.status.shixin] run return 0

# ⑤ 给它附加「噬心」（附着 -> tag/mark）
$data modify storage zx:work ic set value {target:"$(vx_uuid)",mark:"shixin"}
function sweetdream:tag/mark with storage zx:work ic

# ⑥ 自身获得 3 秒抗性提升Ⅰ
effect give @s minecraft:resistance 3 0 true

# ⑦ 表现 + 记账 + 收尾
$execute at $(vx_uuid) run particle minecraft:item{item:{id:"minecraft:pointed_dripstone",count:1}} ~ ~1 ~ 0.3 0.4 0.3 0.02 8 normal
execute at @s run playsound minecraft:block.amethyst_cluster.break player @a ~ ~ ~ 0.5 1.5
scoreboard players operation @s zx.thorn_cd = #now manacore.meta
scoreboard players operation @s zx.thorn_cd += #200 zx.meta
$tag $(vx_uuid) remove zx.victim
