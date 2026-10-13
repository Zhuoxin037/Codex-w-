# ============================================================
# sweetdream:internal/itembackup/backup —— 把带 itemreplace 的武器快照进命令存储(暂存区)
# ------------------------------------------------------------
# 【执行者】玩家本人(@s)。**普通函数**(宏变量 $(uuid) 的消费点在 snap_main/snap_off,
#   本文件两行是静态门控 + with storage 转发 —— 行首带 $ 却没有 $(...) 会整个函数作废)
# 【调用方】① 右键触发的那一刻(itembackup/effect_1, "消耗还没走完"的最准时机,
#   调用前先把 zx:work a.uuid 备好)  ② lib/second 每秒一次 —— 走 backup_go 包装。
#   两处都写 `function backup with storage zx:work a`: with 源合法, 参数由 snap 消费。
# 【★ O03(2026-10-11): 备份从"固定盔甲架"搬进命令存储 ★】
#   老设计: 每人一个 test_stand_<uuid> 盔甲架, 固定召在主世界 0.5,-60,0.5 ——
#     · 依赖出生区块常驻加载(架子一卸载, 备份/回手全部静默失败 => 武器消失);
#     · 每刻 6 次 `@e[distance=0..]` 全实体扫描(display 一多, 很贵)。
#   新设计: 快照写进 zx:ret p."<uuid>".stage.mainhand / .stage.offhand —— 存储跟着存档走,
#     跨死亡/重连/维度都在, 和实体加载状态彻底解耦。
# 【★ A02(2026-10-11 三审): 这是"暂存区", 不是"待归还" ★】
#   本文件拍的只是"玩家**当前**手里那把", 落点 stage.*; 它随时会被下一秒的
#   backup_go 覆盖 —— 这是**故意**的(暂存区就该跟着手走)。
#   消费当刻由 effect_1 -> enqueue 把这一份**搬进队列** q(那才是"欠玩家的那件",
#   从此不再被覆盖, 直到还回玩家手里)。所以本文件**不需要**任何冻结逻辑。
# 【★ 坑 95(2026-10-11 二次事故): 玩家物品不能直接 data 拷, 必须走 snap 中转 ★】
#   玩家 NBT 实测(playerdata 解剖): equipment 复合只存**穿戴的盔甲**,
#   主手/快捷栏物品在 Inventory 列表且主手是"选中的格"(无静态 NBT 路径)。
#   O03 首版 `set from entity @s equipment.mainhand` 对玩家 = 路径不存在
#   ⇒ 静默失败 ⇒ zx:ret 连键都没建出来(用户实测 `/data get storage zx:ret` = {})。
#   修法: 门控命中后调 snap_main / snap_off —— 用 item replace(谓词语法, 对玩家
#   合法)把武器拷上临时架, 再从盔甲架的 equipment.mainhand(生物路径)拷进存储。
#   形态与 restore 完全对称(restore: 存储 -> 架 -> 玩家; snap: 玩家 -> 架 -> 存储)。
# 【主手/副手各存各的】回手按"这一下是从哪一格消耗的"取对应那份(见 effect_2)。
# 【为什么用 ~ 部分匹配】以后往 give 的 custom_data 里加字段, 这里不用跟着改。
# ============================================================

# ① 主手是武器 -> 快照主手(暂存区 stage.mainhand)
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["itemreplace"]}] run function sweetdream:internal/itembackup/snap_main with storage zx:work a

# ② 副手是武器 -> 快照副手(暂存区 stage.offhand)
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["itemreplace"]}] run function sweetdream:internal/itembackup/snap_off with storage zx:work a
