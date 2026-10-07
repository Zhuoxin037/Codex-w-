# ============================================================
# internal/damage/calc —— 技能伤害计算(三通道 + 独立乘区)
# ------------------------------------------------------------
# 【宏参数】manacore:work.a {uuid,
#          max_mana_mul, attack_mul, other_mul,   <- 三条倍率通道
#          base_attack, other_base,               <- 基数覆盖(-1 = 用通道默认基数)
#          custom_damage, health_ratio, independent_multiplier}
# 【公式】
#    伤害 =   最大魔力   x max_mana_mul
#            + 基础攻击力 x attack_mul
#            + 其他基数   x other_mul
#            + custom_damage
#            + 最大生命   x health_ratio
#    最后整体 x independent_multiplier
# ------------------------------------------------------------
# 【★ 三条倍率通道各吃什么基数 ★】
#   max_mana_mul : 最大魔力值技能倍率, 基数 = 玩家面板 max_mana
#   attack_mul   : 基础攻击力倍率,     基数 = base_attack 字段, -1 = 面板 base_attack
#   other_mul    : 其他倍率,           基数 = other_base 字段, -1 = 面板 current_mana
#   前者给"以最大魔力结算"的技能, 中者给"以攻击力结算"的技能,
#   后者给其余口径(最常见的是"当前魔力结算", 所以默认基数就是当前魔力)。
#
# 【★ 缺省规则(很重要) ★】
#   ① 三条通道一条都没给 -> 按旧行为: 基础攻击力 x1。
#      所以老调用 `{base_attack:-1, skill_multiplier:2.0}` 结果不变。
#   ② 只要给了任意一条 -> 没给的通道一律当 0。
#      所以"最大魔力类技能"只写 max_mana_mul 就够了, **不会**再顺手加一份面板攻击力。
#
# 【为什么要把一条拆成三条】旧版只有一个 skill_multiplier, "吃什么"是靠
#   **改写 base_attack** 表达的(先读 max_mana 塞进 base_attack, 再乘 skill_multiplier)。
#   同一个字段既当"伤害基数"又当"口径开关", 于是面板上没法把三类加成分开显示,
#   也没法给某一类单独加乘区。拆开之后: 技能显式声明走哪条通道, 基数由框架取。
#
# 【旧字段兼容】skill_multiplier = attack_mul 的旧名, 只在没给 attack_mul 时生效。
#   新写的代码请直接用 attack_mul。
#
# 【定点运算】基数按 x1000, 倍率按 x100, 相乘后除回 #100 -> 结果 x1000。
#   计分板是 32 位有符号整数(上限 21.4 亿)。若两个操作数都按 x1000 相乘,
#   中间量到 x1000000, 裸数值超过约 2147 就溢出成负数, 然后被下面的
#   "matches ..0 -> 0" 夹成 0(现象就是伤害突然变 0.0d)。
#   倍率降一个数量级后中间量只有 x100000, 上限提升到约 21474。
# 【为什么要走宏参数】倍率/固定伤害在不同技能里完全不同, 用宏参数传进来
#   就能"一个函数服务所有技能", 不必为每个技能写一份计算函数。
# 【出参】manacore:out.damage; 并抛 #manacore:event/damage_calc 供外部改算
# ============================================================

# ---- ① 旧字段兼容 + 补默认(直接调 internal 时也自给自足) ----
execute unless data storage manacore:work a.attack_mul if data storage manacore:work a.skill_multiplier run data modify storage manacore:work a.attack_mul set from storage manacore:work a.skill_multiplier
execute unless data storage manacore:work a.attack_mul unless data storage manacore:work a.max_mana_mul unless data storage manacore:work a.other_mul run data modify storage manacore:work a.attack_mul set value 1.0
execute unless data storage manacore:work a.attack_mul run data modify storage manacore:work a.attack_mul set value 0.0
execute unless data storage manacore:work a.max_mana_mul run data modify storage manacore:work a.max_mana_mul set value 0.0
execute unless data storage manacore:work a.other_mul run data modify storage manacore:work a.other_mul set value 0.0
execute unless data storage manacore:work a.base_attack run data modify storage manacore:work a.base_attack set value -1.0
execute unless data storage manacore:work a.other_base run data modify storage manacore:work a.other_base set value -1.0
execute unless data storage manacore:work a.custom_damage run data modify storage manacore:work a.custom_damage set value 0.0
execute unless data storage manacore:work a.health_ratio run data modify storage manacore:work a.health_ratio set value 0.0
execute unless data storage manacore:work a.independent_multiplier run data modify storage manacore:work a.independent_multiplier set value 1.0

# ---- ② 三个基数(x1000) ----
#   一律"先归零再 store": data get 读不到时 store 不执行, 会留着上一个值。
scoreboard players set #base_a manacore.math 0
execute store result score #base_a manacore.math run data get storage manacore:work a.base_attack 1000
execute if score #base_a manacore.math matches ..-1 run function manacore:internal/damage/use_base with storage manacore:work a

scoreboard players set #base_m manacore.math 0
$execute store result score #base_m manacore.math run data get storage manacore:players "$(uuid)".stats.max_mana 1000

scoreboard players set #base_o manacore.math 0
execute store result score #base_o manacore.math run data get storage manacore:work a.other_base 1000
execute if score #base_o manacore.math matches ..-1 run function manacore:internal/damage/use_other with storage manacore:work a

# ---- ③ 三条倍率(x100) ----
execute store result score #mul_m manacore.math run data get storage manacore:work a.max_mana_mul 100
execute store result score #mul_a manacore.math run data get storage manacore:work a.attack_mul 100
execute store result score #mul_o manacore.math run data get storage manacore:work a.other_mul 100

# ---- ④ 三通道贡献相加(x1000) ----
scoreboard players operation #dmg manacore.math = #base_m manacore.math
scoreboard players operation #dmg manacore.math *= #mul_m manacore.math
scoreboard players operation #dmg manacore.math /= #100 manacore.meta

scoreboard players operation #acc manacore.math = #base_a manacore.math
scoreboard players operation #acc manacore.math *= #mul_a manacore.math
scoreboard players operation #acc manacore.math /= #100 manacore.meta
scoreboard players operation #dmg manacore.math += #acc manacore.math

scoreboard players operation #acc manacore.math = #base_o manacore.math
scoreboard players operation #acc manacore.math *= #mul_o manacore.math
scoreboard players operation #acc manacore.math /= #100 manacore.meta
scoreboard players operation #dmg manacore.math += #acc manacore.math

# ---- ⑤ 固定伤害 + 生命项 + 独立乘区 ----
execute store result score #cd manacore.math run data get storage manacore:work a.custom_damage 1000
scoreboard players operation #dmg manacore.math += #cd manacore.math
execute store result score #hr manacore.math run data get storage manacore:work a.health_ratio 100
execute if score #hr manacore.math matches 1.. run function manacore:internal/damage/health_part with storage manacore:work a
execute store result score #im manacore.math run data get storage manacore:work a.independent_multiplier 100
scoreboard players operation #dmg manacore.math *= #im manacore.math
scoreboard players operation #dmg manacore.math /= #100 manacore.meta
execute if score #dmg manacore.math matches ..0 run scoreboard players set #dmg manacore.math 0
execute store result storage manacore:out r.damage double 0.001 run scoreboard players get #dmg manacore.math
$data modify storage manacore:ctx uuid set value "$(uuid)"
data modify storage manacore:ctx reason set value "calc"
function #manacore:event/damage_calc
