# ============================================================
# sweetdream:equipment/tool/nullify/on_create_go —— 宏: 真正写下那个按 uuid 的标记
# ------------------------------------------------------------
# 【宏参数】zx:work nf.uu = 术阵归属玩家的 uuid 文本
# 【为什么按 uuid 当键名】事件回调的 ctx 里没有玩家实体(见 RULES 坑 60), 只能靠
#   uuid 字符串把"谁召唤了术阵"记下来; 而 tool/nullify/on_second 侧在 as @a 循环里
#   能取到自己的 uuid(lib/uuid) —— 两边对得上。
#   ★ 注意: 兑现在 on_go 里写的是**玩家自己的计分项** zx.mm_add(不是这套 uuid 键),
#     uuid 只用来标记"这一次召唤事件归属于谁"。
# ★ 宏参数缺失时整个函数一条都不跑(不是"跑一半"), 所以不会写出 form_mark."" 这种垃圾键。
# ============================================================

$data modify storage zx:data form_mark."$(uu)" set value 1b
