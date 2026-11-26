# ============================================================
# fallendream:equipment/armor/mirror_sleep/ol_consume —— 超限·镜寐: 本件附加的白昼梦被消耗 -> 扩散 + 回魔
# ------------------------------------------------------------
# 【执行者】自身（消耗白昼梦的玩家；on_consume ⑪ 已判穿超限镜寐 + mark=dream + 快照在）
# 【文案(逐字)】"本次附加的「白昼梦」若被消耗则使被消耗的生物的 3 格内的其他生物
#   被附加一次持续 8 秒的「白昼梦」，之后使自身恢复 1% 魔力值。"
# 【★ "被消耗的那只"怎么找 ★】mark_take 在摘 dream 之前把它快照成 zx.ms_src;
#   摘标签后原选择器里的 tag=zx.status.dream 就失效了, 必须用这个临时标记当圆心。
# 【★ 8 秒白昼梦 ★】tag/mark 默认给 15 秒, 附完立刻把 zx.tt.dream 改写成 8
#   (cage_day/skill 同款先例)。
# 【★ "其他生物" ★】distance 从 0.01 起排除圆心自己；不传施加者归属(扩散的梦不用
#   再触发本件的"被消耗扩散", 否则会无限连锁)。
# ============================================================

function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
execute unless entity @e[tag=zx.ms_src,distance=0..,limit=1] run return 0

# ---- ① 3 格内其他生物附 8 秒白昼梦 ----
#   ★ 先给圆心打临时专属标签，as 切过去之后 @s 就只剩圆心了
tag @a remove zx.ms_center
execute as @e[tag=zx.ms_src,distance=0..,limit=1] run tag @s add zx.ms_center
execute at @a[tag=zx.ms_center,limit=1] run tag @e[type=!#fallendream:no_damage,distance=0.01..3,tag=!zx.status.dream] add zx.ms_new
# 用 tag/mark 给这批生物正式附着白昼梦(带图标/计时/租约)
execute as @e[tag=zx.ms_new,distance=0..] run function fallendream:tag/mark {target:"@s",mark:"dream"}
# 改写成 8 秒
scoreboard players set @e[tag=zx.ms_new,distance=0..] zx.tt.dream 8
tag @e[tag=zx.ms_new,distance=0..] remove zx.ms_new
tag @a remove zx.ms_center

# ---- ② 恢复 1% 最大魔力值（R05 上界保护） ----
data modify storage manacore:in arg set value {uuid:"",key:"max_mana"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
scoreboard players set #ms_m zx.meta 0
execute store result score #ms_m zx.meta run data get storage manacore:out r.value 1000
execute unless score #ms_m zx.meta matches 1.. run return 0
scoreboard players set #ms_100 zx.meta 100
scoreboard players set #ms_cap zx.meta 2147483647
scoreboard players operation #ms_cap zx.meta /= #ms_100 zx.meta
scoreboard players operation #ms_add zx.meta = #ms_m zx.meta
execute if score #ms_add zx.meta > #ms_cap zx.meta run scoreboard players operation #ms_add zx.meta = #ms_cap zx.meta
scoreboard players operation #ms_add zx.meta /= #ms_100 zx.meta

data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 0.001 run scoreboard players get #ms_add zx.meta
function manacore:api/mana/add
