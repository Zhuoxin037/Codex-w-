# ============================================================
# sweetdream:internal/damage/stg_mul —— 天穹「升痕」的加伤(宏 {u0..u3})
# ------------------------------------------------------------
# 【执行者】带「升痕」的那只目标   【谁调它】internal/damage/one(且 #stg >= 1 才调)
# 【规则】文案: "带有「升痕」的生物受到来自比自身位置更高的攻击时, 每层「升痕」
#   使本次技能伤害提升 5%。"
#     -> 本次伤害 x(1 + 5% x 层数), 层数夹在 1..3。
# 【"来自更高处"怎么判】任一成立即可:
#   · 攻击者带 zx.sv_high —— 天穹俯冲起手时给自己打的标记(落地那一瞬玩家未必比目标高,
#     光比 Y 会漏判, 所以俯冲走这个标记)
#   · 攻击者的 Y 比目标高 0.5 格以上(其他"从高处打的技能/平A"走这条)
# 【★ 底数从哪来: zx:work ob.num ★】
#   ob 是 with_from 在**进循环前**抄下的"这一批的完整入参快照"(别的函数一律不碰它)。
#   a.damage 不行 —— a 是全包共用的临时节点, 循环里被嵌套调用改过就不可信;
#   而且有一类调用点(流光/超限流光)只写 a.num、根本不写 a.damage,
#   拿 a.damage 当底数会读到**上一批的残留值**。
#   ob.num 是所有调用点都会写的那个 double(api/damage 与流光系都会写)。
# 【怎么改伤害值】double 没法直接乘 —— 搬到分数(x1000)乘完再写回 a.num,
#   然后由 lib/num/plain 生成 a.num_str, 交给 internal/damage/deal 去打。
# 【层数从哪读】上游 one 已把 @s 的 zx.stg 读进 #stg zx.meta。
# ============================================================

# ① 攻击者在不在? 不在(离线 / 无归属) -> 不改
$execute unless entity @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] run return 0

# ② 目标 Y 与攻击者 Y(各 x100)
execute store result score #vy zx.meta run data get entity @s Pos[1] 100
scoreboard players set #ay zx.meta 0
$execute store result score #ay zx.meta run data get entity @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] Pos[1] 100

# ③ "来自更高处"? 高 0.5 格以上, 或带天穹俯冲标记
scoreboard players set #hi zx.meta 0
scoreboard players operation #dy zx.meta = #ay zx.meta
scoreboard players operation #dy zx.meta -= #vy zx.meta
execute if score #dy zx.meta matches 50.. run scoreboard players set #hi zx.meta 1
$execute if entity @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},tag=zx.sv_high,limit=1] run scoreboard players set #hi zx.meta 1
execute if score #hi zx.meta matches 0 run return 0

# ④ 夹层数到 1..3, 算乘区(x100) = 100 + 5 × 层数
execute if score #stg zx.meta matches 4.. run scoreboard players set #stg zx.meta 3
scoreboard players set #mul zx.meta 100
scoreboard players operation #acc zx.meta = #stg zx.meta
scoreboard players operation #acc zx.meta *= #5 zx.meta
scoreboard players operation #mul zx.meta += #acc zx.meta

# ⑤ 底数(x1000) <- 这一批的原始伤害(基准快照) -> ×乘区 -> 写回 a.num
scoreboard players set #dmg zx.meta 0
execute if data storage zx:work ob.num store result score #dmg zx.meta run data get storage zx:work ob.num 1000
# 兜底(理论上不会走到): 快照里没有 num 就退回 a.num
execute unless data storage zx:work ob.num store result score #dmg zx.meta run data get storage zx:work a.num 1000
scoreboard players operation #dmg zx.meta *= #mul zx.meta
scoreboard players operation #dmg zx.meta /= #100 zx.meta
execute store result storage zx:work a.num double 0.001 run scoreboard players get #dmg zx.meta
data modify storage zx:work a.damage set from storage zx:work a.num

# ⑥ 重新生成纯数字字符串(交给 deal 去打)
function sweetdream:lib/num/plain
