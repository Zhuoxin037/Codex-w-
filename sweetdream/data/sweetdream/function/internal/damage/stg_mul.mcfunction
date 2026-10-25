# ============================================================
# sweetdream:internal/damage/stg_mul —— 天穹「升痕」的加伤(宏 {u0..u3})
# ------------------------------------------------------------
# 【执行者】带「升痕」的那只目标   【谁调它】internal/damage/one(且 #stg >= 1 才调)
# 【规则】文案: "带有「升痕」的生物受到来自比自身位置更高的攻击时, 每层「升痕」
#   使本次技能伤害提升 5%。"
#     -> 本次伤害 x(1 + 5% x 层数), 层数夹在 1..3。
#   【超限·天穹(2026-10-23 批 K4)】每层 **10%**(见 ④: 按攻击者手里那把是不是
#     超限版分档)。层数上限仍是 3。
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
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute unless entity @a[tag=zx.ub,limit=1] run return 0

# ② 目标 Y 与攻击者 Y(各 x100)
#   【★ 攻击者 Y 不再在这里读 ★】2026-10-23 卡顿修复: `data get entity <玩家> Pos[1]`
#   会把玩家**整份 NBT**(含背包 DataComponents)写出来, ≈10 ms —— 天穹半径 6 打 10 只、
#   每只 3 层升痕 ⇒ 30 次 ×10 ms = 一次落地 0.3 秒的顿帧。
#   现在攻击者 Y 由 with_from **每批只反查一次**, 存进 #stg_ay; 再由 one 每只目标
#   从 ob.ay 复原(嵌套伤害改过它也不怕)。这里只剩"读目标 Y"这一条(生物 NBT 便宜)。
execute store result score #vy zx.meta run data get entity @s Pos[1] 100
scoreboard players operation #ay zx.meta = #stg_ay zx.meta

# ③ "来自更高处"? 高 0.5 格以上, 或带天穹俯冲标记
scoreboard players set #hi zx.meta 0
scoreboard players operation #dy zx.meta = #ay zx.meta
scoreboard players operation #dy zx.meta -= #vy zx.meta
execute if score #dy zx.meta matches 50.. run scoreboard players set #hi zx.meta 1
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute if entity @a[tag=zx.ub,tag=zx.sv_high,limit=1] run scoreboard players set #hi zx.meta 1
execute if score #hi zx.meta matches 0 run return 0

# ④ 夹层数到 1..3, 算乘区(x100) = 100 + (5 或 10) × 层数
#   【超限·天穹(2026-10-23 批 K4)】每层从 5% 抬到 **10%**。
#   ★ 判据必须落在**攻击者手里那把**上: 「升痕」的加伤是"这把武器"的被动,
#     别人拿着普通天穹(或别的武器)来打, 仍然是每层 5%。
#   ★ 攻击者是玩家(① 已经确认在线), 所以直接拿 UUID 反查他手里那件 —— 主副手都判。
execute if score #stg zx.meta matches 4.. run scoreboard players set #stg zx.meta 3
scoreboard players set #stg_per zx.meta 5
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute as @a[tag=zx.ub,limit=1] run function sweetdream:internal/damage/stg_per
scoreboard players set #mul zx.meta 100
scoreboard players operation #acc zx.meta = #stg zx.meta
scoreboard players operation #acc zx.meta *= #stg_per zx.meta
scoreboard players operation #mul zx.meta += #acc zx.meta

# ⑤ 底数(x1000) <- 这一批的原始伤害(基准快照) -> ×乘区 -> 写回 a.num
scoreboard players set #dmg zx.meta 0
execute if data storage zx:work ob.num store result score #dmg zx.meta run data get storage zx:work ob.num 1000
# 兜底(理论上不会走到): 快照里没有 num 就退回 a.num
execute unless data storage zx:work ob.num store result score #dmg zx.meta run data get storage zx:work a.num 1000
# 【★ R05 整数上界保护(2026-10-10)★】#dmg 此刻是**×1000 定点**, 下一步要 ×#mul。
#   计分板是 **int32**, 中间值越过 2,147,483,647 会**回绕成负数** —— 不报错,
#   得到的却是一个天文数字或负值(表现就是"伤害突然变成几百亿/负数")。
#   这里补一道动态上限 = INT32_MAX ÷ #mul; 常态数值远不到那个量级, 一行都不受影响。
#   ★ 为什么带上 `matches 1..`: 除数如果是 0, 这条 operation **静默失败**(见坑 85 的
#     除零事故), 乘数是百分比加法的结果、被减到 0 以下是有可能的。
#   ★ 为什么不改成"先 ÷100 再 ×": 那会把 45.67 砍成 45, 让常态丢掉小数精度 ——
#     为防一个极端数值牺牲常态精度不划算(vuln_tag 那条注释里有同样的取舍)。
scoreboard players set #dmg_cap zx.meta 2147483647
execute if score #mul zx.meta matches 1.. run scoreboard players operation #dmg_cap zx.meta /= #mul zx.meta
execute if score #mul zx.meta matches 1.. if score #dmg zx.meta > #dmg_cap zx.meta run scoreboard players operation #dmg zx.meta = #dmg_cap zx.meta
scoreboard players operation #dmg zx.meta *= #mul zx.meta
scoreboard players operation #dmg zx.meta /= #100 zx.meta
execute store result storage zx:work a.num double 0.001 run scoreboard players get #dmg zx.meta
data modify storage zx:work a.damage set from storage zx:work a.num

# ⑥ 重新生成纯数字字符串(交给 deal 去打)
function sweetdream:lib/num/plain
