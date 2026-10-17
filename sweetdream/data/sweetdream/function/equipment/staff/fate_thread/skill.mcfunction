# ============================================================
# sweetdream:equipment/staff/fate_thread/skill —— 命缕 · 主动技能(潜行右键)
# ------------------------------------------------------------
# 【谁调用它】cast ①(潜行)   【执行者】施法者
# 【技能原文】
#   ✦ 主动技能   魔力 240 · 冷却 40 秒
#   "使用后选中自身 10 格内最近的一个附有「噬心」的生物，使其及 6 格内最多 2 个其他
#    生物以绯色丝线相连，持续 7 秒。期间其每次受到自身造成的伤害后，相连的其他生物
#    分别受到一次相当于本次伤害 ×0.3 的真实伤害（最多触发 6 次）。若其死亡或失去
#    「噬心」，则丝线断开；若与相连生物的距离超过 12 格，则对应丝线断开。"
# 【★ 四要素 ★】
#   ① 触发: 潜行右键。
#   ② 范围: 主目标 = 自身 10 格内**最近的**噬心者; 相连者 = 主目标 6 格内最多 2 个其他生物。
#   ③ 次数: 连丝本身不限次数, 但**真伤结算最多 6 次**(zx.ft_got, 记在**玩家**身上)。
#   ④ 时长: 7 秒(zx.ft_end = 施法刻 +140, 由 watch 每刻判, 到点自己收场)。
# 【★ 实例号怎么来 ★】= 施法刻 `#now`, 同时写到主目标/相连者的 zx.ft_n 上。
#   一秒后可能同时存在多个玩家的连丝 —— 靠这个号把"哪一组"分开,
#   否则 A 的主目标受伤会让 B 的相连者一起掉血。
# 【★★ 2026-10-17 第二版: 不再用 marker ★★】
#   第一版把"计时 / 次数 / 归属"记在一个 marker 上, 结果 marker 从来没生成成功
#   (存档实证: zx.ft_own / zx.ft_ft / zx.ft_cnt 一条记录都没有) ⇒ 7 秒不收场、
#   失去噬心不断、距离超过 12 格不断, 而且玩家**看不到任何丝线**。
#   现在: 位置/计时/次数/断开条件全在玩家侧(equipment/staff/fate_thread/watch, 每刻轮询),
#   主目标位置由标签 zx.ft_main 现取, 表现由 watch 每刻画粒子。少一个实体 = 少一种静默失败。
# ============================================================

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 只读检查: 冷却好没好 + 魔力 240
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:fate_thread",mana:240.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check

execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"命缕冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 240）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 10 格内有噬心者吗? 没有就整个不放
execute unless entity @e[type=!#sweetdream:no_damage,distance=0.1..10,tag=zx.status.shixin] run tellraw @s [{"text":"附近没有附有「噬心」的生物","color":"red"}]
execute unless entity @e[type=!#sweetdream:no_damage,distance=0.1..10,tag=zx.status.shixin] run return fail

# ④ 扣魔力 -240
data modify storage manacore:in arg set value {uuid:"",value:240.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run return fail

# ⑤ 记冷却 40 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:fate_thread",cooldown_seconds:40.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑥ 清掉**自己**上一组连丝(同一时间只留一条)
#   ★★ 2026-10-17 第二版: 连丝**不再用 marker** ★★
#     原来靠 marker 的 zx.ft_own 认"这条丝是不是我放的", 而 marker 一直没生成成功
#     (存档实证: zx.ft_own / zx.ft_ft / zx.ft_cnt 一条记录都没有) ⇒ 换丝时清不掉旧丝,
#     也看不到任何丝线表现。现在"有没有丝"只看玩家自己的 zx.ft_mine, 收场走 watch_end,
#     记录/计时/断开条件全在玩家身上, 少一个实体就少一种静默失败。
execute unless score @s zx.ft_mine matches 0 run function sweetdream:equipment/staff/fate_thread/watch_end
tag @e[tag=zx.ft_main,distance=0..] remove zx.ft_main
tag @e[tag=zx.ft_lk,distance=0..] remove zx.ft_lk
tag @e[tag=zx.ft_hit2,distance=0..] remove zx.ft_hit2
#   自己的实例索引先归零(下面 ⑩ 会写成新的) —— 否则旧号在这中间被 tick 读到会去找旧主目标
scoreboard players set @s zx.ft_mine 0
tag @s remove zx.ft_link

# ⑦ 选主目标: 自身 10 格内**最近的**噬心者
execute as @e[type=!#sweetdream:no_damage,distance=0.1..10,tag=zx.status.shixin,sort=nearest,limit=1] run tag @s add zx.ft_main

# ⑧ 相连者: 主目标 6 格内最多 2 个**其他**生物
execute at @e[tag=zx.ft_main,distance=0..,limit=1] run tag @e[type=!#sweetdream:no_damage,distance=0.01..6,tag=!zx.ft_main,sort=nearest,limit=2] add zx.ft_lk

# ⑨ 实例号 = **施法刻(#now)**
#   ★★ 2026-10-17 事故(存档实证) ★★
#     原来用 marker 的 UUID[0] 当实例号: 先 summon, 再从 marker 上 `scoreboard players get`
#     读回来当 #ft_iid。那一步一旦读空 ⇒ #ft_iid = 0 ⇒ 主目标/相连者/玩家三方全写成 0,
#     而且 `zx.ft_own`/`zx.ft_ft`/`zx.ft_cnt` 三行也没落地 ⇒ 连丝"放得出来、提示也出,
#     但永远不会结算"(零日志)。表现就是玩家说的"全部失效"。
#     现在直接取 #now(绝对刻): 一次赋值、四处同源, 不依赖任何实体查询。
#   ★ 两位玩家同刻施法会撞号, 后果仅是共用 6 次上限, 可以接受;
#     换成"当前刻×1000 + 序号"这类算式在计分板上做不了取模, 反而不稳。
scoreboard players operation #ft_iid zx.meta = #now manacore.meta

# ⑩ 实体载体: **没有** —— 丝线不召 marker(见 ⑥ 的说明, 存档实证 marker 一直没生成成功)。
#   位置/计时/次数/断开条件全在玩家侧(watch), 表现由 watch 每刻画。

# ⑪ 实例号写三方 + 玩家自己的状态(到期刻 / 已结算次数)
scoreboard players operation @e[tag=zx.ft_main,distance=0..] zx.ft_n = #ft_iid zx.meta
scoreboard players operation @e[tag=zx.ft_lk,distance=0..] zx.ft_n = #ft_iid zx.meta
#   主目标的"上次血量"快照(真伤按前后血量差算, 见 watch)
execute store result score @e[tag=zx.ft_main,distance=0..] zx.ft_hp run data get entity @e[tag=zx.ft_main,distance=0..,limit=1] Health 1000
#   ★ 玩家身上记三样: 实例号 / 到期绝对刻(+140 刻 = 7 秒) / 已结算次数
scoreboard players add @s zx.ft_mine 0
scoreboard players operation @s zx.ft_mine = #ft_iid zx.meta
scoreboard players operation @s zx.ft_end = #now manacore.meta
scoreboard players add @s zx.ft_end 140
scoreboard players set @s zx.ft_got 0
#   ★ zx.ft_scan / zx.ft_max 两个排查期诊断量已于 2026-10-17 删除(结论: 训练人偶不吃伤害)。
#   ★ 入口用**标签**而不是判分: core/tick 里 `@a[tag=zx.ft_link]` 在选择器层就筛掉了
#     没放丝的人(= 绝大多数时刻), 函数根本不进; 判分写法每刻都要对每个玩家调一次函数。
tag @s add zx.ft_link
tag @e[tag=zx.ft_new,distance=0..] remove zx.ft_new

# ⑫ 表现 + 提示
execute at @e[tag=zx.ft_main,distance=0..,limit=1] run particle minecraft:dust{color:[0.75,0.1,0.2],scale:1.6} ~ ~1 ~ 1.0 1.0 1.0 0.02 40 normal
playsound minecraft:entity.vex.ambient player @a ~ ~ ~ 0.9 0.8
tellraw @s [{"text":"绯色丝线已连结（7 秒）","color":"light_purple"}]
# ★ 2026-10-17: 补一句"打哪只" —— 文案里的"其"只指**主目标**, 打相连者不会结算。
#   前三轮复测都卡在这个理解差上(玩家以为"随便打一只都行"), 提示里必须写明。
tellraw @s [{"text":"  -> 打那只头顶有红色光柱的（主目标），相连的另外几只才会跟着掉血","color":"dark_purple"}]
