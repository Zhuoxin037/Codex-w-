# ============================================================
# sweetdream:equipment/axe/charge/mode_off —— 超限·超•负•荷: 退出「第二形态」(收回加成)
# ------------------------------------------------------------
# 【为什么必须有它】第二形态那两条加成(基础攻击力翻倍 / 最大魔力 +50%)是用
#   `manacore:api/stats/add` 加在**玩家存档属性**上的 —— **不是效果(effect), 不会自己过期**。
#   旧版只加不收, 而 `zx.chg_mode` 又是"进了就不退" ⇒ 加成**永久焊在身上**, 连
#   "每次攻击自伤 5%"(hit -> self_hurt)也一直跟着。
#   用户 2026-10-10 报: "超负荷的增益焊在我身上了, 即使我没有开启超载"。
# 【谁调用它】① end(超载状态**真的**结束那一拍 —— 没被 end_ol 重新点起);
#            ② second(兜底: 形态还挂着但状态已是 0, 补收漏网的)
# 【执行者】玩家
# 【★ 按账本收, 不反推 ★】加了多少记在 `zx.chg_atk` / `zx.chg_mm`(整数 = "加的量 ×100")
#   上(由 mode_on 写入), 这里**原样取负减回去**。
#   ★ 绝不"重新读面板反推": 面板里混着别的装备/升级加成, 反推会把**别人的**加成也减掉。
#   · zx.chg_atk = 当时加的 base_attack × 100  ⇒ 减 zx.chg_atk × 0.01
#   · zx.chg_mm  = 当时的 max_mana    × 100  ⇒ 减 zx.chg_mm  × 0.005
#     (mode_on 加的是 (M×100)×0.005 = M×0.5; 这里同系数取负 = 原样退回)
# 【取负怎么写】计分板没有"取负"运算 ⇒ `#chg_neg = 0 - @s zx.chg_atk` 再 store。
#   (也可以写 `execute store … double -0.01` 的负系数, 但显式取负好读、也不怕解析差异。)
# 【★ 账本是空的怎么办】那说明这是**修复前**就焊上的旧加成(那时根本没记账本) ——
#   反推会把别人的加成一起减掉, 所以这里**不猜**: 只把 chg_mode 归 0
#   (让自伤 / 落点追加伤害 / 冷却冻结立刻停止), 并提示玩家手动跑
#   `sweetdream:debug/charge_unstick`(它会打印前后值给你核对)。
# ============================================================

# ① 不是第二形态 -> 什么都没加过, 直接回
execute unless score @s zx.chg_mode matches 1 run return 0

# ② 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

# ③ 账本是空的 -> 修不动(见头注): 只复位形态 + 提示, 不猜数值
#   ★ 判据 = "两个账本相加 == 0": 两边都只会是 ≥0 的数, 相加为 0 就是**都没记过**
#     (单项判会遇到"那一项恰好是 0"的误判, 所以看总和)。
scoreboard players set #chg_neg zx.meta 0
scoreboard players operation #chg_neg zx.meta += @s zx.chg_atk
scoreboard players operation #chg_neg zx.meta += @s zx.chg_mm
execute unless score #chg_neg zx.meta matches 1.. run tellraw @s [{"text":"⚠ 超•负•荷: 第二形态的账本是空的(= 这是修复前就焊上的旧加成), 本次只停掉了自伤/落点伤害/冷却冻结。要连属性一起退干净, 请跑 ","color":"yellow"},{"text":"/function sweetdream:debug/charge_unstick","color":"aqua","clickEvent":{"action":"suggest_command","value":"/function sweetdream:debug/charge_unstick"}},{"text":"(会打印前后值给你核对)","color":"gray","italic":true}]
execute unless score #chg_neg zx.meta matches 1.. run scoreboard players set @s zx.chg_mode 0
execute unless score #chg_neg zx.meta matches 1.. run return 0

# ④ 基础攻击力: 减回 zx.chg_atk × 0.01
scoreboard players set #chg_neg zx.meta 0
scoreboard players operation #chg_neg zx.meta -= @s zx.chg_atk
data modify storage manacore:in arg set value {uuid:"",key:"base_attack",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 0.01 run scoreboard players get #chg_neg zx.meta
function manacore:api/stats/add

# ⑤ 最大魔力值: 减回 zx.chg_mm × 0.005
scoreboard players set #chg_neg zx.meta 0
scoreboard players operation #chg_neg zx.meta -= @s zx.chg_mm
data modify storage manacore:in arg set value {uuid:"",key:"max_mana",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 0.005 run scoreboard players get #chg_neg zx.meta
function manacore:api/stats/add

# ⑥ 复位: 形态开关 + 账本
scoreboard players set @s zx.chg_mode 0
scoreboard players set @s zx.chg_atk 0
scoreboard players set @s zx.chg_mm 0

# ⑦ 表现
execute at @s run particle minecraft:flash ~ ~1 ~ 1.0 1.2 1.0 0.1 12 normal
tellraw @s [{"text":"超限·超•负•荷 · 超载结束, 第二形态的加成已收回","color":"gray","italic":true}]
