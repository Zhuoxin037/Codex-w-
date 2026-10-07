# ============================================================
# sweetdream:internal/itembackup/backup —— 把手里带 itemreplace 的武器备份到盔甲架
# ------------------------------------------------------------
# 【宏参数】zx:work a {uuid}     【执行者】玩家本人(@s)
# 【谁调用它】① 每刻那条 tick 线(itembackup/mainhand_1)
#             ② 右键触发的那一刻(itembackup/effect_1, "消耗还没走完"的最准时机)
# ------------------------------------------------------------
# 【★ 主手 / 副手都要备份 ★】(本次修复的重点)
#   老版本只备份主手(weapon.mainhand), 于是武器放副手右键时会连出两件事:
#     ① 副手那把从来没进过架子 -> 消耗掉之后没人还它 -> **武器凭空消失**
#     ② 架子里还留着上一次主手那把 -> 回手时又被塞进主手
#        -> **把主手正在用的东西顶掉**(item replace 是覆盖, 不会掉地上)
#   现在两个槽位各存各的, 回手时按"这一下是用哪只手放的"取回对应的那一份。
#   (盔甲架有 weapon.mainhand / weapon.offhand 两个槽位, 正好够用)
# 【为什么用 if items 而不是 nbt={SelectedItem:...}】
#   SelectedItem 是玩家 NBT 里的老字段, 依赖内部结构; if items 是 1.20.5 起的
#   官方语法, 直接读槽位 + 组件谓词, 和包里其它地方的 [custom_data~{zx:[...]}]
#   写法也是一套, 更不容易被版本变动坑到。
# 【为什么必须在"手上是 itemreplace 物品"时才备份】这个判断不能省:
#   消耗流程跑完之后, 那个槽位会变成空气。要是不判断就每刻复制,
#   下一 tick 就会把"空气"备份进架子, 回手自然什么都没有。
# 【为什么用 ~ 部分匹配】以后往 give 的 custom_data 里加字段, 这里不用跟着改。
# ============================================================

# ① 主手是武器 -> 存进架子的主手槽(架子固定在主世界, 所以要切维度过去找它)
$execute in minecraft:overworld if items entity @s weapon.mainhand *[minecraft:custom_data~{zx:["itemreplace"]}] run item replace entity @e[distance=0..,tag=test_stand_$(uuid),limit=1] weapon.mainhand from entity @s weapon.mainhand

# ② 副手是武器 -> 存进架子的副手槽
$execute in minecraft:overworld if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["itemreplace"]}] run item replace entity @e[distance=0..,tag=test_stand_$(uuid),limit=1] weapon.offhand from entity @s weapon.offhand
