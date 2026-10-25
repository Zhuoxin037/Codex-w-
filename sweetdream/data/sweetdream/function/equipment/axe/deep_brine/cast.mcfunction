# ============================================================
# sweetdream:equipment/axe/deep_brine/cast —— 重溟 · 主动技能(右键)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/axe/deep_brine(consume_item) -> rewards
# 【技能原文(必须和这里对上)】
#   魔力 280 / 冷却 45 秒。
#   "使用后重击自身前方 5×4 格范围内的全部生物，造成一次相当于自身最大魔力值
#    ×0.1 的伤害。若命中了附有「渊海」的生物，则消耗其中最多 2 个生物的「渊海」。
#    每消耗一个则在其位置生成一个半径 3 格、持续 4 秒的领域。领域内的生物每秒
#    受到一次相当于自身最大魔力值 ×0.03 的伤害，且持续被拉向中心。"
# 【★ 四要素逐个落实 ★】
#   ① 触发: 右键。
#   ② 目标范围: "自身前方 5×4 格" -> 见 area(世界轴方盒近似, 口径同 烈火残躯)。
#   ③ 次数: 立即 1 次(×0.1); 领域**每秒 1 次**(×0.03), 共 4 次。
#   ④ 时长: 领域持续 4 秒(marker 上 zx.db_ft=4, lib/second 每秒 -1, 归零 kill)。
# 【伤害口径】两段都是"自身最大魔力值" -> max_mana_mul 通道(0.1 / 0.03)。
# 【数值改哪】倍率 0.1 / 0.03 = 下面两处 max_mana_mul; 判定盒形状 = area;
#   领域半径 3 = field_tick 的 distance=..3; 领域时长 4 = field_one 的 zx.db_ft。
# 【★ "消耗其中最多 2 个"的挑法(原文没写) ★】
#   2026-10-16 实装口径: 取**离施法者最近的 2 个**(与沉渊"6 格内最近一只"同一读法;
#   原文没写"随机"就不随机 —— 长夜那件明写"随机 1 个"才随机)。
# 【★ 消耗必须由施法者发起 ★】余烬/回潮扣/烛跬 认的是"消耗者"(见 lib/on_consume),
#   所以调 lib/mark_consume 时 **@s 必须还是玩家**, 目标写成选择器字符串(dom_one)。
# 【★ 只有真的摘掉才生成领域 ★】穿「永恒」时 consum 会变成"原地刷新"(done=1b),
#   那不是消耗 -> 不生成领域。判据见 lib/mark_take。
# ============================================================

# ⓪ 撤销自己的进度
advancement revoke @s only sweetdream:equipment/axe/deep_brine

# ⓪.6 这一次是不是超限版(亲手/副手那把带 ol:"deep_brine")
scoreboard players set @s zx.db_ol 0
execute if items entity @s weapon.mainhand diamond_axe[custom_data~{ol:"deep_brine"}] run scoreboard players set @s zx.db_ol 1
execute if items entity @s weapon.offhand diamond_axe[custom_data~{ol:"deep_brine"}] run scoreboard players set @s zx.db_ol 1

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ② 只读检查: 冷却 + 魔力 280 / 超限 400
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:deep_brine",mana:280.0}
execute if score @s zx.db_ol matches 1 run data modify storage manacore:in arg.mana set value 400.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/skill/check
execute if data storage manacore:out r{reason:"cooldown"} run tellraw @s [{"text":"重溟冷却中，还剩 ","color":"red"},{"nbt":"r.remaining","storage":"manacore:out"},{"text":" tick","color":"red"}]
execute if score @s zx.db_ol matches 0 if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 280）","color":"red"}]
execute if score @s zx.db_ol matches 1 if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足（需要 400）","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 前方有目标吗? 没有就整个不放(不扣蓝、不进冷却)
#   判据 = "朝向保留、俯仰归零后, 前方 2 格处半径 2.5 的球" —— 只是"有没有人"的门槛,
#   形状与 area 的受力区同源(省一次完整框选)。
execute rotated ~ 0 positioned ^ ^ ^2 unless entity @e[type=!#sweetdream:no_damage,distance=..2.5] run tellraw @s [{"text":"前方没有目标","color":"red"}]
execute rotated ~ 0 positioned ^ ^ ^2 unless entity @e[type=!#sweetdream:no_damage,distance=..2.5] run return fail

# ④ 扣魔力 280 / 超限 400
data modify storage manacore:in arg set value {uuid:"",value:280.0}
execute if score @s zx.db_ol matches 1 run data modify storage manacore:in arg.value set value 400.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ⑤ 起冷却 45 秒
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:deep_brine",cooldown_seconds:45.0,reduce:1b}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/start

# ⑥ 算立即段伤害: 自身最大魔力值 ×0.1 / 超限 ×0.12(给 area 用)
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.1}
execute if score @s zx.db_ol matches 1 run data modify storage manacore:in arg.max_mana_mul set value 0.12
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work db.dmg set from storage manacore:out r.damage

# ⑦ 算领域段伤害(先算好写进 marker 的 NBT): 自身最大魔力值 ×0.03
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.03}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc
data modify storage zx:work dbf.dmg set from storage manacore:out r.damage

# ⑦.2 领域 marker 的"击杀归属" = 施法者 UUID 四个整数
#   (与威霆 open ④ 一致: 直接抄 @s 的 UUID, 不用绕 manacore:players 的文本路径)
data modify storage zx:work dbf.u0 set from entity @s UUID[0]
data modify storage zx:work dbf.u1 set from entity @s UUID[1]
data modify storage zx:work dbf.u2 set from entity @s UUID[2]
data modify storage zx:work dbf.u3 set from entity @s UUID[3]

# ⑧ 框出"前方 5×4"并打立即段伤害(见 area)
function sweetdream:equipment/axe/deep_brine/area

# ⑨ 从"这一发打到的"里挑出带「渊海」的 -> 普通版就近取最多 2 个, 超限版**全部**
#   ★ 必须排在 ⑧ **之后**: 此刻 zx.db_hit 才是"这一发打到的那批"。
tag @e[tag=zx.db_ysel] remove zx.db_ysel
execute as @e[tag=zx.db_hit,distance=0..] if entity @s[tag=zx.status.yuanhai] run tag @s add zx.db_ysel

execute if score @s zx.db_ol matches 1 run function sweetdream:equipment/axe/deep_brine/ol_dom_all
execute if score @s zx.db_ol matches 0 run function sweetdream:equipment/axe/deep_brine/dom_two

# ⑩ 收尾: 清本轮全部临时标签, 不留残余
tag @e[tag=zx.db_ysel] remove zx.db_ysel
tag @e[tag=zx.db_hit,distance=0..] remove zx.db_hit

# ⑪ 表现: 重击的浪压
execute at @s run playsound minecraft:entity.player.attack.sweep player @a ~ ~ ~ 1.0 0.7
execute at @s run playsound minecraft:block.conduit.deactivate player @a ~ ~ ~ 0.8 0.9
