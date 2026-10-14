# ============================================================
# sweetdream:equipment/tool/everlit/strike —— 「灯灵」的一次结算(每 2 秒)
# ------------------------------------------------------------
# 【执行者】主人(@a[tag=zx.el_own]), 位置 = 主人自己
# 【文案(lore 逐字)】
#   「“灯灵”每 2 秒对自身 6 格内最近的一个生物造成一次相当于自身当前魔力值
#     ×0.02 的真实伤害。自身魔力值低于 200 时“灯灵”熄灭，不再造成伤害。」
# 【★ 基数为什么是"当前魔力" ★】走 calc 的 other 通道: other_base 默认取
#   arg.uuid 那个玩家的**当前魔力**, other_mul 设 0.02 就正好等于文案的式子,
#   不必自己拼定点乘法(先例 bow/dragon_tongue/fire 第 ② 步)。
# 【★ 为什么不先扣魔力 ★】坑 152 说的是"消耗型"技能(文案写了消耗 N 魔力)要
#   先扣后算, 否则会把"还没扣的钱"算进伤害。长明**不消耗**魔力 —— 它只是
#   "读取"当前魔力当基数, 所以这里没有扣蓝这一步。
# 【★ 熄灭 = 门槛而不是撤场 ★】魔力 < 200 时这一下不打(灯还亮着, 只是没火),
#   不 kill 灯灵 —— 回蓝上来自然恢复, 不需要重新召唤。
# 【真伤】sweetdream:true_damage —— 本包已注册(进 bypasses_armor +
#   bypasses_cooldown), 不需要退世界重进。走 api/damage 带 by <主人>, 击杀算玩家。
# ============================================================

# ① 当前魔力
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
scoreboard players set #el_m zx.meta 0
execute store result score #el_m zx.meta run data get storage manacore:out r.value 1

# ② 熄灭门槛: 魔力 < 200 -> 这一下不打(灯还在)
execute if score #el_m zx.meta matches ..199 run return 0

# ③ 伤害 = 当前魔力 ×0.02
data modify storage manacore:in arg set value {uuid:"",other_mul:0.02,other_base:-1.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc

# ④ 目标: 6 格内最近的 1 个生物(排掉玩家/marker/箭/display; distance 兼锁维度)
tag @e[tag=zx.el_t,distance=0..] remove zx.el_t
tag @e[type=!#sweetdream:no_damage,distance=..6,sort=nearest,limit=1] add zx.el_t
execute unless entity @e[tag=zx.el_t,distance=0..,limit=1] run return 0

# 捕获本次实际目标的位置，供模型转向；目标即使被这一击击杀也能完成动画。
data modify storage zx:elvis target set from entity @e[tag=zx.el_t,distance=0..,limit=1] Pos
data modify storage zx:elvis owner set value {uuid:""}
data modify storage zx:elvis owner.uuid set from storage zx:data self.uuid
function sweetdream:equipment/tool/everlit/visual/aim with storage zx:elvis owner

# ⑤ 真实伤害
data modify storage zx:in arg set value {target:"@e[tag=zx.el_t,distance=0..,limit=1]",damage:0.0,type:"sweetdream:true_damage",read:"manacore"}
function sweetdream:api/damage

# ⑥ 表现: 灯焰扑向目标
execute at @e[tag=zx.el_t,distance=0..,limit=1] run particle minecraft:small_flame ~ ~1.0 ~ 0.25 0.4 0.25 0.03 12 normal
execute at @e[tag=zx.el_t,distance=0..,limit=1] run particle minecraft:flash ~ ~1.0 ~ 0.1 0.1 0.1 0.01 1 normal

tag @e[tag=zx.el_t,distance=0..] remove zx.el_t
return 1
