# ============================================================
# sweetdream:equipment/staff/five_curses/ol_tier —— 「世咒」各世的**强度分档表**
# ------------------------------------------------------------
# 【谁调用它】curse_step(每次推进一世之前, 在它的最前面)
# 【入参(调用方必须先设好)】
#   #fcv_ol  zx.meta = 施法者手上这件是不是**超限·五世恶咒**(0/1)
#   #fcv_skl zx.meta = 这一刀是**主动技能**推进的(1) 还是**普攻命中**推进的(0)
# 【出参(全部是 meta 假名)】
#   #fcv_t1  第一世时长(秒)   #fcv_t2  第二世时长(秒)   #fcv_sl2 第二世缓慢等级(amplifier)
#   #fcv_v3  第三世易伤千分比(120 = +20%)  #fcv_t3 第三世时长(秒)
#   #fcv_apct 第四世破甲百分比(100 = 清零) #fcv_t4 第四世时长(秒)
#   #fcv_t5  第五世记录窗口(秒)  #fcv_fin 终世结算百分比
# 【★ 为什么单独一个文件 ★】这些数在 curse_step 里要被**五段**代码各读一次, 抄五遍
#   必然漏改; 而且"普攻推进"与"主动推进"是两套(主动的那套更狠), 再乘"超限与否"
#   一共三档 ⇒ 收成一张表, 一眼能对齐。
# 【三档对照(2026-10-23 批 K9)】
#                 一世      二世        三世         四世          五世     终世
#   未超限        虚弱Ⅲ 3s  缓慢Ⅳ 3s    +20% 5s     -50% 5s      10s     30%
#   超限·普攻     虚弱Ⅲ 5s  缓慢Ⅳ 5s    +20% 8s     -80% 8s      12s     40%
#   超限·主动     虚弱Ⅲ 5s  缓慢Ⅴ 5s    +40% 8s     清零 8s      15s     40%(主动结算时
#                                                                        被 skill 提到 100%)
# 【★ 先灌原版、再被覆盖 ★】与全仓"分档一律先灌原版值"的口径一致: 没超限/不是主动
#   时, 读到的就是原版那一行, 与改动前逐字相同, 不维护两套分支。
# ============================================================

# ① 原版值(先灌)
scoreboard players set #fcv_t1 zx.meta 3
scoreboard players set #fcv_t2 zx.meta 3
scoreboard players set #fcv_sl2 zx.meta 3
scoreboard players set #fcv_v3 zx.meta 120
scoreboard players set #fcv_t3 zx.meta 5
scoreboard players set #fcv_apct zx.meta 50
scoreboard players set #fcv_t4 zx.meta 5
scoreboard players set #fcv_t5 zx.meta 10
scoreboard players set #fcv_fin zx.meta 30

# ② 超限·普攻档(各世延长 + 三世易伤不变 + 四世 -80% + 终世 40%)
execute if score #fcv_ol zx.meta matches 1 run scoreboard players set #fcv_t1 zx.meta 5
execute if score #fcv_ol zx.meta matches 1 run scoreboard players set #fcv_t2 zx.meta 5
execute if score #fcv_ol zx.meta matches 1 run scoreboard players set #fcv_t3 zx.meta 8
execute if score #fcv_ol zx.meta matches 1 run scoreboard players set #fcv_apct zx.meta 80
execute if score #fcv_ol zx.meta matches 1 run scoreboard players set #fcv_t4 zx.meta 8
execute if score #fcv_ol zx.meta matches 1 run scoreboard players set #fcv_t5 zx.meta 12
execute if score #fcv_ol zx.meta matches 1 run scoreboard players set #fcv_fin zx.meta 40

# ③ 超限·主动档(在 ② 之上再强化: 二世 Ⅳ→Ⅴ、三世 +20%→+40%、四世 -80%→清零、五世 12→15 秒)
execute if score #fcv_ol zx.meta matches 1 if score #fcv_skl zx.meta matches 1 run scoreboard players set #fcv_sl2 zx.meta 4
execute if score #fcv_ol zx.meta matches 1 if score #fcv_skl zx.meta matches 1 run scoreboard players set #fcv_v3 zx.meta 140
execute if score #fcv_ol zx.meta matches 1 if score #fcv_skl zx.meta matches 1 run scoreboard players set #fcv_apct zx.meta 100
execute if score #fcv_ol zx.meta matches 1 if score #fcv_skl zx.meta matches 1 run scoreboard players set #fcv_t5 zx.meta 15
