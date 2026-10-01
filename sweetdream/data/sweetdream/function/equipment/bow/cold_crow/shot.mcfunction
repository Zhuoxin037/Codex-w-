# ============================================================
# sweetdream:equipment/bow/cold_crow/shot —— 每次射击
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/bow/cold_crow(触发器 shot_crossbow)
#   选了弩来做底材, 就是因为有 shot_crossbow 这个"射击"事件(弓没有)。
# 【文案】消耗 20/50/120/320(按「冰凌」层数); 每次射击积攒 1 点冰凌;
#   一层冰冻 2 秒 / 二层 2 格内冰冻 2 秒 / 三层 3 格内冰冻 2 秒 + 最大魔力×0.1 /
#   四层 4 格内冰冻 3 秒 + 最大魔力×0.25, 之后清空冰凌。
# 【顺序】这一发的层数 = **射击前**的冰凌 + 1(文案说"根据弓目前的冰凌")。
#   所以先算层数、扣魔力, 再决定"冰凌 +1 还是清空"。
# 【★ 魔力是射出去之后才扣的 ★】射击事件发生在箭离弦之后, 所以不可能"没蓝就不射";
#   这里只能"没蓝就不生效"(给一句提示)。这点和剑那套(先查后扣)不一样。
# 【这发箭怎么带上"层数"和"伤害"】箭不知道自己是谁射的, 也不知道面板是多少,
#   所以要把三样东西交给它:
#     zx.cc_tier 计分项   —— 这一发是第几层(箭的命中结算要按它选范围和冰冻时长)
#     data.zx.cc.dmg      —— 射手算好的伤害(最大魔力 ×0.1 / ×0.25, 已过"下一次技能加成")
#     data.zx.cc.u0..u3   —— 射手的 UUID 四个整数(打伤害时用来算击杀归属)
#   之后由 core/tick 的 arrow_tick 盯着这支箭, 看它撞到了谁。
#   (和"法球"是同一套思路: 飞行物只负责飞, 数值在发射时就算好。)
# 【★ 这一发怎么和"打中了谁"对上 ★】
#   以前试过"在射击这一 tick 去认领场上那支箭", 结果反复出问题: 地上插着的老箭
#   往往比刚飞出去的新箭更近, 数据就写错了对象; 而且进度触发时机还可能早于箭进世界。
#   现在改成让**原版自己判断命中**: 给寒鸦加了一个数据包附魔「霜矢」
#   (sweetdream:cold_crow), 它的 post_attack 回调会在"这把弩射出的箭打中生物"时触发
#   (原版 punch 就是这么判断 direct_attacker 是箭头的) —— 于是:
#     · 命中判定交给原版, 我们不再需要认箭
#     · 这一 tick 只负责算好数值并存到射手名下(zx:data cc."<uuid>")
#     · 打中以后由 hook_victim / fire 去读出来结算
#   ⚠️ 附魔属于**注册表**内容: 第一次装(或者改动它)之后要**退出世界再进**,
#      光 /reload 不够 —— 没生效的话寒鸦就是"射得出去、什么都不发生"。
# ============================================================

advancement revoke @s only sweetdream:equipment/bow/cold_crow
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail
scoreboard players add @s zx.cc_ice 0

# ① 这一发的层数 = 当前冰凌 + 1
scoreboard players operation #tier zx.meta = @s zx.cc_ice
scoreboard players add #tier zx.meta 1

# ② 按层数扣魔力
scoreboard players set #cost zx.meta 20
execute if score #tier zx.meta matches 2 run scoreboard players set #cost zx.meta 50
execute if score #tier zx.meta matches 3 run scoreboard players set #cost zx.meta 120
execute if score #tier zx.meta matches 4 run scoreboard players set #cost zx.meta 320
data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #cost zx.meta
function manacore:api/mana/consume
execute if data storage manacore:out r{success:0b} run tellraw @s [{"text":"魔力不足 —— 这一箭没有冰凌效果","color":"red"}]
execute if data storage manacore:out r{success:0b} run return fail

# ③ 算这一发的伤害(只有 3/4 层用得上, 但一起算省得两套代码)
data modify storage manacore:in arg set value {uuid:"",key:"max_mana"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
data modify storage manacore:in arg set value {uuid:"",base_attack:-1.0,skill_multiplier:0.1,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
execute if score #tier zx.meta matches 4 run data modify storage manacore:in arg.skill_multiplier set value 0.25
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.base_attack set from storage manacore:out r.value
data modify storage zx:work wg.uuid set from storage zx:data self.uuid
function sweetdream:lib/max_mana_bonus with storage zx:work wg
function manacore:api/damage/calc

# ④ 把这一发的数据记在射手名下, 然后**立刻**沿准星探一次(见 store / cast / step)
data modify storage zx:work cc.uuid set from storage zx:data self.uuid
execute store result storage zx:work cc.tier int 1 run scoreboard players get #tier zx.meta
data modify storage zx:work cc.dmg set value 0.0
data modify storage zx:work cc.dmg set from storage manacore:out r.damage
execute store result storage zx:work cc.u0 int 1 run data get entity @s UUID[0]
execute store result storage zx:work cc.u1 int 1 run data get entity @s UUID[1]
execute store result storage zx:work cc.u2 int 1 run data get entity @s UUID[2]
execute store result storage zx:work cc.u3 int 1 run data get entity @s UUID[3]
function sweetdream:equipment/bow/cold_crow/store with storage zx:work cc

# ⑤ 命中判定: 由弩上自带的附魔「霜矢」回调(hook_victim)完成 —— 原版判定"这支箭打中了谁"。
#   【备用方案】如果哪天附魔路线出问题, 把下面这行的注释去掉即可: 改成"射击瞬间沿准星探",
#   探到生物就地结算(没用附魔, 不依赖注册表, 只是效果出现在射出瞬间而不是箭到达时)。
# function sweetdream:equipment/bow/cold_crow/cast with storage zx:work cc

# ⑤ 冰凌: 1~3 层 +1; 第 4 层用掉后清空
execute if score #tier zx.meta matches 4 run scoreboard players set @s zx.cc_ice 0
execute unless score #tier zx.meta matches 4 run scoreboard players add @s zx.cc_ice 1

# ⑥ 表现: 层数越高, 冰屑越多、音调越高
execute at @s run particle minecraft:snowflake ~ ~1.3 ~ 0.5 0.4 0.5 0.02 12 normal
execute at @s run particle minecraft:item_snowball ~ ~1.3 ~ 0.3 0.3 0.3 0.02 8 normal
execute at @s run playsound minecraft:item.crossbow.shoot player @a ~ ~ ~ 0.7 1.2
execute if score #tier zx.meta matches 4 run playsound minecraft:block.glass.break player @a ~ ~ ~ 0.8 1.5
