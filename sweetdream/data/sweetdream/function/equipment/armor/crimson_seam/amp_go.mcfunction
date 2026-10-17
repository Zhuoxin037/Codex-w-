# ============================================================
# sweetdream:equipment/armor/crimson_seam/amp_go —— 缝心: 兑现「绯结」的施法者侧动作
# ------------------------------------------------------------
# 【谁调用它】crimson_seam/set_true_hit（用 `as <施法者>` 送进来）
# 【执行者】那个玩家
# 【出参】#cr_ok zx.meta = 1 表示"这次真的可以兑现"（穿齐 + 节流过 + 有层数）
#   ★ 伤害的放大由 set_true_hit 在**目标**上下文里做（它要改 zx:work a.num），
#     这里只做"施法者身上那些事"—— 于是需要一个出参告诉调用方"放行"。
# 【文案(套装段 逐字)】对原本附有「噬心」的目标造成真实伤害时，若有「绯结」则消耗
#   1 层并使这一段真实伤害提高 15%（独立乘区），并获得 2 秒抗性提升Ⅰ。
#   该强化 5 秒内最多触发一次。
# ============================================================

scoreboard players set #cr_ok zx.meta 0

# ① 穿齐「缝心」两件吗
execute unless items entity @s armor.head *[minecraft:custom_data~{zx:["needle_sleep"]}] run return 0
execute unless items entity @s armor.chest *[minecraft:custom_data~{zx:["crimson_seam"]}] run return 0

# ② 5 秒节流（"该强化 5 秒内最多触发一次"）
scoreboard players set #cra_due zx.meta 0
execute store result score #cra_due zx.meta run scoreboard players get @s zx.cr_amp_cd
execute if score #cra_due zx.meta > #now manacore.meta run return 0

# ③ 有「绯结」吗（层数 ≥ 1）
scoreboard players add @s zx.cr_knit 0
execute if score @s zx.cr_knit matches ..0 run return 0

# ④ 消耗 1 层
scoreboard players remove @s zx.cr_knit 1

# ⑤ 2 秒抗性提升Ⅰ（amplifier 0 = Ⅰ）
effect give @s minecraft:resistance 2 0 true

# ⑥ 记账（现在 + 100 刻 = 5 秒）
scoreboard players operation @s zx.cr_amp_cd = #now manacore.meta
scoreboard players operation @s zx.cr_amp_cd += #100 zx.meta

# ⑦ 放行（告诉 set_true_hit"伤害可以乘 1.15 了"）
scoreboard players set #cr_ok zx.meta 1
