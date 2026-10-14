# ============================================================
# sweetdream:lib/on_lightning —— "有人召唤了一道闪电"的公共收尾钩子
# ------------------------------------------------------------
# 【谁调用它】每一处 `summon minecraft:lightning_bolt` 之后(目前**七处, 全覆盖**):
#   · equipment/axe/charge/bolt      (超•负•荷 的每次雷)
#   · equipment/axe/anion/cast       (负离子 的第一波雷; 注意窗口在 cast 末尾才开,
#                                     所以这波**不吃**落点伤害 —— 文案是"**之后** 8 秒内")
#   · equipment/axe/anion/second_strike (负离子 1 秒后的第二道雷 —— 窗口内, 会吃)
#   · equipment/staff/thunderrod/bolt_atk / bolt_skill  (引雷针 的普攻雷与技能雷)
#   · equipment/bow/arc/ol_fire      (超限·电弧 的跳雷; ★ 它 @s 是放电的生物, 调用前
#                                     必须先 `at @s as @a[nbt={UUID:[I;$(u0)…]}]` 切回射手)
#   · equipment/tool/thunder/pend_go (雷鸣 的第二道雷; ★ 副手常驻 —— 见下面"雷鸣"条)
#   · equipment/axe/thunderclap/bolt_one (威霆 的每道真闪电; ★ @s 是排期 marker,
#                                     要 `as` 反查射手, UUID 由 bolt_go 写进 marker)
# 【执行者】**召唤这道雷的玩家**   【位置】**落点**
#   调用方必须保证这两个上下文: 下面要按 @s 找"谁的 buff"、按当前位置算范围。
# ★★ 【★ 本文件里**绝对不许出现 `at @s`** ★】★ 2026-10-13 修: 原来 ①② 都写成
#   `… at @s run function …`, 而 @s 是**玩家** ⇒ 位置被从"落点"挪回"玩家脚下",
#   下游 ol_bonus / ol_bolt_bonus 里的 `execute at @s … distance=..2` 又挪一次
#   ⇒ "落点 2 格"实际变成"**玩家** 2 格", 与文案「对落地处造成…」完全不符
#   (表现为"闪电离得远就一点追加伤害都没有")。位置一律沿用调用方给的落点。
# 【为什么要有这一层】"自身召唤闪电时…"是**跨武器**的效果(负离子放完 8 秒内
#   切到别的武器召唤的雷也该吃), 所以不能写死在某一支武器的 bolt 里 ——
#   否则每加一把会召唤闪电的武器就要回去改一遍。
#   ★ 反面教材 2026-10-13: 新写的引雷针**漏接**了这一层 ⇒ 用户实测"开了超限负离子
#     再用引雷针普攻, 落点伤害完全不触发"(静默、零日志)。新增落雷点必看本文件。
# 【★ 接口 vs 实战 —— 别拿后者当理由砍接口 ★】2026-10-13 用户拍板:
#   "是否有接口"与"实战能不能打上"是两件事。本钩子是**契约层**: 只要是"自己召唤
#   的一道闪电"就该走这里, 至于那道雷在不在 8 秒窗口内、伤害够不够看, 那是**数值层**
#   的事(要调就调 ol_bonus 的倍率/节流, 别退回"不给接口")。
#   ⇒ 现在**全包所有 summon lightning_bolt 的点都接了**(守门 onlight 桶兜底)。
#   ★ 反面教材: 雷鸣当初按"8 秒内切不过去"判成不接 —— 但雷鸣是**副手**, 根本不用切:
#     它被动抓场上任何一道不带 zx.th_seen 的新闪电(含自然雷、含别的武器带 zx.th_own
#     劈出来的雷), 1 秒后自动连锁劈一道,
#     副手常驻 ⇒ 只要窗口开着且场上有雷, 连锁雷就会落在窗口里。判据本身是错的。
# 【★ 换身份的两种写法 ★】钩子契约是"@s = 召唤那道雷的玩家":
#   · 调用方已经是玩家(charge/bolt、anion/cast、thunderrod/*) —— 直接 `function 本函数`。
#   · 调用方是 marker/生物(arc/ol_fire、thunder/pend_go、thunderclap/bolt_one) ——
#     必须 `at @s as <反查到的射手> run function 本函数`: `at` 钉落点、`as` 换执行者。
#     ★ 顺序反了雷的落点会跑到玩家脚下(arc/ol_fire 已经踩过一次)。
# 【诊断】#an_dbg0..3(zx.meta 上的假玩家, 每次 +1)是本链的**四级锚**, 用
#   /function sweetdream:debug/lightning_probe 打印: 数字从哪一级起是 0, 链就断在哪。
# ============================================================

# ⓪ 锚 0: 钩子**被调用**的次数(不管窗口开没开都 +1)
scoreboard players add #an_dbg0 zx.meta 1

# ① 负离子·超限: 8 秒内自身召唤闪电 → 闪电额外对落地处造成 当前魔力 ×0.1
#    (位置 = 调用方给的落点, 别加 at @s —— 见头注)
execute if score @s zx.an_boost matches 1.. run function sweetdream:equipment/axe/anion/ol_bonus

# ② 超•负•荷·超限(第二形态): 每次召唤闪电 → 对落点处的生物造成 基础攻击力 ×3
execute if score @s zx.chg_mode matches 1 run function sweetdream:equipment/axe/charge/ol_bolt_bonus
