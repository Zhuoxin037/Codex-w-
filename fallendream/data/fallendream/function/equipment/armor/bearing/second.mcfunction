# ============================================================
# fallendream:equipment/armor/bearing/second —— 「承」每秒结算
# ------------------------------------------------------------
# 【执行者】玩家（lib/fm/read 之后）
# 【文案(基础)】魔力 +140（armor_mana 登记）；每占用 1 个术阵位 → 护甲 +2 / 韧性 +1（最多 3 层）；
#   术阵为空时移速 +6%。
#   套装（枢 + 承）：术阵位全满 → 8 秒「阵成」（技能伤害 +15% 独立乘区、技能冷却 −10%）；
#   术阵自然结束或主动归还时返还 25 点魔力值；每 12 秒最多进入一次。
# 【文案(超限·逐字)】自身魔力值上限 +180。每占用 1 个术阵位，自身护甲值 +2、护甲韧性 +1。
#   自身术阵为空时，移动速度 +8%。术阵结束时自身恢复 1% 魔力值，且自身的护甲值和护甲韧性
#   加成会额外保留 4 秒。自身保持满术阵 4 秒后，进入「阵成」（可以和套装和枢的「阵成」叠加），
#   冷却 12 秒。套装的「阵成」所需的术阵数 -1。
# 【★ 层数怎么来 ★】zx.fm_u（lib/fm/read 每秒下发），基础最多 3 层，超限按实际占用。
# 【★ 换档必须先摘后挂 ★】同 id modifier 重复 add 会失败，且失败会**截断**后续命令
#   （attribute 的 remove 不存在虽不截断，但 add 重复一定失败）⇒ 用账本 zx.br_a / zx.br_t
#   记"当前挂的是几"，档位没变就一条 attribute 都不发。
# 【★ 「阵成」的触发是"边沿"不是"电平" ★】zx.br_full 记上一秒是否满，只有 0→1 才触发。
# 【★ 「返还 25 魔力」为什么用"占用下降"判 ★】前置包的 formation_remove 事件带的是
#   **uuid 文本**，反查玩家要序列化 NBT（卡顿坑 1）；而占用数本来每秒就在读 ⇒
#   直接看 zx.fm_u 掉了几个，掉 N 个返还 25×N。"自然结束/主动归还"都表现为占用下降。
# 【★ 超限前缀用 brx_ ★】br_ol / br_g / br_gl / br_gn 已经是「折光/折径」的账本，
#   别再往上叠 —— 承的超限账本统一走 zx.brx_*。
# ============================================================

# ⓪ 没穿 → 全部撤掉
execute unless items entity @s armor.legs *[minecraft:custom_data~{zx:["bearing"]}] run function fallendream:equipment/armor/bearing/off
execute unless items entity @s armor.legs *[minecraft:custom_data~{zx:["bearing"]}] run return 0

# ⓪.5 档位快照（这一秒：基础 / 超限）
scoreboard players set @s zx.brx_ol 0
execute if items entity @s armor.legs *[minecraft:custom_data~{zx:["bearing"],ol:"bearing"}] run scoreboard players set @s zx.brx_ol 1

# ⓪.6 "术阵结束"判定 = 本秒占用归零、上一秒还有（3→1 不算结束）
#   ★ zx.brx_pu 没有分数时是"没有这个分数", `if score` 不成立 ⇒ 首次跑不会误判。
scoreboard players set #br_end zx.meta 0
execute if score @s zx.fm_u matches 0 if score @s zx.brx_pu matches 1.. run scoreboard players set #br_end zx.meta 1

# ① 层数：基础最多 3 层；超限按实际占用。
scoreboard players set #br_n zx.meta 0
scoreboard players operation #br_n zx.meta = @s zx.fm_u
scoreboard players set #br_3 zx.meta 3
execute unless score @s zx.brx_ol matches 1 if score #br_n zx.meta > #br_3 zx.meta run scoreboard players set #br_n zx.meta 3
execute if score #br_n zx.meta matches ..0 run scoreboard players set #br_n zx.meta 0

execute unless score @s zx.brx_ol matches 1 run scoreboard players set @s zx.brx_keep 0
execute unless score @s zx.brx_ol matches 1 run scoreboard players set @s zx.brx_hold 0
execute unless score @s zx.brx_ol matches 1 run scoreboard players set @s zx.brx_zc 0

# ①.5 ★ 超限·承: "术阵结束时护甲/韧性加成额外保留 4 秒" ★
#   · 归零那一下把"刚才的层数"抄进 brx_kn，并把保留到期刻推到 #now+80
#   · 保留窗口内层数一律取 brx_kn（等于护甲/韧性那一档原封不动再挂 4 秒）
execute if score @s zx.brx_ol matches 1 if score #br_end zx.meta matches 1 run scoreboard players operation @s zx.brx_kn = @s zx.brx_pn
execute if score @s zx.brx_ol matches 1 if score #br_end zx.meta matches 1 run scoreboard players operation @s zx.brx_keep = #now manacore.meta
execute if score @s zx.brx_ol matches 1 if score #br_end zx.meta matches 1 run scoreboard players add @s zx.brx_keep 80
execute if score @s zx.brx_ol matches 1 if score @s zx.brx_keep > #now manacore.meta if score #br_n zx.meta matches 0 run scoreboard players operation #br_n zx.meta = @s zx.brx_kn

# ② 护甲 = 2n
scoreboard players set #br_a zx.meta 0
scoreboard players operation #br_a zx.meta = #br_n zx.meta
scoreboard players set #br_2 zx.meta 2
scoreboard players operation #br_a zx.meta *= #br_2 zx.meta

# ③ 换档（护甲）
execute unless score #br_a zx.meta = @s zx.br_a run function fallendream:equipment/armor/bearing/attr_arm
# ④ 换档（韧性 = n，整数点）
execute unless score #br_n zx.meta = @s zx.br_t run function fallendream:equipment/armor/bearing/attr_tou

# ⑤ 套装：返还魔力 + 「阵成」
function fallendream:equipment/armor/bearing/refund
function fallendream:equipment/armor/bearing/set_full

# ⑤.5 ★ 超限·承: 术阵结束 —— 恢复 1% 魔力值 ★
execute if score #br_end zx.meta matches 1 if score @s zx.brx_ol matches 1 run function fallendream:equipment/armor/bearing/ol_end

# ⑤.6 ★ 超限·承: 保持满术阵 4 秒 → 自己那份「阵成」（和套装/枢的阵成叠加） ★
execute if score @s zx.brx_ol matches 1 run function fallendream:equipment/armor/bearing/ol_full

# ⑥ 术阵为空 → 移速 +6%（超限 +8%）
scoreboard players set #br_s zx.meta 0
execute if score @s zx.fm_u matches 0 run scoreboard players set #br_s zx.meta 1
execute if score @s zx.brx_ol matches 1 if score #br_s zx.meta matches 1 run scoreboard players set #br_s zx.meta 2
execute unless score #br_s zx.meta = @s zx.br_spd run function fallendream:equipment/armor/bearing/spd_set

# ⑦ 记基线（下一秒判"结束"、以及结束时抄层数都靠这两条）
scoreboard players operation @s zx.brx_pu = @s zx.fm_u
scoreboard players operation @s zx.brx_pn = #br_n zx.meta
