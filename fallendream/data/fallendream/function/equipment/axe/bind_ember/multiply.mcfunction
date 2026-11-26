# ============================================================
# fallendream:equipment/axe/bind_ember/multiply —— 缚烬被动「流火 + 缓慢」加伤
# ------------------------------------------------------------
# 【执行者】被命中的生物（由 internal/damage/one ①.5 段按"目标带流火 + 带缓慢"
#   两个条件送进来）   【宏参数】zx:work a（含施法者 u0..u3）
# 【原版文案】"自身对同时附有「流火」且处于缓慢状态的生物造成的伤害提高 50%。"
# 【超限文案】同上，**80%**。
# 【★ 为什么 1.8 写成 ×8/10 而不是 ×18/10 ★】
#   #be_d 是千分定点。×8 再 /10 的中间值只有 8 倍，离 int32 上界更远；
#   ×18 会把中间值翻到 18 倍，没有更好精度却更容易撞界。
# 【★ 原版分支一个字都不改 ★】#be_on 的判定、s2_b_damage 的传递原样保留。
# ============================================================
scoreboard players set #be_on zx.meta 0
$execute as @a[scores={manacore.u0=$(u0),manacore.u1=$(u1),manacore.u2=$(u2),manacore.u3=$(u3)},limit=1] if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["bind_ember"]}] run scoreboard players set #be_on zx.meta 1
$execute as @a[scores={manacore.u0=$(u0),manacore.u1=$(u1),manacore.u2=$(u2),manacore.u3=$(u3)},limit=1] if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["bind_ember"]}] run scoreboard players set #be_on zx.meta 1
execute unless score #be_on zx.meta matches 1 run return 0

# 超限判定（施法者那只手持的是不是超限缚烬）
scoreboard players set #be_ol zx.meta 0
$execute as @a[scores={manacore.u0=$(u0),manacore.u1=$(u1),manacore.u2=$(u2),manacore.u3=$(u3)},limit=1] if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["bind_ember"],ol:"bind_ember"}] run scoreboard players set #be_ol zx.meta 1
$execute as @a[scores={manacore.u0=$(u0),manacore.u1=$(u1),manacore.u2=$(u2),manacore.u3=$(u3)},limit=1] if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["bind_ember"],ol:"bind_ember"}] run scoreboard players set #be_ol zx.meta 1

execute store result score #be_d zx.meta run data get storage zx:work a.num 1000
scoreboard players operation #be_up zx.meta = #be_d zx.meta
# 原版 +50% = 加一半
execute if score #be_ol zx.meta matches 0 run scoreboard players operation #be_up zx.meta /= #2 zx.meta
# 超限 +80% = 加 8/10
scoreboard players set #be_8 zx.meta 8
scoreboard players set #be_10 zx.meta 10
execute if score #be_ol zx.meta matches 1 run scoreboard players operation #be_up zx.meta *= #be_8 zx.meta
execute if score #be_ol zx.meta matches 1 run scoreboard players operation #be_up zx.meta /= #be_10 zx.meta
scoreboard players operation #be_d zx.meta += #be_up zx.meta
execute store result storage zx:work a.num double 0.001 run scoreboard players get #be_d zx.meta
data modify storage zx:work a.damage set from storage zx:work a.num
data modify storage zx:work a.s2_b_damage set value {n:0,d:1}
data modify storage zx:work a.s2_b_damage set from storage zx:work a.s2_b_num
function fallendream:lib/num/plain
