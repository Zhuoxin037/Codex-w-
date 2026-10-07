# ============================================================
# sweetdream:upgrade/api/boil —— 「沸腾」: 冻结 + 燃烧 同时成立 -> 追加真实伤害
# ------------------------------------------------------------
# 【谁调用它】upgrade/api/on_hit 的第 ④ 步(已确认主手这件装了 沸腾)
# 【执行者】动手的玩家   【前置】调用方已经跑过 lib/victim, zx.victim = 刚被打的那只
# 【文案】自身每次攻击生物时，若其同时处于冻结和燃烧状态则对其额外造成
#         相当自身最大魔力值 ×0.05 的真实伤害。
# 【★ "冻结"和"燃烧"怎么判 ★】都用原版自己记的 NBT, 逐实体 data get 出来比:
#   · 燃烧 = Fire  > 0(站在火里/被点燃剩余时间)
#   · 冻结 = TicksFrozen > 0(原版细雪冻结进度; 归零后会有 140 tick 的"寒冷"缓冲,
#     这里按 NBT 原值判, 不加额外缓冲)
#   ⚠️ 不能在 NBT 过滤器里写 {Fire:1..} —— 1.21.5 会报"应为十进制数"并让
#      **整个函数加载失败**(check 规则 73 nbtrange)。必须逐实体读出来再比。
# 【★ "真实伤害" = sweetdream:true_damage ★】本包自己注册的伤害类型, 无视护甲。
#   走 manacore 的伤害公式(基数 = 面板最大魔力)算出数, 再用这个类型打出去。
# 【★ 顺序: 先算伤害再打 ★】calc 会读施法者的面板, 与"目标是谁"无关, 所以先算;
#   打的时候才有目标。别把 calc 挪到"确认冻结+燃烧"之前又放到后面重复算。
# ============================================================

# ① 目标同时"冻结 + 燃烧"吗
scoreboard players set #bo_f zx.meta 0
scoreboard players set #bo_i zx.meta 0
execute as @e[tag=zx.victim,limit=1] store result score #bo_f zx.meta run data get entity @s TicksFrozen
execute as @e[tag=zx.victim,limit=1] store result score #bo_i zx.meta run data get entity @s Fire
execute unless score #bo_f zx.meta matches 1.. run return 0
execute unless score #bo_i zx.meta matches 1.. run return 0

# ② 伤害 = 自身最大魔力值 ×0.05
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.05,independent_multiplier:1.0,custom_damage:0.0,health_ratio:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/damage/calc

# ③ 打出去(真实伤害: 无视护甲)
data modify storage zx:in arg set value {target:"@e[tag=zx.victim]",read:"manacore",type:"sweetdream:true_damage"}
function sweetdream:api/damage

# ④ 表现: 白汽混火星("又冷又热"的观感)
execute at @e[tag=zx.victim] run particle minecraft:small_gust ~ ~1 ~ 0.4 0.5 0.4 0.02 10 normal
execute at @e[tag=zx.victim] run particle minecraft:flame ~ ~1 ~ 0.4 0.5 0.4 0.02 10 normal
execute at @e[tag=zx.victim] run playsound minecraft:block.lava.extinguish player @a ~ ~ ~ 0.5 1.5
