# ============================================================
# sweetdream:lib/dmg_add_put —— 往"加算池"里加一份百分比(宏)
# ------------------------------------------------------------
# 【宏参数】zx:work put {ch:"mm"|"atk"|"oth", pct:<整数>}
#     ch  = 加哪条通道(必须和 zx:work add / zx:work ch 的键名一致)
#     pct = 加多少(整数; 10 = +10% —— 和池子的量纲一致: 池子里 0.10 就是 10)
# 【调用模板】
#     scoreboard players operation #pct zx.meta = …      <- 算出百分比
#     execute store result storage zx:work put.pct int 1 run scoreboard players get #pct zx.meta
#     data modify storage zx:work put.ch set value "mm"
#     function sweetdream:lib/dmg_add_put with storage zx:work put
# 【为什么写成宏】"读出来 -> 加 -> 写回去"这三步对 mm/atk/oth 完全一样, 只有键名
#   不同。抄三遍就等着哪天改错一行 —— 而且 __storage 的 double 没有 "+=" 运算符,
#   只能走计分板中转, 抄错一次就是静默的数值错误。
# 【★★ 唯一一个坑: 累加那一步必须 `players add` ★★】见函数体里的长注 ——
#   `players operation … += $(pct)` 展开成数字后**整行非法**, 加载期不报错、
#   运行时静默失效, 会让**所有**加算加成一起死。改这一行前先看那段注释。
# 【★ 每次读之前先 #t=0 ★】`data get` 读不到键时 store 不执行, #t 会留着上一个值
#   (跨通道串味)。clear 之后键一定存在, 但这行是白送的保险。
# 【★ 调用方必须先 dmg_add_clear ★】否则池子里会带着上一次施法的残留。
# ============================================================

# ★ 第一行**故意不带 $** —— `$` 只允许加在"含 $(变量)"的行上, 加了却没有变量
#   会报 "Macro without variables" 并作废**整个函数**(check 规则 dollar / RULES 16)。
#   宏函数里非 $ 开头的行照常按普通命令执行。
scoreboard players set #t zx.meta 0
$execute store result score #t zx.meta run data get storage zx:work add.$(ch) 100
# ★★ 必须 players add, 不能写 `players operation #t zx.meta += $(pct)` ★★
#   宏是**运行时**才替换并解析的: 加载期 $(pct) 被当成合法宏参数放过(所以日志里
#   一个错都没有), 真跑起来那行变成 `players operation #t zx.meta += 10` ——
#   operation 的运算数只能是"源玩家 + 源计分项", 数字会被当成目标名、缺 objective
#   ⇒ **该行静默失败**, 池子永远是 0。players add 的 count 本来就是整数参数,
#   是这里唯一正确的写法(2026-10-08 真实事故: 这一行让愿景/共振/漫步冥河/炽天使/
#   mm_add 全部"加算"加成一起失效, 而 check.py 当时 0 报告 —— 宏展开成的字面量
#   在静态文本里看不出来, 已给规则 24 补上"宏运算数"分支)。
$scoreboard players add #t zx.meta $(pct)
$execute store result storage zx:work add.$(ch) double 0.01 run scoreboard players get #t zx.meta
