# ============================================================
# sweetdream:equipment/axe/xiugou/spawn —— 生成锈犬本体（宏）
# ------------------------------------------------------------
# 【宏参数】sweetdream:work xg {dmg,u0,u1,u2,u3}
#   dmg = 这一发的基础攻击力（每口咬这么多）
#   u0..u3 = 使用者的 UUID（伤害归属；也用于"同一使用者只能有一只"）
# 【本体是 marker】不吃伤害、不占实体上限、不会被怪打死 ——
#   它就是"咬人的判定点"，参考 thunder_wedge 的雷楔。
# ============================================================
$summon minecraft:marker ~ ~ ~ {Tags:["zx.xg_dog","zx.xg_new"],data:{zx:{dmg:$(dmg),u:[I;$(u0),$(u1),$(u2),$(u3)]}}}
scoreboard players set @e[type=marker,tag=zx.xg_new,distance=..2,limit=1] zx.xg_ft 10
scoreboard players set @e[type=marker,tag=zx.xg_new,distance=..2,limit=1] zx.xg_n 0
scoreboard players operation @e[type=marker,tag=zx.xg_new,distance=..2,limit=1] zx.xg_own = #xg_me zx.meta
# 超限·锈犬: 额外打一个"我是超限版"的标签 —— dog_tick 按它分流到 ol_bite(8 格 + 连击)
execute if score #xg_ol zx.meta matches 1 run tag @e[type=marker,tag=zx.xg_new,distance=..2] add zx.xg_ol
tag @e[type=marker,tag=zx.xg_new,distance=..2] remove zx.xg_new
execute at @e[type=marker,tag=zx.xg_dog,distance=..2] run particle minecraft:smoke ~ ~0.2 ~ 0.4 0.3 0.4 0.02 14 normal
execute at @e[type=marker,tag=zx.xg_dog,distance=..2] run particle minecraft:crit ~ ~0.3 ~ 0.3 0.3 0.3 0.02 10 normal
