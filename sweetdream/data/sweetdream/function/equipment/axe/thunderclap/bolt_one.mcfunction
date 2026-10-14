# ============================================================
# sweetdream:equipment/axe/thunderclap/bolt_one —— 威霆: 召唤一道真闪电(宏)
# ------------------------------------------------------------
# 【宏参数】zx:work bs.ang = 相对执行位置的水平角度(0 / 30 / 60 …)
# 【谁调用它】thunderclap/bolt_fx   【执行者】落雷排期 marker(位置 = 被击者处)
# 【干什么】在"以自己为圆心、角度 $(ang)、半径 1 格"的地方劈一道真闪电。
# 【★ 带 zx.th_own ★】= 玩家用武器劈出来的雷 ⇒ **会**被 tool/thunder(雷鸣)的每刻
#   扫描接管, 给 6 格内持雷鸣的玩家追加一道 1 秒后的连锁雷(2026-10-13 由 seen 改 own)。
#   ★ 别写成 zx.th_seen ★ core/tick 只扫 tag=!zx.th_seen —— 预带 seen 会让雷鸣看不见它。
#   ★ 不会无限连锁: own → 扫描 → 雷鸣登记 → 1 秒后劈一道(seen) → 被跳过, **一层就停**
#     (雷鸣自己那道连锁雷必须保留 seen, 见 pend_go)。
# 【实现】rotated $(ang) 0 -> 朝向水平转过去; positioned ^ ^ ^1.0 -> 沿视线前进 1 格;
#   summon ~ ~ ~ -> 就落在那里。三段必须按这个顺序(rotated 只改朝向, positioned 才用得上它)。
# ============================================================

$execute rotated $(ang) 0 positioned ^ ^ ^1.0 run summon minecraft:lightning_bolt ~ ~ ~ {Tags:["zx.th_own"]}

# ★★ "自身召唤闪电"的公共收尾钩子 ★★(接口层: 只要是"自己召唤的雷"就走这里)
#   ★ 契约: lib/on_lightning 要求 "@s = 召唤这道雷的玩家 / 位置 = 落点"。
#     本函数的 @s 是**排期 marker** ⇒ 必须 `as` 换回施法者; 而位置要留在
#     `positioned ^ ^ ^1.0` 之后的那个点(真正的落点), 所以 `rotated/positioned`
#     要在最前面、`as` 放最后(顺序反了雷的落点会跑到玩家脚下, 同 arc/ol_fire)。
#   ★ u0..u3 由 bolt_go 写进 marker、bolt_fx 摊进 zx:work bs(宏参数只能取键)。
#     全 0(找不到射手)时选不到人 ⇒ 整行安全空转。
$execute rotated $(ang) 0 positioned ^ ^ ^1.0 as @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] run function sweetdream:lib/on_lightning
