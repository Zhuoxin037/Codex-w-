# ============================================================
# fallendream:equipment/armor/tread_ash/reward —— 踏灰：位移确认后的兑现
# ------------------------------------------------------------
# 【谁调用它】equipment/armor/step_finish ①（检测窗口到期、确认位移过之后）
# 【执行者】玩家
# 【技能原文（基础 · lore 逐字）】
#   "自身魔力值上限 +100。自身主动技能完成实际位移后为自身恢复最大生命值 8% 的
#    生命，并使本次位移技能的冷却时间 -4 秒。该效果 12 秒内最多触发一次。"
# 【技能原文（超限 · lore 逐字）】
#   "自身魔力值上限 +150。自身主动技能完成实际位移后为自身恢复最大生命值12%的生命，
#    并使本次位移技能的冷却时间 -5 秒。该效果 8秒内最多触发一次。触发后在位移终点
#    留下半径 1 格、持续 6 秒的灰痕。生物首次经过时获得 3 秒缓慢Ⅲ；自身离开后再次
#    走入时，额外恢复 8% 最大生命值，并获得 6 秒迅捷Ⅱ。每片灰痕最多触发一次效果。"
# 【★ 两个效果都做、顺序固定 ★】
#   ① 回血走 lib/heal（整点、天花板压到目标生命，见该文件头）；
#   ② 减冷却走 manacore:api/cooldown/reduce，目标技能 id 从 zx:step casts 里读回来
#      —— 那是 step_observe 在 cooldown_start 时记下的**本次**技能，不是"身上随便一个"。
# 【★ 节流写在**兑现前**、记账写在最后**★】先判后记账：`zx.ta_cd` 存"下次可触发刻"，
#   若先记账再判，判断依据已经被自己改掉（12 秒节流形同虚设）。
# 【★ 为什么回血排在减 CD 之前 ★】文案两个效果没有先后，但回血依赖 lib/heal 的
#   "跨一拍撤天花板"（core/tick 驱动），与减 CD 无关；先回血可保证即便后面
#   api/cooldown/reduce 因技能已结束而无效果，回血也已经生效。
# 【★ 灰痕（超限独占）★】在位移终点 summon 一个 `zx.ta_field` marker：
#   寿命 `zx.ta_life` 120 刻（6 秒），`zx.ta_used` 保证"每片最多触发一次效果"，
#   `zx.ta_out` 记"主人中途离开过"。逐刻结算在 tread_ash/field_tick
#   （core/tick 三维度各一行）。
# ============================================================

# ① 穿着门控（脚上不是踏灰 → 不算）
execute unless items entity @s armor.feet *[minecraft:custom_data~{zx:["tread_ash"]}] run return 0

# ①.5 档位快照
scoreboard players set #ta_ol zx.meta 0
execute if items entity @s armor.feet *[minecraft:custom_data~{zx:["tread_ash"],ol:"tread_ash"}] run scoreboard players set #ta_ol zx.meta 1

# ② 节流: 基础 12 秒 / 超限 8 秒（zx.ta_cd = 下次可触发刻）
scoreboard players add @s zx.ta_cd 0
execute if score @s zx.ta_cd > #now manacore.meta run return 0

# ③ 恢复最大生命: 基础 8% / 超限 12%（向下取整；读原版属性而不是面板账本）
execute store result score #heal_pt zx.meta run attribute @s minecraft:max_health get
scoreboard players set #ta_pct zx.meta 8
execute if score #ta_ol zx.meta matches 1 run scoreboard players set #ta_pct zx.meta 12
scoreboard players operation #heal_pt zx.meta *= #ta_pct zx.meta
scoreboard players operation #heal_pt zx.meta /= #100 zx.meta
function fallendream:lib/heal

# ④ 本次位移技能冷却: 基础 -4 秒(80) / 超限 -5 秒(100)
data modify storage zx:step ctx set value {}
data modify storage zx:step ctx.u0 set from entity @s UUID[0]
data modify storage zx:step ctx.u1 set from entity @s UUID[1]
data modify storage zx:step ctx.u2 set from entity @s UUID[2]
data modify storage zx:step ctx.u3 set from entity @s UUID[3]
function fallendream:equipment/armor/step_load with storage zx:step ctx
data modify storage zx:step cur.t set value 80
execute if score #ta_ol zx.meta matches 1 run data modify storage zx:step cur.t set value 100
execute if data storage zx:step cur.skill run function fallendream:equipment/armor/tread_ash/cd_go with storage zx:step cur

# ⑤ 记账: 节流 基础 240 刻(12 秒) / 超限 160 刻(8 秒)
scoreboard players operation @s zx.ta_cd = #now manacore.meta
execute if score #ta_ol zx.meta matches 0 run scoreboard players add @s zx.ta_cd 240
execute if score #ta_ol zx.meta matches 1 run scoreboard players add @s zx.ta_cd 160

# ⑥ ★ 超限: 在位移终点留一片灰痕（半径 1、6 秒）★
#   ★ "位移终点" = 现在脚下（step_finish 在位移确认之后才调本函数）
#   ★ 用 marker 而不是把坐标记在玩家身上: 半径判定要 `at` 一个实体才自然,
#     而且"生物经过"是别人的事, 记在玩家身上反而要 macro 拼坐标。
execute if score #ta_ol zx.meta matches 1 at @s run summon minecraft:marker ~ ~ ~ {Tags:["zx.ta_field"]}
execute if score #ta_ol zx.meta matches 1 run scoreboard players set @e[tag=zx.ta_field,distance=..2,limit=1] zx.ta_life 120
execute if score #ta_ol zx.meta matches 1 run scoreboard players set @e[tag=zx.ta_field,distance=..2,limit=1] zx.ta_used 0
execute if score #ta_ol zx.meta matches 1 run scoreboard players set @e[tag=zx.ta_field,distance=..2,limit=1] zx.ta_out 0
execute if score #ta_ol zx.meta matches 1 run data modify entity @e[tag=zx.ta_field,distance=..2,limit=1] data.zx.u set from entity @s UUID

# ⑦ 表现：脚下一圈灰、短促的砂砾声
execute at @s run particle minecraft:ash ~ ~0.1 ~ 0.5 0.05 0.5 0.01 18 normal
execute at @s run particle minecraft:dust{color:[0.45,0.42,0.4],scale:1.1} ~ ~0.2 ~ 0.55 0.1 0.55 0.01 10 normal
execute at @s run playsound minecraft:block.sand.step player @a ~ ~ ~ 0.8 1.1
