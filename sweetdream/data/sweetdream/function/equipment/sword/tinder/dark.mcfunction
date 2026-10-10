# ============================================================
# sweetdream:equipment/sword/tinder/dark —— 熄灭态: 反噬自己 + 点燃自己
# ------------------------------------------------------------
# 【谁调用它】tinder/hit(熄灭态分支)
# 【执行者】施法者(玩家)
# 【两步】① 对**自身**造成 最大生命值 ×0.3 的伤害。② 使「火种」变为燃烧状态。
# 【伤害怎么算】读面板最大生命(manacore:api/stats/get key=max_health, 出参 ×100),
#   ×0.3 = 面板值 ×3 / 1000(整数, 精度足够)。用 api/damage 打自己(target="@s")。
# ============================================================

# 钉死被击者(这里只用它确认"确实打到了生物")
function sweetdream:lib/victim
execute unless entity @e[tag=zx.victim,limit=1] run return 0

# uuid + 读最大生命
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",key:"max_health"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get

scoreboard players set #td_hp zx.meta 0
execute store result score #td_hp zx.meta run data get storage manacore:out r.value 100

# 伤害 = 面板最大生命(×100) × 0.3 = ×3 / 1000
#   除法分两步(#100 与 #10 都是 core/load 注册过的常数假玩家; 没有 #1000 这个常数)
scoreboard players operation #td_dmg zx.meta = #td_hp zx.meta
scoreboard players operation #td_dmg zx.meta *= #3 zx.meta
scoreboard players operation #td_dmg zx.meta /= #100 zx.meta
scoreboard players operation #td_dmg zx.meta /= #10 zx.meta

# ① 对自身打伤害
data modify storage zx:in arg set value {target:"@s",damage:0.0}
execute store result storage zx:in arg.damage double 1 run scoreboard players get #td_dmg zx.meta
function sweetdream:api/damage

# ② 变为燃烧状态
scoreboard players set @s zx.td_on 1
#   ★ 当刻就换成"燃烧"外观(不等下一秒 second 的兜底): 点着了, 剑要立刻烧起来
function sweetdream:equipment/sword/tinder/visual/sync

# 表现: 身上腾起火焰(烧起来了)
execute at @s run particle minecraft:flame ~ ~1 ~ 0.4 0.6 0.4 0.03 20 normal
execute at @s run playsound minecraft:item.firecharge.use player @a ~ ~ ~ 0.8 0.8

# 清理 victim
tag @e[tag=zx.victim] remove zx.victim
