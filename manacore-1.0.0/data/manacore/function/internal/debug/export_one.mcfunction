# ============================================================
# internal/debug/export_one —— 导出单个玩家的记录(mode 8)
# ------------------------------------------------------------
# 【宏参数】manacore:work.a {uuid}(由 index/visit 传入)
# 【做什么】把 players."<uuid>" 整份复制到 out r.players."<uuid>"
# 【调用方】api/stats/export_all
# 【用途】整包备份 / 迁移到别的存档(改个键名再 data modify 写回去即可)
# ============================================================
$execute if data storage manacore:players "$(uuid)" run data modify storage manacore:out r.players."$(uuid)" set from storage manacore:players "$(uuid)"
