# ============================================================
# sweetdream:event/cooldown_start_go —— 写入记录(宏参数: {uuid, skill, reason})
# ------------------------------------------------------------
# 【写入内容】sweetdream:data last_skill."<玩家UUID>" = "技能id"
# 【出参】没有, 纯粹记一笔, 供 sweetdream:equipment/look/render_go 读取。
# ============================================================

$data modify storage zx:data last_skill."$(uuid)" set value "$(skill)"
