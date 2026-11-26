# ============================================================
# fallendream:equipment/armor/crimson_seam/knit_add —— 缝心: 积攒 1 层「绯结」
# ------------------------------------------------------------
# 【谁调用它】needle_sleep/hit ⑧（"为原本未带噬心的生物**成功附加**噬心"那一刻）
# 【执行者】玩家（动手的那个人）
# 【文案(套装段 逐字)】自身为原本未附有「噬心」的生物成功附加噬心后，积攒 1 层
#   「绯结」（最多 3 层，6 秒内最多积攒一次）。
# 【★ 为什么"原本未附有"不用在这里判 ★】调用点 needle_sleep/hit ④ 已经排除了
#   "目标本来带噬心"的情况，走到这里的必然是"原本没带、这次被我们挂上"。
# 【★ 「绯结」是**私有积攒**, 拆件即清 ★】用户稿的总则: "拆去任一成员后，套装增益和
#   私有积攒立即清除"。主责在 crimson_seam/second（每秒判一次, 拆件后最多 1 秒生效,
#   与全包 9 套"逐秒重算 ⇒ 拆件天然即清"的口径一致）；本文件开头那次判定只是
#   **顺手再判一遍**的保险 —— 只要走到"积攒"这一步, 就一定先确认两件还在身上。
#   两者不是重复: 每秒件负责"拆了就清", 这里负责"拆了绝不继续攒"。
# ============================================================

# ① 拆了任一件 -> 「绯结」归零（主责在 crimson_seam/second, 这里是同一件事的即时兜底）
#    ★ 只清**层数**（私有积攒）★ 不清 zx.cr_knit_cd / zx.cr_amp_cd 这两条节流账本 ——
#      它们记的是"多久内最多一次", 清掉等于"撤装再装就能重置冷却", 反而是漏洞。

# ② 穿齐「缝心」两件吗（● 针眠 = 头盔 / ● 绯缝 = 胸甲）

# ③ 6 秒节流（账本存"下次可积攒刻"）
#   ★ 超限·针眠的"套装激活"窗口(zx.ns_set_end > #now)内没有这条限制 ——
#     文案:"「绯结」的积攒时间冷却限制…去除"。@s 没这个分数时是 0, 比较为假 ⇒ 照常节流。
function fallendream:equipment/armor/crimson_seam/set_active
execute unless score #cr_set zx.meta matches 1 run return 0
scoreboard players set #crk_lim zx.meta 1
execute if score @s zx.ns_boost_end > #now manacore.meta run scoreboard players set #crk_lim zx.meta 0
scoreboard players set #crk_due zx.meta 0
execute store result score #crk_due zx.meta run scoreboard players get @s zx.cr_knit_cd
execute if score #crk_lim zx.meta matches 1 if score #crk_due zx.meta > #now manacore.meta run return 0

# ④ 层数上限（基础 3 / 超限激活窗口内 5；先 add 0 保证"没分数"的玩家也能判）
scoreboard players set #crk_max zx.meta 3
execute if score @s zx.ns_boost_end > #now manacore.meta run scoreboard players set #crk_max zx.meta 5
scoreboard players add @s zx.cr_knit 0
execute if score @s zx.cr_knit >= #crk_max zx.meta run return 0

# ⑤ 积攒 1 层
scoreboard players add @s zx.cr_knit 1

# ⑥ 表现 + 记账（现在 + 120 刻 = 6 秒）
execute at @s run particle minecraft:item{item:{id:"minecraft:redstone",count:1}} ~ ~1 ~ 0.3 0.4 0.3 0.01 6 normal
execute at @s run playsound minecraft:block.wool.place player @a ~ ~ ~ 0.4 1.6
scoreboard players operation @s zx.cr_knit_cd = #now manacore.meta
scoreboard players operation @s zx.cr_knit_cd += #120 zx.meta
