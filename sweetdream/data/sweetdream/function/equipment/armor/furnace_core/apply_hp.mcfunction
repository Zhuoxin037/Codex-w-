# ============================================================
# sweetdream:equipment/armor/furnace_core/apply_hp —— 给最大生命值加差值
# ------------------------------------------------------------
# 【入参】#diff = 要加的差值(可正可负)   【执行者】玩家
# 【生命上限要改两个地方】
#   ① 面板 max_health —— 技能伤害公式读它, 必须跟着变
#   ② 原版属性 minecraft:max_health —— 真正的血条长度
#   面板那个只是"账本", 不会让血条变长; 想真的耐打就得加原版属性。
# 【属性 id 本件独有】sweetdream:eqp_fc_hp —— 和体外供能装置/脊骨共生那几个
#   分开, 各自摘不打架。
# 【★ 摘 modifier 看"旧账"而不是"新账" ★】这是 2026-10-05 实测 bug 的根因:
#   旧写法在账本 += #diff 之后才判断要不要摘, 于是"脱下把账本正好减到 0"那一帧,
#   新账 = 0, 两条 matches(..-1 / 1..) 都不满足 -> modifier 没被摘 ->
#   面板 max_health 被 api/stats/add 正确减回 20, 但原版属性还挂着 +10 -> 上限仍是
#   30, 而 Health NBT 还停在 30 -> 观测镜读"面板 20 / 实际 30"显示成 30/20 脏值。
#   改法: 先记下旧账(≠0 才是挂过), 账本更新后再按"旧账"摘旧的, 最后按"新账"加回来。
# 【为什么不直接盲摘】摘一个不存在的 modifier 会失败(旧注释说会截断函数),
#   所以用"旧账 ≠ 0"当安全门, 只在确实挂过时才摘。
# ============================================================

# ① 面板: 加差值
data modify storage manacore:in arg set value {uuid:"",key:"max_health",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #diff zx.meta
function manacore:api/stats/add

# ② 旧账: 摘 modifier 前先看"原本记着加过多少"(≠0 才是挂过)
scoreboard players set #old zx.meta 0
scoreboard players operation #old zx.meta = @s zx.fc_hp

# ③ 账本更新
scoreboard players operation @s zx.fc_hp += #diff zx.meta

# ④ 先把旧的 modifier 摘掉(只在旧账 ≠ 0 时, 避免摘不存在的)
execute unless score #old zx.meta matches 0 run attribute @s minecraft:max_health modifier remove sweetdream:eqp_fc_hp

# ⑤ 新账 ≠ 0 就按新账加回来(先把账本数值写进 zx:work x.v 给宏拼字面量)
execute unless score @s zx.fc_hp matches 0 run data modify storage zx:work x set value {v:0}
execute unless score @s zx.fc_hp matches 0 store result storage zx:work x.v int 1 run scoreboard players get @s zx.fc_hp
execute unless score @s zx.fc_hp matches 0 run function sweetdream:equipment/armor/furnace_core/hp_add with storage zx:work x

# ⑥ 夹当前生命: 上限变低(脱下装备 / 燃灰掉层)后, 当前生命可能还停在新上限之上,
#    原版**不会**自动把血扣下来 -> 显示成 30/20 这种脏值。只在当前 > 上限时才动手,
#    不会误回血(上限变大时当前血一定 < 上限, 条件不成立, 安全)。
#    ⚠️ 必须在 ④ 摘完、⑤ 加完之后读, 才能拿到"真正的最终上限"。
execute store result score #maxhp zx.meta run attribute @s minecraft:max_health get
execute store result score #curhp zx.meta run data get entity @s Health
execute if score #curhp zx.meta > #maxhp zx.meta run execute store result entity @s Health double 1 run scoreboard players get #maxhp zx.meta
