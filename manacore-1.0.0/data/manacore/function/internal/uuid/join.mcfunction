# ============================================================
# manacore:internal/uuid/join —— 用宏一次性拼出标准 UUID(宏 {h0,h1,h2,h3,h4})
# ------------------------------------------------------------
# 【为什么要宏】命令文本里没法直接拼接字符串: `data modify ... append` 只对**列表**生效,
#   对字符串用 append 会静默失败 —— 这正是"UUID 只有 8 位"的病根(优化建议第 1 条)。
#   宏变量替换本身就是"文本拼接", 一把就能拼成 8-4-4-4-12。
# 【顺带做的事】把老键(残缺的 8 位)迁移到新键上, 免得修好之后玩家数据看起来被清空。
#   老的残缺键 = 十六进制的前 8 位, 正好就是 h0。
# ============================================================

# 【★ 2026-10-10 修复(静默失效)★】同 migrate: `storage manacore:players."…"` 漏了
#   id 与路径之间的空格 ⇒ 解析成 id=`manacore:players.`, 迁到另一个存储上。
#   本文件目前无调用方(拼连字符那套已被 uuid/build 的"纯 hex 键"取代),
#   但仍按同一修法补空格, 免得将来被引用时踩同一个坑。
#   ★ 一并提醒: uuid/build 已说明"拼连字符这一步实测不生效", 别再把本文件接回去。
# ============================================================

$data modify storage manacore:work a.uuid set value "$(h0)-$(h1)-$(h2)-$(h3)-$(h4)"
$execute if data storage manacore:players "$(h0)" unless data storage manacore:players "$(h0)-$(h1)-$(h2)-$(h3)-$(h4)" run data modify storage manacore:players "$(h0)-$(h1)-$(h2)-$(h3)-$(h4)" set from storage manacore:players "$(h0)"
# 【★ 登记"终身清单"(修 F16)★】同 migrate: 新建了键就要登记(见 internal/player/create)。
#   ★ 条件必须逐字照抄上面那句的 if/unless(同 migrate 的 92 条重复事故),
#   否则每次调用都会无条件长一条。
$execute if data storage manacore:players "$(h0)" unless data storage manacore:players "$(h0)-$(h1)-$(h2)-$(h3)-$(h4)" run data modify storage manacore:players_all list append value "$(h0)-$(h1)-$(h2)-$(h3)-$(h4)"
# 【★ N04 修(2026-10-11)★】同 migrate: 新建了键就补打"已登记"标志(见 existing 的说明)。
$execute if data storage manacore:players "$(h0)" unless data storage manacore:players "$(h0)-$(h1)-$(h2)-$(h3)-$(h4)" run data modify storage manacore:players "$(h0)-$(h1)-$(h2)-$(h3)-$(h4)".reg set value 1b