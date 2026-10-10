# ============================================================
# manacore:internal/uuid/migrate —— 把老键(残缺 8 位)的数据迁到新键(宏 {h0,uuid})
# 【为什么单独一层】上一版把它和"拼 uuid"写在同一个宏里, 那一行出问题就整个宏都不干活;
#   拆开后: 拼 uuid 不依赖宏, 迁移失败也只影响迁移本身。
# 【老键长啥样】以前 UUID 只拼出前 8 位 -> 老键就是 hex 的前 8 位(正好 = h0)。
# ============================================================

# 【★ 2026-10-10 修复(静默失效)★】原来写成 `storage manacore:players."$(h0)"`
#   —— storage id 与路径之间**漏了空格**。resource location 的字符集是
#   `[a-z0-9_.:/-]`, 到 `"` 就断 ⇒ 实际解析成 **id = `manacore:players.`**(多一个尾点)
#   + path = `"$(h0)"`, 也就是**整个迁移都作用在另一个存储上**, 真实记录里的老键
#   永远迁不过来(函数能加载、不报错, 完全静默)。修法: id 与路径之间补空格。
#   ⇒ 这次的迁移才是真的生效。守门: check.py 的 dstore 规则(已补 `.` 后跟引号)。
# ============================================================

$execute if data storage manacore:players "$(h0)" unless data storage manacore:players "$(uuid)" run data modify storage manacore:players "$(uuid)" set from storage manacore:players "$(h0)"
# 【★ 登记"终身清单"(修 F16)★】上面这一句会**新建**一个键(老键 -> 新键), 属于
#   "建记录"的一种 ⇒ 也要登记(见 internal/player/create 的说明)。
#   ★★ 2026-10-10 修: 登记条件必须**逐字照抄上面那句的 if/unless**!
#   第一版漏抄了, 于是本函数每次 join 都无条件 append 一条 —— 事故现场
#   `players_all.list` 里同一个 uuid 重复 92 次(每秒长一条, 无限增长)。
#   清单元素是裸字符串、判不了重, 所以"只在真的迁移时登记"是唯一正确的写法。
$execute if data storage manacore:players "$(h0)" unless data storage manacore:players "$(uuid)" run data modify storage manacore:players_all list append value "$(uuid)"