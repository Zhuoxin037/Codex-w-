# ============================================================
# sweetdream:equipment/armor/late_dusk/consume —— 消耗一层「回光」
# ------------------------------------------------------------
# 【执行者】@s = **攻击者**（穿迟暮的玩家）
# 【受害者】@e[tag=zx.ld_v]（由 late_dusk/hit 打的临时标签, 调用返回时摘掉）
# 【★ 文案(逐字) ★】
#   "自身对附有「白昼梦」的生物造成伤害时消耗一层「回光」，之后使其时停 2 秒
#    并记录接下来 5 秒其受到的伤害。"
#   "累计消耗 3 层「回光」后获得 15 秒抗性提升Ⅴ，若受到伤害则立即清除抗性提升。"
#   套装："自身消耗「回光」后使立即获得一种光效。"
# 【★ 顺序 ★】先扣层数 → 再判累计 3 层 → 再看套装 → 最后才去动受害者。
#   反过来（先时停再扣）在"层数为 0"时会把目标白停 2 秒。
# ============================================================

function sweetdream:equipment/armor/late_dusk/expire

# ① 没有回光 ⇒ 收工
execute unless score @s zx.ld_s matches 1.. run return 0

# ② 扣一层
scoreboard players operation @s zx.ld_t1 = @s zx.ld_t2
scoreboard players operation @s zx.ld_t2 = @s zx.ld_t3
scoreboard players set @s zx.ld_t3 0
function sweetdream:equipment/armor/late_dusk/expire

# ③ 累计消耗 3 层 ⇒ 抗性提升Ⅴ（15 秒）+ 受伤即清标记
scoreboard players add @s zx.ld_c 1
execute if score @s zx.ld_c matches 3.. run function sweetdream:equipment/armor/late_dusk/shield

# ④ 套装（与浮光同穿）：消耗「回光」后立即获得一种光效
#   ★ 复用浮光那一份发牌逻辑（随机 + 已齐则不发）, 不另写一套取色。
execute if items entity @s armor.head *[minecraft:custom_data~{zx:["glimmer"]}] run function sweetdream:equipment/armor/glimmer/give_color

# ⑤ 对受害者：时停 2 秒 + 开一个 5 秒的伤害记录窗口
execute as @e[tag=zx.ld_v,limit=1] at @s run function sweetdream:equipment/armor/late_dusk/rec_open
