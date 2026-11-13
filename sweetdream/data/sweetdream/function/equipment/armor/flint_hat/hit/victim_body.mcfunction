$execute unless entity $(vx_uuid) run return 0

# ④ 它必须**未**带「流火」（已经烧着的不用再点一次）
$execute as $(vx_uuid) if entity @s[tag=zx.status.liuhuo] run return 0

# ⑤ 拿 uuid（下面扣魔力的公共输入口要它）
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

# ⑥ 消耗 20 魔力（够才扣；不够就直接收工，什么都不做）
data modify storage manacore:in arg set value {uuid:"",value:20.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay_pas
execute unless data storage manacore:out r{success:1b} run return 0

# ⑦ 给它附加「流火」（附着 -> tag/mark；tag/mark 内部会一并挂上 15 秒计时与图标）
$data modify storage zx:work ic set value {target:"$(vx_uuid)",mark:"liuhuo"}
function sweetdream:tag/mark with storage zx:work ic

# ⑧ 表现
$execute at $(vx_uuid) run particle minecraft:flame ~ ~0.6 ~ 0.3 0.4 0.3 0.01 8 normal
execute at @s run playsound minecraft:item.flintandsteel.use player @a ~ ~ ~ 0.6 1.2

# ⑨ 记下"下次可触发刻"（现在 + 160 刻 = 8 秒）
scoreboard players operation @s zx.fh_cd = #now manacore.meta
scoreboard players operation @s zx.fh_cd += #160 zx.meta

# ⑩ 收尾
$tag $(vx_uuid) remove zx.victim
