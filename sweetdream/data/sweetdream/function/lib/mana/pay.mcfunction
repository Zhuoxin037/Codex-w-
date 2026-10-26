# ============================================================
# sweetdream:lib/mana/pay —— 本包**唯一**的"扣魔力"入口（2026-10-25 批 14 新建）
# ------------------------------------------------------------
# 【为什么要有这一层】「剖面」("自身每消耗 100 魔力值…") 与「迟暮」("花掉的魔力
#   存进「暮账」") 都要知道"**这一刻实际花掉了多少魔力**"。而全包 145 个扣费点
#   原来都是**直接** `function manacore:api/mana/consume` —— 前置包那个接口只管
#   "扣没扣成功", 不记账, 也没有任何 sweetdream 侧的落点。
#   ⇒ 现在把那 145 处统一改走本函数: 它**先原样扣费、再记一笔**, 对调用点完全透明。
# 【契约（与 manacore:api/mana/consume 一字不差）】
#   入参 manacore:in arg {uuid:"<UUID>", value:<double>}
#   出参 manacore:out r {success:1b/0b, reason:"ok"/"mana"}  ← 由原接口写, 本函数不碰
#   ★ 所以调用点原有的 `execute unless data storage manacore:out r{success:1b} run return fail`
#     一律照旧可用。
# 【记在哪】玩家自己的两个**互相独立**的累计账本（单位 = 魔力 ×1000, 即毫魔力点）:
#     zx.pm_sum —— 「剖面」用(每攒够 100000 = 100 魔力, 扣一次 100000)
#     zx.tf_sum —— 「折潮」用(150魔力累计门槛；每笔扣费最多1面，只留不足门槛的零头)
#   ★ 迟暮原来也在这儿记一份 zx.ld_sum —— 2026-10-25 按用户原稿重写后,
#     迟暮改成「回光」层数机制, **不再依赖花掉的魔力** ⇒ 那一份账本已删除。
#   ★★ 为什么是三份而不是共用一份 ★★
#     它们都是"从 0 攒到阈值就扣掉"的消费账。共用一份的话, 剖面先扣掉 100000,
#     折潮就永远攒不到 150000（反之也一样）—— 穿两件时**必然互相饿死**。
#     所以每件的账本各自满额累加、各自扣减, 互不干扰。
#     代价只是每次扣费多两行 operation（施法频率, 不是每刻）。
# 【★ 只记真的扣到的 ★】success:0b = 一个字节都没扣（魔力不足）⇒ 不记。
#   这是"要不要"的关键: 免费施放 / 扣费失败 都不该算进"花掉的魔力"。
# 【★ 负数不记 ★】debug/recover_mana 用 `value:-1000` 反向加蓝, 那是**加**不是花
#   ⇒ `matches 1..` 挡掉。
# 【★ @s 必须是玩家 ★】少数调用点以 marker / 生物为执行者（敌方技能、法球结算）,
#   那些不是"玩家花魔力", 直接跳过记账（扣费照常发生）。
# 【★ 为什么不用"每刻读当前魔力求差值" ★】那要每刻每人读一次 mana/get（内部走
#   player NBT, ≈10 ms/次, 卡顿坑 1）, 而且"上限变化把当前魔力夹低"会被误算成
#   "花掉了" —— 换件装备就白送好几次触发。记账法精确得多也便宜得多。
# ============================================================

# ① 原样扣费（这一步的行为与改动前**完全一致**）
#    ★★ 2026-10-25 事故：批量把 145 处 `manacore:api/mana/consume` 换成本函数的
#       那次脚本遍历时**把本函数自己也换掉了** ⇒ 这里一度变成 `function
#       sweetdream:lib/mana/pay`（自己调自己 = 无限递归, /reload 后每一次施法都会
#       直接把服务端栈打满）。批量替换脚本必须**排除被新建的那个文件本身**。
#       现在这里写死前置包接口, 且下面加了 check.py 的 selfrec 守门。
function sweetdream:profession/pay_prepare
function manacore:api/mana/consume
execute if entity @s[type=minecraft:player] run function sweetdream:profession/paid

# ② 没扣成功 ⇒ 一个字节都没花, 不记账
execute unless data storage manacore:out r{success:1b} run return 0

# ③ 执行者不是玩家 ⇒ 不是"玩家花魔力", 不记账
execute unless entity @s[type=minecraft:player] run return 0

# ④ 记一笔（魔力 ×1000）—— 两个账本各加一份
#   ★ 剖面(pm_sum) / 折潮(tf_sum) 的文案没有"排除被动扣费"的口径 ⇒ 被动也算。
scoreboard players set #pm_v zx.meta 0
execute store result score #pm_v zx.meta run data get storage manacore:in arg.value 1000
execute if score #pm_v zx.meta matches 1.. run scoreboard players operation @s zx.pm_sum += #pm_v zx.meta
# 折潮只在这笔成功的正数扣费内结算一次；不留给每刻循环批量兑现。
execute unless items entity @s armor.head *[minecraft:custom_data~{zx:["tide_fold"]}] run scoreboard players set @s zx.tf_sum 0
execute if score #pm_v zx.meta matches 1.. if items entity @s armor.head *[minecraft:custom_data~{zx:["tide_fold"]}] run function sweetdream:equipment/armor/tide_fold/on_mana
