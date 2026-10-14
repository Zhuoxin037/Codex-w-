# ============================================================
# sweetdream:core/tick —— 每游戏刻执行
# ------------------------------------------------------------
# 【谁调用它】data/minecraft/tags/function/tick.json
# 【现在做四件事】都靠"先筛人/筛实体再干活", 没参与的对象开销为零:
#   · 把"自撤销型"进度整体归零(安全网, 见下)
#   · 给开着数值面板的玩家刷新动作栏(标签 @a[tag=test_look_on])
#   · 推横刀的突进(分数 zx.dash >= 1 的玩家)
#   · 推法球(场上所有 zx.ball)
# 【以后加东西】每刻的逻辑写这里; 每秒的逻辑建议挂到 #manacore:event/second。
# ============================================================

# ★ 安全网: 把"自撤销型"进度整体撤销一遍(每刻) ★
#   一次性的技术类进度(打到生物 / 使用物品 / 受击 …)必须先被撤销, 下次事件
#   才会重新授予 —— 正常情况下奖励函数第一行就自己 revoke 了, 那时这里完全是
#   空操作(撤销一条没授予的进度 = 什么都不发生)。它只在一个死角里起作用:
#   **奖励函数被跳过**(该刻命令预算打满 65536 条, 排在后面的函数整段不跑),
#   此时 revoke 不会执行, 进度永久卡在"已授予" -> 对应效果静默失效、
#   一个字都不报。真实事故 2026-10-04 04:08:55: upgrade/attack 卡住 ->
#   魔力增殖 α/β/Ω 的攻击回魔全死, 玩家描述为"升级失效了"。
#   【为什么放每刻 + 最前面】① 每刻跑才有意义 —— 那次事故恰恰发生在"每秒"
#     这一次没轮到的 tick 上; ② 它是兜底, 不能排在下面这些重活后面被拖累。
#   【开销】32 条 revoke, 相对 65536 的预算可忽略; 正常情况全是空操作。
#   清单在 lib/rearm; check.py 规则 27 盯着它的完整性。
function sweetdream:lib/rearm

# ============================================================
# ★★ 调色盘(2026-10-07 批3): “色彩”每刻推进(到点自毁 / 出界 / 追最近生物 / 移动 / 命中结算)
# ------------------------------------------------------------
# 【★ 为什么必须排在最前面(紧跟 rearm)★】
#   2026-10-08 用户报: "调色盘的自定义生物不会自己打人, 生成就呆在原地不动, 而且消除不掉"。
#   离线读存档查到的**核心事实**: 那个光球的寿命计分项**一帧都没减过**、
#   zx.pal_n 也没有分数 —— 即"推进段一次都没跑到过它"。
#   症状与"这一段整段没轮到"完全一致: core/tick 后面越堆越多, 一旦某刻命令预算打满,
#   **排在后面的整段静默跳过**(见上面 rearm 头部那起 2026-10-04 事故)。“色彩”的
#   全部行为(出界自毁/追/打/到点收尾)都在这段里, 被跳过 = 光球死机且永不消失。
#   ⇒ 提到最前面, 与 rearm 同级, 不再被后面的重活拖累。
#   【★ 现在没有"每秒兜底"了 ★】原来还挂过一条 `palette/second` 的每秒兜底, 2026-10-08 已删:
#     ① 它当时唯一的作用是"按 30 秒兜底寿命收尾", 而用户明确不要时间限制(见 color_body ①);
#     ② 于是本段成了"色彩"**唯一**的每刻驱动 —— 放最前面这件事因此更要紧。
#     (真要手工清场: 退世界重进 / `/reload`, core/load 末尾会 kill @e[tag=zx.pal_col]。)
# 【★ 选择器**只按标签**, 不写 type= ★】
#   光球的实体类型已经变过一次(marker -> item_display, 2026-10-08), 每次都回来改
#   这里的 type= 就是给自己埋雷(改了 A 忘了 B ⇒ 整段匹配不到零个实体, 而且零日志)。
#   按标签认人就没有这个问题。
# 【★ 三维度各写一遍 + 每行 distance=0.. ★】#minecraft:tick 只在主世界跑;
#   裸 @e 会跨维度搜索 —— 不锁维度的话同一个“色彩”会被三行各推一次(飞 3 倍速 / 打 3 份伤害)。
# ============================================================
execute in minecraft:overworld as @e[tag=zx.pal_col,distance=0..] at @s run function sweetdream:equipment/staff/palette/color_tick
execute in minecraft:the_nether as @e[tag=zx.pal_col,distance=0..] at @s run function sweetdream:equipment/staff/palette/color_tick
execute in minecraft:the_end as @e[tag=zx.pal_col,distance=0..] at @s run function sweetdream:equipment/staff/palette/color_tick

# 超限·崩裂(2026-10-12 批 I1): 「裂缝锁」每刻一步 —— "在裂缝上的生物将无法离开裂缝"。
#   ★ 必须每刻: 一秒 20 刻, 生物一步就能跨出伤害半径(3 格), 放成每秒等于没锁。
#   ★ 选择器不带 type(裂缝是 item_display, 换型史见 fissure/field 头部)。
#   ★ 三维度各写一遍 + distance=0..(同调色盘/神裁领域)。
execute in minecraft:overworld as @e[tag=zx.fi_field,distance=0..] at @s run function sweetdream:equipment/axe/fissure/lock_tick
execute in minecraft:the_nether as @e[tag=zx.fi_field,distance=0..] at @s run function sweetdream:equipment/axe/fissure/lock_tick
execute in minecraft:the_end as @e[tag=zx.fi_field,distance=0..] at @s run function sweetdream:equipment/axe/fissure/lock_tick

# 【备份公共输入口】下面三套每刻逻辑都会写 manacore:in arg(观测镜要查术阵数量),
#   不还回去的话你在聊天栏手填的参数每刻都被冲掉 —— 见 lib/in_bak。
function sweetdream:lib/in_bak

execute as @a[tag=test_look_on] run function sweetdream:equipment/tool/look/render

# 横刀突进: 只有分数 >= 1 的玩家参与, 平时完全不参与(开销为零)
execute as @a[scores={zx.dash=1..}] at @s run function sweetdream:equipment/sword/hengdao/dash_tick

# 无息(2026-10-07 批1): 向前突击 8 格(16 步 × 0.5), 撞生物不停、只被终点/障碍物拦下
#   停下由 dash_end 打去程一击(×0.1) + 起归位; 同样只筛有分数的玩家。
execute as @a[scores={zx.hush=1..}] at @s run function sweetdream:equipment/sword/hush/dash_tick

# 无息 · 归位(2026-10-07 批1): 每刻朝原点 marker 迈 2 格, 约 0.2 秒闪回
#   到点/倒计时耗尽由 back_finish 收尾并打回程一击(×0.2)。只筛带标签的人。
execute as @a[tag=zx.hs_back] at @s run function sweetdream:equipment/sword/hush/back_step

# 回锋(2026-10-07 批1): 主动的"每 0.35 秒重复一次"倒计时(zx.rb_t 7->0 = 7 刻)
#   ★ 筛 `zx.rb_t=1..` 是天然停摆: 打完最后一段就停在 0, 不再被选中, 不用额外清标签。
#   必须在 lib/in_restore 之前 —— tick_step 里的 recalc 要用公共输入口 manacore:in arg。
execute as @a[scores={zx.rb_t=1..}] at @s run function sweetdream:equipment/sword/rebound/tick_step

# 缺月(2026-10-12 批11): 主动"冻结窗"的每刻驱动(zx.cr_t 120->0 = 6 秒)
#   ★ 为什么必须**每刻**: 冻结 = 每刻把被冻结技能的剩余冷却顶回原值
#     (api/cooldown/increase 1 tick)。每秒做一次会漏掉 19/20 的刻 —— 那就不是冻结,
#     而是"冷却照常走"(与坑 120"干活频率 ≠ 持续时间"同源)。
#   ★ 筛 `zx.cr_t=1..` 是天然停摆: 窗归零后 freeze_end 收尾, 玩家不再被选中。
#   必须在 lib/in_restore 之前 —— freeze_tick/freeze_end 里的 calc 要用公共输入口。
execute as @a[scores={zx.cr_t=1..}] at @s run function sweetdream:equipment/sword/crescent/freeze_drive

# 沉锚(2026-10-12 批11): 主动"牵引"的每刻驱动(zx.an_pull 14->0 = 0.7 秒)
#   ★ 为什么必须**每刻**: 用户拍板"拉近要有过程, 不要瞬移"= 位置得每刻变一小段;
#     每秒跑一次就成了一秒一跳的"瞬移三连"。0.5 格/刻 = 10 格/秒。
#   ★ 筛 `zx.an_pull=1..` 是天然停摆: 停下那刻 pull_end 把分数清零, 玩家不再被选中。
#   必须在 lib/in_restore 之前 —— pull_end -> impact 里的 calc 要用公共输入口 manacore:in arg。
execute as @a[scores={zx.an_pull=1..}] at @s run function sweetdream:equipment/axe/anchor/pull_tick

# 圣骸: 主/副手回调维护, 不扫描/猜测附近尸体。
execute as @a at @s run function sweetdream:equipment/axe/sacred_relic/watch
# 每次施法独立计时, 每隔准确 20 刻结算; 12 跳后停。先结算最后一跳, 再清到期遗骸。
execute as @a[scores={zx.sr_on=1..}] at @s if score @s zx.sr_next <= #now manacore.meta run function sweetdream:equipment/axe/sacred_relic/second
execute in minecraft:overworld as @e[type=minecraft:marker,tag=zx.sr_w,distance=0..] at @s run function sweetdream:equipment/axe/sacred_relic/watch_dead with entity @s data
execute in minecraft:the_nether as @e[type=minecraft:marker,tag=zx.sr_w,distance=0..] at @s run function sweetdream:equipment/axe/sacred_relic/watch_dead with entity @s data
execute in minecraft:the_end as @e[type=minecraft:marker,tag=zx.sr_w,distance=0..] at @s run function sweetdream:equipment/axe/sacred_relic/watch_dead with entity @s data
execute in minecraft:overworld as @e[tag=zx.sr_relic,distance=0..] at @s run function sweetdream:equipment/axe/sacred_relic/relic_tick
execute in minecraft:the_nether as @e[tag=zx.sr_relic,distance=0..] at @s run function sweetdream:equipment/axe/sacred_relic/relic_tick
execute in minecraft:the_end as @e[tag=zx.sr_relic,distance=0..] at @s run function sweetdream:equipment/axe/sacred_relic/relic_tick

# 圣骸(2026-10-12 批11): 「遗骸」的常亮表现(每刻) —— marker 天生隐形, 不每刻铺粒子
#   玩家根本看不见遗骸(粒子寿命 < 1 秒, 每秒一次 = 20 帧里只有 1 帧)。
#   ★ 三维度各写一遍 + 每行 distance=0..: #minecraft:tick 只在主世界跑, 裸 @e 会跨维度重复处理。
#   ★ 只管表现; 计时/寿命仍在 lib/second 的 relic_tick(每秒)。

# 红莲(2026-10-07 批2): 主动"每 0.35 秒推一段"倒计时(zx.rl_t 7->0 = 7 刻)
#   ★ 用户口径: 多段都依次隔 0.35 秒(同刻打完会被受伤无敌帧吃掉, 等于只有第一下掉血)。
#   ★ 筛 `zx.rl_t=1..` 是天然停摆: 打完最后一段就停在 0, 不再被选中, 不用额外清标签。
#   必须在 lib/in_restore 之前 —— tick_step 里的 recalc 要用公共输入口 manacore:in arg。
execute as @a[scores={zx.rl_t=1..}] at @s run function sweetdream:equipment/axe/red_lotus/tick_step

# 负离子·超限(2026-10-09 批 F1): "1 秒后那道雷"的每刻倒计时(zx.an_2nd 20->0)
#   ★ 为什么挂每刻而不是每秒: 每秒扫会把"1 秒后"落成 1~2 秒之间某一刻(同永霜那条)。
#   ★ 筛 `zx.an_2nd=1..` 是天然停摆: 放完就减到 0, 不再被选中, 不用额外清。
#   必须在 lib/in_restore 之前 —— second_strike 里的 calc 要用公共输入口 manacore:in arg。
execute as @a[scores={zx.an_2nd=1..}] at @s run function sweetdream:equipment/axe/anion/second_strike

# 苍蓝星(2026-10-07 批2): 主动第 2 段的 0.35 秒倒计时(zx.as_d 7->0 = 7 刻)
#   ★ 用户口径: 主动两段依次隔 0.35 秒(同刻第二段会被受伤无敌帧吃掉)。
#   ★ 筛 `zx.as_d=1..` 是天然停摆: 落地后 tick_step 统一把它清 0, 不再被选中。
#   必须在 lib/in_restore 之前 —— tick_step 里的 recalc2 要用公共输入口 manacore:in arg。
execute as @a[scores={zx.as_d=1..}] at @s run function sweetdream:equipment/axe/azure_star/tick_step

# 葬火(2026-10-07 批2): 第二段的 2 秒倒计时(40 -> 0, 归零在 pyre/boom 结算)
#   ★ 筛 zx.py_d=1.. 是天然停摆: 归零后不再被选中(boom 里会把 pyre_x 清 0, 观测镜「葬火」段随之消失)。
#   必须在 lib/in_restore 之前 —— boom 会走 api/damage(它要用公共输入口)。
execute as @a[scores={zx.py_d=1..}] at @s run function sweetdream:equipment/axe/pyre/tick

# 威霆(2026-10-07 批2): 「天煌」每刻 +1(上限 2000; 手持威霆且本刻没攻击到生物)
#   没拿威霆时 passive 第一行就 return, 开销可忽略。
execute as @a run function sweetdream:equipment/axe/thunderclap/passive

# 威霆(2026-10-07 批2): 落雷表现 —— 每刻替"落雷排期" marker 劈**一道**真闪电
#   ★ 2026-10-07 用户定: "真召唤闪电实体"(视觉上一道一道劈下来)。
#     bolt_go 每次结算攻击放一个 marker(zx.tc_bs = 还剩几道), 这里每刻劈一道、剩余 -1,
#     劈完 bolt_fx 自己 kill 掉 marker。
#   【★ 三维度各写一遍 + 每行 distance=0.. ★】#minecraft:tick 只在主世界跑;
#     而裸 @e 会跨维度搜索 —— 不锁维度同一道排期会被三行各推一次(劈 3 倍闪电)。
execute in minecraft:overworld as @e[type=minecraft:marker,tag=zx.tc_strike,distance=0..] at @s run function sweetdream:equipment/axe/thunderclap/bolt_fx
execute in minecraft:the_nether as @e[type=minecraft:marker,tag=zx.tc_strike,distance=0..] at @s run function sweetdream:equipment/axe/thunderclap/bolt_fx
execute in minecraft:the_end as @e[type=minecraft:marker,tag=zx.tc_strike,distance=0..] at @s run function sweetdream:equipment/axe/thunderclap/bolt_fx

# 共鸣(2026-10-07 批3): "自身法球穿过共鸣水晶" —— 每刻扫水晶, 看有没有自己人的法球进来
#   【为什么每刻】"穿过时立即"是刻级事件(法球每刻飞 0.75 格), 每秒轮询会漏。
#   【★ 注意】pass_set 内部会把"找球"的 distance 基准**抬高 1.6 格**(水晶召唤在脚底、
#     法球飞在眼睛高度, 三维 distance 光高度差就 >1.5 ⇒ 不抬恒不成立)。见 pass_set 头注释。
#   【★ 三维度各写一遍 + 每行 distance=0.. ★】#minecraft:tick 只在主世界跑;
#     裸 @e 会跨维度搜索 —— 不锁维度的话同一颗水晶会被三行各判一次(可能多打一份)。
execute in minecraft:overworld as @e[type=minecraft:marker,tag=zx.ch_cry,distance=0..] at @s run function sweetdream:equipment/staff/chime/pass_check
execute in minecraft:the_nether as @e[type=minecraft:marker,tag=zx.ch_cry,distance=0..] at @s run function sweetdream:equipment/staff/chime/pass_check
execute in minecraft:the_end as @e[type=minecraft:marker,tag=zx.ch_cry,distance=0..] at @s run function sweetdream:equipment/staff/chime/pass_check

# 风帆(2026-10-08 改): 旋风的**形状**每刻画一帧(三条螺旋臂 + 漏斗收缩, 见 whirl_draw)
#   【为什么必须每刻】每秒只闪一次 = "一团粒子凭空出现又消失", 转不起来;
#     角度 zx.sl_a 每刻 +6 度, 60 刻(3 秒)转满一圈, 这才像旋风。
#   【★ 三维度各写一遍 + 每行 distance=0.. ★】#minecraft:tick 只在主世界跑;
#     裸 @e 会跨维度搜索 —— 不锁维度的话同一个旋风会被三行各画一次(转 3 倍速)。
#   【颜色】跟着"最近一次附着了哪种属性"走: 流火鲜红 / 渊海深蓝 / 白昼梦粉 / 噬心黑。
execute in minecraft:overworld as @e[type=minecraft:marker,tag=zx.sl_vtx,distance=0..] at @s run function sweetdream:equipment/staff/sail/whirl_fx
execute in minecraft:the_nether as @e[type=minecraft:marker,tag=zx.sl_vtx,distance=0..] at @s run function sweetdream:equipment/staff/sail/whirl_fx
execute in minecraft:the_end as @e[type=minecraft:marker,tag=zx.sl_vtx,distance=0..] at @s run function sweetdream:equipment/staff/sail/whirl_fx

# 释梦(2026-10-07 批2; 2026-10-08 修"不同入梦体还是追同一只"):
#   ①【占位标记每刻重建】zx.dr_claim 由**已绑定的入梦体**在自己的 pet_follow 里重新盖回来
#      (先在上面三行清掉) —— 所以"占位"永远跟着真正在追它的那一个走, 不会留在死物上。
#   ②【★ 必须分两遍跑, 顺序锁死 ★】先"已绑定(带 zx.dr_has)"的, 再"未绑定"的:
#      若未绑定的先跑, 它会赶上"占位刚被清、老入梦体还没重建"的空窗, 把老入梦体的目标
#      抢走(又变回"两个追同一只")。见 pet_tick 头注释。
#   【★ 三维度各写一遍 + 每行 distance=0.. ★】#minecraft:tick 只在主世界跑;
#     而裸 @e 会跨维度搜索 —— 不锁维度的话同一只入梦体会被三行各推一次(飞 3 倍速)。
execute in minecraft:overworld run tag @e[distance=0..,tag=zx.dr_claim] remove zx.dr_claim
execute in minecraft:the_nether run tag @e[distance=0..,tag=zx.dr_claim] remove zx.dr_claim
execute in minecraft:the_end run tag @e[distance=0..,tag=zx.dr_claim] remove zx.dr_claim
execute in minecraft:overworld as @e[distance=0..,tag=zx.dr_pet,tag=zx.dr_has] at @s run function sweetdream:equipment/axe/dream_reader/pet_tick
execute in minecraft:the_nether as @e[distance=0..,tag=zx.dr_pet,tag=zx.dr_has] at @s run function sweetdream:equipment/axe/dream_reader/pet_tick
execute in minecraft:the_end as @e[distance=0..,tag=zx.dr_pet,tag=zx.dr_has] at @s run function sweetdream:equipment/axe/dream_reader/pet_tick
execute in minecraft:overworld as @e[distance=0..,tag=zx.dr_pet,tag=!zx.dr_has] at @s run function sweetdream:equipment/axe/dream_reader/pet_tick
execute in minecraft:the_nether as @e[distance=0..,tag=zx.dr_pet,tag=!zx.dr_has] at @s run function sweetdream:equipment/axe/dream_reader/pet_tick
execute in minecraft:the_end as @e[distance=0..,tag=zx.dr_pet,tag=!zx.dr_has] at @s run function sweetdream:equipment/axe/dream_reader/pet_tick

# 万念 / 千散 的延迟换手: 只对刚预约过的玩家跑(标签 zx.mq_swap, 见 myriad/swap)
#   为什么必须排队等几 tick: 通用回手线会在 +1 tick 把备份塞回手里, 换早了会被覆盖。
execute as @a[tag=zx.mq_swap] run function sweetdream:equipment/sword/myriad/swap

# 超限·万念: 「剑魂」的绕身视觉 —— 只对身上有剑魂的玩家跑(每刻, 每秒画会闪)
#   计分板 zx.mq_soul 就是剑魂数(0 个时选择器全空, 开销为零)。
execute as @a[scores={zx.mq_soul=1..}] run function sweetdream:equipment/sword/myriad/soul_fx

# 超限·万念: 「领域」的边界圈 —— 视觉每刻画, 寿命那部分留给 ol_second 每秒扣
#   【★ 三维度各写一遍 + 每行 distance=0.. ★】#minecraft:tick 只在主世界跑;
#     裸 @e 会跨维度搜索 —— 不锁维度的话同一个领域会被三行各画一次(转 3 倍速)。
#   【为什么不画 Shoebox】domain_tick 每秒一次不够看的: 20 fps 里只有 1 帧有点,
#     那就等于"看不见领域"(全套机制的边界判据, 看不见就没法玩)。
execute in minecraft:overworld as @e[type=minecraft:marker,tag=zx.mq_f,distance=0..] at @s run function sweetdream:equipment/sword/myriad/domain_fx
execute in minecraft:the_nether as @e[type=minecraft:marker,tag=zx.mq_f,distance=0..] at @s run function sweetdream:equipment/sword/myriad/domain_fx
execute in minecraft:the_end as @e[type=minecraft:marker,tag=zx.mq_f,distance=0..] at @s run function sweetdream:equipment/sword/myriad/domain_fx

# 深海的回响 · 待机与施法通道互斥；两手持剑的玩家只推进一次待机相位。
execute as @a[tag=!zx.de_cast] if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["deepsea_echo"]}] run function sweetdream:equipment/sword/deepsea_echo/anim/idle_tick
execute as @a[tag=!zx.de_cast] unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["deepsea_echo"]}] if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["deepsea_echo"]}] run function sweetdream:equipment/sword/deepsea_echo/anim/idle_tick
execute as @a[tag=zx.de_cast] run function sweetdream:equipment/sword/deepsea_echo/anim/tick

# 极光与幻梦 · 月蚀流光模型动画接线
execute as @a[tag=!zx.ad_cast] if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["aurora_dream"]}] run function sweetdream:equipment/sword/aurora_dream/anim/idle_tick
execute as @a[tag=!zx.ad_cast] unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["aurora_dream"]}] if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["aurora_dream"]}] run function sweetdream:equipment/sword/aurora_dream/anim/idle_tick
execute as @a[tag=zx.ad_cast] run function sweetdream:equipment/sword/aurora_dream/anim/tick
# 极光与幻梦 · 月蚀流光模型动画接线 / END


# 深海的回响 · 连锁推进: 每人自己的倒计时 zx.de_t 归零就推一波(1 秒 = 20 tick)
#   【为什么不用 schedule】schedule 按函数名排队 + 默认 replace, 两个人同时放
#     会互相顶掉(水链少一波)。详见 cast ⑦ 的注释。
#   【顺序】先减 1 再判 <=0 —— 设 20 就正好 20 tick 后推进, 和原来的 1s 等价。
#   【开销】只对带 zx.de_run 的玩家跑, 没施法时选择器全空。
#   【链断了会自己停】最后一波在 wave_go 里调 finish, finish 摘掉 zx.de_run。
execute as @a[tag=zx.de_run] run scoreboard players remove @s zx.de_t 1
execute as @a[tag=zx.de_run,scores={zx.de_t=..0}] at @s run function sweetdream:equipment/sword/deepsea_echo/wave_self

# 冷冻: TicksFrozen 每 tick 会自己 -2(离开粉雪就衰减), 这里帮被冻住的生物续回 140,
#   这样"冻 N tick"就是真的 N tick(见 lib/freeze_hold)。
#   只对带 zx.freeze 的生物跑, 没冻住东西时开销为零。
execute in minecraft:overworld as @e[distance=0..,tag=zx.freeze] run function sweetdream:lib/freeze_hold
execute in minecraft:the_nether as @e[distance=0..,tag=zx.freeze] run function sweetdream:lib/freeze_hold
execute in minecraft:the_end as @e[distance=0..,tag=zx.freeze] run function sweetdream:lib/freeze_hold

# 永霜 到点结算(2026-10-08: 从 lib/second 挪到这里)
#   ★ 为什么必须每 tick: 冰冻写的是 60 tick(3 秒), 但原来只有每秒扫一次的
#     lib/second 会去判"到点没" ⇒ 实际 3~4 秒才结算, 玩家体感"冻太久了"。
#     这里每 tick 判一次, 3 秒就是 3 秒。开销可忽略(只对正在施法的玩家)。
execute as @a[tag=zx.ef_casting] at @s run function sweetdream:equipment/sword/everfrost/hit_self

# 法球(法杖类普攻的载体): 场上没有法球时这个选择器是空的, 开销为零
#   为什么不用 @a 而是 @e: 法球是 minecraft:marker, 要靠它自己带的数据飞,
#   和"谁在拿着法杖"无关 —— 发射出去之后你切武器、走开都不影响它。
execute in minecraft:overworld as @e[distance=0..,tag=zx.ball] at @s run function sweetdream:projectile/ball/tick with entity @s data
execute in minecraft:the_nether as @e[distance=0..,tag=zx.ball] at @s run function sweetdream:projectile/ball/tick with entity @s data
execute in minecraft:the_end as @e[distance=0..,tag=zx.ball] at @s run function sweetdream:projectile/ball/tick with entity @s data

# 三形态法杖 · 强化重枪「抗性提升失效 2 秒」(2026-10-13 用户拍板按文案做成真·2 秒):
#   每刻替带 zx.tri_nores 的目标清一次抗性提升, 并扣 1 刻倒计时, 到点摘标签。
#   【为什么每刻】原版没有"禁止获得效果"的设施, "失效 2 秒"只能靠反复清除实现;
#     若每秒清一次, 中间最多 1 秒的空档里抗性是**真的生效**的 ⇒ 与文案不符。
#   【开销】选择器带标签门控, 没人被重枪打中时完全为空 —— 不会每刻扫全部实体。
#   【★ 三维度各写一遍 + 每行 distance=0.. ★】#minecraft:tick 只在主世界跑;
#     裸 @e 会跨维度搜索 —— 不锁维度的话同一只目标会被三行各推一次(倒计时 3 倍速)。
execute in minecraft:overworld as @e[distance=0..,tag=zx.tri_nores] at @s run function sweetdream:equipment/staff/triad/nores_tick
execute in minecraft:the_nether as @e[distance=0..,tag=zx.tri_nores] at @s run function sweetdream:equipment/staff/triad/nores_tick
execute in minecraft:the_end as @e[distance=0..,tag=zx.tri_nores] at @s run function sweetdream:equipment/staff/triad/nores_tick

# 标签位置每 2 tick 更新；完整状态校验固定每 20 tick，跨原版三维度。
scoreboard players add #icon_t zx.meta 1
execute if score #icon_t zx.meta matches 2.. run function sweetdream:tag/follow_all
execute if score #icon_t zx.meta matches 2.. run scoreboard players set #icon_t zx.meta 0
scoreboard players add #tag_clock zx.meta 1
execute if score #tag_clock zx.meta matches 20.. run function sweetdream:tag/second
execute if score #tag_clock zx.meta matches 20.. run scoreboard players set #tag_clock zx.meta 0

# 标签图标淡出: 到点的标签摘掉后, 图标不是"啪"地消失, 而是逐帧降透明度 + 缩小再收掉。
#   两个驱动各管一件事(只在淡出期间跑, 平时选择器全空):
#     · as @e[tag=zx.icon_fading]            -> tag/icon_fade_icon: 逐帧淡出 + 到点 kill。
#       从**图标侧**驱动: 生物中途死亡时图标仍能自己淡完, 不留孤儿。
#     · as @e[tag=zx.icon_fading_owner] at @s -> tag/icon_fade: 淡出期间继续贴到头顶。
#       生物这时已不在 zx.tagged 里、跟随循环不管它, 不补这条图标会被甩在原地。
#       ★ at @s 不能省: icon_fade_go 用 `at @s anchored eyes` 取头顶位置。
#   ★ 三维度各写一遍，并用 distance=0.. 限定维度；裸 @e 会跨维度重复处理。
execute in minecraft:overworld as @e[distance=0..,tag=zx.icon_fading] run function sweetdream:tag/icon_fade_icon
execute in minecraft:the_nether as @e[distance=0..,tag=zx.icon_fading] run function sweetdream:tag/icon_fade_icon
execute in minecraft:the_end as @e[distance=0..,tag=zx.icon_fading] run function sweetdream:tag/icon_fade_icon
execute in minecraft:overworld as @e[distance=0..,tag=zx.icon_fading_owner] at @s run function sweetdream:tag/icon_fade
execute in minecraft:the_nether as @e[distance=0..,tag=zx.icon_fading_owner] at @s run function sweetdream:tag/icon_fade
execute in minecraft:the_end as @e[distance=0..,tag=zx.icon_fading_owner] at @s run function sweetdream:tag/icon_fade

# ★ 云迹: 补认"上一刻射出、但 shot 那一瞬还没进世界"的箭(坑 141)。
#   **必须排在下面打 zx.cc_seen 之前**: 箭一旦被补上 cc_seen 就再也认不出来了,
#   而 shot 的触发时机可能早于箭进世界 —— 这是唯一能补救的窗口。
#   【为什么只写一行 + 为什么不用三维度】`as @a[...] at @s` 给了位置基准, 后面的
#     @e 会被锁进玩家所在维度; 写三遍的话同一个玩家会被跑三次, zx.ct_seek 会被多扣。
execute as @a[scores={zx.ct_seek=1..}] at @s run function sweetdream:equipment/bow/cloudtrail/arrow_seek

# 寒鸦逐箭快照: 给"这一刻之前就已经存在的箭"都打上 zx.cc_seen。
#   【为什么要这么绕】想把"这一发的层数/伤害"绑到**具体某一支箭**上, 就必须在
#     射击那一刻把它认出来。按"离玩家最近的一支"认会被地上插着的老箭骗
#     (以前就是栽在这上面)。而 #minecraft:tick 跑在实体刻**之前**, 所以:
#       这一刻开始时 -> 场上所有旧箭都带 zx.cc_seen
#       同一刻稍后玩家扣扳机 -> 新箭出生, 它是**唯一**不带这个标签的
#     -> shot 里用 tag=!zx.cc_seen 就能精确抓到它(连多重射击的 3 支一起抓)
#   下一次 tick 开头再把它们补上标记, 循环继续。没参与时开销为零。
#   【为什么写三行 + 为什么每行都要 distance=0..】tick 函数的执行维度默认是主世界, 所以要三个维度各来一遍;
#     但**裸 @e 会跨维度搜索**(没有位置参数就搜全部维度) —— 三行都写裸 @e 的话, 同一支箭会被标记 3 次。
#     `distance=0..` 本身不过滤任何东西, 它的作用只是给选择器一个位置基准, 从而把搜索锁进当前维度。
execute in minecraft:overworld run tag @e[distance=0..,type=#sweetdream:cc_arrow,tag=!zx.cc_seen] add zx.cc_seen
execute in minecraft:the_nether run tag @e[distance=0..,type=#sweetdream:cc_arrow,tag=!zx.cc_seen] add zx.cc_seen
execute in minecraft:the_end run tag @e[distance=0..,type=#sweetdream:cc_arrow,tag=!zx.cc_seen] add zx.cc_seen

# 云迹: 「射击后若**未射中生物**, 则在箭停留位置生成一个持续 5 秒的半径 3 格的领域」。
#   判据 = inGround:1b(1.21.5 原版字段: 箭插进方块后变 1b; 同幽匿残响 se_live 那条,
#   见 RULES 第 32 条) —— 打中了生物的箭不会插地(而且 hook_arrow 会先摘掉 zx.ct_live),
#   所以"带 zx.ct_live 且 inGround"就是"落空"。
#   ★ field_spawn 建完领域会自己摘掉 zx.ct_live, 所以不会每刻重复建。
#   ★ 三维度各一行 + distance=0..(裸 @e 会跨维度搜索, 同一支箭会被处理 3 次)。
execute in minecraft:overworld as @e[distance=0..,tag=zx.ct_live,nbt={inGround:1b}] at @s run function sweetdream:equipment/bow/cloudtrail/field_spawn
execute in minecraft:the_nether as @e[distance=0..,tag=zx.ct_live,nbt={inGround:1b}] at @s run function sweetdream:equipment/bow/cloudtrail/field_spawn
execute in minecraft:the_end as @e[distance=0..,tag=zx.ct_live,nbt={inGround:1b}] at @s run function sweetdream:equipment/bow/cloudtrail/field_spawn

#   【为什么写三行】tick 函数执行维度默认主世界, 所以要三个维度各来一遍。
#   【★ 每行都要 distance=0.. ★】裸 @e 会跨维度搜索 —— 三行都写裸 @e 的话, 同一支箭每刻会被结算 3 次。
#   【为什么每刻】文案是"每刻造成伤害", 必须每 tick 结算; 没箭参与时选择器全空。
#   【为什么写三行】tick 函数执行维度默认主世界, @e 不跨维度。
execute in minecraft:overworld as @e[distance=0..,tag=zx.se_live] at @s run function sweetdream:equipment/bow/sculk_echo/tick_live
execute in minecraft:the_nether as @e[distance=0..,tag=zx.se_live] at @s run function sweetdream:equipment/bow/sculk_echo/tick_live
execute in minecraft:the_end as @e[distance=0..,tag=zx.se_live] at @s run function sweetdream:equipment/bow/sculk_echo/tick_live

# 清醒梦: 被标记生物的"受击额外真伤"(每刻扫, 靠 HurtTime 判挨打) —— 只对带 zx.ld_mark 的生物跑
#   【为什么每刻】"每次受到攻击"必须每 tick 才抓得准; 没被标记时选择器全空。
#   【★ at @s 不能省 ★】`as` 只换执行者、**不改坐标**。少了 at @s, hit_extra 里的
#     粒子会画在世界原点, 而 hit_extra_dmg 那句"2 格内全部生物"的选择器也在原点
#     取范围 —— 结果就是范围真伤一次都打不到人(玩家报"梦回触发后不生效")。
#     2026-10-05 修。旁边两条 zx.se_live / zx.freeze 同款, 后者的 freeze_hold
#     只用实体 NBT、确实用不到坐标, 但保持一致的写法更安全。
execute in minecraft:overworld as @e[distance=0..,tag=zx.ld_mark] at @s run function sweetdream:equipment/bow/lucid_dream/hit_extra
execute in minecraft:the_nether as @e[distance=0..,tag=zx.ld_mark] at @s run function sweetdream:equipment/bow/lucid_dream/hit_extra
execute in minecraft:the_end as @e[distance=0..,tag=zx.ld_mark] at @s run function sweetdream:equipment/bow/lucid_dream/hit_extra


# 霜矢:「箭打中了谁」由弩上自带的附魔回调(hook_arrow / hook_victim)交给原版判定

# 焚舟: 每刻推 烈空(只对穿着焚舟的人跑)
#   攻击命中时 hurt 里的 buff_on 也会写 manacore:in arg, 所以放在
#   in_restore 之前, 让这一整段都在公共输入口的备份保护里。
execute as @a[tag=zx.im_on] at @s run function sweetdream:equipment/armor/immolate/tick

# 余烬: 燃烧边沿检测 —— **每 5 刻一次**(不是每秒!)
#   【为什么提速】原来挂在 #manacore:event/second(20 刻), 而它是**边沿检测**:
#     火熄灭那一刻并不结算, 要等下一次心跳发现"上一轮有标记、这一轮 Fire=0"
#     ⇒ 延迟 0~1 秒、平均 0.5 秒。用户 2026-10-12: "每次燃烧结束都不能及时
#     上流火/夜火" ⇒ 拍板"更密集的周期" ⇒ 5 刻一次, 延迟 0~0.25 秒。
#   【为什么不再更密】每次扫描要给 9 格内每个实体读两次 Fire NBT;
#     5 刻 = 每秒 4 次已经是手感与开销的平衡点(再密收益递减、扫描开销线性涨)。
#   【分频】#now manacore.meta 每刻 +1(持久化 tick 计数), 对 #5 取模 = 0 的刻跑。
#     ★ 用取模而不是自己的倒数计数器: 不额外占一个需要初始化的常量,
#       且 #now 跨 /reload 连续, 不会因为重载而"卡在某一次不跑"。
#   【门控】zx.em_on 由 ember/second_one 每秒维护(穿上打、脱下摘);
#     没人穿余烬时 @a[tag=zx.em_on] 是空集, 这一行零开销。
#     ⚠️ 副作用: 刚穿上那一秒还没打上标签, 高频扫描要等下一次秒心跳才开始 ——
#        与焚舟 zx.im_on 同款, 可接受。
scoreboard players operation #em_t zx.meta = #now manacore.meta
scoreboard players operation #em_t zx.meta %= #5 zx.meta
execute if score #em_t zx.meta matches 0 as @a[tag=zx.em_on] at @s run function sweetdream:equipment/armor/ember/scan_one

# 焱(2026-10-08): 「视为金甲」—— 每刻掐掉猪灵挑"不穿金甲的人"的那条通道
#   【必须每刻】猪灵的 NEAREST_TARGETABLE_PLAYER_NOT_WEARING_GOLD 记忆由
#     NearestPlayersSensor 每 20 刻刷一次; 秒级清完它下一刻就填回来 = 白清。
#   【开销】pig_tick 第一行就是"穿着"门控, 没穿焱的人一步都不往下走。
#   【注意】它只写自己的节点 zx:work ba, 不碰公共输入口, 不用 in_bak 保护。
execute as @a at @s run function sweetdream:equipment/armor/blaze_armor/pig_tick

# 天穹: 跃升(每刻抬 0.5 格, 共 12 刻 = 6 格 ≈ 0.6 秒) + 跃升倒计时 + 俯冲推进
#   【为什么放每刻】俯冲要 20 fps 才顺; 跃升也要逐刻才有"看得见的上升过程"。
#   只对带 tag 的人跑, 没参与时选择器全空。
#   顺序: 先抬一格(步数 1..12) -> 步数 +1 -> 超过 12 就到顶转"可俯冲"。
#   【速率配套改】步数上限(12) 要跟 rise_step 的每刻高度(0.5) 配套 = 6 格。
execute as @a[tag=zx.sv_rising,scores={zx.sv_rise=1..10}] at @s run function sweetdream:equipment/axe/skyvault/rise_step
execute as @a[tag=zx.sv_rising] run scoreboard players add @s zx.sv_rise 1
execute as @a[tag=zx.sv_rising,scores={zx.sv_rise=11..}] at @s run function sweetdream:equipment/axe/skyvault/rise_end
execute as @a[tag=zx.sv_air,scores={zx.sv_launch=1..}] run scoreboard players remove @s zx.sv_launch 1
execute as @a[tag=zx.sv_dive] at @s run function sweetdream:equipment/axe/skyvault/dive_tick

# 天使核心: 两段技能之间的"间隔"倒计时(0.5 秒 = 10 tick), 到点放第二段
execute as @a[tag=zx.ac_delay] run scoreboard players remove @s zx.ac_d 1
execute as @a[tag=zx.ac_delay,scores={zx.ac_d=..0}] at @s run function sweetdream:equipment/axe/angel_core/dmg2

# 终末天启 · 光柱: 施法期间**每刻**刷新实体光柱(不是每秒! 见 beam 头注释)
#   【2026-10-07 改版】粒子 -> item_display 实体光柱(以撒风粗白光柱, 玩家口径)。
#     beam = 外壳(备 UUID), beam_go = 跟随(tp 到眼睛下 0.4/前方 10 + 继承朝向)
#     + 续命(zx.fr_ref 续到 3) + 按需生成; 寿命保险在下面那六行。
#   【为什么必须每刻】同前: 每秒一次 = 20 fps 里 19 帧不动, 光柱跟不上视线。
#   【跟随扫射】执行者是玩家本人、且用 at @s 把坐标+朝向都换成玩家的。
#   【★ 中心轴仍沿视线**下方**偏 0.4 格(^-0.4)】见 beam 文件头的坑 69:
#     与视线共线的光束在第一人称里投影成准星上的一个点 = **隐形**。
#     实体光柱一样是共线几何, 偏移不能省(0.35 -> 0.4: 光柱更粗了)。
#     判定(scan/伤害)不在这, 永远留准星轴上。
#   【开销】选择器带 zx.fr_t=1.., 没人在放光柱时这条完全不进函数。
execute as @a[scores={zx.fr_t=1..}] at @s run function sweetdream:equipment/staff/final_revelation/beam

# —— 偏振光 · 持续光线(2026-10-09 新增, 每刻) ——
# 【为什么每刻】同上: 粒子寿命 < 1 秒, 每秒只铺一次 = 20 fps 里只有 1 帧有东西,
#   看着"不算一条光线"。
# 【做什么】沿"眼睛 -> 锁定目标"每 0.4 格撒光点(见 polarized_light/beam);
#   顺带给照到的"自己人的共鸣水晶"打 zx.ch_beam 戳 -> 共鸣触发"法术穿过"。
# 【开销】选择器带 zx.pl_t=1.., 没人在放光线时这条完全不进函数。
execute as @a[scores={zx.pl_t=1..}] at @s run function sweetdream:equipment/staff/polarized_light/beam

# 偏振光超限(批 G): 三道光线的伤害节奏是"每 0.5 秒", 每秒入口跟不上 ——
#   由这里每刻推闸(half): 每 10 刻结算一次(锁 3 目标/伤害/缓慢Ⅲ), 每 20 刻再扣
#   1 秒(★ 倒计时按真实时间扣, 不在 tick 里扣 —— 坑 120: 在 tick 里扣会把"秒"当
#   "半秒", pl_t=5 只撑 2.5 秒, 与 lore 的"持续 5 秒"差一半)。
#   基础版仍走 second(zx.pl_ol=0), 两边互不见面, 不会双倍伤害。
execute as @a[scores={zx.pl_t=1..,zx.pl_ol=1}] at @s run function sweetdream:equipment/staff/polarized_light/half

# 海棠超限(批 G): 漩涡增强检测 —— "若有生物在漩涡范围内死亡"。
#   刚死的生物这一 tick 还在(Health:0.0f), 必须每刻查(每秒查会漏 19/20 的死亡)。
#   裸 @e[tag=zx.bg_vtx] 带不了 distance 就没有维度问题: 全维度每只漩涡各处理一次。
execute as @e[tag=zx.bg_vtx] at @s run function sweetdream:equipment/staff/begonia/vortex_death

# —— 终末天启 · 实体光柱的寿命保险(每刻, 三维度各一遍) ——
# 【续命制】放的时候 beam_go 每刻把光柱的 zx.fr_ref 续到 3; 这里每刻 -1,
#   扣到 0 自杀。收尾函数漏调 / 玩家中途退游戏 / 实体被手动杀 —— 无论哪种
#   断供, 光柱最多多活 3 刻, 不会变成永久孤儿(比在 end 里 kill 稳得多)。
# 【为什么三维度各一遍】裸 @e 跨维度搜索(坑 55); 带维度前缀逐维度扫才不串。
execute in minecraft:overworld as @e[type=item_display,tag=zx.fr_beam,distance=0..] run scoreboard players remove @s zx.fr_ref 1
execute in minecraft:the_nether as @e[type=item_display,tag=zx.fr_beam,distance=0..] run scoreboard players remove @s zx.fr_ref 1
execute in minecraft:the_end as @e[type=item_display,tag=zx.fr_beam,distance=0..] run scoreboard players remove @s zx.fr_ref 1
execute in minecraft:overworld as @e[type=item_display,tag=zx.fr_beam,distance=0..] if score @s zx.fr_ref matches ..0 run kill @s
execute in minecraft:the_nether as @e[type=item_display,tag=zx.fr_beam,distance=0..] if score @s zx.fr_ref matches ..0 run kill @s
execute in minecraft:the_end as @e[type=item_display,tag=zx.fr_beam,distance=0..] if score @s zx.fr_ref matches ..0 run kill @s


# 陨星: 熔星形态期间每刻检查"主手还是不是陨星", 换手立刻失效(见 meteor/tick)
execute as @a[scores={zx.mt_on=1..}] run function sweetdream:equipment/axe/meteor/tick

# 陨星(2026-10-08 批 D): 落下来的「陨石」每刻下降 + 到地炸开(见 meteor/rock_tick)
#   【为什么每刻】"从 7 格高 0.2 秒砸下来"要 20 fps 才不卡; 4 刻就落地, 秒级轮询等于看不见。
#   【★ 三维度各写一遍 + 每行 distance=0.. ★】#minecraft:tick 只在主世界跑;
#     而裸 @e 会跨维度搜索 —— 不锁维度的话同一颗陨石会被三行各推一次(3 倍速下落)。
#   【寿命】倒计时归零那刻自己 kill, 不需要额外的兜底计时。
execute in minecraft:overworld as @e[type=item_display,tag=zx.mt_rock,distance=0..] at @s run function sweetdream:equipment/axe/meteor/rock_tick
execute in minecraft:the_nether as @e[type=item_display,tag=zx.mt_rock,distance=0..] at @s run function sweetdream:equipment/axe/meteor/rock_tick
execute in minecraft:the_end as @e[type=item_display,tag=zx.mt_rock,distance=0..] at @s run function sweetdream:equipment/axe/meteor/rock_tick

# 威霆(2026-10-08 批 D): 「领域」实体跟着术阵走 —— 每刻扫一遍, 自己那座 marker
#   不在了就自杀。
#   【为什么不自己计时】领域的真相是术阵本身(半径 6 的判定用的也是 marker), 让领域
#     去数自己的秒数等于维护第二份真相, 两边任何一处断了都查不出来。改成"看术阵还在不在"
#     就永远不会错位: 术阵正常到点由 field_end 直接 kill(快路径), 这里只兜底
#     "marker 被非正常清掉"(例如手动 /kill、区块异常)。
#   【★ 2026-10-10 修 F17: 按 UUID 认亲, 不再用 distance=..2 ★】
#     领域生成时把"所属 marker 自身的 UUID"写进 data.zx.m, 这里查的就是**那一座**;
#     旧写法"附近 2 格内有没有 zx.tc_field"会把隔壁术阵的 marker 当成自己的,
#     让已经该收的孤儿领域永远活着(域模型残留)。
#   【三维度各写一遍】#minecraft:tick 只在主世界跑, 而 @e 只覆盖当前维度 ——
#     不这么写的话, 在下界/末地召唤的领域永远不会被兜底。distance=0.. 只用来锁维度。
execute in minecraft:overworld as @e[type=item_display,tag=zx.tc_dom,distance=0..] run function sweetdream:equipment/axe/thunderclap/domain_keep
execute in minecraft:the_nether as @e[type=item_display,tag=zx.tc_dom,distance=0..] run function sweetdream:equipment/axe/thunderclap/domain_keep
execute in minecraft:the_end as @e[type=item_display,tag=zx.tc_dom,distance=0..] run function sweetdream:equipment/axe/thunderclap/domain_keep

# 启示录: 每刻魔力快照(该武器位于快捷栏时) —— cooldown_start 观察者靠
#   "本刻开头的魔力 - 现在的魔力"算出这次技能实际消耗了多少蓝, 见 apocalypse/snap。
#   (#minecraft:tick 跑在实体刻之前 → 快照必然早于同一刻里发生的技能消耗)
#   "快捷栏有启示录"由 wand_check 每刻打 zx.ap_has 标签, snap 只对有标签的人跑。
execute as @a run function sweetdream:equipment/staff/apocalypse/wand_check
execute as @a[tag=zx.ap_has] run function sweetdream:equipment/staff/apocalypse/snap

#   ★ 三维度各写一遍, **且每行都要 distance=0..**: #minecraft:tick 只在主世界跑, 所以要三个维度各来一遍;
#     而裸 @e 会跨维度搜索 —— 不锁维度的话, 同一只朽木/暗潮会被三行各推一次(动画 3 倍速)。
#   · zx.anim       朽木破土升起 / 暗潮向四周扩散 / 两者的退场(沉回地里、退潮收拢);
#                   参数(field/track/key/dir)在实体自己的 data.zx.anim 里, 帧值查 zx:anim 表。
#   ★ 三维度各写一遍: #minecraft:tick 只在主世界跑, 而 @e 只覆盖当前维度 ——
#     不这么写的话, 在下界/末地召唤的朽木、暗潮会永远卡在起始帧(和法球、freeze_hold 同理)。
#   ★ 关键帧由服务端每刻下发, interpolation_duration 保持 0, 不靠客户端补间(见 lib/anim_step)。
execute in minecraft:overworld as @e[distance=0..,tag=zx.anim] at @s run function sweetdream:lib/anim_step with entity @s data.zx.anim
execute in minecraft:the_nether as @e[distance=0..,tag=zx.anim] at @s run function sweetdream:lib/anim_step with entity @s data.zx.anim
execute in minecraft:the_end as @e[distance=0..,tag=zx.anim] at @s run function sweetdream:lib/anim_step with entity @s data.zx.anim

# 雷鸣(thunder): 副手道具的"雷击连锁"
#   【为什么必须每刻】闪电实体只活几刻(拖尾一结束就没了), 用每秒轮询必然漏;
#     而"1 秒后再劈"也要求刻级精度。
#   【两道扫描, 平时都空转】① 到点的 marker -> 原地再劈; ② 新出现的闪电 -> 登记。
#   【★ 三维度各写一遍 + 每行 distance=0.. ★】#minecraft:tick 只在主世界跑,
#     所以要三个维度各来一遍; 而裸 @e 会跨维度搜索 —— 不锁维度的话同一道闪电
#     会被三行各处理一次(劈出 3 道雷)。distance=0.. 不过滤任何东西, 只用来锁维度。
execute in minecraft:overworld as @e[distance=0..,tag=zx.th_pend] at @s if score @s zx.th_due <= #now manacore.meta run function sweetdream:equipment/tool/thunder/pend_go
execute in minecraft:the_nether as @e[distance=0..,tag=zx.th_pend] at @s if score @s zx.th_due <= #now manacore.meta run function sweetdream:equipment/tool/thunder/pend_go
execute in minecraft:the_end as @e[distance=0..,tag=zx.th_pend] at @s if score @s zx.th_due <= #now manacore.meta run function sweetdream:equipment/tool/thunder/pend_go
execute in minecraft:overworld as @e[distance=0..,type=minecraft:lightning_bolt,tag=!zx.th_seen] at @s run function sweetdream:equipment/tool/thunder/strike
execute in minecraft:the_nether as @e[distance=0..,type=minecraft:lightning_bolt,tag=!zx.th_seen] at @s run function sweetdream:equipment/tool/thunder/strike
execute in minecraft:the_end as @e[distance=0..,type=minecraft:lightning_bolt,tag=!zx.th_seen] at @s run function sweetdream:equipment/tool/thunder/strike

# 引雷针(thunderrod, 2026-10-13 批 13): 普攻预约的那一道雷到期 —— 与雷鸣同形态,
#   只是到期后**不再新劈一道真闪电的连锁**(雷要劈在命中点, 由 pend_go 自己 summon)。
#   ★ pend_go 是宏函数(要拿 marker 里的主人 UUID 四个整数), 所以这里带
#     `with entity @s data.zx.tr` 把参数喂进去(宏源只能是调用时 with 的那一份)。
execute in minecraft:overworld as @e[distance=0..,tag=zx.tr_pend] at @s if score @s zx.tr_due <= #now manacore.meta run function sweetdream:equipment/staff/thunderrod/pend_go with entity @s data.zx.tr
execute in minecraft:the_nether as @e[distance=0..,tag=zx.tr_pend] at @s if score @s zx.tr_due <= #now manacore.meta run function sweetdream:equipment/staff/thunderrod/pend_go with entity @s data.zx.tr
execute in minecraft:the_end as @e[distance=0..,tag=zx.tr_pend] at @s if score @s zx.tr_due <= #now manacore.meta run function sweetdream:equipment/staff/thunderrod/pend_go with entity @s data.zx.tr

# 长明(everlit, 2026-10-13 批 13): 「灯灵」的**每刻表现**
#   ★ 表现必须每刻画(坑 147): 挂每秒 = 20 帧里只有 1 帧有粒子 => 肉眼看不见。
#     计时与结算在 lib/second(每秒), 这里只画粒子。
execute in minecraft:overworld as @e[distance=0..,tag=zx.el_wisp] at @s run function sweetdream:equipment/tool/everlit/wisp_fx
execute in minecraft:the_nether as @e[distance=0..,tag=zx.el_wisp] at @s run function sweetdream:equipment/tool/everlit/wisp_fx
execute in minecraft:the_end as @e[distance=0..,tag=zx.el_wisp] at @s run function sweetdream:equipment/tool/everlit/wisp_fx

# 调试用的 /trigger: 只有刚按过的人分数 >= 1, 平时三个选择器全空。
#   它也写 manacore:in arg(查数值/清冷却都要走前置包接口), 所以放在
#   in_restore 之前, 让这一整段都在公共输入口的备份保护里。
function sweetdream:debug/tg_router

# 烈火残躯：独立玩家姿态与短时回旋焰刃，三维度各推进一次。
execute as @a[tag=zx.fb_cast] at @s run function sweetdream:equipment/sword/flame_brokenbody/visual/tick
execute in minecraft:overworld as @e[type=minecraft:item_display,tag=zx.fb_fx,distance=0..] at @s run function sweetdream:equipment/sword/flame_brokenbody/visual/fx_tick
execute in minecraft:the_nether as @e[type=minecraft:item_display,tag=zx.fb_fx,distance=0..] at @s run function sweetdream:equipment/sword/flame_brokenbody/visual/fx_tick
execute in minecraft:the_end as @e[type=minecraft:item_display,tag=zx.fb_fx,distance=0..] at @s run function sweetdream:equipment/sword/flame_brokenbody/visual/fx_tick

execute as @a[tag=zx.av_cast] at @s run function sweetdream:equipment/axe/anchor/visual/tick
execute in minecraft:overworld as @e[type=minecraft:item_display,tag=zx.av_anchor,distance=0..] at @s run function sweetdream:equipment/axe/anchor/visual/world_tick
execute in minecraft:the_nether as @e[type=minecraft:item_display,tag=zx.av_anchor,distance=0..] at @s run function sweetdream:equipment/axe/anchor/visual/world_tick
execute in minecraft:the_end as @e[type=minecraft:item_display,tag=zx.av_anchor,distance=0..] at @s run function sweetdream:equipment/axe/anchor/visual/world_tick
execute as @a at @s run function sweetdream:equipment/axe/anchor/visual/idle
function sweetdream:lib/in_restore
