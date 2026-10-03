# ============================================================
# sweetdream:overlimit/api/lore_seed —— 把超限定义的 lore 整段搬出来(宏 {ol})
# ------------------------------------------------------------
# 【谁调用它】station/api/lore_refresh 的 ② —— 只在"敲过超限"的时候走。
# 【为什么这条线】以前的做法是"原始描述 + 追加一行 ✦ 超限", 结果
#   **技能都被顶掉了, 描述里还写着旧技能**(玩的时候根本看不出变成了什么)。
#   现在改整段替换: 有 ol -> 描述 = oldef.<ol>.lore, 原描述一行不留。
# 【★ 空列表兜底 ★】万一某条定义忘了写 lore, "set from" 会失败(静默),
#   物品就变成一个**没有描述**的东西 —— 那就比改之前更糟了。
#   所以先 set value [] 占位, 有 lore 再覆盖过去。
# ============================================================

data remove storage zx:work lore
data modify storage zx:work lore set value []
$execute if data storage zx:config oldef."$(ol)".lore run data modify storage zx:work lore set from storage zx:config oldef."$(ol)".lore
