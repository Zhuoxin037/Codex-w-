# ============================================================
# sweetdream:equipment/staff/begonia/vortex_death —— 漩涡增强检测(每刻)
# ------------------------------------------------------------
# 【谁调用它】core/tick: execute as @e[tag=zx.bg_vtx] at @s run ...(执行者 = 漩涡本体)
# 【技能原文(超限·海棠)】"若有生物在漩涡范围内死亡，则对该漩涡进行增强"
# 【★ 2026-10-12 重写(RULES 坑 134)★】
#   旧版: `@e[type=!#sweetdream:no_damage,distance=..6,nbt={Health:0.0f},limit=1]`
#   —— 想直接"选到刚死的生物"。但原版 @e/@n 的解析会附加 Entity.isAlive() 过滤
#   (MC-108307, Confirmed / Won't Fix): 血量一归零 isAlive 就为 false
#   ⇒ **这条判决恒假, "增强"永不触发**(静默, 玩家只看到效果不存在)。
#   死亡动画那 ~20 刻实体确实还在世界里(还会挡方块放置), 但选择器只认
#   @s / UUID 字面量 / 关系选择器 —— 没有一条能"扫一圈看谁死了"。
#   新口径 = **不去选尸体, 改成数活体**:
#     每刻数一次 6 格内的活体数量; 比上一刻少 => 范围内少了生物(死亡) => 增强。
# 【★ 边界(必须知道)★】"被移出 6 格"(击退 / 瞬移 / 末影人传送)也会被算成一次"少了"。
#   但漩涡每秒会把范围内的生物朝中心拉(见 vortex_tick), 正常情况下它们出不去;
#   而且误判的方向是"多给一次增强", 不会少给。要做到 100% 精确得按 UUID 追踪个体
#   (见 RULES 坑 134 的备选方案), 当前按"够用且不静默"取舍。
# 【范围】6 格 = 超限漩涡的半径(基础漩涡没有"增强"一说, 第一行就退出)。
# 【增强状态】给漩涡本体打 tag zx.bg_emp, **跟随漩涡寿命**(kill 时一起消失),
#   不做时限 —— 文案是"对该漩涡进行增强", 漩涡活着就一直增强。
# 【开销】只有场上有超限漩涡时才会真正执行; 第一行数据判不过就 return,
#   已经增强过的也直接 return(增强是一次性的, 不重复扫描)。
# ============================================================

execute unless data entity @s data.zx.bg{ol:1b} run return 0
execute if entity @s[tag=zx.bg_emp] run return 0

# ① 这一刻 6 格内有几只活体
#   ★ type=!#sweetdream:no_damage 已经把玩家 / 物品 / 箭 / 展示实体挖掉
#     (漩涡本体 item_display 也在里面), 剩下的就是"可伤害的生物"。
#   ★ @s 已由调用方(at @s)保证是漩涡本体, 所以 distance 就是以漩涡中心量的。
scoreboard players set #bg_n zx.meta 0
execute as @e[type=!#sweetdream:no_damage,distance=..6] run scoreboard players add #bg_n zx.meta 1

# ② 比上一刻少 => 范围内有生物消失(死亡) => 增强
execute if score #bg_n zx.meta < @s zx.bg_n run tag @s add zx.bg_emp

# ③ 存下这一刻的数量, 供下一拍对比(首拍 @s zx.bg_n 默认 0, 不会误触发)
scoreboard players operation @s zx.bg_n = #bg_n zx.meta
