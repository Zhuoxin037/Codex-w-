$execute unless entity $(vx_uuid) run return 0

# ④ 它必须**未**带「噬心」
$execute as $(vx_uuid) if entity @s[tag=zx.status.shixin] run return 0

# ⑤ 拿 uuid
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

# ⑥ 消耗 60 魔力（够才扣）
data modify storage manacore:in arg set value {uuid:"",value:60.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function fallendream:lib/mana/pay_pas
execute unless data storage manacore:out r{success:1b} run return 0

# ⑦ 给它附加「噬心」（附着 -> tag/mark）
$data modify storage zx:work ic set value {target:"$(vx_uuid)",mark:"shixin"}
function fallendream:tag/mark with storage zx:work ic

# ⑧ ★ 缝心套装: 为"原本未带噬心"的生物成功附加后, 积攒 1 层「绯结」 ★
#   文案(套装段): "自身为原本未附有「噬心」的生物成功附加噬心后，积攒 1 层「绯结」
#   （最多 3 层，6 秒内最多积攒一次）。"
#   ★ 上一句 ④ 已经保证"原本未带" ⇒ 这里就是套装要的那个时机。
#   ★ 积攒与"是否消耗魔力成功"无关吗? 不是 —— 文案要求的是"成功附加噬心",
#     而附加发生在扣蓝成功之后, 所以排在 ⑥⑦ 之后正是"成功附加"成立的那一刻。
# 绯结由通用首次附着入口积攒，避免针眠重复计数。

# ⑧.5 ★ 超限(2026-11-22): 10 秒内第 3 次附加噬心 ⇒ 套装激活 / 绯结解锁 30 秒 ★
#   【文案】若自身在 10 秒内使用本装备触发了三次附加「噬心」效果且自身未激活套装
#     效果则激活，持续 30 秒。若已激活套装效果则「绯结」的积攒时间冷却限制和增伤
#     冷却限制去除，且层数提高至 5 层，持续 30 秒。
#   【★ 两种情形合并成一个 30 秒窗口 ★】本包里"套装效果"等于"穿齐两件就跑绯结",
#     没有单独的开启态; 所以"未激活→激活"与"已激活→解锁"落到同一个开关
#     zx.ns_set_end 上(窗口内 = 绯结解锁)。★ 口径待用户确认 ★
#   【窗口】zx.ns_win = 本窗口起点刻; 距起点超过 200 刻(10 秒)就清零重开一个窗口。
#     ★ 必须 add 0 再判 0: 计分项"没分数"时 if score 不成立, 不能拿它表达"从没记过"。
scoreboard players operation #ns_gap2 zx.meta = #now manacore.meta
scoreboard players operation #ns_gap2 zx.meta -= @s zx.ns_win
execute if score #ns_gap2 zx.meta matches 201.. run scoreboard players set @s zx.ns_n 0
execute if score #ns_gap2 zx.meta matches 201.. run scoreboard players set @s zx.ns_win 0
scoreboard players add @s zx.ns_win 0
execute if score @s zx.ns_win matches 0 run scoreboard players operation @s zx.ns_win = #now manacore.meta
scoreboard players add @s zx.ns_n 1
execute if score @s zx.ns_n matches 3.. run function fallendream:equipment/armor/needle_sleep/ol_set

# ⑨ 表现
$execute at $(vx_uuid) run particle minecraft:item{item:{id:"minecraft:amethyst_shard",count:1}} ~ ~0.8 ~ 0.3 0.4 0.3 0.02 6 normal
execute at @s run playsound minecraft:block.trial_spawner.place player @a ~ ~ ~ 0.5 1.5

# ⑩ 记下"下次可触发刻"（基础 现在 + 200 刻 = 10 秒 / 超限 + 160 刻 = 8 秒）
scoreboard players set #ns_gap zx.meta 200
execute if items entity @s armor.head *[minecraft:custom_data~{zx:["needle_sleep"],ol:"needle_sleep"}] run scoreboard players set #ns_gap zx.meta 160
scoreboard players operation @s zx.ns_cd = #now manacore.meta
scoreboard players operation @s zx.ns_cd += #ns_gap zx.meta

# ⑪ 收尾
$tag $(vx_uuid) remove zx.victim
