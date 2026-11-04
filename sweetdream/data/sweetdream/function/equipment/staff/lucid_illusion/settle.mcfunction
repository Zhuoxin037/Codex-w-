# ============================================================
# sweetdream:equipment/staff/lucid_illusion/settle —— 清醒与幻觉：4 秒后按失血结算
# ------------------------------------------------------------
# 【执行者】玩家
# 【文案】按自身已损失的生命值结算一次：每损失 20% 生命值生成一个法球；
#   每有一个法球超过上限，则改为生成一个持续 20 秒的额外法球。
# 【★ 先补上限内的、再补额外 ★】文案的"超过上限"是按**总生成数**算的：
#   先生成 n 个球，能塞进上限的塞进去（最多补到 jcap），剩下的每一个变额外球。
#   这样"上限 3、现有 2、失血 60%（n=3）" = 先补 1 个到上限，剩下 2 个变额外球。
# 【★ 没有循环 ★】n 最多 5（100% 失血 ÷ 20%），用三次"够不够"判断代替循环。
# ============================================================

scoreboard players set @s zx.li_on 0

# ① n = 已损失百分比 ÷ 20%（#hp_p100 是千分比：满血 10000）
function sweetdream:lib/hp_pct
scoreboard players set #li_lost zx.meta 10000
scoreboard players operation #li_lost zx.meta -= #hp_p100 zx.meta
execute if score #li_lost zx.meta matches ..0 run return 0
scoreboard players set #li_twenty zx.meta 2000
scoreboard players operation #li_n zx.meta = #li_lost zx.meta
scoreboard players operation #li_n zx.meta /= #li_twenty zx.meta

# ② 上限内还能塞几个
function sweetdream:profession/mage/tally
scoreboard players add @s zx.j_orb 0
scoreboard players operation #li_room zx.meta = #jcap zx.meta
scoreboard players operation #li_room zx.meta -= #jorbs zx.meta
execute if score #li_room zx.meta matches ..0 run scoreboard players set #li_room zx.meta 0

scoreboard players operation #li_fill zx.meta = #li_n zx.meta
execute if score #li_fill zx.meta > #li_room zx.meta run scoreboard players operation #li_fill zx.meta = #li_room zx.meta
scoreboard players operation @s zx.j_orb += #li_fill zx.meta

# ③ 超出的部分 -> 额外法球（20 秒 = 400 刻，最多 3 个）
scoreboard players operation #li_over zx.meta = #li_n zx.meta
scoreboard players operation #li_over zx.meta -= #li_fill zx.meta
scoreboard players set #li_dur zx.meta 400
execute if score #li_over zx.meta matches 1.. run function sweetdream:equipment/staff/lucid_illusion/extra
execute if score #li_over zx.meta matches 2.. run function sweetdream:equipment/staff/lucid_illusion/extra
execute if score #li_over zx.meta matches 3.. run function sweetdream:equipment/staff/lucid_illusion/extra

execute at @s run particle minecraft:end_rod ~ ~1 ~ 0.9 0.7 0.9 0.08 24 normal
execute at @s run playsound minecraft:entity.experience_orb.pickup player @a ~ ~ ~ 0.9 1.8
