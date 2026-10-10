# ============================================================
# sweetdream:internal/itembackup/backup —— 把带 itemreplace 的武器快照进命令存储
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
#   新设计: 快照写进 zx:ret p."<uuid>".mainhand / .offhand —— 存储跟着存档走,
#     跨死亡/重连/维度都在, 和实体加载状态彻底解耦。
# 【★ 坑 95(2026-10-11 二次事故): 玩家物品不能直接 data 拷, 必须走 snap 中转 ★】
#   玩家 NBT 实测(playerdata 解剖): equipment 复合只存**穿戴的盔甲**,
#   主手/快捷栏物品在 Inventory 列表且主手是"选中的格"(无静态 NBT 路径)。
#   O03 首版 `set from entity @s equipment.mainhand` 对玩家 = 路径不存在
#   ⇒ 静默失败 ⇒ zx:ret 连键都没建出来(用户实测 `/data get storage zx:ret` = {})。
#   修法: 门控命中后调 snap_main / snap_off —— 用 item replace(谓词语法, 对玩家
#   合法)把武器拷上临时架, 再从盔甲架的 equipment.mainhand(生物路径)拷进存储。
#   形态与 restore 完全对称(restore: 存储 -> 架 -> 玩家; snap: 玩家 -> 架 -> 存储)。
# 【主手/副手各存各的】回手按"这一下是用哪只手放的"取对应那份(见 effect_2)。
# 【为什么用 ~ 部分匹配】以后往 give 的 custom_data 里加字段, 这里不用跟着改。
# ============================================================

# ① 主手是武器 -> 快照主手
execute if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["itemreplace"]}] run function sweetdream:internal/itembackup/snap_main with storage zx:work a

# ② 副手是武器 -> 快照副手
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["itemreplace"]}] run function sweetdream:internal/itembackup/snap_off with storage zx:work a
