# ============================================================
# sweetdream:equipment/bow/dark_sun/volley —— 影矢: 向命中位置周围最近的 4 个其他生物
# ------------------------------------------------------------
# 【执行者】射手(玩家), 由 fire ⑥ 调用
# 【入参】zx:work ds {uuid, u0..u3}
# 【文案】向命中位置 6 格内最近的四个其他生物释放一枚影矢。影矢造成一次相当于
#   自身当前魔力值 ×0.08 的伤害, 并使其附加「夜火」。
# 【★ 圆心 = marker 上的"命中位置" ★】不能直接 `at @e[tag=zx.ds_v]` ——
#   受害者可能已被 ④ 那一段打死, 那时它已从世界移除、坐标取不到
#   (所以 fire 在结算**之前**就把坐标落在 zx.ds_pos 上)。
# 【★ 一次选中全部目标 ★】四发影矢的伤害与附加完全相同(同一个公式、同一个射手)
#   ⇒ 算一次、用 `@e[tag=zx.ds_t]` 一次选中四只, with_from 会逐个展开去打,
#     tag/mark 也会对范围内每一只都附着。不需要写四遍循环。
# ============================================================

# ⓪ 命中位置还在吗(极端情况: marker 被别的清理带走)
execute unless entity @e[tag=zx.ds_pos,limit=1] run return 0

# ① 圈"命中位置 6 格内最近的 4 个其他生物"(排除被命中者)
tag @e[tag=zx.ds_t,distance=0..] remove zx.ds_t
execute at @e[tag=zx.ds_pos,limit=1] run tag @e[type=!#sweetdream:no_damage,distance=..6,tag=!zx.ds_v,sort=nearest,limit=4] add zx.ds_t

# 诊断锚 #ds_dbg7 = 这一轮影矢点到几只(0 = 周围没有其他生物, 属正常)
scoreboard players set #ds_dbg7 zx.meta 0
execute as @e[tag=zx.ds_t,distance=0..] run scoreboard players add #ds_dbg7 zx.meta 1

# ② 没有可选目标 -> 收工(影矢落空是合法结果)
execute unless entity @e[tag=zx.ds_t,distance=0..,limit=1] run return 0

# ③ 表现: 每只目标头顶一枚暗紫影矢扎下
execute as @e[tag=zx.ds_t] at @s run particle minecraft:item{item:{id:"minecraft:arrow",count:1}} ~ ~2.5 ~ 0.12 0.9 0.12 0.0 8 normal
execute as @e[tag=zx.ds_t] at @s run particle minecraft:soul_fire_flame ~ ~1 ~ 0.2 0.3 0.2 0.01 6 normal

# ④ 影矢伤害 = 当前魔力值 ×0.08(每只一份, 带射手归属)
data modify storage manacore:in arg set value {uuid:"",other_mul:0.08}
data modify storage manacore:in arg.uuid set from storage zx:work ds.uuid
function manacore:api/damage/calc
data modify storage zx:work ds.sdmg set value 0.0
data modify storage zx:work ds.sdmg set from storage manacore:out r.damage
data modify storage zx:work a set value {target:"@e[tag=zx.ds_t]",damage:0.0,type:"minecraft:player_attack",u0:0,u1:0,u2:0,u3:0}
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type
data modify storage zx:work a.damage set from storage zx:work ds.sdmg
data modify storage zx:work a.u0 set from storage zx:work ds.u0
data modify storage zx:work a.u1 set from storage zx:work ds.u1
data modify storage zx:work a.u2 set from storage zx:work ds.u2
data modify storage zx:work a.u3 set from storage zx:work ds.u3
data modify storage zx:work a.num set from storage zx:work a.damage
function sweetdream:lib/num/plain
function sweetdream:internal/damage/with_from with storage zx:work a

# ⑤ 使其附加「夜火」(附着 -> tag/mark; 会跳过已带有/已死亡的)
data modify storage zx:work ic set value {target:"@e[tag=zx.ds_t]",mark:"yehuo"}
function sweetdream:tag/mark with storage zx:work ic

# ⑥ 收尾
tag @e[tag=zx.ds_t,distance=0..] remove zx.ds_t
