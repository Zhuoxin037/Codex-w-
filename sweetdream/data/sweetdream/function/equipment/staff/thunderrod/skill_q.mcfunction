# ============================================================
# sweetdream:equipment/staff/thunderrod/skill_q —— 主动技能: 排一记"待落的雷"
# ------------------------------------------------------------
# 【谁调用它】skill 第 ⑥ 步: `execute at @e[tag=zx.tr_t] run function 本文件 with storage zx:work tr`
#   ⇒ 位置 = 某个被选中的目标脚下, 执行者仍是**玩家**
# 【为什么要用 marker 排队, 不能当场连劈三道】
#   原版受击后有 **10 tick 无敌帧**: 同一刻在一个人身上连劈三道雷, 只有第一道吃得到
#   伤害(看得见三道雷光、只掉一次血) ⇒ 三道必须**错开**: due = now + 0 / 10 / 20 tick。
#   与普攻"超限两道雷"同一个道理(见 ball_hit 的注释)。
# 【★ 为什么不能用 schedule ★】两人同时施法会互相顶掉(schedule 默认 replace),
#   先例见 tool/thunder/pend_go 的注释。marker + 到期刻是这套项目里的通用解法。
# 【宏参数】storage zx:work tr {u0,u1,u2,u3,ol}
#   ★ ol 必须是 **int**(0/1) 不能是 byte: 它会作为 `scoreboard players set ... $(ol)`
#     展开进命令行, 而 byte 会渲染成 `1b` ⇒ 命令解析失败、整函数作废。
# ============================================================

$summon minecraft:marker ~ ~ ~ {Tags:["zx.tr_sk","zx.tr_skn"],data:{zx:{tr:{u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3),ol:$(ol)}}}}

# 到期刻由调用方算好放在 #tr_d(skill 里按"第几道"递增 10 tick), 这里原样落上去
execute as @e[tag=zx.tr_skn,distance=..3,limit=1] run scoreboard players operation @s zx.tr_due = #tr_d zx.meta
tag @e[tag=zx.tr_skn,distance=..3] remove zx.tr_skn
