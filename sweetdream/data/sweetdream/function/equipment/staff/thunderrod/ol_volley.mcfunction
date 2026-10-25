# ============================================================
# sweetdream:equipment/staff/thunderrod/ol_volley —— 超限·引雷针: 给每只目标排 3 道雷
# ------------------------------------------------------------
# 【谁调用它】skill 第 ⑥' 步(只在超限档跑; @s = 玩家, zx.tr_t = 已选好的目标)
# 【文案】"对自身 8 格内至多 7 个生物**各降下三道闪电**"。
# 【★ 为什么不直接连劈三道 ★】原版受击后有 **10 tick 无敌帧** —— 同一刻在一个人
#   身上连劈三道, 只有第一道吃得到伤害(看得见三道雷光、只掉一次血)。
#   ⇒ 三道错开: 到期刻 now + 0 / +10 / +20 tick, 由 core/tick 驱动 pend_go_sk。
# 【★ 为什么分批写三条而不是循环 ★】到期刻只能来自计分项(#tr_d), 而"第几道"
#   要在调用 skill_q **之前**算好 —— 宏参数是从 storage 现取的, 改一次调一次,
#   三条最直观也不容易漏(全仓里"三道水刃""三只犬"都是这种并排写法)。
# ============================================================

# ⓪ 公共参数: 主人 uuid 四段 + 档位(ol 必须是 **int**, 宏里会展开进 `set ... $(ol)`)
execute store result storage zx:work tr.u0 int 1 run data get entity @s UUID[0]
execute store result storage zx:work tr.u1 int 1 run data get entity @s UUID[1]
execute store result storage zx:work tr.u2 int 1 run data get entity @s UUID[2]
execute store result storage zx:work tr.u3 int 1 run data get entity @s UUID[3]
execute store result storage zx:work tr.ol int 1 run scoreboard players get @s zx.tr_ol

# ① 第一道: 现在就劈
scoreboard players operation #tr_d zx.meta = #now manacore.meta
execute at @e[tag=zx.tr_t,distance=0..] run function sweetdream:equipment/staff/thunderrod/skill_q with storage zx:work tr

# ② 第二道: +10 tick(0.5 秒后)
scoreboard players operation #tr_d zx.meta = #now manacore.meta
scoreboard players add #tr_d zx.meta 10
execute at @e[tag=zx.tr_t,distance=0..] run function sweetdream:equipment/staff/thunderrod/skill_q with storage zx:work tr

# ③ 第三道: +20 tick(1 秒后)
scoreboard players operation #tr_d zx.meta = #now manacore.meta
scoreboard players add #tr_d zx.meta 20
execute at @e[tag=zx.tr_t,distance=0..] run function sweetdream:equipment/staff/thunderrod/skill_q with storage zx:work tr
