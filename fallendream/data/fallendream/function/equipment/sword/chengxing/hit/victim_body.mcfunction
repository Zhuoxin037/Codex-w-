$execute unless entity $(vx_uuid) run return 0

# ---- 超限判定（主手 / 副手，与 hit 入口同口径）----
scoreboard players set #cx_ol zx.meta 0
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["chengxing"],ol:"chengxing"}] run scoreboard players set #cx_ol zx.meta 1
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["chengxing"],ol:"chengxing"}] run scoreboard players set #cx_ol zx.meta 1

# ---- 读属性：韧性 + 护甲 ----
scoreboard players set #cx_t zx.meta 0
execute store result score #cx_t zx.meta run attribute @s minecraft:armor_toughness get
scoreboard players set #cx_a zx.meta 0
execute store result score #cx_a zx.meta run attribute @s minecraft:armor get
scoreboard players operation #cx_t zx.meta += #cx_a zx.meta

# ---- 倍率：原版 ×2 / 超限 ×2.2 ----
# ★ 超限不能直接乘 2.2（计分项只有整数）。做法是乘 22 之后再按 0.1 缩放：
#   (韧+甲)=32 时 32×22=704，704×0.1=70.4，小数完整保留。
#   若写成 ×22 再 /10 取整，70.4 会被截成 70，每一下都少 0.4。
# ★ 缩放是字面量、不能写成变量 ⇒ 原版/超限各一条 store。
scoreboard players set #cx_2 zx.meta 2
scoreboard players set #cx_22 zx.meta 22
execute if score #cx_ol zx.meta matches 0 run scoreboard players operation #cx_t zx.meta *= #cx_2 zx.meta
execute if score #cx_ol zx.meta matches 1 run scoreboard players operation #cx_t zx.meta *= #cx_22 zx.meta
execute if score #cx_ol zx.meta matches 1 if score @s zx.cx_rdy matches 1 run function fallendream:equipment/sword/chengxing/amp_hit
execute if score #cx_t zx.meta matches ..0 run return 0

# ---- 投递固定伤害 ----
$data modify storage zx:work a set value {fixed:1b,uncapped:1b,attack_kind:"extra",target:"$(vx_uuid)",type:"fallendream:parallel_skill"}
# ★ `data get storage ... double <倍数>` 的第三段是**乘数**，不是小数点后位数。
#   原版 ×2 用 1；超限先乘了 22，所以这里用 0.1 还原成 ×2.2。
execute if score #cx_ol zx.meta matches 0 store result storage zx:work a.num double 1 run scoreboard players get #cx_t zx.meta
execute if score #cx_ol zx.meta matches 1 store result storage zx:work a.num double 0.1 run scoreboard players get #cx_t zx.meta
function fallendream:lib/num/plain
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.u0 set from entity @s UUID[0]
data modify storage zx:work a.u1 set from entity @s UUID[1]
data modify storage zx:work a.u2 set from entity @s UUID[2]
data modify storage zx:work a.u3 set from entity @s UUID[3]
function fallendream:internal/attack/submit_extra

$execute at $(vx_uuid) run particle minecraft:crit ~ ~1 ~ 0.35 0.35 0.35 0 10 normal
$execute at $(vx_uuid) run particle minecraft:end_rod ~ ~0.8 ~ 0.3 0.5 0.3 0.02 8 normal
$execute at $(vx_uuid) run playsound minecraft:block.amethyst_block.chime player @a ~ ~ ~ 0.5 1.6
$tag $(vx_uuid) remove zx.victim
