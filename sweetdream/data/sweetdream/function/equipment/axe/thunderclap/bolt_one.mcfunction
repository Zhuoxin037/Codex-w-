# ============================================================
# sweetdream:equipment/axe/thunderclap/bolt_one —— 威霆: 召唤一道真闪电(宏)
# ------------------------------------------------------------
# 【宏参数】zx:work bs.ang = 相对执行位置的水平角度(0 / 30 / 60 …)
# 【谁调用它】thunderclap/bolt_fx   【执行者】落雷排期 marker(位置 = 被击者处)
# 【干什么】在"以自己为圆心、角度 $(ang)、半径 1 格"的地方劈一道真闪电。
# 【★ 一定要带 zx.th_seen ★】否则 tool/thunder/strike 的每刻扫描会把它当成"新出现的
#   雷击"再走一遍雷鸣的连锁 -> 不带 seen 的连锁会无限劈下去(见 bolt_go 的说明)。
# 【实现】rotated $(ang) 0 -> 朝向水平转过去; positioned ^ ^ ^1.0 -> 沿视线前进 1 格;
#   summon ~ ~ ~ -> 就落在那里。三段必须按这个顺序(rotated 只改朝向, positioned 才用得上它)。
# ============================================================

$execute rotated $(ang) 0 positioned ^ ^ ^1.0 run summon minecraft:lightning_bolt ~ ~ ~ {Tags:["zx.th_seen"]}
