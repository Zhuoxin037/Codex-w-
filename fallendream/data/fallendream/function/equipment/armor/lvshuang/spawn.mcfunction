# ============================================================
# fallendream:equipment/armor/lvshuang/spawn —— 在脚下留一片霜
# ------------------------------------------------------------
# 【执行者】玩家
# 【技能原文(lore 逐字)】
#   基础: "…每移动 1 格，在脚下留下一片霜，最多同时存在 6 片，每片持续 5 秒…"
#   超限: "自身魔力值上限 +80。每移动 1 格，在脚下留下一片霜，最多同时存在 24 片，
#          每片持续 16 秒。…自身使用位移类技能时产生的霜将直接提升为 3 层。"
# 【★ 片数上限怎么数】不维护计数器，直接数场上现有 marker —— 计数器在
#   "霜被区块卸载 / 被 /kill / 玩家换维度"时会走偏，数实物永远是对的。
# 【★ 超额时收哪一片】`limit=1` 随便收一片（不保证最旧）。设计只要求"最多 N 片"，
#   没有要求淘汰顺序；要做到最旧优先得给每片区排序号，不值得。
# 【★ 档位快照在这里拍 ★】霜片不知道穿鞋的人是谁；"是不是超限档"必须在这一刻
#   写进 marker，之后 frost_tick 只看 marker 自己的 zx.lsh_ol。
# 【★ "不占上限"怎么落 ★】上限数的是 marker 个数；"档位"(zx.lsh_lv) 是同一片霜
#   内部的加码，加多少都不多生成一片 —— 所以天然不占上限，不需要额外记账。
# ============================================================

# ① 这一片是不是超限档（假玩家先清零：它跨调用会残留）
scoreboard players set #lsh_is_ol zx.meta 0
execute if items entity @s armor.feet *[minecraft:custom_data~{zx:["lvshuang"],ol:"lvshuang"}] run scoreboard players set #lsh_is_ol zx.meta 1

# ② 上限：超限 24 片 / 基础 6 片
scoreboard players set #lsh_cap zx.meta 6
execute if score #lsh_is_ol zx.meta matches 1 run scoreboard players set #lsh_cap zx.meta 24
execute store result score #lsh_cnt zx.meta run execute if entity @e[type=marker,tag=zx.lsh_frost]
execute if score #lsh_cnt zx.meta >= #lsh_cap zx.meta run function fallendream:equipment/armor/lvshuang/drop_one

# ③ 生成
execute at @s run summon minecraft:marker ~ ~0.05 ~ {Tags:["zx.lsh_frost","zx.lsh_new"]}
scoreboard players set @e[type=marker,tag=zx.lsh_new,distance=..1,limit=1] zx.lsh_ft 5
execute if score #lsh_is_ol zx.meta matches 1 run scoreboard players set @e[type=marker,tag=zx.lsh_new,distance=..1,limit=1] zx.lsh_ft 16
execute if score #lsh_is_ol zx.meta matches 1 run scoreboard players set @e[type=marker,tag=zx.lsh_new,distance=..1,limit=1] zx.lsh_ol 1

# ④ 位移技能窗口内产生的霜 = 直接 3 档（窗口由 on_cast 打、tick 每刻递减）
execute if score #lsh_is_ol zx.meta matches 1 if score @s zx.lsh_dash matches 1.. run scoreboard players set @e[type=marker,tag=zx.lsh_new,distance=..1,limit=1] zx.lsh_lv 3

tag @e[type=marker,tag=zx.lsh_new,distance=..1] remove zx.lsh_new
execute at @s run particle minecraft:snowflake ~ ~0.05 ~ 0.45 0.05 0.45 0.01 8 normal
execute at @s run particle minecraft:dust{color:[0.78,0.88,0.95],scale:1.0} ~ ~0.05 ~ 0.4 0.02 0.4 0.005 6 normal
