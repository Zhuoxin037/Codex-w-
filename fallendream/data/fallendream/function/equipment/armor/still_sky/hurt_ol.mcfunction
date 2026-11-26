# ============================================================
# fallendream:equipment/armor/still_sky/hurt_ol —— 超限: 星帷受击(三层制)
# ------------------------------------------------------------
# 【执行者】玩家   【前提】已判戴着超限静穹
# 【顺序】找层 → 消耗 → 临时生命 → 来源减速+白昼梦 → 数"8 秒内第几层"
# 【★ 只清"被选中的那一格" ★】三层是三个独立到期刻, 一口气全清等于白送两层。
# 【★ 先判后改 ★】找层那几行都是"读"层分数, 中间不写, 所以三段判定互不影响。
# ============================================================
execute unless score @s zx.j_orb matches 1.. run return 0

scoreboard players set #s2_slot zx.meta 0
execute if score @s zx.s2_sky1 > #now manacore.meta run scoreboard players set #s2_slot zx.meta 1
execute if score #s2_slot zx.meta matches 0 if score @s zx.s2_sky2 > #now manacore.meta run scoreboard players set #s2_slot zx.meta 2
execute if score #s2_slot zx.meta matches 0 if score @s zx.s2_sky3 > #now manacore.meta run scoreboard players set #s2_slot zx.meta 3
execute if score #s2_slot zx.meta matches 0 run return 0

execute if score #s2_slot zx.meta matches 1 run scoreboard players set @s zx.s2_sky1 0
execute if score #s2_slot zx.meta matches 2 run scoreboard players set @s zx.s2_sky2 0
execute if score #s2_slot zx.meta matches 3 run scoreboard players set @s zx.s2_sky3 0

function fallendream:equipment/armor/eagle_hat/orb_before
scoreboard players remove @s zx.j_orb 1
function fallendream:equipment/armor/eagle_hat/orb_after
scoreboard players set @s zx.s2_sky_full 0

# ---- 8 秒临时生命 = 最大生命 ×0.1, 保底 8 点 ----
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",key:"max_health"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
scoreboard players set #s2_mh zx.meta 0
execute store result score #s2_mh zx.meta run data get storage manacore:out r.value 1000
# ×1000 定点: 10% ⇒ ÷10
scoreboard players operation #s2_g_v zx.meta = #s2_mh zx.meta
scoreboard players operation #s2_g_v zx.meta /= #10 zx.meta
scoreboard players set #s2_g_min zx.meta 8000
execute if score #s2_g_v zx.meta < #s2_g_min zx.meta run scoreboard players set #s2_g_v zx.meta 8000
scoreboard players set #s2_g_t zx.meta 160
function fallendream:batch21/shield/grant

# ---- 来源: 缓慢Ⅲ 2 秒 + 附加「白昼梦」----
effect give @e[tag=zx.s2_source,distance=0..,limit=1] minecraft:slowness 2 2 true
data modify storage zx:work ic set value {target:"@e[tag=zx.s2_source,distance=0..,limit=1]",mark:"dream"}
function fallendream:tag/mark with storage zx:work ic

# ---- 8 秒内消耗满三层 → 抗性Ⅴ + 移速 +40%(4 秒)----
execute unless score @s zx.s2_sky_cw >= #now manacore.meta run scoreboard players set @s zx.s2_sky_ct 0
scoreboard players add @s zx.s2_sky_ct 1
scoreboard players operation @s zx.s2_sky_cw = #now manacore.meta
scoreboard players add @s zx.s2_sky_cw 160
execute if score @s zx.s2_sky_ct >= #3 zx.meta run function fallendream:equipment/armor/still_sky/sky3
