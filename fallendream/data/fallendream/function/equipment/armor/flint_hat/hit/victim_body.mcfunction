$execute unless entity $(vx_uuid) run return 0

# ④ 它必须**未**带「流火」（已经烧着的不用再点一次）
$execute as $(vx_uuid) if entity @s[tag=zx.status.liuhuo] run return 0

# ⑤ 拿 uuid（下面扣魔力的公共输入口要它）
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

# ⑤.5 超限档快照(决定 魔力 15 / 节流 6 秒 / 加强态)
scoreboard players set #fh_ol zx.meta 0
execute if items entity @s armor.head *[minecraft:custom_data~{zx:["flint_hat"],ol:"flint_hat"}] run scoreboard players set #fh_ol zx.meta 1

# ⑥ 消耗魔力（够才扣；不够就直接收工，什么都不做）—— 基础 20 / 超限 15
data modify storage manacore:in arg set value {uuid:"",value:20.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute if score #fh_ol zx.meta matches 1 run data modify storage manacore:in arg.value set value 15.0
function fallendream:lib/mana/pay_pas
execute unless data storage manacore:out r{success:1b} run return 0

# ⑦ 给它附加「流火」（附着 -> tag/mark；tag/mark 内部会一并挂上 15 秒计时与图标）
$data modify storage zx:work ic set value {target:"$(vx_uuid)",mark:"liuhuo"}
function fallendream:tag/mark with storage zx:work ic

# ⑦.5 超限·加强态: 本次附加的「流火」额外让它的**基础护甲值 −50%**
#   ★ 必须排在 tag/mark **之后** —— 先挂削减再挂标签, 中间万一被"已有流火"的判据
#     拦下, 就留下一份永远没人撤的 −50%。
#   ★ 削减跟着「流火」走: 摘标签由 lib/second 扫 zx.fh_strip 撤(见 defortify)。
$execute if score #fh_ol zx.meta matches 1 if score @s zx.fh_amp matches 1 as $(vx_uuid) run function fallendream:equipment/armor/flint_hat/fortify
execute if score #fh_ol zx.meta matches 1 run scoreboard players set @s zx.fh_amp 0

# ⑧ 表现
$execute at $(vx_uuid) run particle minecraft:flame ~ ~0.6 ~ 0.3 0.4 0.3 0.01 8 normal
execute at @s run playsound minecraft:item.flintandsteel.use player @a ~ ~ ~ 0.6 1.2

# ⑨ 记下"下次可触发刻"（基础 +160 刻 = 8 秒 / 超限 +120 刻 = 6 秒）
scoreboard players operation @s zx.fh_cd = #now manacore.meta
execute unless score #fh_ol zx.meta matches 1 run scoreboard players add @s zx.fh_cd 160
execute if score #fh_ol zx.meta matches 1 run scoreboard players add @s zx.fh_cd 120

# ⑩ 收尾
$tag $(vx_uuid) remove zx.victim
