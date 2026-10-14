# ============================================================
# manacore:internal/uuid/migrate —— 把老键(残缺 8 位)的数据迁到新键(宏 {h0,uuid})
# 【为什么单独一层】上一版把它和"拼 uuid"写在同一个宏里, 那一行出问题就整个宏都不干活;
#   拆开后: 拼 uuid 不依赖宏, 迁移失败也只影响迁移本身。
# 【老键长啥样】以前 UUID 只拼出前 8 位 -> 老键就是 hex 的前 8 位(正好 = h0)。
# 【调用方】internal/uuid/build(每次 join 判 a.h0 存在才调; 见 build 末尾)。
# ============================================================

# 【★ 2026-10-10 修复(静默失效)★】原来写成 `storage manacore:players."$(h0)"`
#   —— storage id 与路径之间**漏了空格**。resource location 的字符集是
#   `[a-z0-9_.:/-]`, 到 `"` 就断 ⇒ 实际解析成 **id = `manacore:players.`**(多一个尾点)
#   + path = `"$(h0)"`, 也就是**整个迁移都作用在另一个存储上**, 真实记录里的老键
#   永远迁不过来(函数能加载、不报错, 完全静默)。修法: id 与路径之间补空格。
#   ⇒ 这次的迁移才是真的生效。守门: check.py 的 dstore 规则(已补 `.` 后跟引号)。
# ============================================================
# 【★ N04 修(2026-10-11): 登记被"同一条件"变成死代码 ★】
#   原顺序是"先复制、后登记", 而两句的 if/unless 完全相同(旧键存在 且 新键不存在)。
#   复制一执行, 新键就存在了 ⇒ 紧接着那句同条件的**登记恒假** ⇒ 迁移永远不登记进
#   players_all ⇒ 这些记录 reset_all 清不到。修法: **登记必须排在复制之前**
#   (复制前新键还不存在, 条件成立) —— 守门用顺序锁把"登记先于复制"钉死。
# 【迁移 = 搬移】复制成功后**删掉旧键**: 否则旧键永远留着, 下次 reset_all 清不掉它
#   (它不在清单里), 而下次 join 的 migrate 又把它复制回来 ⇒ 旧属性"复活"。
#   报告 N04 明确要求"迁移保留的旧键也必须纳入清理"。旧键唯一读取点就是本文件,
#   删除后不再有迁移条件成立 ⇒ 一次性、幂等。
# 【★ 登记幂等标志 reg ★】新建/复活记录时写 `players."<uuid>".reg = 1b`, 供
#   internal/join/existing 判断"这条记录是否已登记进终身清单"(补丁前的老记录没有
#   这个字段 ⇒ 上线时补登记一次; 见 existing 的 N04 说明)。
# ============================================================
# 【★ A03 修(2026-10-11 三审): "双键历史残留"漏登记 ★】
#   旧第 ③ 步"两键都在就设 reg"把**登记**当成已发生 —— 但旧第 ① 步的登记条件是
#   "旧键存在 且 新键不存在", 双键时**跳过登记**, 第 ③ 步却照设 reg ⇒ 结果:
#   **标记已登记、实际不在清单**; 之后 existing 见 reg 又跳过补登记 ⇒ 这条记录
#   reset_all 永远清不到(报告 A03 场景)。
#   修法两条:
#     · 登记条件拆成"记录存在(旧键 或 新键任一) 且 未登记" ⇒ 双键也登记(第 ①/③ 步);
#     · `reg` **只在登记之后**才打(第 ④ 步), 且第 ④ 步的条件(新键存在)保证
#       **不会先建出一条只有 reg 的空记录**把第 ② 步的复制顶掉。
#   ① ③ 互斥(① 看旧键、③ 看"旧键不在"), 所以不会重复 append。
# ============================================================

# ① 登记终身清单(**必须在复制之前**, 保持 N04 的顺序锁; 条件 = 旧键存在 且 未登记)
$execute if data storage manacore:players "$(h0)" unless data storage manacore:players "$(uuid)".reg run data modify storage manacore:players_all list append value "$(uuid)"
# ② 复制新键(老键 -> 新键)
$execute if data storage manacore:players "$(h0)" unless data storage manacore:players "$(uuid)" run data modify storage manacore:players "$(uuid)" set from storage manacore:players "$(h0)"
# ③ ★ A03 补: "完整 UUID 键已存在、旧键已不在、且未登记"的历史记录也要补登记。
#   与 ① 互斥(① 要求旧键在, 本步要求旧键不在) ⇒ 不会重复 append。
$execute if data storage manacore:players "$(uuid)" unless data storage manacore:players "$(h0)" unless data storage manacore:players "$(uuid)".reg run data modify storage manacore:players_all list append value "$(uuid)"
# ④ 打"已登记"标志 —— **必须在登记之后**; 此刻新键必然已存在(②复制 / 本来就存在),
#   所以绝不会建出"只有 reg 的空记录"。
$execute if data storage manacore:players "$(uuid)" unless data storage manacore:players "$(uuid)".reg run data modify storage manacore:players "$(uuid)".reg set value 1b
# ⑤ 删旧键(迁移=搬移; 由"两键都在"守护, 只删真正被搬走的那把)
$execute if data storage manacore:players "$(h0)" if data storage manacore:players "$(uuid)" run data remove storage manacore:players "$(h0)"
