# ============================================================
# sweetdream:equipment/armor/spine_symbiote/kill_overlimit —— 超限版的击杀奖励
# ------------------------------------------------------------
# 【前置】kill 已判定: 穿着的那件是「超限·脊骨共生」; @s = 玩家, uuid 已备好
# 【做什么】
#   ① 定时加成 = max(现值, floor(魔力上限 × 0.02)), 持续 20 秒(= 400 刻)
#      —— 由 passive 折进护甲/生命两本账, 到期自动收回。
#   ② 若此刻处于脑髓蛭「蛊虫」的**消耗模式**(zx.bl_gm = 1 —— 满 10 层后
#      每次攻击 -1 层的那段, 不是"身上有层数"), 给 5 秒抗性提升Ⅴ
#      (玩家 2026-10-07 口径; 文案里"该被动效果强化为 ×0.05"在数值上是恒等式 ——
#       见 kill 顶部注释, 可观察的差异就是这条抗性Ⅴ。)
# 【为什么取 max】刚拿过更强的加成时, 这一下不该把数值压低(只延长/维持)。
# ============================================================

data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
scoreboard players set #mx zx.meta 0
execute store result score #mx zx.meta run data get storage manacore:out r.max

scoreboard players operation #new zx.meta = #mx zx.meta
scoreboard players operation #new zx.meta *= #2 zx.meta
scoreboard players operation #new zx.meta /= #100 zx.meta
execute if score #new zx.meta > @s zx.ss_ta run scoreboard players operation @s zx.ss_ta = #new zx.meta
scoreboard players operation @s zx.ss_te = #now manacore.meta
scoreboard players add @s zx.ss_te 400

# 「蛊虫」联动: 处于消耗模式(bl_gm=1)时, 抗性提升Ⅴ 5 秒(amplifier 4 = 等级 V)
execute if score @s zx.bl_gm matches 1 run effect give @s minecraft:resistance 5 4 true
