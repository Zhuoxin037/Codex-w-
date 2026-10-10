# ============================================================
# sweetdream:internal/itembackup/effect_2 —— 回手: 把存储快照里的武器还回来
# ------------------------------------------------------------
# 【宏参数】zx:work a {uuid, slot}     【执行者】玩家本人(@s)
# 【调用】function sweetdream:internal/itembackup/effect_2 with storage zx:work a
# 【★ slot 必传 ★】$(slot) 必须已经写进 zx:work a.slot(由调用方做), 否则含 $(slot)
#   的那几行会因为取不到变量而**整函数作废**(宏缺失变量是运行时错误, 不进日志)。
#   两个调用方: return_go(主路, 1 tick 后)、recover_go(兜底, 每秒)。改这两处时
#   别漏掉 `store result storage zx:work a.slot` 那一句 —— check.py 有形态锁守着。
# ------------------------------------------------------------
# 【★ O03(2026-10-11): 备份从固定盔甲架搬进命令存储 ★】
#   老版从 @e[tag=test_stand_<uuid>] 的主手/副手槽取备份 —— 架子固定在主世界
#   0.5,-60,0.5, 依赖出生区块常驻加载, 且每条分支都是一次 @e 全实体扫描。
#   新版快照在 zx:ret p."<uuid>".mainhand / .offhand(见 backup.mcfunction),
#   还原走 internal/itembackup/restore(临时盔甲架中转, 用完即杀):
#       ① 副手触发(zx.ret_slot=-1) -> 快照 offhand -> 还回 weapon.offhand
#       ② 主手触发(0..8):
#          ②-a 目标格空 -> 快照 mainhand -> 还回 hotbar.<消耗时那一格>(R01 主体)
#          ②-b 目标格被占 -> 还回当前选中格(修 R01 前的老行为, 不硬塞)
#       ③ ret_slot 非法(future self 改坏记账线) -> 退回老行为(写 mainhand)
#   ★ 判空写法(实测定案, 全包禁止 `items … air`): 空槽不是物品栈, 任何物品谓词
#     都匹配不到它; 判空用 `unless items … *`。②-a/②-b 互为补集 => 就算 `*`
#     对空槽的语义与预期相反, 总有一条会跑, 武器一定回得来(失败方向 = 退化为老
#     行为, 不是"武器永远消失")。check.py `airpred` 规则守着这条。
# 【★ 判断一律读计分项而不是 tag zx.ret_off ★】tag 会随实体消失;
#   recover 那条兜底路径是在玩家重连/重生后跑的, 那时 tag 早就没了,
#   读 tag 会把它误判成主手 => 写错槽位。
# 【快照存在性门】每条分支先 `if data storage zx:ret p."$(uuid)".<src>.id`:
#   没有快照就什么都不做(等价于老版"先检查架子上有没有东西"的保险)。
# ============================================================

# ① 副手触发(zx.ret_slot = -1)-> 从快照 offhand 还回副手
#    这一行**不能**出现 $(slot): 它的值是 -1, 拼进 hotbar 会变成非法槽位名。
$execute if score @s zx.ret_slot matches -1 if data storage zx:ret p."$(uuid)".offhand.id run function sweetdream:internal/itembackup/restore {uuid:"$(uuid)",src:"offhand",dst:"weapon.offhand"}

# ② 主手触发(zx.ret_slot = 0..8)
#   ②-a 【目标格是空的】-> 写回【消耗时那一格】(R01 主体 + 占位保护)
$execute if score @s zx.ret_slot matches 0..8 unless items entity @s hotbar.$(slot) * if data storage zx:ret p."$(uuid)".mainhand.id run function sweetdream:internal/itembackup/restore {uuid:"$(uuid)",src:"mainhand",dst:"hotbar.$(slot)"}

#   ②-b 【目标格被占了】-> 不硬塞(会顶掉玩家新放进去的东西), 退回"当前选中格"
#        (老行为)。★ 与 ②-a 互补: 那条不跑这条一定跑, 武器不会就此消失。
#        注: ①(副手)那条没加这道门 —— 从副手消耗后副手本来就是空的, 加门只会
#        平白多一条分支; 走 recover 每秒重试时若副手真被占了, 行为与修 R01 前一致。
$execute if score @s zx.ret_slot matches 0..8 if items entity @s hotbar.$(slot) * if data storage zx:ret p."$(uuid)".mainhand.id run function sweetdream:internal/itembackup/restore {uuid:"$(uuid)",src:"mainhand",dst:"weapon.mainhand"}

# ③ 【兜底】zx.ret_slot 不是"合法值"(-1 或 0..8)—— 说明 effect_1 的记账没跑到
#    (future self 改坏了那条线时会这样)。这时**退回老行为**(写当前选中的 mainhand):
#    行为退化到修 R01 之前, 但至少不会让武器凭空消失。这一行同样不带 $(slot)。
$execute unless score @s zx.ret_slot matches -1 unless score @s zx.ret_slot matches 0..8 if data storage zx:ret p."$(uuid)".mainhand.id run function sweetdream:internal/itembackup/restore {uuid:"$(uuid)",src:"mainhand",dst:"weapon.mainhand"}

# ④ 武器已到位 -> 清掉"待归还"倒计时(不清的话 recover 会继续每秒重试)
execute if score @s zx.ret_slot matches -1 if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["itemreplace"]}] run scoreboard players set @s zx.ret_pend 0
$execute if score @s zx.ret_slot matches 0..8 if items entity @s hotbar.$(slot) *[minecraft:custom_data~{zx:["itemreplace"]}] run scoreboard players set @s zx.ret_pend 0
#    上面这两行判的是"目标格现在是那把武器", 而不是"这次 replace 跑成功了"。
# ④-b 【②-b 那条线的清零】目标格被占 + 当前主手已经是 itemreplace 物品
#    = 武器走 ②-b 退回了主手 => 同样要把倒计时清零。
#    不加这条会怎样: ②-b 写的是 weapon.mainhand, 上面第 ④ 行只认 hotbar.$(slot),
#    于是倒计时一直不归零 => recover 每秒重试 => 20 秒内可能刷出好几把。
#    ★ O03 后快照在还成功时已被 restore 删掉, 重试不会再"复活"一份 —— 这里
#    只剩"提前放弃"一种误判(与上面两行同款), 比"无限重试"轻。
$execute if score @s zx.ret_slot matches 0..8 if items entity @s hotbar.$(slot) * if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["itemreplace"]}] run scoreboard players set @s zx.ret_pend 0
#    差别在于: 目标格本来就放着另一件 itemreplace 物品时会被误判成成功,
#    结果是**提前放弃**(武器留在外面)。这在两条防线里是较轻的那一个,
#    换来的是不必再引一层返回值传递。
