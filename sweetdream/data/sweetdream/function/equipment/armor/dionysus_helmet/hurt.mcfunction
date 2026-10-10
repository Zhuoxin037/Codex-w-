# ============================================================
# sweetdream:equipment/armor/dionysus_helmet/hurt —— 受伤触发(桂冠的狂醉)
# ------------------------------------------------------------
# 【谁调用它】进度 sweetdream:equipment/armor/dionysus_helmet
#   触发器 minecraft:entity_hurt_player —— 玩家受到任何伤害都会触发。
# 【基础版文案】自身受到伤害后有 20% 的概率获得反胃Ⅲ和力量Ⅲ,
#         并且自身每秒恢复 80 魔力值, 持续 3 秒。
# 【超限版文案(超限·狄俄尼索斯之桂冠, 2026-10-10 实装)】"自身受到伤害后有 20%
#   的概率会获得反胃Ⅱ和力量Ⅲ效果，之后获得一层「酒浆」（最多 10 层），并且
#   自身每秒恢复 60 点魔力值，持续 3 秒。" —— 走 hurt_ol(数值不同 + 「酒浆」+1)。
# 【20% 怎么判】谓词 sweetdream:chance_20(minecraft:random_chance, chance:0.2)。
# 【回魔量记在哪】zx.dio_ramt = 每秒回多少(regen 读它) —— 两版金额不同
#   (基础 80 / 超限受伤 60 / 超限攻击触发 80), 必须跟着触发各写一次。
# ============================================================

# ⓪ 先撤销自己的进度
advancement revoke @s only sweetdream:equipment/armor/dionysus_helmet

# ① 戴着才生效(~ 部分匹配 + 只认桂冠独有的那一段标记)
execute unless items entity @s armor.head netherite_helmet[custom_data~{zx:["dionysus_helmet"]}] run return fail

# ② 掷一次 20%(没中就直接结束)
execute unless predicate sweetdream:chance_20 run return fail

# ③ 超限版: 反胃Ⅱ + 力量Ⅲ + 「酒浆」+1 + 回魔 60/秒×3秒 —— 整段在 hurt_ol
execute if items entity @s armor.head *[minecraft:custom_data~{zx:["dionysus_helmet"],ol:"dionysus_helmet"}] run function sweetdream:equipment/armor/dionysus_helmet/hurt_ol
execute if items entity @s armor.head *[minecraft:custom_data~{zx:["dionysus_helmet"],ol:"dionysus_helmet"}] run return 0

# ---- 基础版 ----
# ③' 反胃Ⅲ + 力量Ⅲ, 各 3 秒(hideParticles 免得烟雾糊脸)
effect give @s minecraft:nausea 3 2 true
effect give @s minecraft:strength 3 2 true

# ④ 每秒回 80 魔力, 持续 3 秒
scoreboard players set @s zx.dio_regen 3
scoreboard players set @s zx.dio_ramt 80

# ⑤ 给自己一点反馈
tellraw @s [{"text":"醉意涌上来了……","color":"light_purple","italic":false}]
