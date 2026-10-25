# ============================================================
# sweetdream:equipment/axe/draught/ol_second —— 超限·饮鸩的第二形态
# ------------------------------------------------------------
# 【谁调用它】draught/cast 的 ①.5(上一轮已经放过超限·饮鸩 => zx.dg_ol2 = 1)
# 【执行者】玩家
# 【文案】"之后若自身的血量高于 60% 则可以再次使用该技能，且本技能效果改为
#   每攻击一次生物则自身受到一次相当于自身最大生命值 ×0.1 的真实伤害，之后
#   使自身基础攻击力 +10%，持续 10 秒且最多触发四次。"
# 【★ 为什么在这里再收一次魔**不**查冷却 ★】
#   两段共用同一条 80 秒冷却(第一段已经起过了)。第二段若也走 manacore 的
#   skill/check, 冷却没走完就永远放不出来 —— 文案说的"可以再次使用"是**紧接着**
#   就能用, 所以这里只查魔力。
# 【★ #dg2 的作用】进函数第一行就置 1 = "这一下右键我已接管"。不管成功失败,
#   外面的 cast 都直接收工; 否则失败(血量不够/蓝不够)时会掉进第一形态,
#   变成"想放第二段结果又自伤了一次 80%"这种灾难。
# 【进入第二形态之后】每一下平A 触发 ol_hit(见 advancement/equipment/axe/draught_hit)。
# ============================================================

scoreboard players set #dg2 zx.meta 1

# ① 血量 > 60%?
execute store result score #dg_hp zx.meta run data get entity @s Health 100
data modify storage manacore:in arg set value {uuid:"",key:"max_health"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
scoreboard players set #dg_mh zx.meta 0
execute store result score #dg_mh zx.meta run data get storage manacore:out r.value 100
scoreboard players operation #dg_need zx.meta = #dg_mh zx.meta
scoreboard players operation #dg_need zx.meta *= #60 zx.meta
scoreboard players operation #dg_need zx.meta /= #100 zx.meta
execute if score #dg_hp zx.meta < #dg_need zx.meta run tellraw @s [{"text":"饮鸩: 血量需高于 60% 才能使用第二形态","color":"red"}]
execute if score #dg_hp zx.meta < #dg_need zx.meta run return 0

# ② 扣魔力 360(不查冷却, 见文件头)
data modify storage manacore:in arg set value {uuid:"",value:360.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function sweetdream:lib/mana/pay
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足（需要 360）","color":"red"}]
execute if data storage manacore:out r{success:0b} run return 0

# ③ 进第二形态: 关掉"可再次使用"、开模式 2、触发次数归零、计时清 0(等第一下平A才起表)
scoreboard players set @s zx.dg_ol2 0
scoreboard players set @s zx.dg_mode 2
scoreboard players set @s zx.dg_n 0
scoreboard players set @s zx.dg_on2 0

# ④ 表现
execute at @s run particle minecraft:item{count:8,item:{id:"minecraft:fermented_spider_eye"}} ~ ~1 ~ 0.5 0.5 0.5 0.08 16 normal
execute at @s run particle minecraft:witch ~ ~1 ~ 0.3 0.5 0.3 0.02 10 normal
execute at @s run playsound minecraft:entity.generic.drink player @a ~ ~ ~ 0.9 0.5
tellraw @s [{"text":"饮鸩·第二形态: 接下来 4 次攻击, 每次自伤 10% 最大生命换 10% 基础攻击力","color":"dark_red"}]
