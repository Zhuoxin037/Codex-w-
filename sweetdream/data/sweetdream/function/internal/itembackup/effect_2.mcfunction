# ============================================================
# sweetdream:internal/itembackup/effect_2 —— 回手: 把【队首】那一件还回去(宏)
# ------------------------------------------------------------
# 【宏参数】zx:work a {uuid, slot}   【执行者】玩家本人(@s)
#   uuid = 定位存储键 / slot = **队首**的首选槽位(0..8; 副手或非法值时给安全值 0)
# 【调用】function sweetdream:internal/itembackup/effect_2 with storage zx:work a
#   两个调用方: return_go(主路, 1 tick 后)、recover_go(兜底, 每秒)。
#   任一缺宏参数 => 含它的行取不到变量 => **整个宏函数运行时作废**(零日志)。
#   ★ 注意 $(slot) 是**文本替换**, 副手时若不钳成合法值会拼出 `hotbar.-1`;
#     钳制在 return_go / recover_go 里做(它们读镜像 zx.ret_slot)。
# ------------------------------------------------------------
# 【★ 只处理队首 q[0] ★】
#   物品从 zx:ret p."<uuid>".q[0].item 取(不再按 $(src) 去读两份固定快照);
#   落地成功(或队首压根没东西可还)才**出队**, 由本文件末尾统一做并重算镜像。
# ------------------------------------------------------------
# 【★★ A02(2026-10-11 三审)★★】
#   旧版回手只认"原格 / 副手"两个落脚点, 且把等待限成 20 秒(超时**放弃**)。
#   现在:
#     ① 首选槽(原格 / 副手)被占 => 依次扫 **快捷栏 0..8 -> 主背包 0..26**,
#        落进**第一个空格**(槽位名 inventory.0-26 -> 索引 9-35, 见 1.21.5 槽位表);
#     ② **永不放弃**: 全满就一行都不写, 留给 recover 每秒重试(直到还成功);
#     ③ 队首"压根没有东西可还"(快照缺失)=> 出队, 免得堵死后面积压的武器。
# ------------------------------------------------------------
# 【★ 三铁律(承 N08 2026-10-11)★】
#   ① 绝不覆盖: 写前一律判空(下游 restore 也再判一次);
#   ② 落地才算数: 用落地标志 #ret_ok(1 = 临时架有货 且 目标槽为空 且 已 item replace);
#   ③ 失败=保留: #ret_ok=0 时**不出队**, 交给 recover 每秒重试。
# 【★ 判空写法】全包禁止 `items … air`(2026-10-10 实测**恒假**); 判空只用 `unless items … *`。
# 【★ 判断一律读队列 / 计分项, 不读 tag zx.ret_off ★】tag 会随实体消失;
#   recover 那条兜底路径在玩家重连/重生后跑, 那时 tag 早没了。
# ------------------------------------------------------------
# 【★ #ret_ok 是"本轮传球"标志, 不是跨人共享状态 ★】
#   每轮开头先归零, restore 命中就置 1; 后面每一行都带 `if score #ret_ok zx.meta matches 0`,
#   于是"第一名命中"之后整段自动跳过。effect_2 逐人顺序执行, 不存在串味。
# ============================================================

# ① 复位落地标志(restore 会按"临时架有货 且 目标槽空"置 1)
scoreboard players set #ret_ok zx.meta 0

# ② 首选槽: 副手(zx.ret_slot = -1)—— 副手为空才写
#    这一行**不能**出现 $(slot): 它的值是 -1, 拼进 hotbar 会变成非法槽位名。
$execute if score @s zx.ret_pend matches 1.. if score @s zx.ret_slot matches -1 if score #ret_ok zx.meta matches 0 unless items entity @s weapon.offhand * if data storage zx:ret p."$(uuid)".q[0].item.id run function sweetdream:internal/itembackup/restore {uuid:"$(uuid)",dst:"weapon.offhand"}

# ③ 首选槽: 原快捷栏格(zx.ret_slot = 0..8)—— 那一格为空才写(R01 主体)
$execute if score @s zx.ret_pend matches 1.. if score @s zx.ret_slot matches 0..8 if score #ret_ok zx.meta matches 0 unless items entity @s hotbar.$(slot) * if data storage zx:ret p."$(uuid)".q[0].item.id run function sweetdream:internal/itembackup/restore {uuid:"$(uuid)",dst:"hotbar.$(slot)"}

# ④ 兜底: 首选槽被占(或镜像非法)=> 扫**快捷栏 0..8**, 落进第一个空格。
#    每行都要: 队列非空 + 还没落地 + 那一格为空 + 队首真有东西可还。

$execute if score @s zx.ret_pend matches 1.. if score #ret_ok zx.meta matches 0 unless items entity @s hotbar.0 * if data storage zx:ret p."$(uuid)".q[0].item.id run function sweetdream:internal/itembackup/restore {uuid:"$(uuid)",dst:"hotbar.0"}
$execute if score @s zx.ret_pend matches 1.. if score #ret_ok zx.meta matches 0 unless items entity @s hotbar.1 * if data storage zx:ret p."$(uuid)".q[0].item.id run function sweetdream:internal/itembackup/restore {uuid:"$(uuid)",dst:"hotbar.1"}
$execute if score @s zx.ret_pend matches 1.. if score #ret_ok zx.meta matches 0 unless items entity @s hotbar.2 * if data storage zx:ret p."$(uuid)".q[0].item.id run function sweetdream:internal/itembackup/restore {uuid:"$(uuid)",dst:"hotbar.2"}
$execute if score @s zx.ret_pend matches 1.. if score #ret_ok zx.meta matches 0 unless items entity @s hotbar.3 * if data storage zx:ret p."$(uuid)".q[0].item.id run function sweetdream:internal/itembackup/restore {uuid:"$(uuid)",dst:"hotbar.3"}
$execute if score @s zx.ret_pend matches 1.. if score #ret_ok zx.meta matches 0 unless items entity @s hotbar.4 * if data storage zx:ret p."$(uuid)".q[0].item.id run function sweetdream:internal/itembackup/restore {uuid:"$(uuid)",dst:"hotbar.4"}
$execute if score @s zx.ret_pend matches 1.. if score #ret_ok zx.meta matches 0 unless items entity @s hotbar.5 * if data storage zx:ret p."$(uuid)".q[0].item.id run function sweetdream:internal/itembackup/restore {uuid:"$(uuid)",dst:"hotbar.5"}
$execute if score @s zx.ret_pend matches 1.. if score #ret_ok zx.meta matches 0 unless items entity @s hotbar.6 * if data storage zx:ret p."$(uuid)".q[0].item.id run function sweetdream:internal/itembackup/restore {uuid:"$(uuid)",dst:"hotbar.6"}
$execute if score @s zx.ret_pend matches 1.. if score #ret_ok zx.meta matches 0 unless items entity @s hotbar.7 * if data storage zx:ret p."$(uuid)".q[0].item.id run function sweetdream:internal/itembackup/restore {uuid:"$(uuid)",dst:"hotbar.7"}
$execute if score @s zx.ret_pend matches 1.. if score #ret_ok zx.meta matches 0 unless items entity @s hotbar.8 * if data storage zx:ret p."$(uuid)".q[0].item.id run function sweetdream:internal/itembackup/restore {uuid:"$(uuid)",dst:"hotbar.8"}
# ⑤ 兜底续: 快捷栏全满 => 再扫**主背包 inventory.0..26**(= 索引 9-35, 27 格)。
#    ★ A02 的 ①: 旧版只找快捷栏, 主背包有空格也不还。
$execute if score @s zx.ret_pend matches 1.. if score #ret_ok zx.meta matches 0 unless items entity @s inventory.0 * if data storage zx:ret p."$(uuid)".q[0].item.id run function sweetdream:internal/itembackup/restore {uuid:"$(uuid)",dst:"inventory.0"}
$execute if score @s zx.ret_pend matches 1.. if score #ret_ok zx.meta matches 0 unless items entity @s inventory.1 * if data storage zx:ret p."$(uuid)".q[0].item.id run function sweetdream:internal/itembackup/restore {uuid:"$(uuid)",dst:"inventory.1"}
$execute if score @s zx.ret_pend matches 1.. if score #ret_ok zx.meta matches 0 unless items entity @s inventory.2 * if data storage zx:ret p."$(uuid)".q[0].item.id run function sweetdream:internal/itembackup/restore {uuid:"$(uuid)",dst:"inventory.2"}
$execute if score @s zx.ret_pend matches 1.. if score #ret_ok zx.meta matches 0 unless items entity @s inventory.3 * if data storage zx:ret p."$(uuid)".q[0].item.id run function sweetdream:internal/itembackup/restore {uuid:"$(uuid)",dst:"inventory.3"}
$execute if score @s zx.ret_pend matches 1.. if score #ret_ok zx.meta matches 0 unless items entity @s inventory.4 * if data storage zx:ret p."$(uuid)".q[0].item.id run function sweetdream:internal/itembackup/restore {uuid:"$(uuid)",dst:"inventory.4"}
$execute if score @s zx.ret_pend matches 1.. if score #ret_ok zx.meta matches 0 unless items entity @s inventory.5 * if data storage zx:ret p."$(uuid)".q[0].item.id run function sweetdream:internal/itembackup/restore {uuid:"$(uuid)",dst:"inventory.5"}
$execute if score @s zx.ret_pend matches 1.. if score #ret_ok zx.meta matches 0 unless items entity @s inventory.6 * if data storage zx:ret p."$(uuid)".q[0].item.id run function sweetdream:internal/itembackup/restore {uuid:"$(uuid)",dst:"inventory.6"}
$execute if score @s zx.ret_pend matches 1.. if score #ret_ok zx.meta matches 0 unless items entity @s inventory.7 * if data storage zx:ret p."$(uuid)".q[0].item.id run function sweetdream:internal/itembackup/restore {uuid:"$(uuid)",dst:"inventory.7"}
$execute if score @s zx.ret_pend matches 1.. if score #ret_ok zx.meta matches 0 unless items entity @s inventory.8 * if data storage zx:ret p."$(uuid)".q[0].item.id run function sweetdream:internal/itembackup/restore {uuid:"$(uuid)",dst:"inventory.8"}
$execute if score @s zx.ret_pend matches 1.. if score #ret_ok zx.meta matches 0 unless items entity @s inventory.9 * if data storage zx:ret p."$(uuid)".q[0].item.id run function sweetdream:internal/itembackup/restore {uuid:"$(uuid)",dst:"inventory.9"}
$execute if score @s zx.ret_pend matches 1.. if score #ret_ok zx.meta matches 0 unless items entity @s inventory.10 * if data storage zx:ret p."$(uuid)".q[0].item.id run function sweetdream:internal/itembackup/restore {uuid:"$(uuid)",dst:"inventory.10"}
$execute if score @s zx.ret_pend matches 1.. if score #ret_ok zx.meta matches 0 unless items entity @s inventory.11 * if data storage zx:ret p."$(uuid)".q[0].item.id run function sweetdream:internal/itembackup/restore {uuid:"$(uuid)",dst:"inventory.11"}
$execute if score @s zx.ret_pend matches 1.. if score #ret_ok zx.meta matches 0 unless items entity @s inventory.12 * if data storage zx:ret p."$(uuid)".q[0].item.id run function sweetdream:internal/itembackup/restore {uuid:"$(uuid)",dst:"inventory.12"}
$execute if score @s zx.ret_pend matches 1.. if score #ret_ok zx.meta matches 0 unless items entity @s inventory.13 * if data storage zx:ret p."$(uuid)".q[0].item.id run function sweetdream:internal/itembackup/restore {uuid:"$(uuid)",dst:"inventory.13"}
$execute if score @s zx.ret_pend matches 1.. if score #ret_ok zx.meta matches 0 unless items entity @s inventory.14 * if data storage zx:ret p."$(uuid)".q[0].item.id run function sweetdream:internal/itembackup/restore {uuid:"$(uuid)",dst:"inventory.14"}
$execute if score @s zx.ret_pend matches 1.. if score #ret_ok zx.meta matches 0 unless items entity @s inventory.15 * if data storage zx:ret p."$(uuid)".q[0].item.id run function sweetdream:internal/itembackup/restore {uuid:"$(uuid)",dst:"inventory.15"}
$execute if score @s zx.ret_pend matches 1.. if score #ret_ok zx.meta matches 0 unless items entity @s inventory.16 * if data storage zx:ret p."$(uuid)".q[0].item.id run function sweetdream:internal/itembackup/restore {uuid:"$(uuid)",dst:"inventory.16"}
$execute if score @s zx.ret_pend matches 1.. if score #ret_ok zx.meta matches 0 unless items entity @s inventory.17 * if data storage zx:ret p."$(uuid)".q[0].item.id run function sweetdream:internal/itembackup/restore {uuid:"$(uuid)",dst:"inventory.17"}
$execute if score @s zx.ret_pend matches 1.. if score #ret_ok zx.meta matches 0 unless items entity @s inventory.18 * if data storage zx:ret p."$(uuid)".q[0].item.id run function sweetdream:internal/itembackup/restore {uuid:"$(uuid)",dst:"inventory.18"}
$execute if score @s zx.ret_pend matches 1.. if score #ret_ok zx.meta matches 0 unless items entity @s inventory.19 * if data storage zx:ret p."$(uuid)".q[0].item.id run function sweetdream:internal/itembackup/restore {uuid:"$(uuid)",dst:"inventory.19"}
$execute if score @s zx.ret_pend matches 1.. if score #ret_ok zx.meta matches 0 unless items entity @s inventory.20 * if data storage zx:ret p."$(uuid)".q[0].item.id run function sweetdream:internal/itembackup/restore {uuid:"$(uuid)",dst:"inventory.20"}
$execute if score @s zx.ret_pend matches 1.. if score #ret_ok zx.meta matches 0 unless items entity @s inventory.21 * if data storage zx:ret p."$(uuid)".q[0].item.id run function sweetdream:internal/itembackup/restore {uuid:"$(uuid)",dst:"inventory.21"}
$execute if score @s zx.ret_pend matches 1.. if score #ret_ok zx.meta matches 0 unless items entity @s inventory.22 * if data storage zx:ret p."$(uuid)".q[0].item.id run function sweetdream:internal/itembackup/restore {uuid:"$(uuid)",dst:"inventory.22"}
$execute if score @s zx.ret_pend matches 1.. if score #ret_ok zx.meta matches 0 unless items entity @s inventory.23 * if data storage zx:ret p."$(uuid)".q[0].item.id run function sweetdream:internal/itembackup/restore {uuid:"$(uuid)",dst:"inventory.23"}
$execute if score @s zx.ret_pend matches 1.. if score #ret_ok zx.meta matches 0 unless items entity @s inventory.24 * if data storage zx:ret p."$(uuid)".q[0].item.id run function sweetdream:internal/itembackup/restore {uuid:"$(uuid)",dst:"inventory.24"}
$execute if score @s zx.ret_pend matches 1.. if score #ret_ok zx.meta matches 0 unless items entity @s inventory.25 * if data storage zx:ret p."$(uuid)".q[0].item.id run function sweetdream:internal/itembackup/restore {uuid:"$(uuid)",dst:"inventory.25"}
$execute if score @s zx.ret_pend matches 1.. if score #ret_ok zx.meta matches 0 unless items entity @s inventory.26 * if data storage zx:ret p."$(uuid)".q[0].item.id run function sweetdream:internal/itembackup/restore {uuid:"$(uuid)",dst:"inventory.26"}

# ⑥ 出队: 两种情形
#    ① 落地成功(#ret_ok=1);
#    ② 队首**压根没有东西可还**(快照缺失/为空)=> 这一条不清掉会永久堵住队首,
#       后面所有武器一起卡死 —— "永不放弃"只针对**有东西可还**的条目。
$execute if score @s zx.ret_pend matches 1.. if score #ret_ok zx.meta matches 1 run data remove storage zx:ret p."$(uuid)".q[0]
$execute if score @s zx.ret_pend matches 1.. if score #ret_ok zx.meta matches 0 unless data storage zx:ret p."$(uuid)".q[0].item.id run data remove storage zx:ret p."$(uuid)".q[0]

# ⑦ 出队后重算镜像: 还有下一件 => 同步新队首槽位; 空了 => 销账复位。
#    ★ 顺序要紧: 必须**先把 ret_slot 复位**, 再清 ret_pend —— 反过来的话最后一行
#      的门 `if score @s zx.ret_pend matches 1..` 会被自己刚清掉的 0 挡掉。
#    ★ 没出队(还在等空位)时这两行也照跑, 但 q[0] 没变 => 重算结果相同, 幂等无害。
$execute if score @s zx.ret_pend matches 1.. if data storage zx:ret p."$(uuid)".q[0] store result score @s zx.ret_slot run data get storage zx:ret p."$(uuid)".q[0].slot
$execute if score @s zx.ret_pend matches 1.. unless data storage zx:ret p."$(uuid)".q[0] run scoreboard players set @s zx.ret_slot -2
$execute if score @s zx.ret_pend matches 1.. unless data storage zx:ret p."$(uuid)".q[0] run scoreboard players set @s zx.ret_pend 0
