# ============================================================
# sweetdream:equipment/armor/bright_candle/candle_spawn —— 生成一支「烛火」(宏)
# ------------------------------------------------------------
# 【宏参数】zx:work bc {u0,u1,u2,u3}(由 on_hit 从 ob 的宏参数抄到自己的节点上)
# 【执行位置】受害者脚下(由 on_hit 的 `execute at @s run` 送进来)
# 【产物】一支 item_display(蜡烛 + 火焰粒子), 10 秒后自行消失
# 【★ 寿命记计分项、不写 NBT ★】marker/item_display 的 NBT 每写一次 chunk 就标一次脏;
#   计时一律走计分项(范式速查第 11 条)。
# ============================================================

$summon minecraft:item_display ~ ~ ~ {Tags:["zx.bc_fire","zx.bc_new"],item:{id:"minecraft:candle",count:1},item_display:"fixed",billboard:"center",teleport_duration:0,interpolation_duration:0,view_range:1.0f,shadow_radius:0f,brightness:{block:15,sky:15},transformation:{translation:[0f,0.25f,0f],scale:[0.9f,0.9f,0.9f],left_rotation:[0f,0f,0f,1f],right_rotation:[0f,0f,0f,1f]},data:{zx:{u:[I;$(u0),$(u1),$(u2),$(u3)]}}}

# ① 寿命 10 秒(candle_tick 每秒 -1)
execute as @e[tag=zx.bc_new,distance=0..] run scoreboard players set @s zx.bc_life 10

# ② 归属(主人 u0 —— 回蓝时要反查他)
execute as @e[tag=zx.bc_new,distance=0..] store result score @s zx.bc_own run data get storage zx:work bc.u0

scoreboard players add #bc_id zx.meta 1
scoreboard players operation @e[tag=zx.bc_new,distance=0..,limit=1] zx.bc_id = #bc_id zx.meta
scoreboard players operation @e[tag=zx.bc_new,distance=0..,limit=1] zx.bc_end = #now manacore.meta
scoreboard players add @e[tag=zx.bc_new,distance=0..,limit=1] zx.bc_end 200
scoreboard players operation @e[tag=zx.bc_new,distance=0..,limit=1] zx.bc_next = #now manacore.meta
scoreboard players add @e[tag=zx.bc_new,distance=0..,limit=1] zx.bc_next 20
scoreboard players set @e[tag=zx.bc_new,distance=0..,limit=1] zx.bc_fx 0
tag @e[tag=zx.bc_new,distance=0..] remove zx.bc_new
