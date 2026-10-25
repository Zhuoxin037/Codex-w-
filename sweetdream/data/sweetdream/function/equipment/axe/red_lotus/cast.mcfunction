# ============================================================
# sweetdream:equipment/axe/red_lotus/cast —— 红莲 · 主动技能(右键)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/axe/red_lotus(consume_item) -> rewards
# 【技能原文(必须和这里对上)】
#   魔力 80 / 冷却 30 秒。
#   "使用后消耗自身 5 格内全部生物的「流火」或「夜火」效果。之后每消耗一层「流火」则对
#    自身 5 格内的生物造成一次相当于自身基础攻击力的伤害，每消耗一层「夜火」则对自身 6 格内
#    的生物造成一次相当于自身基础攻击力 ×3 的伤害。"
# 【★ 四要素逐个落实 ★】
#   ① 触发: 右键。
#   ② 目标范围: 消耗 —— 自身 5 格内带「流火」/「夜火」的生物; 伤害 —— 自身 5 格(流火)/6 格(夜火)内全部。
#   ③ 次数: "每消耗一层" -> 每只带标签的生物算一层, 有几只就打几次(见下)。
#   ④ 时长: 起手即打第一段; 之后**每 0.5 秒(10 刻)一段**, 依次打完剩下的(见 tick_step)。
# 【★ 2026-10-07 用户改口径: 不再同刻一次性打完 ★】
#   原来 N 只带标签的生物会在**同一刻**各触发一次打击 —— 而生物的受伤无敌帧是 0.5 秒,
#   同一刻的第二下起基本被吃掉(等于只有第一下真的掉血)。用户要求改成
#   "**多段都依次隔 0.5 秒**"(照回锋的写法):
#     第 1 段当场打, 剩下的由 core/tick 驱动 tick_step 每 10 刻推一段。
#   实现见 step / step_fire / step_night / tick_step; 间隔 10 刻 = 0.5 秒。
#
# 【★★ 超限·红莲 的差别(逐字照抄 oldef."red_lotus".lore)★★】
#   "使用后消耗自身 5 格内全部生物的「流火」或「夜火」效果。每消耗一层「流火」则对
#    自身 6 格内全部生物造成一次相当于自身基础攻击力 ×1.5 的伤害并使其燃烧 2 秒，
#    每消耗一层「夜火」则对自身 6 格内全部生物造成两次相当于自身基础攻击力 ×4 的
#    伤害并使其燃烧 5 秒。若本次共消耗了 6 层及以上「流火」及「夜火」，则使自身 5 格内
#    的敌人每秒都会获得「流火」效果，持续 5 秒。"
#   落实: ①消耗范围不变(5 格内带标签的); ②流火: 5格×1 -> **6格×1.5 + 燃烧2秒**;
#         ③夜火: ×3一次 -> **×4 两次 + 燃烧5秒**(半径本来就 6);
#         ④新增"层数 >= 6 -> 自身 5 格内敌人每秒获「流火」, 持续 5 秒"(⑪ + rain_tick)。
# 【★ 「层」怎么理解 ★】「流火」「夜火」是**二值状态**(通用标签, 一只生物只有"有/没有"),
#   不是可叠加的层数 -> 一只带标签的生物 = 一层。所以 N 只带流火 = 打 N 段。
# 【伤害锚点】每段打击都以**自身**(施法者)为圆心 —— 所以 step 系列全程在施法者身份下跑
#   (`core/tick` 用 `as @a[..] at @s` 驱动, 位置始终是施法者)。
# 【消耗】走统一入口 lib/mark_consume(让余烬/永恒的消耗被动收得到信号)。
#   ★ 消耗仍在这一刻一次性做完(文案是"使用后消耗...之后每消耗一层...") ——
#     "打几段"的数在消耗前就数好了, 记在 zx.rl_rep 上, 所以后段不依赖标签还在不在。
# 【数值改哪】倍率 1/3(基础)与 1.5/4(超限) = recalc; 半径 5/6 = hit_fire/hit_night;
#   燃烧 40/100 tick = hit_fire/hit_night 的 `zx:work rl.n`; "6 层"门槛 = 本文件 ⑪;
#   间隔 = tick_step 的 `set @s zx.rl_t 10`(10 刻 = 0.5 秒) 与 core/tick 的 `zx.rl_t=1..`。
# ============================================================

# ⓪ 撤销自己的进度
advancement revoke @s only sweetdream:equipment/axe/red_lotus

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ①' 超限快照: 手里这把是不是超限版(判一次存到玩家身上)
#   ★ 为什么要拍快照: 连击是"每 0.5 秒一段"跨刻走的, 那些段由 core/tick 驱动,
#     到那时"手里那把"已经不一定还是红莲了(见 RULES 的"施法快照")。
#     本段链上读它的地方: recalc(倍率 1.5/4)、hit_fire/hit_night(6 格 + 燃烧)、
#     cast ⑪(>=6 层才开"流火雨")。
#   ★ **不能在 cast 里清掉它** —— 后面几段(以及下雨的判定)都还要读;
#     由 tick_step 在最后一段打完时清(见那个文件的 ③')。
function sweetdream:equipment/axe/red_lotus/is_ol
scoreboard players operation @s zx.rl_ol = #rl_ol zx.meta

# ② 只读检查: 冷却 + 魔力 80
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:red_lotus",mana:80.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"红莲冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 80）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 5 格内至少有一只带「流火」或「夜火」的, 否则整个不放
execute unless entity @e[type=!#sweetdream:no_damage,tag=zx.status.liuhuo,distance=0..5] unless entity @e[type=!#sweetdream:no_damage,tag=zx.status.yehuo,distance=0..5] run tellraw @s [{"text":"5 格内没有带「流火」或「夜火」的生物","color":"red"}]
execute unless entity @e[type=!#sweetdream:no_damage,tag=zx.status.liuhuo,distance=0..5] unless entity @e[type=!#sweetdream:no_damage,tag=zx.status.yehuo,distance=0..5] run return fail

# ④ 扣魔力 80
data modify storage manacore:in arg set value {uuid:"",value:80.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run return fail

# ⑤ 起冷却 30 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:red_lotus",cooldown_seconds:30.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑤' 到这里才算"这一发真的放出去了", 现在才清上一轮的连击残值(正常 1 秒内打完;
#   防退游戏/被打断留下残值)。
#   ★★ 2026-10-10 修 F11: 原来这两行在**最前面**(校验之前) ——
#     于是"冷却中/蓝不够时再右键"这种**注定失败**的尝试也会先把上一轮
#     还没打完的段数(rl_t / rl_rep)清掉, 白丢后面几段。校验失败必须无副作用。
scoreboard players reset @s zx.rl_t
scoreboard players reset @s zx.rl_rep

# ⑥ 圈出"5 格内带流火 / 夜火"的生物(消耗前先把名单钉住)
#   ★ 名单标签只用来"点人头", 每推一段由 step_fire/step_night 逐只摘掉一个。
tag @e[tag=zx.rl_fire,distance=0..] remove zx.rl_fire
tag @e[tag=zx.rl_night,distance=0..] remove zx.rl_night
execute at @s as @e[type=!#sweetdream:no_damage,tag=zx.status.liuhuo,distance=0..5] run tag @s add zx.rl_fire
execute at @s as @e[type=!#sweetdream:no_damage,tag=zx.status.yehuo,distance=0..5] run tag @s add zx.rl_night

# ⑦ 数"一共要打几段" = 流火只数 + 夜火只数
#   ★ 先 set 0 再 store: 选择器一个都没选中时 `execute if entity` 会失败,
#     store 不执行 -> 留着上一轮的值(计分板"没分数/旧值"的坑)。
scoreboard players set #rl_n zx.meta 0
execute store result score #rl_n zx.meta run execute if entity @e[tag=zx.rl_fire,distance=0..]
scoreboard players operation @s zx.rl_rep = #rl_n zx.meta
scoreboard players set #rl_n zx.meta 0
execute store result score #rl_n zx.meta run execute if entity @e[tag=zx.rl_night,distance=0..]
scoreboard players operation @s zx.rl_rep += #rl_n zx.meta

# ⑦' 本次一共消耗几层(= 流火只数 + 夜火只数) —— 超限版要用它判"6 层及以上"
#    ★ 必须赶在 ⑨(remove 1)之前抄走, 否则拿到的少 1。
scoreboard players operation #rl_tot zx.meta = @s zx.rl_rep

# ⑧ 立刻打第 1 段(流火优先; 没有流火就打夜火)
function sweetdream:equipment/axe/red_lotus/step

# ⑨ 剩下的每 0.5 秒(10 刻)推一段, 由 core/tick 驱动 tick_step 直到 rl_rep 用完
scoreboard players remove @s zx.rl_rep 1
execute if score @s zx.rl_rep matches 1.. run scoreboard players set @s zx.rl_t 10

# ⑩ 消耗掉这些「流火」「夜火」(统一入口; 逐只走, 让余烬/永恒收得到)
data modify storage zx:work a set value {target:"@e[tag=zx.rl_fire,distance=0..]",mark:"liuhuo",by:"@s"}
function sweetdream:lib/mark_consume
data modify storage zx:work a set value {target:"@e[tag=zx.rl_night,distance=0..]",mark:"yehuo",by:"@s"}
function sweetdream:lib/mark_consume

# ⑪ 超限: 本次消耗 >= 6 层 -> 自身 5 格内的敌人每秒获得「流火」, 持续 5 秒
#   ★ 语义: "5 秒"= 施法当刻 + 之后 4 秒, 共 5 发(所以 rl_rain 起手 4, 不是 5)。
#     之后由 lib/second 的 `zx.rl_rain=1..` 每发一次 -1, 归零自动停。
execute if score @s zx.rl_ol matches 1 if score #rl_tot zx.meta matches 6.. run function sweetdream:equipment/axe/red_lotus/rain
execute if score @s zx.rl_ol matches 1 if score #rl_tot zx.meta matches 6.. run scoreboard players set @s zx.rl_rain 4
execute if score @s zx.rl_ol matches 1 if score #rl_tot zx.meta matches 6.. run tellraw @s [{"text":"超限·红莲 · 消耗 ","color":"light_purple"},{"score":{"name":"#rl_tot","objective":"zx.meta"},"color":"aqua"},{"text":" 层, 「流火」雨持续 5 秒","color":"light_purple"}]

# ⑫ 表现
#   ★ 这里**不再**清 zx.rl_fire / zx.rl_night —— 名单要留给后面几段用,
#     由 step_fire / step_night 每段各摘一只, 全部打完自然清零(断线/退出也不会留脏数据,
#     下一次 cast 开头会无条件清一遍)。
execute at @s run particle minecraft:flame ~ ~1 ~ 1.4 0.6 1.4 0.06 40 normal
execute at @s run playsound minecraft:item.firecharge.use player @a ~ ~ ~ 1.0 0.7
