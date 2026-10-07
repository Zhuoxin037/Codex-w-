# ============================================================
# sweetdream:upgrade/api/cd_tick —— 冷却剂 / 魔力沸涌 的每秒结算
# ------------------------------------------------------------
# 【执行者】玩家(由 upgrade/second 以 @a 逐个调进来)
# 【三件事】
#   ① 冷却剂 α/β/Ω 的"冷却缩减": 把主手武器升级里的 r.cd(负数)取反, 夹到 [0,1],
#      写进前置包的 cooldown_reduction 属性 —— 技能 start 时自动吃
#      (见 manacore internal/cooldown/apply_reduce)。写前先比 zx.cdr, 没变就跳过。
#   ② 冷却剂·Ω: 本武器对应的技能如果**总冷却 > 30 秒**, 每秒再 -1 秒。
#   ③ 魔力沸涌: 魔力低于 ms.pct% 时攒秒, 每 ms.every 秒把该技能 -1 秒。
#
# 【★ 只减"本武器释放的那个技能"★(玩家 2026-10-07 定稿口径)】
#   技能 id 直接读主手物品的 custom_data.skill(本包所有武器都带)。不追踪全局
#   冷却列表 —— 所以这里既没有"列不出来的键"问题, 也不会误伤别的武器的冷却。
# 【没升级 / 没拿武器】r.cd 与 ms_* 都是 0 -> 第一次判断就省掉了后面的全部开销。
# 【为什么写在 upgrade/second 而不是挂事件】"每秒"本来就要一个每秒入口;
#   冷却缩减是"持续状态"(换武器就该跟着变), 每刻算纯属浪费。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0

function sweetdream:upgrade/api/bonus_held

# ---- 把三样都先抄进计分板(下面要调 mana/get, 那会覆盖 manacore:out) ----
# ① 冷却缩减(×1000 的负值)
scoreboard players set #cdr zx.meta 0
scoreboard players set #t zx.meta 0
execute store result score #t zx.meta run data get storage zx:out r.cd 1000
scoreboard players operation #cdr zx.meta -= #t zx.meta
execute if score #cdr zx.meta matches ..-1 run scoreboard players set #cdr zx.meta 0
execute if score #cdr zx.meta matches 1001.. run scoreboard players set #cdr zx.meta 1000
# ② 长冷却开关
scoreboard players set #cdex zx.meta 0
execute store result score #cdex zx.meta run data get storage zx:out r.cdex
# ③ 魔力沸涌阈值
scoreboard players set #msp zx.meta 0
execute store result score #msp zx.meta run data get storage zx:out r.ms_pct

# ---- 三样全 0 = 主手这把没敲过冷却类升级, 一件都不用做 ----
execute if score #cdr zx.meta matches 0 if score #cdex zx.meta matches 0 if score #msp zx.meta matches 0 run return 0

# ---- ① 落冷却缩减(变了才写) ----
execute unless score #cdr zx.meta = @s zx.cdr run function sweetdream:upgrade/api/cd_stat

# ---- 取"本武器释放的技能"id(工具/空手没有 skill 字段, 就到此为止) ----
#    ⚠️ 这里**不能**把 skill 预置成 "" —— 那样子键存在, "set from" 失败时
#       分辨不出"没这个字段"; 也绝不能让空串流进 cd_tot(它是宏, $(skill) 空值
#       会拼出 `cooldowns.""` 这种路径)。
data modify storage zx:work cq set value {uuid:""}
data modify storage zx:work cq.uuid set from storage zx:data self.uuid
data modify storage zx:work cq.skill set from entity @s SelectedItem.components."minecraft:custom_data".skill
execute unless data storage zx:work cq.skill run return 0

# ---- ② 冷却剂·Ω: 总冷却 > 30 秒(600 tick)的技能每秒 -1 秒 ----
execute if score #cdex zx.meta matches 1.. run function sweetdream:upgrade/api/cd_tot with storage zx:work cq
execute if score #cdex zx.meta matches 1.. if score #cd_tot zx.meta matches 601.. run function sweetdream:upgrade/api/cd_reduce1

# ---- ③ 魔力沸涌 ----
execute unless score #msp zx.meta matches 1.. run return 0

data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
scoreboard players set #mn zx.meta 0
scoreboard players set #mx zx.meta 0
execute store result score #mn zx.meta run data get storage manacore:out r.value
execute store result score #mx zx.meta run data get storage manacore:out r.max

# 魔力 < pct%  <=>  当前魔力×100 < 上限×pct   (定点比较, 不引浮点)
scoreboard players set #hit zx.meta 0
execute if score #mx zx.meta matches 1.. run scoreboard players operation #low zx.meta = #mn zx.meta
execute if score #mx zx.meta matches 1.. run scoreboard players operation #low zx.meta *= #100 zx.meta
execute if score #mx zx.meta matches 1.. run scoreboard players operation #lim zx.meta = #mx zx.meta
execute if score #mx zx.meta matches 1.. run scoreboard players operation #lim zx.meta *= #msp zx.meta
execute if score #mx zx.meta matches 1.. if score #low zx.meta < #lim zx.meta run scoreboard players set #hit zx.meta 1

# 不成立就把攒秒清掉(否则"偶尔低于阈值"会一直攒着, 下次一开就立刻减)
execute if score #hit zx.meta matches 0 run scoreboard players set @s zx.msp_c 0
execute if score #hit zx.meta matches 1 run function sweetdream:upgrade/api/ms_tick
