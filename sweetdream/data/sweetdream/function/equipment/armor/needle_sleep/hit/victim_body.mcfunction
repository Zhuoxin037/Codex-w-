$execute unless entity $(vx_uuid) run return 0

# ④ 它必须**未**带「噬心」
$execute as $(vx_uuid) if entity @s[tag=zx.status.shixin] run return 0

# ⑤ 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

# ⑥ 消耗 60 魔力（够才扣）
data modify storage manacore:in arg set value {uuid:"",value:60.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay_pas
execute unless data storage manacore:out r{success:1b} run return 0

# ⑦ 给它附加「噬心」（附着 -> tag/mark）
$data modify storage zx:work ic set value {target:"$(vx_uuid)",mark:"shixin"}
function sweetdream:tag/mark with storage zx:work ic

# ⑧ ★ 缝心套装: 为"原本未带噬心"的生物成功附加后, 积攒 1 层「绯结」 ★
#   文案(套装段): "自身为原本未附有「噬心」的生物成功附加噬心后，积攒 1 层「绯结」
#   （最多 3 层，6 秒内最多积攒一次）。"
#   ★ 上一句 ④ 已经保证"原本未带" ⇒ 这里就是套装要的那个时机。
#   ★ 积攒与"是否消耗魔力成功"无关吗? 不是 —— 文案要求的是"成功附加噬心",
#     而附加发生在扣蓝成功之后, 所以排在 ⑥⑦ 之后正是"成功附加"成立的那一刻。
function sweetdream:equipment/armor/crimson_seam/knit_add

# ⑨ 表现
$execute at $(vx_uuid) run particle minecraft:item{item:{id:"minecraft:amethyst_shard",count:1}} ~ ~0.8 ~ 0.3 0.4 0.3 0.02 6 normal
execute at @s run playsound minecraft:block.trial_spawner.place player @a ~ ~ ~ 0.5 1.5

# ⑩ 记下"下次可触发刻"（现在 + 200 刻 = 10 秒）
scoreboard players operation @s zx.ns_cd = #now manacore.meta
scoreboard players operation @s zx.ns_cd += #200 zx.meta

# ⑪ 收尾
$tag $(vx_uuid) remove zx.victim
