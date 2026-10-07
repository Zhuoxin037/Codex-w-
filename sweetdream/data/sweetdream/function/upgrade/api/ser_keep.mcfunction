# ============================================================
# sweetdream:upgrade/api/ser_keep —— 旧条目去留: 非本系列才保留(宏 {id, ser})
# ------------------------------------------------------------
# 【干什么】这条旧升级的系列(seen 键集里**只有**新手头的那个系列)不属于
#   正在敲的系列 -> 原样搬进 newlist; 是同系 -> 丢弃(被新手头替换, 一槽一条)。
# 【出参】zx:work newlist(重建中的 up 列表, 由 up_rebuild 写回物品)
# 【调用方】ser_mark2(由 up_rebuild 逐槽喂)
# ============================================================

$execute unless data storage zx:work seen."$(ser)" run data modify storage zx:work newlist append value "$(id)"
