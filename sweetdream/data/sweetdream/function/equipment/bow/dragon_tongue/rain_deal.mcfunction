# ============================================================
# sweetdream:equipment/bow/dragon_tongue/rain_deal —— 一根箭随机落在范围内的某个点
# ------------------------------------------------------------
# 【★ 2026-10-13 改口径 ★】随机的是**落点**, 不再是"随机挑一只生物"。
#   · 旧做法: 从范围内实体列表里 `sort=random,limit=1` 抽一只 ⇒ **有生物就必定命中**
#     ⇒ 玩家看到的是"群体攻击 + 一堆粒子", 与文案"箭矢随机落下"的观感完全不符。
#   · 新做法: 先在被打中那只的 ±2 格里取一个**随机坐标**, 再在那个点上用"一支箭
#     那么大"的判定箱找站着的生物 —— 落在空地就是空的(合法结果), 落在谁脚下就打谁。
#     ⇒ 表现与判定同源: 箭确实落点了, 落没落人才决定有没有伤害。
# 【执行者】射手(玩家); 本函数不依赖 @s 的位置, 全部走显式选择器与 storage。
# 【为什么用 marker 承载落点】mcfunction 的坐标是**字面量**, 写不进变量;
#   想表达"一个算出来的点", 只能借实体的 Pos —— marker 不 tick、开销极小、用完即杀。
# 【随机源】lib/rnd(LCG)。不要用"坐标小数位 + 当前 tick"那类和攻击节奏耦合的源:
#   站着不动打同一只怪会一直落在同一个点(lib/rnd 头注里有这个坑)。
# 【★ 落点半径两档 ★】普通 ±4 格 / 超限 ±6 格。
#   (2026-10-25 用户拍板整体 +2 格: 原 ±2 / ±4 ⇒ 现 ±4 / ±6, 文案同步改「其 4 格内」。)
#   两档用 #800/#400 与 #1200/#600 两套取模, 必须互斥, 见 ② 的注释。
# 【精度 0.01 格】计分项是 Java int, 存不了小数 —— 全程按"百分之一格"做整数运算:
#   读坐标时用 scale 100 拉成整数, 加完偏移再用 double 0.01 写回去。
# ============================================================

# 【诊断锚】dbg6 = 循环进来几根(每一根都算, **含落空的**);
#            dbg7 = 真的砸到目标几根。两者之差 = 落空根数 ——
#            ★ 现在落空是**预期行为**, 不再等于 bug(旧实现里它等于 0)。
scoreboard players add #dt_dbg6 zx.meta 1

# ⓪ 被打中那只还在不在? 死掉 / 被转走的话, 后面的 at 全都依赖它 ⇒ 这一根作废
execute unless entity @e[tag=zx.dt_v,distance=0..,limit=1] run return 0

# ① 清掉上一根可能残留的 marker(双保险), 再在受害者脚下生成一个
kill @e[tag=zx.dt_drop,distance=0..]
execute at @e[tag=zx.dt_v,limit=1] run summon minecraft:marker ~ ~ ~ {Tags:["zx.dt_drop"]}

# ② 两个随机偏移: 普通 ∈ [-400, +399] ⇒ 约 ±4.00 格; 超限 ∈ [-600, +599] ⇒ 约 ±6.00 格
#    【★ 2026-10-25 用户拍板: 落点范围整体 +2 格 ★】普通 2 格 -> 4 格, 超限 4 格 -> 6 格
#      (文案同步改成「其 4 格内」)。跨度因此是 8 格 / 12 格, 平移量 = 跨度的一半。
#    【★ 这四个常数必须先 set 过 ★】#800 / #400 / #200 在 core/load 里已有;
#      #1200 / #600 是 2026-10-25 为"超限扩到 6 格"新增的(见 core/load 的注释)。
#      绝不能写一个没 set 过的常数: 它的值是 0, 而 `operation ... %= 0` 会让
#      **整条命令失败**(等价于除零) ⇒ 后面所有 Pos 写入一条都不执行,
#      箭雨整段静默消失、零日志 —— 这是本函数历史最贵的一个坑。
#    【★ 两档必须**互斥** ★】由 zx.dt_ol(0 = 原版 / 1 = 超限)二选一, 不能连着做两个取模:
#      先 %800 再 %1200 等于没做(值已经小于 800), 顺序写反了表现就是"超限仍然只落 4 格",
#      而且零日志。
function sweetdream:lib/rnd
scoreboard players operation #dt_rx zx.meta = #rnd zx.meta
execute if score @s zx.dt_ol matches 0 run scoreboard players operation #dt_rx zx.meta %= #800 zx.meta
execute if score @s zx.dt_ol matches 0 run scoreboard players operation #dt_rx zx.meta -= #400 zx.meta
execute if score @s zx.dt_ol matches 1 run scoreboard players operation #dt_rx zx.meta %= #1200 zx.meta
execute if score @s zx.dt_ol matches 1 run scoreboard players operation #dt_rx zx.meta -= #600 zx.meta
function sweetdream:lib/rnd
scoreboard players operation #dt_rz zx.meta = #rnd zx.meta
execute if score @s zx.dt_ol matches 0 run scoreboard players operation #dt_rz zx.meta %= #800 zx.meta
execute if score @s zx.dt_ol matches 0 run scoreboard players operation #dt_rz zx.meta -= #400 zx.meta
execute if score @s zx.dt_ol matches 1 run scoreboard players operation #dt_rz zx.meta %= #1200 zx.meta
execute if score @s zx.dt_ol matches 1 run scoreboard players operation #dt_rz zx.meta -= #600 zx.meta

# ③ 受害者坐标 + 随机偏移 = 这一根的落点(只动 x / z; y 沿用受害者脚下的高度)
execute store result score #dt_px zx.meta run data get entity @e[tag=zx.dt_drop,limit=1] Pos[0] 100
scoreboard players operation #dt_px zx.meta += #dt_rx zx.meta
execute store result entity @e[tag=zx.dt_drop,limit=1] Pos[0] double 0.01 run scoreboard players get #dt_px zx.meta
execute store result score #dt_pz zx.meta run data get entity @e[tag=zx.dt_drop,limit=1] Pos[2] 100
scoreboard players operation #dt_pz zx.meta += #dt_rz zx.meta
execute store result entity @e[tag=zx.dt_drop,limit=1] Pos[2] double 0.01 run scoreboard players get #dt_pz zx.meta

# ④ 表现: 这一根箭从上方扎下来 —— ★ 无论有没有砸到都播 ★
#   【为什么不在"没砸到"时静默】这根**箭**是真实存在的产物, 它确实落下去了;
#     落到空地是它自己的命中结果。产物存在 ⇒ 表现存在(坑 145 的硬规则)。
#     要避免的是"播了特效却没有任何产物", 而现在特效的份数严格等于箭的根数。
execute at @e[tag=zx.dt_drop,limit=1] run particle minecraft:item{item:{id:"minecraft:arrow",count:1}} ~ ~3.5 ~ 0.12 1.7 0.12 0.0 10 normal
execute at @e[tag=zx.dt_drop,limit=1] run particle minecraft:crit ~ ~1 ~ 0.2 0.3 0.2 0.02 3 normal

# ⑤ 这个落点上站着谁? —— 一支箭那么大的判定箱(0.8 宽 ≈ 生物半身, 2.2 高够站立高度)
tag @e[tag=zx.dt_hit,distance=0..] remove zx.dt_hit
execute at @e[tag=zx.dt_drop,limit=1] positioned ~-0.4 ~-0.1 ~-0.4 run tag @e[type=!#sweetdream:no_damage,dx=0.8,dy=2.2,dz=0.8,limit=1,sort=nearest] add zx.dt_hit

# ⑥ marker 用完即销毁; 没砸到人 ⇒ 这一根落在空地, 正常收工(不算 bug)
kill @e[tag=zx.dt_drop,distance=0..]
execute unless entity @e[tag=zx.dt_hit,distance=0..,limit=1] run return 0
scoreboard players add #dt_dbg7 zx.meta 1

# ⑦ 结算: 这一根箭砸中的那个目标, 吃 dt.dmg 那份伤害
data modify storage zx:work a set value {target:"@e[tag=zx.dt_hit,limit=1]",damage:0.0,type:"minecraft:player_attack",u0:0,u1:0,u2:0,u3:0}
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.damage set from storage zx:work dt.dmg
data modify storage zx:work a.u0 set from storage zx:work dt.u0
data modify storage zx:work a.u1 set from storage zx:work dt.u1
data modify storage zx:work a.u2 set from storage zx:work dt.u2
data modify storage zx:work a.u3 set from storage zx:work dt.u3
data modify storage zx:work a.num set from storage zx:work a.damage
function sweetdream:lib/num/plain
function sweetdream:internal/damage/with_from with storage zx:work a
