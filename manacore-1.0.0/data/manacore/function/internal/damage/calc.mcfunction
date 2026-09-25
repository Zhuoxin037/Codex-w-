# ============================================================
# internal/damage/calc —— 技能伤害计算(含独立乘区)
# ------------------------------------------------------------
# 【宏参数】manacore:work.a {uuid,base_attack,skill_multiplier,
#          independent_multiplier,custom_damage,health_ratio}
# 【公式】
#    伤害 = ( 基础攻击力 x 技能倍率 + 技能固定伤害 + 最大生命 x 生命系数 )
#           x 独立乘区
#    base_attack           : 传 -1 表示"用玩家面板上的 base_attack"
#    skill_multiplier      : 技能倍率
#    custom_damage         : 技能自带的固定伤害
#    independent_multiplier: 独立乘区(所有加成算完后统一乘一次)
#    health_ratio          : 可选, 最大生命 x 该比例也计入基础伤害
# 【定点运算】先把所有数值变成整数, 用计分板做完乘除后再还原。
#   基础量(攻击力/固定伤害/生命)按 x1000 取, 保留 3 位小数;
#   倍率类(技能倍率/独立乘区/生命系数)按 x100 取, 只保留 2 位小数。
# 【为什么倍率要降成 x100】计分板是 32 位有符号整数, 上限 21.4 亿。两个操作数
#   若都按 x1000 相乘, 中间量到 x1000000, 裸数值超过约 2147 就溢出成负数,
#   然后被下面的 "matches ..0 -> 0" 夹成 0(现象就是伤害突然变 0.0d)。
#   倍率降一个数量级后, 中间量只有 x100000, 上限提升到约 21474。
#   倍率用 2 位小数完全够(2.5 / 1.15 都能精确表示)。
# 【如果要更大】把倍率改成 x10(#10), 上限再涨 10 倍到约 21 万, 代价是
#   倍率只剩 1 位小数。改动点: 下面三行 data get 的 100 -> 10,
#   以及两处 "/= #100" -> "/= #10"。
#   写回 double。先乘后除, 尽量保住精度。
# 【为什么要走宏参数】倍率/固定伤害在不同技能里完全不同, 用宏参数传进来
#   就能"一个函数服务所有技能", 不必为每个技能写一份计算函数。
# 【出参】manacore:out.damage; 并抛 #manacore:event/damage_calc 供外部改算
# ============================================================
execute store result score #base manacore.math run data get storage manacore:work a.base_attack 1000
execute if score #base manacore.math matches ..-1 run function manacore:internal/damage/use_base with storage manacore:work a
execute store result score #sm manacore.math run data get storage manacore:work a.skill_multiplier 100
execute store result score #im manacore.math run data get storage manacore:work a.independent_multiplier 100
execute store result score #cd manacore.math run data get storage manacore:work a.custom_damage 1000
execute store result score #hr manacore.math run data get storage manacore:work a.health_ratio 100
scoreboard players operation #dmg manacore.math = #base manacore.math
scoreboard players operation #dmg manacore.math *= #sm manacore.math
scoreboard players operation #dmg manacore.math /= #100 manacore.meta
scoreboard players operation #dmg manacore.math += #cd manacore.math
execute if score #hr manacore.math matches 1.. run function manacore:internal/damage/health_part with storage manacore:work a
scoreboard players operation #dmg manacore.math *= #im manacore.math
scoreboard players operation #dmg manacore.math /= #100 manacore.meta
execute if score #dmg manacore.math matches ..0 run scoreboard players set #dmg manacore.math 0
execute store result storage manacore:out r.damage double 0.001 run scoreboard players get #dmg manacore.math
$data modify storage manacore:ctx uuid set value "$(uuid)"
data modify storage manacore:ctx reason set value "calc"
function #manacore:event/damage_calc
