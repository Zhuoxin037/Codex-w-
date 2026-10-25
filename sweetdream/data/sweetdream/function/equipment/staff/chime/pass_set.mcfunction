# ============================================================
# sweetdream:equipment/staff/chime/pass_set —— "法术穿过"判定 + 结算(宏)
# ------------------------------------------------------------
# 【宏参数】u0..u3(释放者 UUID 四 int)   【执行者】水晶 marker   【位置】水晶处
# 【判据】"自身释放的法术穿过水晶" —— 下面**任一类**成立就算:
#   ① 附近有一颗 **释放者自己的、还没触发过** 的法球(见 ① 来源 a):
#      · "自己人的" = 球的 data.u0..u3 与释放者一致;
#      · "还没触发过" = 球不带 zx.ch_pass(每颗球对每颗水晶只触发一次)。
#   ② 正被**释放者自己的持续光束**照着(2026-10-09 用户定: 终末天启的光柱 /
#      偏振光的光线都是"持续发射光束", 穿过水晶也应该能触发)—— 光束在自己每刻的
#      表现里给"照到的水晶"打 zx.ch_beam 戳, 这里读它(见 ① 来源 b)。
#   两类共用同一个 0.5 秒节流。
#   ★ 为什么给球打戳而不是 kill 球: 球还要继续飞、还要打它自己的命中伤害,
#     这里只是"穿过水晶"的附加效果, 不能把球收掉。
# 【★ 触发频率: 每 0.5 秒最多一次(用户 2026-10-09 定) ★】
#   这个效果可以**持续触发**(条件一直满足就一直打), 但有 0.5 秒(10 tick)的
#   频率上限 —— 与"终末天启 / 偏振光"那种"条件满足就周期触发"同一个模式,
#   只是周期取 0.5 秒(那两件挂每秒入口, 分辨率不够, 所以这里留在每刻驱动)。
#   实现 = 水晶自己的倒计时 `zx.ch_cd`(见 ⓪ / ① / ①')。
# 【★ 位置口径 ★】本函数由 pass_check 在"as 水晶 at @s"的链上调用 —— 坐标 = 水晶。
#   ★★ 但"找球"的基准必须**抬高 1.6 格**再判 distance ★★
#   水晶召唤在**脚底**(skill 里 summon ~ ~ ~), 法球却飞在**眼睛高度**
#   (fire 里 anchored eyes ^ ^ ^1.5) —— 两者天生相差约 1.62 格(玩家站立眼高)。
#   distance 是**三维**距离, 光这个高度差就已 > 1.5 ⇒ 直接写 distance=..1.5
#   **永远不成立**(2026-10-09 用户实测"法球穿过没有伤害")。
#   所以找球一律 `positioned ~ ~1.6 ~`(把基准抬到法球飞行高度);
#   圈生物(3 格)仍以**水晶本身**为基准(人和怪都站地上)。
# 【★ 为什么先把 3 格内生物圈成标签再结算 ★】被调函数 pass_go 是在
#   "as 释放者" 的链上跑的(坐标会被保留, 但 check 规则 asnoat 看不出这一点),
#   所以让它按**标签**取目标(不与坐标相关), 就不会被误判/真判错。
# ============================================================

# 【★★ 2026-10-20 第二次卡顿修复: 本文件的两个"本刻戳"全部改成计分项 ★★】
#   改动: zx.ch_act(本刻有触发) / zx.ch_p(本刻结算目标) —— 从**实体 tag** 改成**计分项**。
#   为什么: 偏振光/终末天启的光束**持续照着**水晶 ⇒ 每 0.5 秒(zx.ch_cd 节流)走一次
#   完整结算 ⇒ 对水晶 3/5 格内的**每一个生物**先 add 再 remove 同一个 tag。
#   一次 addTag/removeTag 命中就 setChanged() ⇒ 该实体所在 chunk 标脏 ⇒ 下一次存盘
#   整份重写(与 2026-10-20 法球、偏振光本体那两次同一机理)。
#   偏振光持续 5 秒 = 10 轮, 玩家感受就是"打一下卡一下"。
#   计分项只写内存, 且 zx.ch_p 用完即清(zx.ch_act=0 的那刻不清, 见 ⑥)。
#   ★ 语义 1:1: 原来 `if entity @s[tag=zx.ch_act]` → 现在 `if score @s zx.ch_act matches 1`。
# ⓪ 节流倒计时**已挪到 pass_check**（2026-10-20）—— 它必须每刻都减，
#   而本函数现在只在"可能有事件"的刻才会被调用，放在这里会漏减。
#   ★ 原来是倒计时(而不是记"上次触发的时刻"): 本项目的连续性一律走差值/倒计时,
#     免得踩"每秒清 + 同秒判"那类必然失效的写法(见 RULES 58)。

# ① 本刻判定: **节流已过** 且 (附近有自己人的法球 || 正被自己人的光束照着)
#   → 给**水晶**挂一个"本刻戳" zx.ch_act(每刻开头先摘, 所以它只代表"这一
#   刻正好有事件")。后面 ②④⑤⑥ 全部以它为准。
#   ★★ 千万别拿 "zx.ch_p 标签还在不在" 当"这刻触发了"的判据 ★★
#      (2026-10-09 修: 修好高度差之后, 单次触发会在水晶余下的 8 秒里**每刻重复
#      结算** —— ch_p 打完伤害不摘, 于是 `if entity @e[tag=zx.ch_p]` 每刻都成立,
#      现象 = 射一发球, 水晶像疯了似的连炸上百下。门控必须用"本刻戳"。)
scoreboard players set @s zx.ch_act 0

#   来源 a: 自己人的法球 —— 基准抬到法球飞行高度(~1.6), 见头注释的"位置口径"
$execute unless score @s zx.ch_cd matches 1.. positioned ~ ~1.6 ~ if entity @e[tag=zx.ball,distance=..1.5,nbt={data:{u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}},tag=!zx.ch_pass] run scoreboard players set @s zx.ch_act 1

#   来源 b: 自己人的**持续光束**(终末天启光柱 / 偏振光光线) —— 它们在各自的每刻
#     表现里给"照到的水晶"打 zx.ch_beam 戳(final_revelation/beam_go ⑤ 与
#     polarized_light/beam_step ②)。这里读戳, 读完立刻清(它和本刻戳一样是一次性的)。
execute if score @s zx.ch_beam matches 1 unless score @s zx.ch_cd matches 1.. run scoreboard players set @s zx.ch_act 1
scoreboard players set @s zx.ch_beam 0

# ①' 本刻真的触发了 -> 压满节流: 接下来 10 tick(0.5 秒)内不再触发
execute if score @s zx.ch_act matches 1 run scoreboard players set @s zx.ch_cd 10

# ② 本刻真有触发(球或光束) -> 重圈"水晶 N 格内全部生物"(原版 3 / 超限 5; ★ 基准 = 水晶本身, 不抬 —— 人和怪都在地上)
execute if score @s zx.ch_act matches 1 run scoreboard players set @e[scores={zx.ch_p=1}] zx.ch_p 0
execute if score @s zx.ch_act matches 1 run scoreboard players set @e[type=!#sweetdream:no_damage,distance=..3] zx.ch_p 1
execute if score @s zx.ch_act matches 1 if data entity @s data.zx.ch{ol:1} run scoreboard players set @e[type=!#sweetdream:no_damage,distance=..5] zx.ch_p 1

# ②' 超限另加"释放者 3 格内的全部生物" —— 先反查释放者, 再以他为圆心圈一次
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute if score @s zx.ch_act matches 1 if data entity @s data.zx.ch{ol:1} as @a[tag=zx.ub,limit=1] at @s run scoreboard players set @e[type=!#sweetdream:no_damage,distance=..3] zx.ch_p 1

# ③ 给那颗球打"已触发"戳(每颗球对每颗水晶只触发一次; 同样用抬高的基准找它)
$execute positioned ~ ~1.6 ~ as @e[tag=zx.ball,distance=..1.5,nbt={data:{u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}},tag=!zx.ch_pass] run tag @s add zx.ch_pass

# ④ 反查释放者, 交给他结算(执行者=玩家 -> 归属正确)
#   ★ 门控 = "本刻戳" —— 只有"正好这一下"才结算, 不是"标签还挂着"就一直结算。
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute if score @s zx.ch_act matches 1 as @a[tag=zx.ub,limit=1] if entity @e[scores={zx.ch_p=1},limit=1] run function sweetdream:equipment/staff/chime/pass_go with storage zx:work chp

# ⑤ 表现(水晶被法术激发的环; 执行者/坐标仍是水晶; 同样只在"本刻触发"时播一次)
execute if score @s zx.ch_act matches 1 run particle minecraft:enchant ~ ~0.6 ~ 0.6 0.6 0.6 0.4 24 normal
execute if score @s zx.ch_act matches 1 run particle minecraft:end_rod ~ ~0.6 ~ 0.8 0.8 0.8 0.02 16 normal
execute if score @s zx.ch_act matches 1 run playsound minecraft:block.amethyst_block.resonate player @a ~ ~ ~ 0.7 1.5

# ⑥ 收尾: 摘掉本轮的目标标签 —— 让 ch_p 的生命周期只有"本刻"(圈 -> 用 -> 摘),
#   下一次触发从空开始; 也不会在水晶消失后把标签留在生物身上。
execute if score @s zx.ch_act matches 1 run scoreboard players set @e[scores={zx.ch_p=1}] zx.ch_p 0
