# ============================================================
# sweetdream:equipment/axe/frost_carve/cast —— 剜霜 · 主动技能(右键)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/axe/frost_carve(consume_item) -> rewards
# 【技能原文(必须和这里对上)】
#   ✦ 主动技能   魔力 200 · 冷却 30 秒
#   "使用后重击前方 4×3 格范围内的生物，造成一次相当于自身基础攻击力 ×5 的伤害，
#    之后使未处于冰冻状态的生物被冰冻 1 秒，已处于冰冻状态的生物解除冰冻，并额外
#    受到一次相当于自身基础攻击力 ×2 的伤害。若本次至少解除了两个生物的冰冻，
#    则为自身恢复最大生命值 10% 的生命。"
# 【★ 四要素 ★】
#   ① 触发: 右键。
#   ② 范围: "前方 4×3" -> area 的两段采样球(宽 4 精确 / 深略宽松, 完全跟随朝向)。
#   ③ 次数: 重击一次全体; 之后**每只**按自己当前是否被冻住二选一(冻 or 解冻+额外伤)。
#   ④ 时长: 冰冻 1 秒 = 20 刻(lib/freeze 的单位是**刻**) —— 由它自己按 zx.fz_end 解,
#      本技能不留任何计时。
# 【★ 通道 ★】两段都是**基础攻击力**的倍数(atk_mul 5 / 2, 不是最大魔力!)
#   ⇒ lib/skill_mul/def 里登记 wchan.frost_carve = {mm:0b,atk:1b,oth:0b}。
# 【★ "已处于冰冻状态"怎么认 ★】包内统一口径 = 标签 `zx.freeze`(lib/freeze 打的)。
#   不要读 TicksFrozen: 它 >= 140 只是"结霜外观", lib/freeze 之外的原版粉雪、
#   别的效果也会让它非 0, 语义对不上。
# 【★ 解冻必须走 lib/unfreeze_one ★】它不只清 TicksFrozen/速度乘区, 还是
#   「苦寒」钩子的广播点("解除冻结的那一刻")。自己手写会静默吞掉那个联动。
# 【★ 回血为什么用 10% 而不是固定点 ★】lib/heal 的入参是**整点数**, 所以这里先把
#   面板最大生命值(×1000 的整数)取出来, 连除两次 100 折成"10% 的整点"。
# ============================================================

# ⓪ 撤销自己的进度
advancement revoke @s only sweetdream:equipment/axe/frost_carve

# ⓪.5 【超限分流】敲过超限石(ol:"frost_carve")的剜霜:
#   300 蓝 / 35 秒 / 重击 ×6 / 解冻附伤 ×3 / 冰冻 3 秒 / 回血 20% / 新增「披霜」
#   判据判 ol 的**值**, 主副手都要判(与 liuguang/xiugou 同一套标准写法)。
scoreboard players set #frc_ol zx.meta 0
execute if items entity @s weapon.mainhand diamond_axe[minecraft:custom_data~{zx:["frost_carve"],ol:"frost_carve"}] run scoreboard players set #frc_ol zx.meta 1
execute if items entity @s weapon.offhand diamond_axe[minecraft:custom_data~{zx:["frost_carve"],ol:"frost_carve"}] run scoreboard players set #frc_ol zx.meta 1

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 只读检查: 冷却好没好 + 魔力 200 / 超限 300
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:frost_carve",mana:200.0}
execute if score #frc_ol zx.meta matches 1 run data modify storage manacore:in arg.mana set value 300.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check

execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"剜霜冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} if score #frc_ol zx.meta matches 0 run tellraw @s [{"text":"魔力不足（需要 200）","color":"red"}]
execute if data storage manacore:out r{reason:"mana"} if score #frc_ol zx.meta matches 1 run tellraw @s [{"text":"魔力不足（需要 300）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 前方有没有目标? 一个都没有就整个不放
execute rotated ~ 0 positioned ^ ^ ^2 unless entity @e[type=!#sweetdream:no_damage,distance=..2.0] run tellraw @s [{"text":"前方没有目标","color":"red"}]
execute rotated ~ 0 positioned ^ ^ ^2 unless entity @e[type=!#sweetdream:no_damage,distance=..2.0] run return fail

# ④ 扣魔力 -200 / 超限 -300
data modify storage manacore:in arg set value {uuid:"",value:200.0}
execute if score #frc_ol zx.meta matches 1 run data modify storage manacore:in arg.value set value 300.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run return fail

# ⑤ 记冷却 30 秒 / 超限 35 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:frost_carve",cooldown_seconds:30.0,reduce:1b}
execute if score #frc_ol zx.meta matches 1 run data modify storage manacore:in arg.cooldown_seconds set value 35.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑥ 重击伤害 = 基础攻击力 ×5 / 超限 ×6
data modify storage manacore:in arg set value {uuid:"",attack_mul:5.0}
execute if score #frc_ol zx.meta matches 1 run data modify storage manacore:in arg.attack_mul set value 6.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work frc.dmg5 set from storage manacore:out r.damage

# ⑦ 解冻额外伤害 = 基础攻击力 ×2 / 超限 ×3
data modify storage manacore:in arg set value {uuid:"",attack_mul:2.0}
execute if score #frc_ol zx.meta matches 1 run data modify storage manacore:in arg.attack_mul set value 3.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work frc.dmg2 set from storage manacore:out r.damage

# ⑦.5 本轮的时长参数交给 apply / heal_self 读(存 storage, 不走 zw.meta 假玩家 ——
#   中间 area 会调 api/damage, 那条链上的 hook 会动 #字头假玩家, 存不住)
#   icz = 冰冻刻数(1 秒 20 / 超限 3 秒 60)、pct = 回血百分比(10 / 20)
data modify storage zx:work frc.icz set value 20
execute if score #frc_ol zx.meta matches 1 run data modify storage zx:work frc.icz set value 60
data modify storage zx:work frc.pct set value 10
execute if score #frc_ol zx.meta matches 1 run data modify storage zx:work frc.pct set value 20
data modify storage zx:work frc.ol set value 0
execute if score #frc_ol zx.meta matches 1 run data modify storage zx:work frc.ol set value 1

# ⑧ 框"前方 4×3" + 打重击(命中者钉成 zx.frc_hit)
function sweetdream:equipment/axe/frost_carve/area

# ⑨ 逐只二选一: 已冻的 -> 解冻 + 额外伤害; 没冻的 -> 冻 1 秒
function sweetdream:equipment/axe/frost_carve/apply

# ⑩ 本次至少解除两个 -> 恢复最大生命值 10%(超限 20%)
execute if score #frc_thaw zx.meta matches 2.. run function sweetdream:equipment/axe/frost_carve/heal_self

# ⑩.5 超限: 同一条件再挂 3 层、持续 12 秒的「披霜」
execute if score #frc_thaw zx.meta matches 2.. run function sweetdream:equipment/axe/frost_carve/ol_wing

# ⑪ 清理本轮标记
tag @e[tag=zx.frc_hit,distance=0..] remove zx.frc_hit
tag @e[tag=zx.frc_thaw,distance=0..] remove zx.frc_thaw
tag @e[tag=zx.frc_cold,distance=0..] remove zx.frc_cold

# ⑫ 表现
execute rotated ~ 0 positioned ^ ^ ^2 run particle minecraft:snowflake ~ ~0.4 ~ 1.6 0.4 1.6 0.06 30 normal
execute rotated ~ 0 positioned ^ ^ ^2 run particle minecraft:snowflake ~ ~0.4 ~ 1.2 0.4 1.2 0.06 20 normal
playsound minecraft:block.amethyst_block.break player @a ~ ~ ~ 0.8 0.9
playsound minecraft:block.powder_snow.break player @a ~ ~ ~ 0.8 0.7
