# ============================================================
# sweetdream:lib/heal —— 精确恢复生命值（"恢复 N 点生命值"的公共原语）
# ------------------------------------------------------------
# 【入参】#heal_pt zx.meta = 要恢复的**整点数**（必须 1..；0/负数直接返回）
# 【执行者】被治疗的**玩家**（为什么只支持玩家见最后一段）
# 【★★ 2026-10-16 定论：原版禁止用命令写玩家 NBT ★★】
#   本件初版写的 `execute store result entity @s Health <float|double> …`
#   （以及 furnace_core/apply_hp、upgrade/api/hp_add 里的"夹当前生命"）
#   —— **从来没生效过一次，而且和类型写 float 还是 double 无关**。
#   真因：`/data` 与 `/execute store` 对**玩家**实体一律拒绝，抛
#     `commands.data.entity.invalid` = "Unable to modify player data"
#   （已在 1.21.5 客户端 jar 的 assets/minecraft/lang/en_us.json 里核到该键，
#     并确认引用它的正是 data 命令那个类）。
#   同理"给玩家写 Fire"（`data merge entity @s {Fire:-20s}`）也一律无效。
#   ⇒ 2026-10-15 那轮"改成 float 就好了"的判断是**错的**，类型根本不是原因。
#   （**生物**的 NBT 可以写，所以包里给生物点火的 immolate/ignite 一直是好的。）
# 【★ 正解：压上限 → 顶满 → 跨一拍撤上限（全程只用 /attribute 与 /effect）★】
#   ① 用一个**负的 add_value 修饰符**把 minecraft:max_health 临时压到"目标生命"
#       目标生命 = 当前生命 + N，且不超过原上限；
#   ② 给一发**超大等级**的 instant_health —— 治疗量远超需求，会被 setHealth 夹到
#       "临时上限"，于是当前生命正好落在目标生命；
#   ③ 把修饰符摘掉 —— 上限复原，当前生命停在目标值（≤ 原上限 ⇒ 不会再被回夹）。
#   ★★ 2026-10-16 二次返工：③ **不能**和 ② 挤在同一个函数里 ★★
#     `instant_health` 真正治疗发生在**实体的 tickEffects()**，而本链的触发点是
#     **进度**(player_hurt / hurt_entity) —— 那一刻早于 tickEffects()。所以"发药水
#     当场撤天花板"= 药水生效时已无天花板 ⇒ 4·2^20 顶到真实上限 ⇒ 一键满血
#     (用户报的"归息回了 19 血")。③ 现在由 **lib/heal_off + core/tick** 在**再下一拍**
#     执行。详见 lib/heal_up 文件头。
#   ★ 其它写法都做不到"精确 N 点"：instant_health 只有 4·2^k 的档位（4/8/16/32…），
#     absorption 是**另一条血池**（黄心，不是生命值），玩家 NBT 又写不了。
# 【★ 为什么要夹上限 ★】instant_health 是无差别大治疗，不给它天花板就会一口气满血。
# 【★ 精度：整点 ★】修饰符的增量只能是**整数字面量**（见 lib/heal_up 的说明），
#   所以当前生命向下取整 ⇒ 实得 = N + (0 ~ 1 点的小数残差)，**只会少不会多**。
#   例：当前 3.166 点、N=6 ⇒ 目标 3+6=9 点（实得 5.834 点，半个心以内看不出）。
# 【★ 为什么只支持玩家 ★】路线② 依赖 instant_health，而它对**亡灵**是伤害；
#   生物又根本不需要这么绕（生物 NBT 可写）。当前三个调用点（沸痕/归息/殓丝）全是玩家。
# 【★ 常数不存在也不用慌 ★】#heal_pt 没分数时下面第 ① 步会把它补成 0 并直接返回，
#   不会走到"没有天花板就满血"的坏路径。
# ------------------------------------------------------------
# 【★★★ 2026-10-19 三次修复：重入时读到的是"被压低的临时上限" ★★★】
#   症状：上限 20、当前 5，连做两次"恢复 5 点"，**结果是 20（直接满血）**，应为 15。
#   根因（两层）：
#     ① 第 ③ 步读的 `attribute … max_health get` 是**含修饰符的总值**。上一轮的
#        `sweetdream:heal_cap` 要跨两拍才被 core/tick 撤（heal_p→heal_on→heal_off），
#        这期间读到的是**临时上限**（例 10）⇒ 目标算成 min(5+5, 10) = 10、增量 d = 0；
#        而 lib/heal_up ① 会先摘旧修饰符 ⇒ 上限当场恢复 20 ⇒ 那发 4·2^20 顶到 20。
#     ② **同一刻**连调两次（绯缝 + 殓丝在同一击里就是这样）时，
#        `data get entity @s Health` 读到的仍是旧值 —— instant_health 要到本刻
#        tickEffects() 才生效 ⇒ 光靠 Health 根本没法累加。
#   正解（下面 ③~⑦）：把上一轮的临时上限**当作"上一次治疗的目标生命"**来用。
#     · 基点 = max(Health, 当前属性上限)   ← 只在 heal_p / heal_on 在场时才取后者
#     · 然后在**同一个函数执行内**先摘旧修饰符、再重读上限（这次是真实上限）
#     · 目标 = min(基点 + N, 真实上限)，增量 d = 目标 − 真实上限（由夹取保证恒 ≤ 0）
#   ★ 为什么"摘旧 → 重读 → 加新"必须在同一个函数里：
#     从摘掉旧天花板到挂上新的之间**不能跨 tickEffects**，否则那一发尚未生效的药水
#     会没有天花板、一口气顶到真实上限 —— 正是二次返工时踩过的"一键满血"。
#     函数内顺序执行不跨 tick，天然满足；所以不能拆成两个函数、更不能交给下一拍。
#   ★ 副作用（好的那个）：同刻多次治疗现在**可以累加**：5 → +5 = 10 → +5 = 15，
#     而不是"只生效一次"。绯缝(5% 上限) 与殓丝(30% 上限) 同击时两笔都会算进去。
#   ★ 单次行为**完全不变**：没有残留标签时基点 = Health、上限 = 真实值，算式同旧版。
# ============================================================

# ① 入参守卫（补 0 后再判，避免"没分数 ⇒ if 不成立 ⇒ 继续跑"）
scoreboard players add #heal_pt zx.meta 0
execute if score #heal_pt zx.meta matches ..0 run return fail

# ② 当前生命（整点，向下取整）
execute store result score #heal_cur zx.meta run data get entity @s Health

# ③ 当前属性上限（★ 可能仍带着上一轮的临时压低，见文件头 2026-10-19）
execute store result score #heal_cap zx.meta run attribute @s minecraft:max_health get
execute if score #heal_cap zx.meta matches ..0 run return fail

# ④ 基点：默认 = 当前生命；若上一轮的天花板还在（它的药水可能尚未生效），取较大值。
#    ★ 只认 zx.heal_p / zx.heal_on 两个标签 —— 不变量是"标签在场 ⟺ heal_cap 修饰符
#      挂着"（见 lib/heal_up 文件头），所以拿它们当门控是可靠的。
#    ★ 为什么用"天花板"而不是自己存一份目标值：天花板本身就是上一轮的目标生命
#      （d = 目标 − 上限 ⇒ 临时上限 ≡ 目标），不用另开计分项，也不会过期失效。
scoreboard players operation #heal_base zx.meta = #heal_cur zx.meta
execute if entity @s[tag=zx.heal_p] if score #heal_cap zx.meta > #heal_base zx.meta run scoreboard players operation #heal_base zx.meta = #heal_cap zx.meta
execute if entity @s[tag=zx.heal_on] if score #heal_cap zx.meta > #heal_base zx.meta run scoreboard players operation #heal_base zx.meta = #heal_cap zx.meta

# ⑤ ★ 摘掉上一轮的临时上限，再重读**真实**上限 ★
#    ★ remove 必须带 `execute if` 门控：没挂过去 remove 会执行失败
#      （wiki /attribute："不存在具有指定命名空间ID的修饰符"）。
#    ★ 两个标签必须紧跟着清掉：不变量是"标签在场 ⟺ 修饰符挂着"；不清的话
#      core/tick 下一拍会拿着 heal_on 去摘一个已经不存在的修饰符。
#    ★ 这里**故意不加 return**：摘了旧的上限就必须走到 ⑧ 把新的挂上，
#      中间任何提前退出都会留下一段"没有天花板"的空窗（未生效药水会顶满血）。
#      上限读失败时 store 不会覆盖，#heal_cap 仍是 ③ 的值（正数），流程照常安全。
execute if entity @s[tag=zx.heal_p] run attribute @s minecraft:max_health modifier remove sweetdream:heal_cap
execute if entity @s[tag=zx.heal_on] run attribute @s minecraft:max_health modifier remove sweetdream:heal_cap
tag @s remove zx.heal_p
tag @s remove zx.heal_on
execute store result score #heal_cap zx.meta run attribute @s minecraft:max_health get

# ⑥ 目标生命 = min(基点 + N, 真实上限)
scoreboard players operation #heal_new zx.meta = #heal_base zx.meta
scoreboard players operation #heal_new zx.meta += #heal_pt zx.meta
execute if score #heal_new zx.meta > #heal_cap zx.meta run scoreboard players operation #heal_new zx.meta = #heal_cap zx.meta

# ⑦ 修饰符增量 = 目标 − 真实上限（⑥ 已夹取 ⇒ 恒 ≤ 0；= 0 表示"本就该顶到上限"，
#    此时那发 instant_health 恰好把血顶满 —— 结果同样正确，所以**不要**提前 return）
scoreboard players operation #heal_d zx.meta = #heal_new zx.meta
scoreboard players operation #heal_d zx.meta -= #heal_cap zx.meta

# ⑧ 交给宏件（modifier 的 add_value 只能是字面量，接不了 score）
#   ★ 这里只负责"压上限 + 发药水 + 挂待撤标签"；摘上限是 lib/heal_off 的事，
#     由 core/tick 在两拍之后调 —— 别图省事挪回来（见文件头 ③）。
data modify storage zx:work hp set value {d:0}
execute store result storage zx:work hp.d int 1 run scoreboard players get #heal_d zx.meta
function sweetdream:lib/heal_up with storage zx:work hp

# ⑨ 自检留痕（查现场用：/scoreboard players get #heal_d zx.meta 应为 ≤0 的整数）

# ⑩ ★ 出参: 本次"实际回复量"(整点) ★
#   定义 = 目标生命 − 基点 = (⑥ 的 #heal_new) − (④ 的 #heal_base)。
#   · 满血时会夹成 0（⑥ 的 min），所以调用方拿 0 就该跳过后续动作；
#   · 这是**计划值**，真正落到血条上要等本刻 tickEffects()（见文件头第 ③ 段）。
#     "归途·超限"拿它当真伤基数 —— 文案写的是"相当于本次回复血量"，
#     用计划值才不会因为药水晚一拍而算成 0。
#   ★ 只读出参，不参与任何分支：加在最后一行，前面 ⑧ 的 return 路径一条都不影响。
scoreboard players operation #heal_got zx.meta = #heal_new zx.meta
scoreboard players operation #heal_got zx.meta -= #heal_base zx.meta
