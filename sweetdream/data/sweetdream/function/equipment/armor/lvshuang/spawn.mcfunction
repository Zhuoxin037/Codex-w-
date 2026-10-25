# ============================================================
# sweetdream:equipment/armor/lvshuang/spawn —— 在脚下留一片霜
# ------------------------------------------------------------
# 【执行者】玩家
# 【★ 6 片上限怎么数】不维护计数器，直接数场上现有 marker —— 计数器在
#   "霜被区块卸载 / 被 /kill / 玩家换维度"时会走偏，数实物永远是对的。
# 【★ 超额时收哪一片】`limit=1` 随便收一片（不保证最旧）。设计只要求"最多 6 片"，
#   没有要求淘汰顺序；要做到最旧优先得给每片排序号，不值得。
# ============================================================
execute store result score #lsh_cnt zx.meta run execute if entity @e[type=marker,tag=zx.lsh_frost]
execute if score #lsh_cnt zx.meta matches 6.. run function sweetdream:equipment/armor/lvshuang/drop_one

execute at @s run summon minecraft:marker ~ ~0.05 ~ {Tags:["zx.lsh_frost","zx.lsh_new"]}
scoreboard players set @e[type=marker,tag=zx.lsh_new,distance=..1,limit=1] zx.lsh_ft 5
tag @e[type=marker,tag=zx.lsh_new,distance=..1] remove zx.lsh_new
execute at @s run particle minecraft:snowflake ~ ~0.05 ~ 0.45 0.05 0.45 0.01 8 normal
execute at @s run particle minecraft:dust{color:[0.78,0.88,0.95],scale:1.0} ~ ~0.05 ~ 0.4 0.02 0.4 0.005 6 normal
