# ============================================================
# sweetdream:equipment/armor/crimson_seam/heal_go —— 绯缝: 真的去回那 5%
# ------------------------------------------------------------
# 【谁调用它】crimson_seam/on_true_hit（用 `as <施法者>` 送进来）
# 【执行者】那个玩家（lib/heal 要求执行者就是被治疗的玩家）
# 【★ 为什么拆一层 ★】on_true_hit 是**宏函数**(要展开施法者 UUID)；
#   而"算 5% → 调 lib/heal → 记节流"这几步既要用 items/attribute 又要用账本，
#   放在宏函数里也跑得动，但拆开之后宏那一层只剩"反查 + 切换身份"，更好读。
#   ★ check.py 的 equipgate 规则要求被 `as` 调用的函数体内出现 `items entity @s`
#     —— 穿着判定就在本文件里, 满足。
# ============================================================

# ① 没穿绯缝就没这事（胸甲）
execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["crimson_seam"]}] run return 0

# ② 6 秒节流（账本存"下次可触发刻"）
scoreboard players set #cr_due zx.meta 0
execute store result score #cr_due zx.meta run scoreboard players get @s zx.cr_cd
execute if score #cr_due zx.meta > #now manacore.meta run return 0

# ③ 要回多少 = 最大生命值 × 5%（取整，向下）
#    ★ 读**原版属性**而不是面板账本（同 lib/heal / 殓丝 on_hurt 的口径，
#      免得差出"面板与属性不同步"的那一截）。
#    ★ R05 intovf-ok：底数 = 玩家上限(本包实测上限约 30)，×5 最多 150，
#      离 int32 上限差 7 个数量级；乘数是文案里的死数字 5，不会动态放大。
execute store result score #heal_pt zx.meta run attribute @s minecraft:max_health get
scoreboard players set #cr_pct zx.meta 5
scoreboard players operation #heal_pt zx.meta *= #cr_pct zx.meta
scoreboard players operation #heal_pt zx.meta /= #100 zx.meta

# ④ 回复（lib/heal 自会处理"0 点就返回"与"跨一拍撤上限"）
function sweetdream:lib/heal

# ⑤ 表现 + 记账
execute at @s run particle minecraft:heart ~ ~1.2 ~ 0.3 0.4 0.3 0.0 4 normal
execute at @s run playsound minecraft:entity.arrow.hit_player player @a ~ ~ ~ 0.5 1.8
scoreboard players operation @s zx.cr_cd = #now manacore.meta
scoreboard players operation @s zx.cr_cd += #120 zx.meta
