# ============================================================
# sweetdream:internal/itembackup/snap_main —— 玩家主手 -> zx:ret 快照(宏 {uuid})
# ------------------------------------------------------------
# 【★ 为什么必须中转盔甲架(坑 95, 2026-10-11)】
#   玩家 NBT 实测(playerdata 解剖): **equipment 复合只存穿戴的盔甲**
#   (equipment={feet,legs}), 玩家的主手/快捷栏物品全在 Inventory 列表
#   (Slot 0-8) —— 主手是"选中的快捷栏格", 没有静态 NBT 路径可指。
#   O03 首版写的 `set from entity @s equipment.mainhand` 对玩家 = 路径
#   不存在 ⇒ data modify 静默失败、零日志 ⇒ zx:ret 从未被写入(症状与
#   坑 93 同族: 上次是谓词语法混进 NBT 路径, 这次是生物路径套玩家)。
#   修法 = 反转 restore 的中转: item replace 的**源槽** weapon.mainhand
#   (物品谓词语法, 对玩家合法)先把武器拷上临时架, 再从**盔甲架**的
#   equipment.mainhand(生物路径, 合法)拷进存储。
# 【宏参数】zx:work a {uuid}    【执行者】玩家本人(@s)
# 【谁调用它】backup(门控: 主手有 itemreplace 武器才调); $(uuid) 由
#   backup_go(每秒安全网)/effect_1(消耗瞬间)备好传入。
# 【开销】召/杀一个 Marker 架(Marker:1b 无碰撞), 仅在"手里有 itemreplace
#   武器"时发生 —— 正确性优先, 每秒最多 2 次(主手+副手)。
# ============================================================

# ① 防串味: 清掉可能残留的临时架
kill @e[tag=zx.snap_tmp]

# ② 就地召临时架(形态先例: restore ② 的 zx.ret_tmp)
execute at @s run summon minecraft:armor_stand ~ ~ ~ {Tags:["zx.snap_tmp"],Marker:1b,Invisible:1b,NoGravity:1b,Invulnerable:1b,Silent:1b,Small:1b}

# ③ 玩家主手 -> 临时架主手(item replace 的槽位 = 物品谓词语法, 对玩家合法)
item replace entity @e[tag=zx.snap_tmp,limit=1] weapon.mainhand from entity @s weapon.mainhand

# ④ 临时架(生物) -> 存储(equipment.mainhand 对非玩家实体有效)
$data modify storage zx:ret p."$(uuid)".mainhand set from entity @e[tag=zx.snap_tmp,limit=1] equipment.mainhand

# ⑤ 收尾
kill @e[tag=zx.snap_tmp]
