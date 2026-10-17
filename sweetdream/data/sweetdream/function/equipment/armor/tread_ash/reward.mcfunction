# ============================================================
# sweetdream:equipment/armor/tread_ash/reward —— 踏灰：位移确认后的兑现
# ------------------------------------------------------------
# 【谁调用它】equipment/armor/step_finish ①（检测窗口到期、确认位移过之后）
# 【执行者】玩家
# 【技能原文（lore 逐字）】
#   "自身魔力值上限 +100。自身主动技能完成实际位移后为自身恢复最大生命值 8% 的
#    生命，并使本次位移技能的冷却时间 -4 秒。该效果 12 秒内最多触发一次。"
# 【★ 两个效果都做、顺序固定 ★】
#   ① 回血走 lib/heal（整点、天花板压到目标生命，见该文件头）；
#   ② 减冷却走 manacore:api/cooldown/reduce（ticks:80 = 4 秒），
#      目标技能 id 从 zx:step casts 里读回来 —— 那是 step_observe 在 cooldown_start
#      时记下的**本次**技能，不是"身上随便一个技能"。
# 【★ 节流写在**兑现前**、记账写在最后**★】先判后记账：`zx.ta_cd` 存"下次可触发刻"，
#   若先记账再判，判断依据已经被自己改掉（12 秒节流形同虚设）。
# 【★ 为什么回血排在减 CD 之前 ★】文案两个效果没有先后，但回血依赖 lib/heal 的
#   "跨一拍撤天花板"（core/tick 驱动），与减 CD 无关；先回血可保证即便后面
#   api/cooldown/reduce 因技能已结束而无效果，回血也已经生效。
# ============================================================

# ① 穿着门控（脚上不是踏灰 → 不算）
execute unless items entity @s armor.feet *[minecraft:custom_data~{zx:["tread_ash"]}] run return 0

# ② 12 秒节流（zx.ta_cd = 下次可触发刻）
scoreboard players add @s zx.ta_cd 0
execute if score @s zx.ta_cd > #now manacore.meta run return 0

# ③ 恢复最大生命值 8%（向下取整；读原版属性而不是面板账本，口径同 lib/heal）
execute store result score #heal_pt zx.meta run attribute @s minecraft:max_health get
scoreboard players set #ta_pct zx.meta 8
scoreboard players operation #heal_pt zx.meta *= #ta_pct zx.meta
scoreboard players operation #heal_pt zx.meta /= #100 zx.meta
function sweetdream:lib/heal

# ④ 本次位移技能冷却 -4 秒（80 刻）
data modify storage zx:step ctx set value {}
data modify storage zx:step ctx.u0 set from entity @s UUID[0]
data modify storage zx:step ctx.u1 set from entity @s UUID[1]
data modify storage zx:step ctx.u2 set from entity @s UUID[2]
data modify storage zx:step ctx.u3 set from entity @s UUID[3]
function sweetdream:equipment/armor/step_load with storage zx:step ctx
execute if data storage zx:step cur.skill run function sweetdream:equipment/armor/tread_ash/cd_go with storage zx:step cur

# ⑤ 记账（12 秒 = 240 刻）
scoreboard players operation @s zx.ta_cd = #now manacore.meta
scoreboard players add @s zx.ta_cd 240

# ⑥ 表现：脚下一圈灰、短促的砂砾声
execute at @s run particle minecraft:ash ~ ~0.1 ~ 0.5 0.05 0.5 0.01 18 normal
execute at @s run particle minecraft:dust{color:[0.45,0.42,0.4],scale:1.1} ~ ~0.2 ~ 0.55 0.1 0.55 0.01 10 normal
execute at @s run playsound minecraft:block.sand.step player @a ~ ~ ~ 0.8 1.1
