# ============================================================
# sweetdream:equipment/staff/fate_thread/watch —— 连丝真伤结算(每刻轮询)
# ------------------------------------------------------------
# 【谁调用它】core/tick(每刻; 入口 = @a[tag=zx.ft_link], 没放丝的人不进函数)
# 【执行者】**施法者本人**   【位置】玩家所在
# 【技能原文】"期间其每次受到自身造成的伤害后，相连的其他生物分别受到一次相当于
#   本次伤害 ×0.3 的真实伤害（最多触发 6 次）。若其死亡或失去「噬心」，则丝线断开；
#   若与相连生物的距离超过 12 格，则对应丝线断开。"
#
# 【★★ 口径(2026-10-17 用户原话: "谁说要法球打主目标才反伤了，是全部伤害呀") ★★】
#   原来接了两条特例链(fate_thread_hit 进度 / link_from_ball 法球回调), 各只覆盖一部分
#   来源。MC **没有**"任意生物受伤"事件 ⇒ 覆盖全部来源的唯一办法 = 每刻读一次 Health,
#   与快照比差值(顺带拿到"本次伤害"的数值)。任何来源都算: 近战 / 别的武器 / 别的玩家 /
#   怪物 / 摔落 / 着火 / 中毒 / 法术。两条特例链已删除(否则会双结算)。
#
# 【★★ 状态记在玩家身上, 不依赖 marker ★★】
#   zx.ft_mine = 实例号     zx.ft_end = 到期绝对刻(+140 刻)     zx.ft_got = 已结算次数
#   2026-10-17 事故: 实例号原来从 marker 的 UUID[0] 读回, 那一步读空 ⇒ 三方全写 0 ⇒
#   连丝"放得出来但永不结算"(存档实证: 玩家 zx.ft_mine=0, 主目标/marker 实例号互不相同)。
#   现在**没有 marker**: 到期/次数/实例号全在玩家身上, 表现靠粒子从玩家侧画。
#
# 【★ 只由"主目标"掉血触发 ★】文案"其每次受到…后, 相连的其他生物分别受到" —— "其"=主目标。
#   相连者受伤不触发(否则两组丝会互相引爆, 6 次瞬间烧完)。
# 【★ 快照无论结算与否都刷新 ★】否则下一 tick 的差值会把同一段伤害再算一遍(翻倍)。
# 【★ 这次 @s 始终是玩家 ★】所以 api/damage/calc 直接查面板, 不用反查 uuid。
# ============================================================

# ① 本刻先认自己的丝(0 = 没有; 主目标在别的维度也可能, 所以不加 distance)
execute if score @s zx.ft_mine matches 0 run tag @s remove zx.ft_link
execute if score @s zx.ft_mine matches 0 run return 0
scoreboard players operation #ft_iid zx.meta = @s zx.ft_mine

# ② 到期处理
#   基础版（zx.ft2_end 从不赋值 = 0）：7 秒整条收场，行为与改动前逐字一致。
#   超限版（zx.ft2_end > 0）：
#     · 第一组 12 秒到期 → 先绷紧一次 + 摘掉第一组的相连者（主目标保留），
#       整条丝继续跑到第二组的 18 秒；
#     · 第二组 18 秒到期 → 收场（watch_end 里再绷第二组）。
#   ★ "绷紧只做一次"靠 zx.ft_tg1 幂等：ft_end 过期后会每刻都进来，
#     不立旗标就会每刻绷一次（10×N 连发几十遍）。
scoreboard players add @s zx.ft2_end 0
scoreboard players add @s zx.ft_tg1 0
execute if score @s zx.ft_end <= #now manacore.meta if score @s zx.ft_tg1 matches 0 run function sweetdream:equipment/staff/fate_thread/ol_pre_end
execute if score @s zx.ft2_end <= #now manacore.meta run function sweetdream:equipment/staff/fate_thread/watch_end
execute if score @s zx.ft2_end <= #now manacore.meta run return 0

# ③ 钉住本实例的主目标
#   ★ 全维度搜(不写 execute in): 玩家刚换维度时丝可能还在原世界。
tag @e[tag=zx.ft_wt] remove zx.ft_wt
execute as @e[tag=zx.ft_main] if score @s zx.ft_n = #ft_iid zx.meta run tag @s add zx.ft_wt
execute unless entity @e[tag=zx.ft_wt,limit=1] run function sweetdream:equipment/staff/fate_thread/watch_end
execute unless entity @e[tag=zx.ft_wt,limit=1] run return 0

# ④ 主目标失去「噬心」(被消耗/过期) -> 收场
execute unless entity @e[tag=zx.ft_wt,tag=zx.status.shixin,limit=1] run function sweetdream:equipment/staff/fate_thread/watch_end
execute unless entity @e[tag=zx.ft_wt,tag=zx.status.shixin,limit=1] run return 0

# ⑤ 与主目标距离超限的相连者, 断掉它自己那条(只剩主目标那根丝)
#   ★ 以**主目标当前位置**为圆心(主目标会走, 不能用施放点)
#   ★ 半径分档（批 K9）：基础 12 格 / 超限 16 格；第二组同一条规则。
execute if score @s zx.ft2_end matches 0 at @e[tag=zx.ft_wt,limit=1] as @e[tag=zx.ft_lk,distance=12.01..] if score @s zx.ft_n = #ft_iid zx.meta run tag @s remove zx.ft_lk
execute if score @s zx.ft2_end matches 1.. at @e[tag=zx.ft_wt,limit=1] as @e[tag=zx.ft_lk,distance=16.01..] if score @s zx.ft_n = #ft_iid zx.meta run tag @s remove zx.ft_lk
execute if score @s zx.ft2_end matches 1.. at @e[tag=zx.ft_wt,limit=1] as @e[tag=zx.ft_lk2,distance=16.01..] if score @s zx.ft2n = #ft_iid zx.meta run tag @s remove zx.ft_lk2

# ⑤-b 丝线表现(★ 2026-10-17 第二版: marker 取消后, 表现改由这里每刻画 ★)
#   ★★ 第四版追加: **主目标要一眼认出来** ★★
#     前三轮复测有个躲不掉的可能: 场上 3 只生物都被丝连着, 但"其受到伤害"里的"其"
#     只指**主目标** —— 打相连者是不会结算的(文案如此)。而原来的表现只差 2 个粒子,
#     玩家根本分不出该打哪只, 于是"打了没反应"很可能只是**打错目标**。
#     现在: 主目标 = 头顶一条红色光柱 + 更亮更大的光雾; 相连者 = 体表淡淡的一层。
execute at @e[tag=zx.ft_wt,limit=1] run particle minecraft:dust{color:[1.0,0.18,0.28],scale:2.0} ~ ~1 ~ 0.45 0.55 0.45 0.01 10 normal
execute at @e[tag=zx.ft_wt,limit=1] run particle minecraft:end_rod ~ ~1.0 ~ 0.16 0.8 0.16 0.02 6 normal
execute at @e[tag=zx.ft_wt,limit=1] run particle minecraft:end_rod ~ ~2.2 ~ 0.10 0.5 0.10 0.01 4 normal
execute as @e[tag=zx.ft_lk] if score @s zx.ft_n = #ft_iid zx.meta at @s run particle minecraft:dust{color:[0.75,0.1,0.2],scale:1.0} ~ ~1 ~ 0.15 0.2 0.15 0.01 3 normal

# ⑥ 本次掉血 = 上次快照 - 当前血量(两边都 ×1000 取整; 误差 < 0.002 点)
scoreboard players set #ft_old zx.meta 0
execute store result score #ft_old zx.meta run scoreboard players get @e[tag=zx.ft_wt,limit=1] zx.ft_hp
scoreboard players set #ft_cur zx.meta 0
execute store result score #ft_cur zx.meta run data get entity @e[tag=zx.ft_wt,limit=1] Health 1000

# ★ 两条必须有的护栏(否则会把"读不到"当成"掉了好几千血") ★
#   ① 快照缺失(#ft_old = 0): 说明这是第一刻/刚被 reset —— 只补快照, 不结算。
#   ② 当前血量读不到(#ft_cur = 0): 主目标**这一 tick 已经死了**/实体被移除,
#      `data get` 失败 ⇒ store 不写入 ⇒ #ft_cur 停在 0 ⇒ 差值会变成一个巨大的正数,
#      真的打出去就是"连着丝的生物被瞬秒"。必须直接收场。
#   (★ 通用: `data get` 取不到 ⇒ `store result` 不写入 —— 见 RULES 坑 166)
execute if score #ft_cur zx.meta matches ..0 run function sweetdream:equipment/staff/fate_thread/watch_end
execute if score #ft_cur zx.meta matches ..0 run return 0
execute if score #ft_old zx.meta matches ..0 run scoreboard players operation @e[tag=zx.ft_wt,limit=1] zx.ft_hp = #ft_cur zx.meta
execute if score #ft_old zx.meta matches ..0 run return 0

# ★ 无论是否结算都刷新快照 ★ 否则下一刻的差值会把这一下重复算进去(伤害翻倍)
scoreboard players operation @e[tag=zx.ft_wt,limit=1] zx.ft_hp = #ft_cur zx.meta

scoreboard players operation #ft_diff zx.meta = #ft_old zx.meta
scoreboard players operation #ft_diff zx.meta -= #ft_cur zx.meta
# 没掉血(回血 / 自然再生 / 被无敌帧吃掉) -> 本刻不结算
execute if score #ft_diff zx.meta matches ..0 run return 0

# ⑦ 次数上限（**只有基础版有**；超限版文案里没有"最多触发 6 次"）
scoreboard players add @s zx.ft_got 0
execute if score @s zx.ft2_end matches 0 if score @s zx.ft_got matches 6.. run return 0

# ⑧ 算「本次伤害 × 倍率」: 把差值当 other_base 传进 calc(计分项 -> double 走 store 缩放)
#   基础 0.3 / 超限单丝 0.5；超限双丝 0.8 单独再算一份（dmg2）。
execute store result storage zx:work ft.db double 0.001 run scoreboard players get #ft_diff zx.meta
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",other_base:0.0,other_mul:0.3}
execute if score @s zx.ft2_end matches 1.. run data modify storage manacore:in arg.other_mul set value 0.5
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.other_base set from storage zx:work ft.db
function manacore:api/damage/calc
data modify storage zx:work ft.dmg1 set from storage manacore:out r.damage
execute if score @s zx.ft2_end matches 1.. run data modify storage manacore:in arg.other_mul set value 0.8
execute if score @s zx.ft2_end matches 1.. run function manacore:api/damage/calc
execute if score @s zx.ft2_end matches 1.. run data modify storage zx:work ft.dmg2 set from storage manacore:out r.damage

# ⑨ 圈出**本实例**的相连者(选择器不能判分, 先打标签)
#   ★ 双丝组（zx.ft_cn ≥ 2）单独一组：文案"若相连的生物有两个或以上丝线同时相连
#     则改为受到本次伤害 x0.8"。
tag @e[tag=zx.ft_hit2] remove zx.ft_hit2
tag @e[tag=zx.ft_hit3] remove zx.ft_hit3
execute as @e[tag=zx.ft_lk] if score @s zx.ft_n = #ft_iid zx.meta unless score @s zx.ft_cn matches 2.. run tag @s add zx.ft_hit2
execute if score @s zx.ft2_end matches 1.. as @e[tag=zx.ft_lk2] if score @s zx.ft2n = #ft_iid zx.meta unless score @s zx.ft_cn matches 2.. run tag @s add zx.ft_hit2
execute if score @s zx.ft2_end matches 1.. as @e[tag=zx.ft_lk2] if score @s zx.ft2n = #ft_iid zx.meta if score @s zx.ft_cn matches 2.. run tag @s add zx.ft_hit3
execute as @e[tag=zx.ft_lk] if score @s zx.ft_n = #ft_iid zx.meta if score @s zx.ft_cn matches 2.. run tag @s add zx.ft_hit3
execute unless entity @e[tag=zx.ft_hit2,limit=1] unless entity @e[tag=zx.ft_hit3,limit=1] run return 0

# ⑩ 打过去(真实伤害); 以主目标为圆心 —— 相连者必在同维度
#   甲：单丝组（基础 0.3 / 超限 0.5）
data modify storage zx:in arg set value {target:"@e[tag=zx.ft_hit2,distance=0..]",damage:0.0,type:"sweetdream:true_damage"}
data modify storage zx:in arg.damage set from storage zx:work ft.dmg1
execute at @e[tag=zx.ft_wt,limit=1] run function sweetdream:api/damage
#   乙：双丝组（超限 0.8）
execute if entity @e[tag=zx.ft_hit3,limit=1] run data modify storage zx:in arg set value {target:"@e[tag=zx.ft_hit3,distance=0..]",damage:0.0,type:"sweetdream:true_damage"}
execute if entity @e[tag=zx.ft_hit3,limit=1] run data modify storage zx:in arg.damage set from storage zx:work ft.dmg2
execute if entity @e[tag=zx.ft_hit3,limit=1] at @e[tag=zx.ft_wt,limit=1] run function sweetdream:api/damage

# ⑪ 次数 +1(记在玩家身上 -> 整条丝共用)
scoreboard players add @s zx.ft_got 1

# ⑫ 表现: 丝线被扯动一下
execute at @e[tag=zx.ft_hit2,limit=1] run particle minecraft:dust{color:[0.75,0.1,0.2],scale:1.4} ~ ~1 ~ 0.4 0.5 0.4 0.02 16 normal
execute at @e[tag=zx.ft_hit2,limit=1] run playsound minecraft:block.amethyst_block.resonate player @a ~ ~ ~ 0.5 1.7
execute at @e[tag=zx.ft_hit3,limit=1] run particle minecraft:dust{color:[1.0,0.18,0.28],scale:1.6} ~ ~1 ~ 0.4 0.5 0.4 0.02 18 normal
execute at @e[tag=zx.ft_hit3,limit=1] run playsound minecraft:block.amethyst_block.resonate player @a ~ ~ ~ 0.6 1.9

# ⑬ 收尾(本刻现打的临时标签一律摘掉)
tag @e[tag=zx.ft_wt] remove zx.ft_wt
tag @e[tag=zx.ft_hit2] remove zx.ft_hit2
tag @e[tag=zx.ft_hit3] remove zx.ft_hit3
