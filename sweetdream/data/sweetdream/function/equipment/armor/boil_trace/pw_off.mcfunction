# ============================================================
# sweetdream:equipment/armor/boil_trace/pw_off —— 回收沸痕的"细雪灭点"
# ------------------------------------------------------------
# 【谁调用它】core/tick 每刻扫 `@e[type=minecraft:marker,tag=zx.bt_pw2]`(三维度各一遍)
# 【执行者/位置】那块细雪的 marker（位置 = 当初放细雪的那一格）
# 【做两件事】清掉那格细雪（若还在）/ 销毁 marker 自己
# ------------------------------------------------------------
# 【★ 为什么是 `replace minecraft:powder_snow` 而不是 `replace air` ★】
#   只替换**细雪**：那格若是别的方块（玩家当时贴着天花板, keep 压根没放成），或者细雪
#   已被玩家自己撞毁、那格又落了别的东西 —— 本命令都**什么都不做**。
#   这是"只管自己放的东西"的保险丝；写成 `replace air` 就会把别人的方块清掉。
# 【★ 为什么两拍才轮到它 ★】on_hurt 里挂的是 `zx.bt_pw1`，由 core/tick 先升格成
#   `zx.bt_pw2` 才进到这里 —— 保证那块细雪**活过至少一个完整的玩家 tick**。
#   早一拍清掉的话，玩家还没 tick 到、细雪就没了，等于没灭火（这是本机制唯一的坑）。
# 【正常路径其实用不到它】燃烧中的玩家碰到细雪会**自己把它撞毁**，本件只是兜底
#   "放完就跳开/走开"的那一块，避免在地上留个看不见的细雪陷阱。
# ============================================================

# 【★ 2026-10-17 修：旧写法 `setblock ~ ~ ~ minecraft:air replace minecraft:powder_snow`
#   是**非法语法** ★】setblock 的第三个参数只有 destroy / keep / replace 三个模式,
#   **不接受"要替换的方块"** —— 整行解析失败 ⇒ 整个 pw_off 加载失败(日志里一行
#   Whilst parsing, 玩家完全无感) ⇒ marker 永不销毁、每刻被 core/tick 反复扫。
#   想"只替换细雪"只能先用 `if block` 门控, 再 `replace`(默认模式, 无条件替换):
execute if block ~ ~ ~ minecraft:powder_snow run setblock ~ ~ ~ minecraft:air replace
kill @s
