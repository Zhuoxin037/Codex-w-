# ============================================================
# sweetdream:lib/look/layer_row —— 观测镜: 渲染一条「层数」段
# ------------------------------------------------------------
# 【宏参数】layer 表的一行 {o,l,c,e,n,max}         【执行者】玩家本人
#   o = 计分项   l = 短标签   c = 数值颜色   e = 属于哪件装备(在身才显示)
#   n = 尾巴备注(「层」「点」「次」…可空)   max = 上限常数(0 = 不显示 X/Y)
# 【干什么】把那件装备的层数, 拼成一个文本组件**追加**到 zx:look.xline 里。
#   同一次刷新里每个槽都会 append, 于是"有几件在身的层数机制"就拼出几段。
# 【★ 一条分隔符 ★】整个层数段挂在动作栏**冷却后面、同一行**。第一条命中的 layer 行
#   会先垫一个 " ｜ " 分隔符(#ly_first 计数: render_go 每轮把它置 1, 用一次就 0)。
#   段与段之间用 " · "(中点)隔开。
# 【★ 过滤条件(和 debug/stat_row 一个道理) ★】
#   ① 只在"这件装备在身 / 在手上"时显示: 查 zx:work eq.$(e)
#      (render_go 刷新时会先扫 6 个槽位登记在身装备; 没穿的层数不该占地方)
#   ② 层数为 0 不显示(没在积攒就不占行)
# 【★ 两种格式 ★】
#   max > 0 -> 显示 "标签 当前/上限" (如 "燃灰 3/10")
#   max = 0 -> 只显示 "标签 当前"
# 【★ 上限怎么判 ★】max 是宏参数(常数), 先塞进 #ly_show 计分项, 用 >0 决定要不要补 "/上限";
#   但**显示**时不能挂 {"score":"#ly_show"}(会被后续行覆盖成 0), 要写死 {"text":"/$(max)"}。
#   上限值本身用 {text} 组件写死(它是常数, 不做动态 scoring)。
# 【★ 组件结构 ★】每段 3~5 个组件:
#   {"text":"<l> ","color":"gray"}  标签
#   {"score":{"name":"@s","objective":"<o>"},"color":"<c>"}  当前值
#   (有上限时) {"text":"/","color":"dark_gray"} + {"text":"<max>","color":"dark_gray"}
#   {"text":" <n>","color":"dark_gray"}  备注
# 【谁调它】lib/look/layer_unroll(生成文件, 观测镜刷新时逐槽调)
# ============================================================

# ⓪ 先把分数"建成" —— ★ 这是"层数为 0 不显示"能生效的前提 ★
#   `if score @s <计分项> matches 0` 在玩家**还没在这条计分项上有分数**时会
#   **直接失败**(不是当成 0), 于是守卫放行, 观测镜上冒出 "启示 0/3 页" 这种
#   幽灵段(2026-10-05 真实事故: 七条层数计分项里 zx.ap_n 漏了初始化)。
#   `add ... 0` = 有分数就加 0(不动), 没分数就建成 0 —— 一行通吃, 不用每个
#   计分项都记得去 core/load 里补一句。
$scoreboard players add @s $(o) 0

# ① 只在装备在身 + 层数非 0 时往下走(否则什么都不拼)
$execute unless data storage zx:work eq.$(e) run return 0
$execute if score @s $(o) matches 0 run return 0

# ② 分隔符: 第一条命中的层数段垫 " ｜ ", 之后的段垫 " · "
#   ★ 这里必须用"先抄一份再清"的写法 ★ —— mcfunction 没有 else, 直接
#     "if(==1){垫｜; 置0}" 后面紧跟 "if(==0){垫·}" 的话, 第一条会**两个都垫**。
#     所以先把 #ly_first 抄进 #ly_was, 用 #ly_was 决定垫哪个, 再清 #ly_first。
scoreboard players operation #ly_was zx.meta = #ly_first zx.meta
scoreboard players set #ly_first zx.meta 0
execute if score #ly_was zx.meta matches 1 run data modify storage zx:look xline append value {"text":"  ｜ ","color":"dark_gray"}
execute if score #ly_was zx.meta matches 0 run data modify storage zx:look xline append value {"text":"  ·  ","color":"dark_gray"}

# ③ 标签 + 当前值(所有情况都有)
$data modify storage zx:look xline append value {"text":"$(l) ","color":"gray"}
$data modify storage zx:look xline append value {"score":{"name":"@s","objective":"$(o)"},"color":"$(c)"}

# ④ 有上限(max>0) -> 补 "/上限"
#   ★ 上限必须写成**写死的 text 组件** {"text":"$(max)"}, 不能挂 {"score":"#ly_show"} ★
#     因为组件是"动作栏渲染那一刻"才读值的: 所有 layer 行共用同一个 #ly_show,
#     后面几行(尤其 max=0 的那几行)会把它覆盖成 0 —— 于是燃灰永远显示 "x/0"。
#     max 本来就是常数, 直接写进 text 就不会被串味。
$scoreboard players set #ly_show zx.meta $(max)
$execute if score #ly_show zx.meta matches 1.. run data modify storage zx:look xline append value {"text":"/$(max)","color":"dark_gray"}

# ⑤ 备注(「层」「点」「次」…可空)
$data modify storage zx:look xline append value {"text":" $(n)","color":"dark_gray"}
