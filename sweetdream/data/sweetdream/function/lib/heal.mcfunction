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
# ============================================================

# ① 入参守卫（补 0 后再判，避免"没分数 ⇒ if 不成立 ⇒ 继续跑"）
scoreboard players add #heal_pt zx.meta 0
execute if score #heal_pt zx.meta matches ..0 run return fail

# ② 当前生命（整点，向下取整）
execute store result score #heal_cur zx.meta run data get entity @s Health
# ③ 真实上限（整点）—— 读**原版属性**而不是面板账本：修饰符的加减是相对属性总值的，
#    拿面板值算会差出"面板与属性不同步"的那一截。
#    （读玩家属性完全合法：只读不写。）
execute store result score #heal_cap zx.meta run attribute @s minecraft:max_health get
execute if score #heal_cap zx.meta matches ..0 run return fail

# ④ 目标生命 = min(当前 + N, 上限)
scoreboard players operation #heal_new zx.meta = #heal_cur zx.meta
scoreboard players operation #heal_new zx.meta += #heal_pt zx.meta
execute if score #heal_new zx.meta > #heal_cap zx.meta run scoreboard players operation #heal_new zx.meta = #heal_cap zx.meta

# ⑤ 修饰符增量 = 目标 − 上限（恒 ≤ 0；= 0 表示"本就该顶到上限"，此时那发
#    instant_health 恰好把血顶满 —— 结果同样正确，所以这里**不要**提前 return）
scoreboard players operation #heal_d zx.meta = #heal_new zx.meta
scoreboard players operation #heal_d zx.meta -= #heal_cap zx.meta

# ⑥ 交给宏件（modifier 的 add_value 只能是字面量，接不了 score）
#   ★ 这里只负责"压上限 + 发药水 + 挂待撤标签"；摘上限是 lib/heal_off 的事，
#     由 core/tick 在两拍之后调 —— 别图省事挪回来（见文件头 ③）。
data modify storage zx:work hp set value {d:0}
execute store result storage zx:work hp.d int 1 run scoreboard players get #heal_d zx.meta
function sweetdream:lib/heal_up with storage zx:work hp

# ⑦ 自检留痕（查现场用：/scoreboard players get #heal_d zx.meta 应为 ≤0 的整数）
