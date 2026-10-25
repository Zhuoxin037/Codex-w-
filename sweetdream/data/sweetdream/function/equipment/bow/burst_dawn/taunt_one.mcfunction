# ============================================================
# sweetdream:equipment/bow/burst_dawn/taunt_one —— 单只生物: 它在追我主人吗?
# ------------------------------------------------------------
# 【谁调用它】taunt ②: execute as @e[...] run function ...
# 【执行者】@s = 那一只候选生物
# 【★ 为什么单独拆一个文件(而且不是宏函数)★】
#   `execute on target` 会把 @s 换成"它的索敌目标", 而我们要给**它自己**打标签
#   —— 所以判断和打标签必须分成两条命令, 中间靠一个**全局计分项**传话:
#     · `execute on target if entity @s[tag=zx.bd_owner]` 只负责把结果写进
#       #bd_tt(写计分项不挑执行者, 所以换了上下文也没关系);
#     · 第二条回到**原来的 @s**(因为 execute ... run 不会改外面)再打标签。
# 【★ 为什么不能写成 `execute on target unless entity @s[...] run return 0` ★】
#   那只生物**根本没有索敌目标**时, `on target` 会因为没有目标而让整条命令失败
#   -> `return 0` 根本不会执行 -> 下面那句会**误把它也标上**(静默扩大范围)。
#   用"计分项传话"则两种情况(没目标 / 目标不是主人)都落在同一个结果上。
# 【★ execute on target 是哪来的 ★】1.21.5 的 `execute on <关系>`(本包圣骸
#   observe.mcfunction 已经在用 `on attacker`, 同一批子命令)。
# ============================================================

scoreboard players set #bd_tt zx.meta 0
execute on target if entity @s[tag=zx.bd_owner] run scoreboard players set #bd_tt zx.meta 1
execute if entity @s[tag=sd.fb.body] run function sweetdream:boss/fireaxe/taunt/check
execute if entity @s[tag=sd.kn.body] run function sweetdream:boss/knight/taunt/check
execute if entity @s[tag=sd.hk.body] run function sweetdream:boss/husk/taunt/check
execute if score #bd_tt zx.meta matches 1 run tag @s add zx.bd_t
