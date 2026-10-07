# ============================================================
# sweetdream:equipment/armor/spine_symbiote/passive —— 脊骨共生的被动 + 套装
# ------------------------------------------------------------
# 【执行者】玩家(由 second 逐个 as @a 调进来)
# 【文案上写的(普通)】
#   ① 自身魔力值上限 -180
#   ② 每次击杀生物都会恢复自身 60 点魔力值(在 kill.mcfunction 里, 事件驱动)
#   ③ 当魔力值满后, 自身获得相当于自身魔力值上限 *0.03 的护甲值以及最大生命值
#   ④ 套装(脑髓蛭 + 脊骨共生): 魔力值满后获得抗性提升 II 及再生 II
# 【★ 超限(2026-10-07): 穿着的那件是「超限·脊骨共生」时整条换挡 ★】
#   ② 击杀回魔 60 -> 80; ③ 系数 0.03 -> 0.05; 另外多一样:
#   ④ 每次击杀给 20 秒的"上限×0.02"护甲/生命**定时**加成(见 kill.mcfunction);
#      若击杀那一刻自身处于脑髓蛭「蛊虫」的**消耗模式**(zx.bl_gm = 1,
#      玩家 2026-10-07 口径), 额外给 5 秒抗性提升Ⅴ(见 kill_overlimit)。
# 【套装为什么写在这一份里】套装要同时看两件, 放哪边都得知道另一件; 按
#   体外供能装置的先例统一放"后做的一件", 脑髓蛭那份只管自己。
# 【★ 关于 -180 把上限算成负数 ★】见 brain_leech/passive 顶部注释 —— 由
#   sweetdream:lib/mana_floor 统一兜底, 本件不做夹取。
# 【定时加成怎么落】和脑髓蛭一样: 把"基础 + 定时(未过期)"一起写进 #want,
#   再走 zx.ss_armor / zx.ss_hp 两本账做差值 —— 到期自然减回去。
# ============================================================

# ① 拿 UUID
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

# ② 自己穿了吗 / 脑髓蛭戴了吗(套装要两件都在) / 自己是不是超限版
scoreboard players set #ss_on zx.meta 0
execute if items entity @s armor.chest diamond_chestplate[custom_data~{zx:["spine_symbiote"]}] run scoreboard players set #ss_on zx.meta 1
scoreboard players set #ss_ol zx.meta 0
execute if items entity @s armor.chest diamond_chestplate[custom_data~{ol:"spine_symbiote"}] run scoreboard players set #ss_ol zx.meta 1
scoreboard players set #bl_on zx.meta 0
execute if items entity @s armor.head diamond_helmet[custom_data~{zx:["brain_leech"]}] run scoreboard players set #bl_on zx.meta 1
scoreboard players operation #set_on zx.meta = #ss_on zx.meta
scoreboard players operation #set_on zx.meta *= #bl_on zx.meta

# ③ 魔力上限 -180(账本 zx.ss_mana, 只加差值)
scoreboard players set #want zx.meta 0
execute if score #ss_on zx.meta matches 1 run scoreboard players set #want zx.meta -180
scoreboard players operation #diff zx.meta = #want zx.meta
scoreboard players operation #diff zx.meta -= @s zx.ss_mana
execute unless score #diff zx.meta matches 0 run function sweetdream:equipment/armor/spine_symbiote/apply_mana

# ④ 没穿就把定时加成清干净(穿着让它自己按到期时间走)
execute if score #ss_on zx.meta matches 0 run scoreboard players set @s zx.ss_ta 0
execute if score #ss_on zx.meta matches 0 run scoreboard players set @s zx.ss_te 0

# ⑤ 读一次魔力, 判断"满不满"(上限为 0 或负数时不算满)
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
execute store result score #mana zx.meta run data get storage manacore:out r.value
execute store result score #mana_max zx.meta run data get storage manacore:out r.max
scoreboard players set #full_mana zx.meta 0
execute if score #mana_max zx.meta matches 1.. if score #mana zx.meta >= #mana_max zx.meta run scoreboard players set #full_mana zx.meta 1

# ⑥ 目标加成 = floor(魔力上限 × 系数 / 100)(护甲和血量用同一个数)
#    系数: 3(普通) / 5(超限)
scoreboard players set #coef zx.meta 3
execute if score #ss_ol zx.meta matches 1 run scoreboard players set #coef zx.meta 5
scoreboard players set #want zx.meta 0
execute if score #ss_on zx.meta matches 1 if score #full_mana zx.meta matches 1 run scoreboard players operation #want zx.meta = #mana_max zx.meta
execute if score #ss_on zx.meta matches 1 if score #full_mana zx.meta matches 1 run scoreboard players operation #want zx.meta *= #coef zx.meta
execute if score #ss_on zx.meta matches 1 if score #full_mana zx.meta matches 1 run scoreboard players operation #want zx.meta /= #100 zx.meta

# ⑦ 再叠上"定时加成"(超限的击杀奖励, 未过期才有效)
execute if score #ss_on zx.meta matches 1 if score @s zx.ss_te > #now manacore.meta run scoreboard players operation #want zx.meta += @s zx.ss_ta

# ⑧ 护甲值(只有原版属性, 面板没有"护甲"这一项)
scoreboard players operation #diff zx.meta = #want zx.meta
scoreboard players operation #diff zx.meta -= @s zx.ss_armor
execute unless score #diff zx.meta matches 0 run function sweetdream:equipment/armor/spine_symbiote/apply_armor

# ⑨ 最大生命值(原版属性 + 面板, 和体外供能装置一样两边都要写)
scoreboard players operation #diff zx.meta = #want zx.meta
scoreboard players operation #diff zx.meta -= @s zx.ss_hp
execute unless score #diff zx.meta matches 0 run function sweetdream:equipment/armor/spine_symbiote/apply_hp

# ⑩ 套装: 魔力满 -> 抗性提升 II + 再生 II
#    给 3 秒、每秒刷新的写法: 条件不成立时它自己会在 3 秒内消失;
#    而 effect clear 在"本来就没有"时会失败, 那种失败会截断整个函数。
execute if score #set_on zx.meta matches 1 if score #full_mana zx.meta matches 1 run effect give @s minecraft:resistance 3 1 true
execute if score #set_on zx.meta matches 1 if score #full_mana zx.meta matches 1 run effect give @s minecraft:regeneration 3 1 true
