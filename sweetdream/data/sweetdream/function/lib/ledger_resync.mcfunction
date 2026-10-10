# ============================================================
# sweetdream:lib/ledger_resync —— R02: 死亡重生后的属性账本自愈(每秒, 以玩家身份)
# ------------------------------------------------------------
# 【谁调用它】lib/second: execute as @a run function ... (在 in_bak/in_restore 窗口内)
# 【问题】原版属性修饰符(sweetdream:upg_* / eqp_*)挂在**玩家实体**上; 死亡重生会
#   重建玩家实体 —— 修饰符丢、计分板账本还在 ⇒ 差量账本算出 diff = want - 账本 = 0
#   ⇒ 加成**永远不再补挂**(静默; 不换装备就一直缺)。
# 【怎么修】用原版死亡计数当探针: zx.deaths 比上次见到的多 **且人活着**(Health>=1)
#   ⇒ 死过并已重生 ⇒ 调 ledger_resync_go 清/退账本, 下一秒正常流程按 want 重新挂。
# 【为什么用死亡计数而不是"读属性里还有没有修饰符"】后者要读玩家 NBT 的
#   attributes[].modifiers[] —— 本包无先例, 路径写错就是静默; 死亡计数是原版
#   criterion, 一行就有, 且顺带覆盖"重生成的新实体属性被外部改动"这类情况。
# 【开销】没死过的玩家 = 2 条比较, 空转。
# 【★ 面板型账本不要在这里清 ★】zx.am_mana(盔甲魔力)/zx.up_mana(升级魔力)改的是
#   manacore 面板(command storage, 死亡不丢), 账本与面板一致 —— 清了反而会让
#   下一秒把面板**重复加上**。能清的只有"挂原版属性"的账本, 分两类见 go 文件。
# ============================================================

# 【★ 只对"活着"的玩家做探针/记账(2026-10-10 二修) ★】
#   死亡计数在**死亡瞬间**就 +1; 而开了 keepInventory 时, 死着的玩家身上仍"穿着"
#   装备 ⇒ 若在死亡期间清账本, 同一秒 upgrade/second 的重挂循环会立刻把账本按
#   want 重新填满(挂在那个马上要销毁的旧实体上) ⇒ 重生后修饰符丢、账本却是满的
#   ⇒ diff=0 永不补挂, 且 dc_last 已被消费 ⇒ 探针再也不会触发。
#   2026-10-10 实测复现:"死后没有补回, 重新放一遍才生效"。
#   正解: 死着(Health=0)时什么都不做 —— 重生后第一秒才触发, 那时清账本,
#   同一秒的重挂循环就在**新实体**上把加成补挂回去了。
# 【Health 读法】★ 2026-10-11 换成 criterion: 读 @s zx.hp_c(原版裸名 health
#   criterion, 原版自动同步) —— 纯计分板操作, 免费。之前用
#   `data get entity @s Health 1`: 任何 data ... entity 都会把整个玩家(背包+组件)
#   完整序列化成 NBT, spark 剖析里这是最大热点之一(NbtPredicate.entityToNbt)。
#   活着 >=1, 死着 =0 —— 与 criterion 的刻度无关(0 就是死)。
#   ★ 若保留 data get 写法, 必须先 `scoreboard players set #lr_hp zx.meta 0`
#   再 store(store 在命令失败时不动分数, 残留值会造成假"活着")。
scoreboard players operation #lr_hp zx.meta = @s zx.hp_c

# 活着 && 死过(分数存在且 >=1) && 比上次见到的多 -> 这一秒死过且已重生 -> 自愈
execute if score #lr_hp zx.meta matches 1.. if score @s zx.deaths matches 1.. unless score @s zx.deaths = @s zx.dc_last run function sweetdream:lib/ledger_resync_go
# 记下本次见到的死亡数 —— 同样只在活着时记(死着记账=把探针消费在死人身上)
execute if score #lr_hp zx.meta matches 1.. if score @s zx.deaths matches 1.. run scoreboard players operation @s zx.dc_last = @s zx.deaths
