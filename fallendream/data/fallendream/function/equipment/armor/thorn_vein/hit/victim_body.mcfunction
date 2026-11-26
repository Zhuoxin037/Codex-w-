$execute unless entity $(vx_uuid) run return 0
$execute as $(vx_uuid) if entity @s[tag=zx.status.shixin] run return 0

# ⑤ 给它附加「噬心」（附着 -> tag/mark）
$data modify storage zx:work ic set value {target:"$(vx_uuid)",mark:"shixin"}
function fallendream:tag/mark with storage zx:work ic

# ⑤.5 ★ 超限·刺纹: 自身 <30% 血时, 额外让"它 3 格内的其他 2 个生物"也带上噬心 ★
#   · "其他" = 排除被命中的那一只(distance 从 0.01 起; 已带噬心的不再算)
#   · 就近取 2 只(sort=nearest + limit=2); 场上不足 2 只就有几只算几只
#   · 先打临时标 zx.tv_new 再交给 ol_low 批量附着 —— 为什么不在这一行直接 tag/mark:
#     tag/mark 的 target 是个字符串, 这里 `at` 已经切到目标脚下, 直接写选择器最清楚
$execute if score @s zx.tv_low matches 1 at $(vx_uuid) run tag @e[type=!#fallendream:no_damage,distance=0.01..3,tag=!zx.status.shixin,sort=nearest,limit=2] add zx.tv_new
execute if score @s zx.tv_low matches 1 run function fallendream:equipment/armor/thorn_vein/ol_low

# ⑥ 抗性提升: 基础 3 秒Ⅰ / 超限 6 秒Ⅱ
#   ★ 两档各写一条, 不要 effect clear 再给 —— clear 会把别处给的抗性一起抹掉。
execute unless score @s zx.tv_ol matches 1 run effect give @s minecraft:resistance 3 0 true
execute if score @s zx.tv_ol matches 1 run effect give @s minecraft:resistance 6 1 true

# ⑦ 表现 + 记账 + 收尾
$execute at $(vx_uuid) run particle minecraft:item{item:{id:"minecraft:pointed_dripstone",count:1}} ~ ~1 ~ 0.3 0.4 0.3 0.02 8 normal
execute at @s run playsound minecraft:block.amethyst_cluster.break player @a ~ ~ ~ 0.5 1.5

# ⑦.5 记账: CD 按档重算(不读 hit 里的 #tv_gap —— 中间隔了 tag/mark, 假计分项不保证还在)
scoreboard players set #tv_gap zx.meta 200
execute if score @s zx.tv_ol matches 1 run scoreboard players set #tv_gap zx.meta 160
execute if score @s zx.tv_low matches 1 run scoreboard players set #tv_gap zx.meta 120
scoreboard players operation @s zx.thorn_cd = #now manacore.meta
scoreboard players operation @s zx.thorn_cd += #tv_gap zx.meta
$tag $(vx_uuid) remove zx.victim
