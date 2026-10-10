# ============================================================
# sweetdream:equipment/armor/dionysus_helmet/hurt_ol —— 超限受伤被动(反胃Ⅱ/酒浆+1/回魔60)
# ------------------------------------------------------------
# 【谁调用它】hurt 第 ③ 步(确认戴着**超限版**桂冠、20% 已掷中)
# 【文案(超限·狄俄尼索斯之桂冠, 逐字)】"自身受到伤害后有 20% 的概率会获得
#   反胃2和力量3效果，之后获得一层「酒浆」（最多10层），并且自身每秒恢复
#   60点魔力值，持续3秒。"
# 【★ 数值与基础版不同, 是原文如此, 不是笔误 ★】反胃 Ⅲ->Ⅱ、回魔 80->60;
#   新增「酒浆」+1(最多 10 层 —— 层数存玩家计分项 zx.dio_wine)。
# ============================================================

# 反胃Ⅱ + 力量Ⅲ, 各 3 秒
effect give @s minecraft:nausea 3 1 true
effect give @s minecraft:strength 3 2 true

# 「酒浆」+1(最多 10 层, 到顶夹住)
scoreboard players add @s zx.dio_wine 1
execute if score @s zx.dio_wine matches 11.. run scoreboard players set @s zx.dio_wine 10

# 每秒回 60 魔力, 持续 3 秒(金额记 zx.dio_ramt, regen 每秒读它)
scoreboard players set @s zx.dio_regen 3
scoreboard players set @s zx.dio_ramt 60

tellraw @s [{"text":"醉意涌上来了……","color":"light_purple","italic":false}]
