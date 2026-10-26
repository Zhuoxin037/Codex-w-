# ============================================================
# sweetdream:lib/second —— 公共件们的每秒入口(挂在 #manacore:event/second)
# ------------------------------------------------------------
# 【备份公共输入口】下面这些都会读/写 manacore:in arg, 见 lib/in_bak。
# ============================================================

# 【进度的安全网不在这里】lib/rearm 是"每刻"跑的, 挂在 core/tick 最前面, 不挂这里
#   —— 理由见那两个文件; 别在本文件里再调一次(会变成每刻 + 每秒各一次, 无意义)。

function sweetdream:lib/in_bak

# 【R06 兜底】还有待归还武器的玩家: 每秒重试一次回手 —— 覆盖"消耗后立刻掉线 /
#   当刻死亡重生 / 目标格临时被占"这三种漏网场景(原来只有 1 tick 后的一次机会)。
#   没有待归还的人不满足选择器 => 通常就是一次空转。详见 internal/itembackup/recover。
function sweetdream:internal/itembackup/recover

# 【R02 自愈】死亡重生会重建玩家实体: 原版属性修饰符丢、计分板账本还在 ⇒
#   差量账本算出 diff=0 永不补挂(静默)。这里按死亡计数探针, 死过且**已重生**
#   (活着)的玩家把"挂原版属性"的账本清/退, 下一秒按 want 重挂 —— 详见
#   lib/ledger_resync 头部。★ 为什么必须等活着: keepInventory 下死着的玩家
#   仍"穿着"装备, 死着清账本会被同一秒的重挂循环在旧实体上填回去(实测踩过)。
execute as @a run function sweetdream:lib/ledger_resync

# 【O02 面板缓存】观测镜面板的重数据(装备在身名单 / 手持武器 skill / 当前生命)
#   每秒缓存一次(见 equipment/tool/look/cache 头部说明) —— render_go 每刻只读缓存,
#   不再做任何 data ... entity 的全玩家 NBT 序列化。
execute as @a[tag=test_look_on] run function sweetdream:equipment/tool/look/cache

# 【O03 回手安全网】手里拿着 itemreplace 武器的人每秒快照一次(backup 内部有
#   if items 门, 没拿武器的人只是两条免费谓词)。真正"最准"的快照在消耗那一刻
#   (effect_1); 这条是兜底 —— 老版是每刻一条 tick 进度循环(O03 删除),
#   每秒一次足够: 快照内容在两次消耗之间不会变。
execute as @a run function sweetdream:internal/itembackup/backup_go

# 「最大魔力值技能倍率」通用加成(风声 / 忘川彼岸 / 无效)的每秒衰减 ——
#   2026-10-08: mm_add 改成"打出一次最大魔力值技能才清零", 不再需要每秒推进;
#   lib/mm_add/tick 那份文件已删(原来的按秒衰减作废, 见 lib/mm_add/take)。
#   ★ 只给"还有剩余秒数"的人跑(没有这个分数的人不必每小时都进去走一趟)。

# 冻结/时停到点解冻
# 流光: 每秒扫"到点结算"的人 —— 取代一次性 schedule, 多人同时施法不会互相顶掉(第 3 条)
execute as @a[tag=zx.lg_casting] at @s run function sweetdream:equipment/sword/liuguang/hit_self
# 超限·流光: 同上, 每秒扫"到点结算"的人(4 个目标的延迟伤害)
execute as @a[tag=zx.lgo_casting] at @s run function sweetdream:equipment/sword/liuguang/ol_hit_self

# 游星(2026-10-07 批1): 每秒扫"到点结算"的人 —— 锁定 3 秒后对被锁目标 2 格内全部生物打 基础攻击力×4
execute as @a[tag=zx.rs_casting] at @s run function sweetdream:equipment/sword/rogue_star/hit_self

# 红莲·超限(2026-10-09 批 F1): "流火雨"每秒一发 —— 给自身 5 格内的敌人挂「流火」
#   zx.rl_rain 起手 4(施法当刻 cast 已经发过一发) -> 一共 5 发 = 文案的"持续 5 秒"。
execute as @a[scores={zx.rl_rain=1..}] at @s run function sweetdream:equipment/axe/red_lotus/rain_tick

# 负离子·超限(2026-10-09 批 F1): "8 秒雷劲"窗口每秒 -1
#   (判定在 lib/on_lightning: 有这道分数就说明还在窗口里)
execute as @a[scores={zx.an_boost=1..}] run scoreboard players remove @s zx.an_boost 1

# 永霜: 2026-10-08 挪到 core/tick 每 tick 判 —— 原来放这儿(每秒扫)的话,
#   "冰冻 3 秒后结算"会变成"3~4 秒之间某个时刻才结算", 玩家体感就是冻太久。
#   (现在在 core/tick 里, 见那里"永霜 到点结算"那一行)

# 神裁(2026-10-07 批1): 「领域」每秒一跳 —— 领域内(半径 2)生物吃 基础攻击力×3;
#   领域是 marker 实体, 计时 zx.vd_ft 归零就 kill 自己。
#   ★ 三维度各写一遍 + 每行 distance=0.. (event/second 默认在主世界跑; 裸 @e 会跨维度重复处理)
execute in minecraft:overworld as @e[type=marker,tag=zx.vd_field,distance=0..] at @s run function sweetdream:equipment/sword/verdict/field_tick
execute in minecraft:the_nether as @e[type=marker,tag=zx.vd_field,distance=0..] at @s run function sweetdream:equipment/sword/verdict/field_tick
execute in minecraft:the_end as @e[type=marker,tag=zx.vd_field,distance=0..] at @s run function sweetdream:equipment/sword/verdict/field_tick

# 崩裂(2026-10-07 批2): 「裂缝」每秒一跳 —— 裂缝内(半径 3)全部生物吃 施放者基础攻击力×1;
#   裂缝是 **item_display**(2026-10-08 换型: 用户要贴图, 原为 marker), 计时 zx.fi_ft 归零就 kill 自己。
#   ★ 选择器**不带 type**: 换型后写死 `type=marker` 会让整段静默失效(2026-10-08 同步改过一次)。
#   ★ 三维度各写一遍 + distance=0..(同神裁领域)。
execute in minecraft:overworld as @e[tag=zx.fi_field,distance=0..] at @s run function sweetdream:equipment/axe/fissure/field_tick
execute in minecraft:the_nether as @e[tag=zx.fi_field,distance=0..] at @s run function sweetdream:equipment/axe/fissure/field_tick
execute in minecraft:the_end as @e[tag=zx.fi_field,distance=0..] at @s run function sweetdream:equipment/axe/fissure/field_tick

# 超限·电弧(2026-10-12 批 I1): 「放电锚」每秒一跳 —— 8 格内重判配对、3 格宽电线、
#   沿途与两端 1 格内伤害 + 落雷(都在 ol_fire); 计时 zx.arc_wt 归零由 ol_tick_go 收尾。
#   ★ 三维度各写一遍 + distance=0..(同神裁领域/崩裂裂缝)。
execute in minecraft:overworld as @e[type=marker,tag=zx.arc_w,distance=0..] at @s run function sweetdream:equipment/bow/arc/ol_tick
execute in minecraft:the_nether as @e[type=marker,tag=zx.arc_w,distance=0..] at @s run function sweetdream:equipment/bow/arc/ol_tick
execute in minecraft:the_end as @e[type=marker,tag=zx.arc_w,distance=0..] at @s run function sweetdream:equipment/bow/arc/ol_tick

# 超限·电弧: 配对两端的"放电窗口"计时(安全网) —— 锚先死时也保证窗口最多 3 秒。
#   见 ol_sweep 头部(两端是非玩家生物, 所以按维度扫 @e 而不是 @a)。
function sweetdream:equipment/bow/arc/ol_sweep

# 云迹(2026-10-12 批 11): 「领域」每秒一跳 —— 画一圈云气 + 计时 ct_ft -1, 归零 kill 自己。
#   ★ 三维度各写一遍 + distance=0..(同神裁领域 / 崩裂裂缝 / 电弧放电锚)。
execute in minecraft:overworld as @e[type=marker,tag=zx.ct_field,distance=0..] at @s run function sweetdream:equipment/bow/cloudtrail/field_tick
execute in minecraft:the_nether as @e[type=marker,tag=zx.ct_field,distance=0..] at @s run function sweetdream:equipment/bow/cloudtrail/field_tick
execute in minecraft:the_end as @e[type=marker,tag=zx.ct_field,distance=0..] at @s run function sweetdream:equipment/bow/cloudtrail/field_tick

# 爆裂黎明(2026-10-12 批 11): 「魂灵之影」每秒一跳 —— 魂火 + 3 秒攻击倒计时
#   + 索敌转移 + 寿命 bd_ft -1(归零消失)。实体是**铁傀儡**(不是 marker:
#   文案要"生命值 100"能被打掉, marker 没有生命值字段), 所以选择器按标签认人。
#   ★ 三维度各写一遍 + distance=0..(同云迹领域 / 威霆术阵 / 电弧放电锚)。
execute in minecraft:overworld as @e[tag=zx.bd_shade,distance=0..] at @s run function sweetdream:equipment/bow/burst_dawn/shade_tick
execute in minecraft:the_nether as @e[tag=zx.bd_shade,distance=0..] at @s run function sweetdream:equipment/bow/burst_dawn/shade_tick
execute in minecraft:the_end as @e[tag=zx.bd_shade,distance=0..] at @s run function sweetdream:equipment/bow/burst_dawn/shade_tick

# 爆裂黎明: 每秒看一眼"我自己的魂灵之影还有没有" —— 没有就立刻收尾(撤术阵)。
#   排在 shade_tick **之后**: 影先走完这一步的寿命 -1 与 kill, 再数才不会把
#   刚在这一秒到期的影算成"还活着"(否则术阵会多留一秒)。
#   【为什么只写一行】`as @a[...] at @s` 带位置基准, 后面的 @e 锁在玩家所在维度;
#     写三遍(三维度)的话同一个玩家会被扫三次。
execute as @a[scores={zx.bd_on=1..}] at @s run function sweetdream:equipment/bow/burst_dawn/check

# 圣骸的脉冲与遗骸寿命由 core/tick 精确计时, 不再受全局秒心跳相位影响。

# 天使核心(2026-10-08): 「圣光柱」每秒 -1 秒, 归零 kill —— 纯表现实体(在受伤生物处升起的光柱)。
#   选择器同样不带 type(display); 三维度各一行 + distance=0..。
execute in minecraft:overworld as @e[tag=zx.ac_beam,distance=0..] at @s run function sweetdream:equipment/axe/angel_core/beam_tick
execute in minecraft:the_nether as @e[tag=zx.ac_beam,distance=0..] at @s run function sweetdream:equipment/axe/angel_core/beam_tick
execute in minecraft:the_end as @e[tag=zx.ac_beam,distance=0..] at @s run function sweetdream:equipment/axe/angel_core/beam_tick

# 重溟(2026-10-16 批 15-5): 「领域」每秒一跳 —— 领域内(半径 3)全部生物吃
#   施法者最大魔力值×0.03, 并被朝中心拉 0.5 格; 计时 zx.db_ft 归零就 kill 自己。
#   领域是**纯 marker**(文案只说"领域"= 范围效果, 没要外观)。
#   ★ 三维度各写一遍 + distance=0..(同神裁领域 / 崩裂裂缝 / 云迹领域 / 威霆术阵)。
execute in minecraft:overworld as @e[type=marker,tag=zx.db_field,distance=0..] at @s run function sweetdream:equipment/axe/deep_brine/field_tick
execute in minecraft:the_nether as @e[type=marker,tag=zx.db_field,distance=0..] at @s run function sweetdream:equipment/axe/deep_brine/field_tick
execute in minecraft:the_end as @e[type=marker,tag=zx.db_field,distance=0..] at @s run function sweetdream:equipment/axe/deep_brine/field_tick

# 长夜(2026-10-16 批 15-5): 「夜原」每秒一跳 —— 随机消耗圈内 1 个带「夜火」的生物
#   (附「流火」+ 护甲/韧性 -60% + 打 最大魔力×0.12, 每消耗一次后续 ×1.08 独立乘区);
#   计时 zx.ln_ft 归零就 field_end(先撤减甲、再删框架术阵、最后 kill)。
#   夜原是**纯 marker**(文案只说"领域/夜原"= 范围效果, 没要外观)。
#   ★ 三维度各写一遍 + distance=0..(同神裁领域 / 崩裂裂缝 / 威霆术阵)。
execute in minecraft:overworld as @e[type=marker,tag=zx.ln_field,distance=0..] at @s run function sweetdream:equipment/staff/long_night/field_tick
execute in minecraft:the_nether as @e[type=marker,tag=zx.ln_field,distance=0..] at @s run function sweetdream:equipment/staff/long_night/field_tick
execute in minecraft:the_end as @e[type=marker,tag=zx.ln_field,distance=0..] at @s run function sweetdream:equipment/staff/long_night/field_tick

# 凝壳（盔甲, 2026-10-16 批 15-5): 「霜壳」每秒推进 —— 每秒对领域内生物打一次
#   基础攻击力 ×4, 并冻住"首次进入"的那一只; 计时 zx.cs_ft 归零就 field_end
#   （删框架术阵 + kill 自己）。
execute in minecraft:overworld as @e[type=marker,tag=zx.cs_field,distance=0..] at @s run function sweetdream:equipment/armor/condensed_shell/field_tick
execute in minecraft:the_nether as @e[type=marker,tag=zx.cs_field,distance=0..] at @s run function sweetdream:equipment/armor/condensed_shell/field_tick
execute in minecraft:the_end as @e[type=marker,tag=zx.cs_field,distance=0..] at @s run function sweetdream:equipment/armor/condensed_shell/field_tick

# 迟庭(法杖, 2026-10-16 批 15-5): 「领域」每秒推进 —— 每秒对圈内**处于缓慢**的生物
#   打一次 最大魔力值 ×0.04, 并处理"缓慢在领域内结束"那一段(基础攻击力 ×4 + 向领域外
#   击退 1 格); 计时 zx.ltc_ft 归零就 field_end(删框架术阵 + kill 自己)。
#   领域是**纯 marker**(文案只说"领域"= 范围效果, 没要外观)。
#   ★ 前缀用 ltc_ 而不是 lt_: zx.lt_* 已经被「沉溺忘川彼岸」(lethe_shore) 占用
#     (zx.lt_end = 残念到期刻), 复用会撞成"一个计分项两件事"(坑 136/143)。
#   ★ 三维度各写一遍 + distance=0..(同神裁领域 / 崩裂裂缝 / 威霆术阵)。
execute in minecraft:overworld as @e[type=marker,tag=zx.ltc_field,distance=0..] at @s run function sweetdream:equipment/staff/late_court/field_tick
execute in minecraft:the_nether as @e[type=marker,tag=zx.ltc_field,distance=0..] at @s run function sweetdream:equipment/staff/late_court/field_tick
execute in minecraft:the_end as @e[type=marker,tag=zx.ltc_field,distance=0..] at @s run function sweetdream:equipment/staff/late_court/field_tick

# 雷楔(剑, 2026-10-16 批 15-5): 「雷楔」召唤物每秒推进 —— 只有倒计时与"还立着"的电花;
#   计时 zx.twg_ft 归零就 wedge_end(删框架术阵 + kill 自己)。
#   落雷不走这里(那是平A命中即触发, 见 thunder_wedge/hit), 这里只管活多久。
#   ★ 三维度各写一遍 + distance=0..(同神裁领域 / 崩裂裂缝 / 威霆术阵)。
execute in minecraft:overworld as @e[type=marker,tag=zx.twg_wedge,distance=0..] at @s run function sweetdream:equipment/sword/thunder_wedge/wedge_tick
execute in minecraft:the_nether as @e[type=marker,tag=zx.twg_wedge,distance=0..] at @s run function sweetdream:equipment/sword/thunder_wedge/wedge_tick
execute in minecraft:the_end as @e[type=marker,tag=zx.twg_wedge,distance=0..] at @s run function sweetdream:equipment/sword/thunder_wedge/wedge_tick

# 超限·雷楔(2026-10-23 批 K3): 「雷楔」留下的持续伤害每秒 -1。
#   ★ 必须排在上面三轮 wedge_tick **之后** ★ 上面那一跳先打伤害、这里再减寿命,
#     于是"3 秒"正好结算 3 跳(先减的话只跳 2 跳)。
#   ★ 为什么不能只靠 ol_tick 计时 ★ 雷楔只活 10 秒, 而 5 秒档的 DoT 可能比它活得久;
#     挂在 marker 上计时 ⇒ marker 一死那些分数就永远不推进(生物永久"每秒掉血")。
#   ★ 选择器按 scores 筛, 平时全场一次空扫; distance=0.. 是"锁当前维度"的那把锁
#     (三维度各写一遍才不会重复处理, 同神裁领域 / 崩裂裂缝)。
execute in minecraft:overworld as @e[scores={zx.twg_dot=1..},distance=0..] run function sweetdream:equipment/sword/thunder_wedge/ol_dot_down
execute in minecraft:the_nether as @e[scores={zx.twg_dot=1..},distance=0..] run function sweetdream:equipment/sword/thunder_wedge/ol_dot_down
execute in minecraft:the_end as @e[scores={zx.twg_dot=1..},distance=0..] run function sweetdream:equipment/sword/thunder_wedge/ol_dot_down

# 威霆(2026-10-07 批2): 「术阵」每秒推进 —— 计时 zx.tc_ft 归零就收阵(field_end 反查施法者清 zx.tc_on)。
execute in minecraft:overworld as @e[type=marker,tag=zx.tc_field,distance=0..] at @s run function sweetdream:equipment/axe/thunderclap/field_tick
execute in minecraft:the_nether as @e[type=marker,tag=zx.tc_field,distance=0..] at @s run function sweetdream:equipment/axe/thunderclap/field_tick
execute in minecraft:the_end as @e[type=marker,tag=zx.tc_field,distance=0..] at @s run function sweetdream:equipment/axe/thunderclap/field_tick

# 饮鸩(2026-10-07 批2): 攻击力加成每秒 -1 秒, 到点撤除(strip 把账本减回去)
execute as @a[scores={zx.dg_on=1..}] run function sweetdream:equipment/axe/draught/expire
# 超限·饮鸩第二形态(2026-10-23 批 K4): 10 秒计时独立一条(账本也没问题: 用的是 dg_buf2)
execute as @a[scores={zx.dg_on2=1..}] run function sweetdream:equipment/axe/draught/ol_expire

# 超限·剜霜(2026-10-23 批 K5): 「披霜」持续 12 秒 —— 每秒 -1, 归零把层数一起清。
#   选择器按 scores 筛(没分数的人天然不进), 平时一次空扫。
execute as @a[scores={zx.frc_ft=1..}] run function sweetdream:equipment/axe/frost_carve/ol_wing_tick

# 超限·沉锚(2026-10-23 批 K6): 「回到原处」4 秒窗口 + 锚点 marker 4 秒自毁
execute as @a[scores={zx.anc_back=1..}] run scoreboard players remove @s zx.anc_back 1
execute in minecraft:overworld as @e[type=marker,tag=zx.anc_org,distance=0..] run scoreboard players remove @s zx.anc_bt 1
execute in minecraft:the_nether as @e[type=marker,tag=zx.anc_org,distance=0..] run scoreboard players remove @s zx.anc_bt 1
execute in minecraft:the_end as @e[type=marker,tag=zx.anc_org,distance=0..] run scoreboard players remove @s zx.anc_bt 1
#   ★ 归零那行用 scores 筛, 不吃"没分数"(marker 生成时就 set 4, 一定带分数)。
execute in minecraft:overworld as @e[type=marker,tag=zx.anc_org,distance=0..,scores={zx.anc_bt=..0}] run kill @s
execute in minecraft:the_nether as @e[type=marker,tag=zx.anc_org,distance=0..,scores={zx.anc_bt=..0}] run kill @s
execute in minecraft:the_end as @e[type=marker,tag=zx.anc_org,distance=0..,scores={zx.anc_bt=..0}] run kill @s

# 火种(2026-10-07 批1): 手持自动点燃 —— 每秒对所有人跑一次(没拿火种/已燃烧/魔力不足都自己 return)
execute as @a run function sweetdream:equipment/sword/tinder/second

# 深海: 正在施法的人每秒补画一次范围环(同上)
execute if entity @a[tag=zx.de_run] run function sweetdream:equipment/sword/deepsea_echo/fx

# 升级: 穿着的盔甲上的升级(魔力上限 / 每秒回魔) —— 见 upgrade/second
function sweetdream:upgrade/second

function sweetdream:lib/unfreeze_sweep

# 曳步·超限(2026-10-23 批 K1): "基础移速 -50%, 持续 5 秒" 到点摘属性修饰符。
#   和上面的 unfreeze_sweep 同一套写法(三维度各扫一次、选择器带 tag 锁维度),
#   健康状态下没有生物带 zx.yb_bind ⇒ 三次空转。见 equipment/sword/yebu/ol_bind_sweep。
function sweetdream:equipment/sword/yebu/ol_bind_sweep

# 虹彩: 漫彩每秒推进(吞噬效果 / 到点结束触发范围伤) —— 只对带 zx.rb_rainbow 的生物跑
execute as @e[tag=zx.rb_rainbow] run function sweetdream:equipment/bow/rainbow/second

# 长明(2026-10-13 批 13): 「灯灵」每秒管理 —— 持有时补召唤 / 不持有时**主动撤**
#   (坑 142)。撤场判据写在灯灵那一侧(它自己反查主人), 所以两个玩家站在一起
#   不会互相杀掉对方的灯灵。详见 equipment/tool/everlit/second。
function sweetdream:equipment/tool/everlit/second

# 常驻状态特效(圣痕=金 / 升痕=天蓝, 按层数分档) —— 见 status/aura
function sweetdream:status/aura

# 生物身上「武器专属标签」的到期衰减(圣痕 15 秒消失 / 升痕 每 15 秒 −1 层) —— 见 status/decay
function sweetdream:status/decay

# 命缕(法杖, 2026-10-17 批 15-6): 连丝的每秒推进 **已移到 core/tick 的每刻轮询**
#   —— 玩家报"全部失效"后查明: marker 一直没生成成功(zx.ft_own/ft_ft 无任何记录),
#   于是"7 秒收场 / 失去噬心断开 / 距离 >12 断开"全都不会发生。
#   现在这三件事全部由 equipment/staff/fate_thread/watch 在玩家侧每刻判, 不再需要每秒驱动。

# 极光与幻梦: 时停期间每隔 4 秒的飘渺钟声 + 持续极光粒子
execute as @a[scores={zx.ad_bell=1..}] run function sweetdream:equipment/sword/aurora_dream/bell

# 续火(法杖, 批 14 补技能): 切换武器后清空"普攻累计次数"
#   文案"切换武器后清空次数" ⇒ 只要主手不再是续火就归零(切走立刻生效, 切回来是 0)。
#   只对**有计数**的玩家跑这一条(`scores={zx.rf_n=1..}`), 平时选择器为空、零开销。
execute as @a[scores={zx.rf_n=1..}] unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["renew_fire"]}] run scoreboard players set @s zx.rf_n 0

# 空枕(头盔, 批 14 补技能): 连续 4 秒没造成伤害 -> 「静息」
#   时刻由 internal/damage/deal 的钩子(on_deal)刷新, 这里只做"够 4 秒就发标签"。
execute as @a run function sweetdream:equipment/armor/empty_pillow/passive

# 返照(头盔, 批 14 补技能): 「回照」5 秒到期后把残留值清 0
#   ★ 判定本身在 backlight/on_cast 里(`zx.bk_wd >= #now` 才算生效), 这里只是清理,
#     让观测镜/调试看到的"回照剩余"不会一直停在过期的旧值上。
function sweetdream:equipment/armor/backlight/second

# 魔力上限下限保护 —— 必须放在所有装备结算之后(脑髓蛭/脊骨共生会把上限算成负数)
execute as @a run function sweetdream:lib/mana_floor

function sweetdream:lib/in_restore

# 极光与幻梦 · 月蚀流光模型兜底
execute as @a if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["aurora_dream"]}] run function sweetdream:equipment/sword/aurora_dream/anim/reset_hands
execute as @a unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["aurora_dream"]}] if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["aurora_dream"]}] run function sweetdream:equipment/sword/aurora_dream/anim/reset_hands
# 极光与幻梦 · 月蚀流光模型兜底 / END

# ============================================================
# 批一 10 件（2026-10-20 实装）：每秒结算
# ------------------------------------------------------------
# 【统一写法】三维度各一行 `execute in <dim> as @e[tag=...,distance=0..] at @s`，
#   和包里 verdict / fissure / cloudtrail 的领域循环完全同款。
# ============================================================
# 驻足：领域每秒 5 点固定伤害 + 减速
execute in minecraft:overworld as @e[type=marker,tag=zx.zz_field,distance=0..] at @s run function sweetdream:equipment/armor/zhuzu/field_tick
execute in minecraft:the_nether as @e[type=marker,tag=zx.zz_field,distance=0..] at @s run function sweetdream:equipment/armor/zhuzu/field_tick
execute in minecraft:the_end as @e[type=marker,tag=zx.zz_field,distance=0..] at @s run function sweetdream:equipment/armor/zhuzu/field_tick
# 铁蒺藜：区域每秒 基础攻击力 + 减速
# 履霜：霜片每秒判定（敌人减速 / 自己加速 / 到期）
execute in minecraft:overworld as @e[type=marker,tag=zx.lsh_frost,distance=0..] at @s run function sweetdream:equipment/armor/lvshuang/frost_tick
execute in minecraft:the_nether as @e[type=marker,tag=zx.lsh_frost,distance=0..] at @s run function sweetdream:equipment/armor/lvshuang/frost_tick
execute in minecraft:the_end as @e[type=marker,tag=zx.lsh_frost,distance=0..] at @s run function sweetdream:equipment/armor/lvshuang/frost_tick
# 锈犬：每秒咬一口 + 到期
execute in minecraft:overworld as @e[type=marker,tag=zx.xg_dog,distance=0..] at @s run function sweetdream:equipment/axe/xiugou/dog_tick
execute in minecraft:the_nether as @e[type=marker,tag=zx.xg_dog,distance=0..] at @s run function sweetdream:equipment/axe/xiugou/dog_tick
execute in minecraft:the_end as @e[type=marker,tag=zx.xg_dog,distance=0..] at @s run function sweetdream:equipment/axe/xiugou/dog_tick
# 超限·锈犬(2026-10-23 批 K4): 「被召唤物攻击 +30%」的剩余秒数每秒 -1。
#   记在**被咬生物**身上, 所以按维度扫 @e(玩家重生不会带走它)。
#   ★ 排在上面 dog_tick **之后**: 先结算这一秒咬的那一口(那时 svul 还是满值),
#     再减寿命 —— 否则刚挂上的 10 秒会当场变成 9 秒(实际只吃到 9 跳)。
execute in minecraft:overworld as @e[scores={zx.svul=1..},distance=0..] run scoreboard players remove @s zx.svul 1
execute in minecraft:the_nether as @e[scores={zx.svul=1..},distance=0..] run scoreboard players remove @s zx.svul 1
execute in minecraft:the_end as @e[scores={zx.svul=1..},distance=0..] run scoreboard players remove @s zx.svul 1
# 冻土：每秒回 3% 最大生命 + 续抗性 + 到期
execute as @a[scores={zx.dng_on=1}] run function sweetdream:equipment/armor/dongtu/second
# 息土：领域每秒回 3 点 + 12 秒到期
execute as @a[scores={zx.so_ft=1..}] at @s run function sweetdream:equipment/armor/breathing_soil/field_tick
# 归途：灯每秒计时 + 低血标记 + 20 秒收场
execute as @a[scores={zx.wb_on=1}] at @s run function sweetdream:equipment/sword/way_back/second
# 批一 10 件 · 每秒结算 / END
execute as @e[type=marker,tag=zx.wb_lamp] at @s run function sweetdream:equipment/sword/way_back/watch
execute as @a run function sweetdream:internal/review/migrate

# 明烛(批 14 2026-10-25)：常态夜视（每秒补 12 秒，脱下后自然退）
execute as @a run function sweetdream:equipment/armor/bright_candle/second
# 明烛「烛火」：每秒一跳（计时 + 烤流火成夜火 + 主人站圈内回蓝）
#   ★ 三维度各一行 + `distance=0..`：裸 @e 会跨维度重复跑（范式速查第 10 条）。
# Candle lifetime/dwell moved to core/tick.
# Candle lifetime/dwell moved to core/tick.
# Candle lifetime/dwell moved to core/tick.
# 借火(批 14)：5 秒到点撤掉"削减目标护甲 / 转移到自己身上"的两组 modifier
execute in minecraft:overworld as @e[tag=zx.bf_strip,distance=0..] if score @s zx.bf_end <= #now manacore.meta at @s run function sweetdream:equipment/armor/borrow_fire/unstrip
execute in minecraft:the_nether as @e[tag=zx.bf_strip,distance=0..] if score @s zx.bf_end <= #now manacore.meta at @s run function sweetdream:equipment/armor/borrow_fire/unstrip
execute in minecraft:the_end as @e[tag=zx.bf_strip,distance=0..] if score @s zx.bf_end <= #now manacore.meta at @s run function sweetdream:equipment/armor/borrow_fire/unstrip
execute as @a[scores={zx.bf_oend=1..}] if score @s zx.bf_oend <= #now manacore.meta run function sweetdream:equipment/armor/borrow_fire/unstrip_self

# 批 14(2026-10-25)：没穿剖面的人不必继续攒"累计消耗魔力"（省得它无限增长）
execute as @a unless items entity @s armor.legs *[minecraft:custom_data~{zx:["profile"]}] run scoreboard players reset @s zx.pm_sum

# 批 14(2026-10-25)：没穿折潮的人不必继续攒"累计消耗魔力"（省得它无限增长）
execute as @a unless items entity @s armor.head *[minecraft:custom_data~{zx:["tide_fold"]}] run scoreboard players reset @s zx.tf_sum

# 批 14(2026-10-25)：返汐「海浪」—— 每秒结算一次移速档位(加档 / 衰减 / 套 modifier)
function sweetdream:equipment/armor/ebb_tide/second

# 批 14 更正(2026-10-25 用户原稿)：浮光 —— 每秒结算（回复 / 移速档 / 减速 / 白的群体白昼梦）
#   ★ 排在迟暮之前或之后都不影响: 这一版没有"残烛"那类跨件开关。
execute as @a at @s run function sweetdream:equipment/armor/glimmer/apply

# 批 14 更正(2026-10-25 用户原稿)：迟暮 —— 「回光」15 秒到期 / 抗性提升Ⅴ标记收尾
execute as @a run function sweetdream:equipment/armor/late_dusk/second

execute in minecraft:overworld as @e[tag=zx.lr_watch,distance=0..] run function sweetdream:equipment/armor/late_dusk/watch_validate

execute in minecraft:the_nether as @e[tag=zx.lr_watch,distance=0..] run function sweetdream:equipment/armor/late_dusk/watch_validate

execute in minecraft:the_end as @e[tag=zx.lr_watch,distance=0..] run function sweetdream:equipment/armor/late_dusk/watch_validate

function sweetdream:internal/native/registry_gc
