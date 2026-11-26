# ============================================================
# fallendream:equipment/staff/fate_thread/skill —— 命缕 · 主动技能(潜行右键)
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
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ①.5 超限分档（2026-10-23 批 K9）
#   魔力 240→350、选中半径 10→12 格、相连 2→6 个、持续 7→12 秒、
#   真伤 ×0.3→×0.5、去掉"最多 6 次"、新增第二段连接（12 格内最多 4 个噬心者 / 18 秒）、
#   两条丝同时连着的目标改吃 ×0.8、距离断开 12→16 格、到期绷紧 10×连接数 + 附噬心。
scoreboard players set #ft_ol zx.meta 0
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["fate_thread"],ol:"fate_thread"}] run scoreboard players set #ft_ol zx.meta 1
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["fate_thread"],ol:"fate_thread"}] run scoreboard players set #ft_ol zx.meta 1
scoreboard players set #ft_ml zx.meta 240
execute if score #ft_ol zx.meta matches 1 run scoreboard players set #ft_ml zx.meta 350

# ② 只读检查: 冷却好没好 + 魔力(基础 240 / 超限 350)
data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:fate_thread",mana:240.0}
execute store result storage manacore:in arg.mana double 1.0 run scoreboard players get #ft_ml zx.meta
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check

execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"命缕冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 ","color":"red"},{"score":{"name":"#ft_ml","objective":"zx.meta"},"color":"red"},{"text":"）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 有噬心者吗? 没有就整个不放（半径：基础 10 / 超限 12）
execute if score #ft_ol zx.meta matches 0 unless entity @e[type=!#fallendream:no_damage,distance=0.1..10,tag=zx.status.shixin] run tellraw @s [{"text":"附近没有附有「噬心」的生物","color":"red"}]
execute if score #ft_ol zx.meta matches 1 unless entity @e[type=!#fallendream:no_damage,distance=0.1..12,tag=zx.status.shixin] run tellraw @s [{"text":"附近没有附有「噬心」的生物","color":"red"}]
execute if score #ft_ol zx.meta matches 0 unless entity @e[type=!#fallendream:no_damage,distance=0.1..10,tag=zx.status.shixin] run return fail
execute if score #ft_ol zx.meta matches 1 unless entity @e[type=!#fallendream:no_damage,distance=0.1..12,tag=zx.status.shixin] run return fail

# ④ 扣魔力（基础 240 / 超限 350）
data modify storage manacore:in arg set value {uuid:"",value:0.0}
execute store result storage manacore:in arg.value double 1.0 run scoreboard players get #ft_ml zx.meta
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function fallendream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run return fail

# ⑤ 记冷却 40 秒
data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:fate_thread",cooldown_seconds:40.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑥ 清掉**自己**上一组连丝(同一时间只留一条)
#   ★★ 2026-10-17 第二版: 连丝**不再用 marker** ★★
#     原来靠 marker 的 zx.ft_own 认"这条丝是不是我放的", 而 marker 一直没生成成功
#     (存档实证: zx.ft_own / zx.ft_ft / zx.ft_cnt 一条记录都没有) ⇒ 换丝时清不掉旧丝,
#     也看不到任何丝线表现。现在"有没有丝"只看玩家自己的 zx.ft_mine, 收场走 watch_end,
#     记录/计时/断开条件全在玩家身上, 少一个实体就少一种静默失败。
function fallendream:equipment/staff/fate_thread/link_begin
