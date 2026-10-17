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

# ⑥ 【2026-10-16 删除】这里原有"上限变低后把当前生命夹回来"的一段:
#       execute if score #curhp > #maxhp run execute store result entity @s Health float 1 …
#    —— **整段作废, 已删**。原版禁止用命令写玩家 NBT: `/data` 与 `/execute store` 对玩家
#    实体一律抛 `commands.data.entity.invalid` = "Unable to modify player data"
#    (1.21.5 客户端 jar 内核实)。所以这句(以及它更早的 double 版本)从来没有生效过,
#    "30/20 脏值"也不是它修的 —— 那次真因是 ④ 里"按旧账摘 modifier"的顺序修正。
#    ⇒ 命令层面**无法**把玩家当前生命夹下来。若以后真出现"当前 > 上限"的脏值,
#      只能靠 /effect 路径或原版自身的钳制, 别再往这里加 NBT 写入。
