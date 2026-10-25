# ============================================================
# sweetdream:equipment/staff/thunderrod/attack —— 引雷针: 普攻(普通右键)
# ------------------------------------------------------------
# 【文案】魔力 20 / 伤害 1; 每次普攻命中后, 1 秒后在目标所在位置降下一道闪电。
# 【★ 法球的 1 点伤害只是"引子" ★】(先例: 调色盘普攻也是"伤害 1");
#   真正的效果在 1 秒后那道雷 —— 由 ball_hit 登记一个 marker(zx.tr_pend,
#   到期刻 = now+20), core/tick 到点触发 pend_go。
#   ★ 2026-10-13 起那道雷**只降雷**, 不再有"当前魔力 ×0.03"的伤害
#     (落点 2 格选不到人 + 会超模, 用户拍板砍掉, 详见 bolt_atk 头注)。
# 【★ hit 回调怎么挂 ★】法球 launcher 会读 zx:work ball.hit; 这里用 **set value**
#   整份替换(绝不能用 merge —— merge 会把上一发残留的键带下来, 见
#   projectile/ball/fire 第 ① 步的事故说明)。
# 【★ 间隔门控必须在扣魔力之前 ★】staff/gate 拦晚了就成了"扣了蓝但没出手"。
# ============================================================

# ① 法杖普攻间隔 0.5 秒(10 刻)
function sweetdream:equipment/staff/gate
execute if score #st_gate zx.meta matches 0 run return fail
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ①.2 拍下超限乘区
function sweetdream:overlimit/api/snap

# ①.3 超限判定(批 K9): 主/副手任一件是超限·引雷针
#   超限·普攻: 魔力 20→**60**、1 秒后的闪电 1→**2 道**(道数在 ball_hit 里按球上的
#   ol 标记分流 —— 命中回调以法球为执行者, 读不到玩家手上的杖)。
scoreboard players set #tr_ol zx.meta 0
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["thunderrod"],ol:"thunderrod"}] run scoreboard players set #tr_ol zx.meta 1
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["thunderrod"],ol:"thunderrod"}] run scoreboard players set #tr_ol zx.meta 1

# ② 只读检查: 魔力 20(普攻不进冷却)
data modify storage manacore:in arg set value {uuid:"",skill:"sweetdream:tr_attack",mana:20.0}
execute if score #tr_ol zx.meta matches 1 run data modify storage manacore:in arg.mana set value 60.0
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage zx:work olv.mana set from storage manacore:in arg.mana
function sweetdream:overlimit/api/mod
function manacore:api/skill/check
scoreboard players set #tr_need zx.meta 0
execute store result score #tr_need zx.meta run data get storage zx:work olv.mana 1
execute if data storage manacore:out r{reason:"mana"} run tellraw @s [{"text":"魔力不足(需要 ","color":"red"},{"score":{"name":"#tr_need","objective":"zx.meta"},"color":"red"},{"text":")","color":"red"}]
execute unless data storage manacore:out r{success:1b} run return fail

# ③ 扣魔力 20(超限后的值)
data modify storage manacore:in arg set value {uuid:"",value:20.0}
data modify storage manacore:in arg.value set from storage zx:work olv.mana
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足(需要 ","color":"red"},{"score":{"name":"#tr_need","objective":"zx.meta"},"color":"red"},{"text":")","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ④ 普攻直伤 = 1(引子, 不吃倍率 —— 落雷才是主体)
#   ol = 这一发是不是超限版(给 ball_hit 的"降两道雷"用)
data modify storage zx:work ball set value {dmg:1.0,style:"thunderrod",ol:0b}
execute if score #tr_ol zx.meta matches 1 run data modify storage zx:work ball.ol set value 1b
data modify storage zx:work ball.hit set value "sweetdream:equipment/staff/thunderrod/ball_hit"
function sweetdream:equipment/staff/attack
