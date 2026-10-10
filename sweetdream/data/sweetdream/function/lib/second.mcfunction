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

# 天使核心(2026-10-08): 「圣光柱」每秒 -1 秒, 归零 kill —— 纯表现实体(在受伤生物处升起的光柱)。
#   选择器同样不带 type(display); 三维度各一行 + distance=0..。
execute in minecraft:overworld as @e[tag=zx.ac_beam,distance=0..] at @s run function sweetdream:equipment/axe/angel_core/beam_tick
execute in minecraft:the_nether as @e[tag=zx.ac_beam,distance=0..] at @s run function sweetdream:equipment/axe/angel_core/beam_tick
execute in minecraft:the_end as @e[tag=zx.ac_beam,distance=0..] at @s run function sweetdream:equipment/axe/angel_core/beam_tick

# 威霆(2026-10-07 批2): 「术阵」每秒推进 —— 计时 zx.tc_ft 归零就收阵(field_end 反查施法者清 zx.tc_on)。
execute in minecraft:overworld as @e[type=marker,tag=zx.tc_field,distance=0..] at @s run function sweetdream:equipment/axe/thunderclap/field_tick
execute in minecraft:the_nether as @e[type=marker,tag=zx.tc_field,distance=0..] at @s run function sweetdream:equipment/axe/thunderclap/field_tick
execute in minecraft:the_end as @e[type=marker,tag=zx.tc_field,distance=0..] at @s run function sweetdream:equipment/axe/thunderclap/field_tick

# 饮鸩(2026-10-07 批2): 攻击力加成每秒 -1 秒, 到点撤除(strip 把账本减回去)
execute as @a[scores={zx.dg_on=1..}] run function sweetdream:equipment/axe/draught/expire

# 火种(2026-10-07 批1): 手持自动点燃 —— 每秒对所有人跑一次(没拿火种/已燃烧/魔力不足都自己 return)
execute as @a run function sweetdream:equipment/sword/tinder/second

# 深海: 正在施法的人每秒补画一次范围环(同上)
execute if entity @a[tag=zx.de_run] run function sweetdream:equipment/sword/deepsea_echo/fx

# 升级: 穿着的盔甲上的升级(魔力上限 / 每秒回魔) —— 见 upgrade/second
function sweetdream:upgrade/second

function sweetdream:lib/unfreeze_sweep

# 虹彩: 漫彩每秒推进(吞噬效果 / 到点结束触发范围伤) —— 只对带 zx.rb_rainbow 的生物跑
execute as @e[tag=zx.rb_rainbow] run function sweetdream:equipment/bow/rainbow/second

# 常驻状态特效(圣痕=金 / 升痕=天蓝, 按层数分档) —— 见 status/aura
function sweetdream:status/aura

# 生物身上「武器专属标签」的到期衰减(圣痕 15 秒消失 / 升痕 每 15 秒 −1 层) —— 见 status/decay
function sweetdream:status/decay

# 极光与幻梦: 时停期间每隔 4 秒的飘渺钟声 + 持续极光粒子
execute as @a[scores={zx.ad_bell=1..}] run function sweetdream:equipment/sword/aurora_dream/bell

# 魔力上限下限保护 —— 必须放在所有装备结算之后(脑髓蛭/脊骨共生会把上限算成负数)
execute as @a run function sweetdream:lib/mana_floor

function sweetdream:lib/in_restore

# 极光与幻梦 · 月蚀流光模型兜底
execute as @a if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["aurora_dream"]}] run function sweetdream:equipment/sword/aurora_dream/anim/reset_hands
execute as @a unless items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["aurora_dream"]}] if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["aurora_dream"]}] run function sweetdream:equipment/sword/aurora_dream/anim/reset_hands
# 极光与幻梦 · 月蚀流光模型兜底 / END
