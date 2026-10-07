# ============================================================
# sweetdream:lib/ctrl_mul/pct —— 「控制时长倍率」的单一真源
# ------------------------------------------------------------
# 【宏参数】zx:work cm {target:"<选择器>"}
# 【出参】两个都落在 zx.meta 上，单位是"百分数"(1.0 倍 = 100)
#     #cm_pct = 最终倍率(100 = 不加成, 120 = ×1.2)  -> 面板显示用
#     #cm_add = 额外加成(= #cm_pct - 100, 0 = 不加成) -> 时长换算用
# 【为什么要单独一个文件】
#   "白昼梦 = 受控时间 +20%" 以前**写死在** lib/timestop 与 lib/freeze 里(两处各自
#   算一遍 `ticks × #20 ÷ #100`)。两处各写一份, 数值一改就得改两处; 而 debug/stats
#   想显示这个倍率时无从下手 —— 这就是"控制时长也要算进倍率里、并且被 stats 读到"
#   要解决的问题: 把**倍率算法**收敛到这一个文件, 结算(timestop/freeze)与显示(stats)
#   读同一个数, 不会再出现"面板显示的和实际生效的不一样"。
# 【★ 为什么每个来源"先 set 临时量、再并入总量"，而不是直接 add ★】
#   $(target) 可能是**范围选择器**(例: aurora_dream 的 `@e[...distance=..6,...]`)。
#   `execute as $(target) ... run scoreboard players add #cm_add ... 20` 会对每一只
#   各加一次 -> 匹配 3 只就变成 +60%。用"临时量 set + 并入总量"则与匹配到几只无关。
# 【★ 以后加新来源 ★】照"来源 1"那三行复制一段, 只改 tag 与数值即可。
# 【★ 无加成时 #cm_pct = 100 / #cm_add = 0 ★】
# ============================================================

scoreboard players set #cm_add zx.meta 0

# ---- 来源 1: 白昼梦(受控时间 +20%) ----
scoreboard players set #cm_b zx.meta 0
$execute as $(target) if entity @s[tag=zx.status.dream] run scoreboard players set #cm_b zx.meta 20
scoreboard players operation #cm_add zx.meta += #cm_b zx.meta

# ---- 最终倍率 = 100 + 额外加成 ----
scoreboard players set #cm_pct zx.meta 100
scoreboard players operation #cm_pct zx.meta += #cm_add zx.meta

# ---- 面板要的"×N.NN"字符串(留给 debug/stats 直接塞进 pl.ctrl_mul) ----
#   ★ 为什么不给 double 让它自己渲染 ★
#     双精度下 #cm_pct ÷100 会出现长尾: 115 -> 1.1500000000000001, 138 -> 1.38 之外
#     还有一批(113/114/115/138..140/163..166/188..191 在 100..200 之间)。面板是给人
#     看的, 所以这里直接拼成两位小数的**字符串** —— num_row 的链路(lib/num/plain)
#     对字符串是原样透传(只砍 d/f 后缀), 拼出来什么样就显示什么样。
#   ★ 拼接用宏: $(i) 是整数部分、$(pad) 是补位用的 "0"、$(f) 是小数部分。
#   ★ zx:work cm 里的 i/f/pad 是**中间字段**, 调用方只管读 cm.s。
#   【只支持非负倍率】现在唯一的来源是 +20%(pct=120)。以后若加"控制时长 -X%"的来源,
#     要么保证 pct >= 0, 要么在这里补一个负号分支。
scoreboard players set #cm_i zx.meta 0
scoreboard players operation #cm_i zx.meta = #cm_pct zx.meta
scoreboard players operation #cm_i zx.meta /= #100 zx.meta
scoreboard players set #cm_f zx.meta 0
scoreboard players operation #cm_f zx.meta = #cm_pct zx.meta
scoreboard players operation #cm_f zx.meta %= #100 zx.meta
execute store result storage zx:work cm.i int 1 run scoreboard players get #cm_i zx.meta
execute store result storage zx:work cm.f int 1 run scoreboard players get #cm_f zx.meta
data modify storage zx:work cm.pad set value ""
execute if score #cm_f zx.meta matches ..9 run data modify storage zx:work cm.pad set value "0"
#   ★ 必须换一个函数来拼(见 lib/ctrl_mul/fmt 的说明): 宏参数在**调用那一刻**就绑死了,
#     本函数里刚写进 cm.i/cm.f 的值这一层引用不到 —— 只有在"下一次调用"里才生效。
function sweetdream:lib/ctrl_mul/fmt with storage zx:work cm
