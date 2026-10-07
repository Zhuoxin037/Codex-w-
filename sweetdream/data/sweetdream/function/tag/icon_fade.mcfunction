# ============================================================
# sweetdream:tag/icon_fade —— 标签图标淡出的入口(每刻, 执行者 = 被标记的那只生物)
# ------------------------------------------------------------
# 【谁调它】core/tick 三维度 `in <dim> as @e[tag=zx.icon_fading_owner] at @s`
# 【★ 为什么要有这一层(跟随)而不是干脆不管 ★】
#   摘掉最后一个标签后生物已经不在 `zx.tagged` 里了(follow_dimension 只遍历它),
#   不补这条的话正在淡出的图标会被移动中的生物甩在原地 —— 0.4 秒能拉开 1~2 格。
# 【逐帧淡出不在本文件】在 `tag/icon_fade_icon`(从**图标侧**驱动): 生物中途死亡、
#   本驱动消失时, 图标仍能自己淡完并 kill, 不会留下永远的孤儿图标。
# 【自清理】生物身上带 zx.icon_fading_owner 当驱动标签; 图标消失(淡完 / 被重贴提前清掉)
#   后由 icon_fade_go 摘掉它, 之后开销归零。
# ============================================================
function sweetdream:tag/identity
function sweetdream:tag/icon_fade_go with storage zx:tag owner
