# ============================================================
# sweetdream:lib/heal_up —— lib/heal 的宏件（临时压上限 → 顶满 → 跨拍撤上限）
# ------------------------------------------------------------
# 【宏参数】zx:work hp {d} —— 要加给 minecraft:max_health 的**整数**增量（≤ 0）
# 【执行者】被治疗的玩家
# 【为什么必须单独一个文件】modifier 的 add_value **只能是字面量**，不能直接接
#   score / storage；想让它跟着计分板变，只能靠宏参数把数字拼进命令里。
#   （同 armor_hp/apply、furnace_core/hp_add、upgrade/api/hp_attr 的写法；
#     宏源统一用 int 标签 —— 包内没有"把 double 当宏参数"的先例。）
# ------------------------------------------------------------
# 【★★★ 2026-10-16 二次定论：药水是**延迟**生效的，修饰符不能在这里就撤 ★★★】
#   用户复测"归息直接回了 19 血(≈满血)、可能远远不止"—— 数**不是**算错的，是**时序**错的：
#     · `instant_health` 虽然是"即时效果"，但它真正治疗发生在**实体的 tickEffects()**
#       阶段；而本件是由**进度**(player_hurt / player_hurt_entity)触发的，那一刻
#       **早于** tickEffects()（网络包与函数都在实体 tick 之前跑）。
#     · 于是旧写法"发药水 → 当场撤修饰符"在**同一次执行内**就跑完了：等药水真生效，
#       天花板(临时上限)已经拆掉 ⇒ 4·2^20 ≈ 419 万点治疗直接顶到**真实上限**
#       ⇒ 表现成"一键满血"，跟要求恢复几点无关。
#   ⇒ 正解 = **把撤修饰符推迟到下一拍**：药水在本刻的 tickEffects() 里生效(那时天花板
#     还在)，由 core/tick 于**再下一拍**调用 lib/heal_off 摘掉它。
#   【★ 为什么交棒给 core/tick 而不是 schedule ★】
#     schedule 的函数**没有执行者**(不带上下文)，多玩家同时回血时要额外扫人；
#     core/tick 每刻都在跑，天然逐人处理，就算某一刻被打断(命令预算打满跳过一整段)
#     下一拍也会自动补上。派发见 core/tick 的"回血收尾"那三行。
# ------------------------------------------------------------
# 【★★ 两个标签的分工（为什么是两拍）★★】
#   zx.heal_p  = "上限已压低、药水已发"（本件设置）
#   zx.heal_on = "到期，可以撤了"（core/tick 把 heal_p 升格成它，下一拍 lib/heal_off 摘）
#   为什么要两拍而不是一拍：本件理论上可能被"函数阶段"的调用点触发(同刻早于 core/tick)，
#   一拍的话会在**同一刻**就被摘掉 —— 药水还没到 tickEffects。两拍给出确定的 ≥1 刻间隔。
#   ★ 不变量：**zx.heal_p 或 zx.heal_on 在场 ⟺ sweetdream:heal_cap 挂着**。
#     两者总是成对设置/清除，所以开头 ① 拿它们做门控是可靠的。
# ------------------------------------------------------------
# 【★ ① 为什么用门控而不是无条件 remove ★】没挂过去 remove，命令会**执行失败**
#   (wiki `/attribute`: "不存在具有指定命名空间ID的修饰符" ⇒ 失败)。包内
#   lib/unfreeze_one 是"无条件 remove 后面还接着 4 条命令"且实测工作正常 ⇒ 失败
#   **不会吞掉后面的命令**；这里的门控是让语义更干净、也让不变量可读，并非救命稻草。
# ============================================================

# ① 若上一轮还没撤（同一刻连点 / core/tick 尚未收尾），先把旧的摘掉
execute if entity @s[tag=zx.heal_p] run attribute @s minecraft:max_health modifier remove sweetdream:heal_cap
execute if entity @s[tag=zx.heal_on] run attribute @s minecraft:max_health modifier remove sweetdream:heal_cap

# ② 把上限临时压到"目标生命"（负数 add_value 就是减；值来自宏）
$attribute @s minecraft:max_health modifier add sweetdream:heal_cap $(d) add_value

# ③ 超大等级 instant_health：4·2^20 ≈ 419 万点，远超任何上限
#    ⇒ 治疗量被 setHealth 夹到"临时上限" = 目标生命。hideParticles = true。
#    ★ 它在**本刻实体 tick 的 tickEffects()** 才生效 —— 所以天花板必须留到那时（见 ④）。
effect give @s minecraft:instant_health 1 20 true

# ④ 交棒：标记"待撤"，由 core/tick 在**再下一拍**调用 lib/heal_off 摘修饰符
tag @s add zx.heal_p
