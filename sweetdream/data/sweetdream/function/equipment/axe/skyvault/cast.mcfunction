# ============================================================
# sweetdream:equipment/axe/skyvault/cast —— 天穹: 两段式(慢慢跃升 -> 俯冲)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/axe/skyvault 的奖励函数(右键消耗时, 玩家身份)
# 【文案】消耗 400 魔力 / 冷却 60 秒。
#   第一段: 自身跃升 6 格, 8 格内至多 5 个生物获得 3 秒飘浮Ⅱ; 0.5 秒后可以再用。
#   第二段: 朝准星高速俯冲, 落地/命中后原地产生半径 5 格的冲击。
# 【两段怎么分】用 zx.sv_air 标记"已跃升、等俯冲"; zx.sv_launch 是"还需几 tick 才能用";
#   zx.sv_rising 是"正在缓缓上升中"(第一段动画还没完)。本函数开头按这三个标记分支。
# 【★ 2026-10-04 改三次 ★】跃升不再是一瞬 tp 6 格 —— 玩家反馈"瞬间上去了没法测试"。
#   逐刻抬 0.2 格/30 刻(1.5 秒, 嫌太慢) -> 0.5 格/12 刻(0.6 秒) -> 现在 **0.6 格/10 刻
#   = 正好 0.5 秒**(共 6 格), 由 core/tick 推进; 到顶挂 zx.sv_air 进入"可俯冲"窗口。
#   【★ 二段解锁时机 ★】跃升到顶 **即** 解锁(rise_end 里 zx.sv_launch = 0), 所以
#   "0.5 秒后可用"= 跃升那 0.5 秒走完就能按第二下 —— 描述与体感一致。
#   【要在哪调速率】rise_step 的每刻高度(0.6) 与 core/tick 的步数上限(10) —— 两处配套。
#   【要在哪调"到顶后还要等几秒"】rise_end 里的 zx.sv_launch(现在 0)。
# 【两段都在同一个右键入口】因为武器是同一个 consume_item 进度触发的 —— 所以
#   分支判断必须放在本函数里, 而不是靠两个不同的入口。
# ============================================================

# ⓪ 撤销自己的进度 + 清掉可能残留的"俯冲加伤"标记
advancement revoke @s only sweetdream:equipment/axe/skyvault
tag @s remove zx.sv_high

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 正在缓缓跃升(第一段动画没结束) -> 什么都不做
execute if entity @s[tag=zx.sv_rising] run tellraw @s [{"text":"跃升中, 稍候…","color":"gray","italic":true}]
execute if entity @s[tag=zx.sv_rising] run return 0

# ③ 已经在"跃升待俯冲"状态 -> 走第二段(俯冲), 然后收工
execute if entity @s[tag=zx.sv_air] run function sweetdream:equipment/axe/skyvault/dive_ready
# 还没到解锁时间 -> dive_ready 会保留 zx.sv_air, 这里就收工
execute if entity @s[tag=zx.sv_air] run return 0
# 已经进入俯冲 -> 同样收工(别又去走跃升那段)
execute if entity @s[tag=zx.sv_dive] run return 0

# ④ 只读检查: 冷却 + 魔力 400
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:skyvault",mana:400.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"天穹冷却中, 还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足(需要 400)","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ⑤ 扣魔力 400
data modify storage manacore:in arg set value {uuid:"",value:400.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足(需要 400)","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ⑥ 起冷却 60 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:skyvault",cooldown_seconds:60.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑦ 第一段: 开始"缓缓跃升"(由 core/tick 每刻用 /tp 抬 0.6 格, 到顶转可俯冲)
#   【★ 步数从 1 起算 ★】core/tick 的顺序是"先抬(+1 前) -> 步数+1 -> 超上限收尾",
#   所以初值给 1 => 第 1 刻就开始上升、第 10 刻收尾, **正好 10 刻 = 0.5 秒**。
#   (初值给 0 的话第一刻是空转, 会多花一刻才到顶 —— 描述写 0.5 秒就对不上了。)
tag @s remove zx.sv_air
tag @s remove zx.sv_dive
tag @s add zx.sv_rising
scoreboard players set @s zx.sv_rise 1

# 8 格内至多 5 个生物飘浮Ⅱ 3 秒(被卷上来)
execute at @s run effect give @e[type=!#sweetdream:no_damage,distance=0.1..8,sort=nearest,limit=5] minecraft:levitation 3 1 true
# 自身给一段缓降: 否则跃升刚结束就摔回地面, 那 0.5 秒的准备时间根本按不出俯冲
effect give @s minecraft:slow_falling 5 0 true

# ⑧ 起手表现
execute at @s run particle minecraft:cloud ~ ~1 ~ 0.6 0.4 0.6 0.03 20 normal
execute at @s run particle minecraft:end_rod ~ ~1 ~ 0.6 0.4 0.6 0.05 16 normal
execute at @s run playsound minecraft:item.trident.riptide_1 player @a ~ ~ ~ 0.9 1.1
execute at @s run playsound minecraft:entity.ender_dragon.flap player @a ~ ~ ~ 0.6 1.3
