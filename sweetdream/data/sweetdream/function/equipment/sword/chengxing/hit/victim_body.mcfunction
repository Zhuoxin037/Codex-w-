$execute unless entity $(vx_uuid) run return 0

# ---- 读属性：韧性 + 护甲 ----
scoreboard players set #cx_t zx.meta 0
execute store result score #cx_t zx.meta run attribute @s minecraft:armor_toughness get
scoreboard players set #cx_a zx.meta 0
execute store result score #cx_a zx.meta run attribute @s minecraft:armor get
scoreboard players operation #cx_t zx.meta += #cx_a zx.meta
scoreboard players operation #cx_t zx.meta *= #2 zx.meta
execute if score #cx_t zx.meta matches ..0 run return 0

# ---- 投递固定伤害 ----
$data modify storage zx:work a set value {fixed:1b,target:"$(vx_uuid)",type:"minecraft:player_attack"}
# ★ 缩放必须是 1：#cx_t 已经是 (韧性 + 护甲) × 2 的整数，再除 10 会正好小十倍
#   （全下界合金 12+20=32 → ×2 = 64，写成 0.1 只剩 6.4，就是"额外伤害才 6 点多"）。
#   `data get storage ... double <倍数>` 的第三段是**乘数**，不是小数点后位数。
execute store result storage zx:work a.num double 1 run scoreboard players get #cx_t zx.meta
function sweetdream:lib/num/plain
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.u0 set from entity @s UUID[0]
data modify storage zx:work a.u1 set from entity @s UUID[1]
data modify storage zx:work a.u2 set from entity @s UUID[2]
data modify storage zx:work a.u3 set from entity @s UUID[3]
function sweetdream:internal/damage/with_from with storage zx:work a

$execute at $(vx_uuid) run particle minecraft:crit ~ ~1 ~ 0.35 0.35 0.35 0 10 normal
$execute at $(vx_uuid) run particle minecraft:end_rod ~ ~0.8 ~ 0.3 0.5 0.3 0.02 8 normal
$execute at $(vx_uuid) run playsound minecraft:block.amethyst_block.chime player @a ~ ~ ~ 0.5 1.6
$tag $(vx_uuid) remove zx.victim
