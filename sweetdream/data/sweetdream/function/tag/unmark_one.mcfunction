# ============================================================
# sweetdream:tag/unmark_one —— 摘标记(宏 {mark}; 以那只生物身份执行)
# ============================================================

$data remove entity @s data.zx.status."$(mark)"
# 同样先收掉旧图标, 再重算: 有别的标签 -> 换图标; 一个不剩 -> 收图标 + 摘 zx.tagged + 清编号
function sweetdream:tag/icon_kill_self
function sweetdream:tag/icon_refresh
