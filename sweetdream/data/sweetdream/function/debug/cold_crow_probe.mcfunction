# ============================================================
# sweetdream:debug/cold_crow_probe —— 看一眼某支箭身上带没带"这一发的快照"
# ------------------------------------------------------------
# 【谁调它】debug/cold_crow 的第 ⑤ 步, 对 8 格内最近的几支箭逐个 as 进来。
# 【执行者】那支箭(位置、维度都是它自己的)
# 【怎么把结果说给人】此刻的 @s 是**箭**, 不是玩家, 所以:
#   · 说话对象必须写 @a[tag=zx.cc_dbg] —— 找那个发起自检的玩家
#     (标签由调用方 debug/cold_crow 的 ⑤ 段打上, 说完自己清掉)
#   · 箭自己的 NBT 用 {"nbt":"...","entity":"@s"} 引用 —— 组件里的 @s
#     解析的是**命令源**(= 这支箭), 不要求是玩家。
# ⚠️ 【别写成 tellraw @e[...]】tellraw / title / subtitle 的"目标"参数
#   在命令树里是 **players-only**(EntityArgument.players())。写成
#   @e[tag=zx.cc_dbg,limit=1] 不是"运行时找不到人", 而是**解析期直接失败**:
#     Whilst parsing command on line N: 只有玩家会受此命令的影响,
#     但提供的选择器包括其他实体
#   → 整个函数加载不出来(一条命令都不跑)。这类"只认玩家"的命令只能配
#     @a / @p / @r / @s(或 @e[type=player])。判据见 check.py 第 12 项。
# ============================================================

execute if data entity @s data.zx.cc{ok:1b} run tellraw @a[tag=zx.cc_dbg,limit=1] [{"text":"  ✓ 这支箭带着自己的快照: ","color":"green"},{"nbt":"data.zx.cc","entity":"@s","color":"aqua"}]
execute unless data entity @s data.zx.cc{ok:1b} run tellraw @a[tag=zx.cc_dbg,limit=1] [{"text":"  · 这支箭没有快照(老箭 / 没写进去) —— 命中时会退回用「射手最近一发」","color":"dark_gray"}]
