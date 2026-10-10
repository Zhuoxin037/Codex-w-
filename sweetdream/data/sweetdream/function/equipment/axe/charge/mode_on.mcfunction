# ============================================================
# sweetdream:equipment/axe/charge/mode_on —— 超限·超•负•荷: 进入「第二形态」
# ------------------------------------------------------------
# 【原文】"该状态结束后若该技能完成冷却，则自动使用且该技能停止正常冷却缩减，
#   之后自身攻击力增加相当于自身当前基础攻击力的数值，最大魔力值增加相当于
#   自身当前最大魔力值 ×0.5 的数值"
# 【谁调用它】end_ol(15 秒状态结束时冷却已归零 -> 自动再开那一拍) —— **唯一入口**
#   (2026-10-10 用户定稿删掉 mode_tick; 冷却没在状态期间归零就不会进第二形态)
#   —— 函数幂等: 已经进过就直接返回, 所以两个入口都调它很安全。
# 【执行者】玩家
# 【★ 第二形态**不是永续的** —— 它就是「超载阶段」本身, 超载结束就退出 ★】
#   (2026-10-10 用户定稿: 用户原话"超负荷的增益焊在我身上了, 即使我没有开启超载")
#   旧版把 zx.chg_mode 做成"进了就不退", 而这里的攻击/魔力加成是 `manacore:api/stats/add`
#   加在**玩家存档属性**上的 —— **不是效果(effect), 不会自己过期** ⇒ 只加不收 = 永久焊在
#   身上, 连"每次攻击自伤 5%"(hit -> self_hurt)也一直跟着。
#   现在: 进形态(本函数)加 → 超载结束那一拍 `end -> mode_off` 按账本原样减回去 + 归 0。
#   · 期间每次召唤闪电都会对落点生物追加 基础攻击力 ×3(见 ol_bolt_bonus);
#   · 每次攻击对自身造成 最大生命值 ×0.05(见 hit);
#   · 该技能冷却**在「本形态(第二形态)」的超载状态期间停止正常冷却缩减**(由 tick -> freeze_cd
#     每秒把结束时刻后推 20 刻实现, **只在 chg_mode=1 时** —— 第一阶段/第一形态不冻,
#     见 tick ③); 状态一结束立刻恢复自然减少。状态期间"攻击到生物 -4 秒"(见 hit)
#     是唯一的额外减冷却手段; **把它压到 0 -> 状态结束那一拍自动再开一轮**(见 end_ol /
#     autocast), 压不到 0 -> 超载结束、冷却恢复自然流动。
#   手动收回: `function sweetdream:equipment/axe/charge/mode_off`(按账本原样减)。
#   ★ 账本 = `zx.chg_atk` / `zx.chg_mm`(都是"加了多少 ×100"的整数), 本函数写入、
#     mode_off 读取并清零。**不许用"重新读面板反推"** —— 面板里混着别的装备加成, 反推会算错。
# 【★ 口径: "当前基础攻击力"取的是**加成前**的面板值 ★】
#   如果每次重算都读"含自己加成的面板", 会自我引用滚雪球(和炉心的注释同一个坑)。
#   这里只在进入第二形态的那一刻读一次、加一份, 之后不再变动 —— 简单且可预期。
# 【数值换算】最大魔力 ×0.5: 先把面板值 ×100 存成整数分数, 再用
#   `store result … double 0.005` => 原值 × 100 × 0.005 = 原值 × 0.5。
# ============================================================

# ① 只在**第一次**进入时加(重复调用是空操作)
execute if score @s zx.chg_mode matches 1 run return 0

# ② 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

scoreboard players set @s zx.chg_mode 1

# ③ 基础攻击力 += 当前基础攻击力(= 翻一倍)
data modify storage manacore:in arg set value {uuid:"",key:"base_attack"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
#   ★ 账本(给 mode_off 回收用): 记下"加了 base_attack × 100"
#     ★ 先归零再 store: data get 失败时 store 不执行, 会留着上一次的值。
scoreboard players set @s zx.chg_atk 0
execute store result score @s zx.chg_atk run data get storage manacore:out r.value 100
data modify storage manacore:in arg set value {uuid:"",key:"base_attack",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.value set from storage manacore:out r.value
function manacore:api/stats/add

# ④ 最大魔力值 += 当前最大魔力值 ×0.5
data modify storage manacore:in arg set value {uuid:"",key:"max_mana"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
#   ★ 账本(给 mode_off 回收用): 记下"当时的 max_mana × 100" —— 加的是 ×0.005 倍,
#     mode_off 用同一个系数取负, 就能原样减回去。
#   ★ 先归零再 store: data get 失败时 store 不执行, 会留着上一次的值。
scoreboard players set @s zx.chg_mm 0
execute store result score @s zx.chg_mm run data get storage manacore:out r.value 100
data modify storage manacore:in arg set value {uuid:"",key:"max_mana",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 0.005 run scoreboard players get @s zx.chg_mm
function manacore:api/stats/add

# ⑤ 表现
execute at @s run particle minecraft:flash ~ ~1 ~ 1.0 1.2 1.0 0.1 20 normal
execute at @s run playsound minecraft:entity.lightning_bolt.thunder player @a ~ ~ ~ 1.0 0.8
tellraw @s [{"text":"超限·超•负•荷 · 第二形态(超载期间): 攻击力翻倍 / 最大魔力 +50% / 每次召唤闪电附加落点伤害, 但每次攻击反噬最大生命值 5%","color":"light_purple"},{"text":" —— 超载结束后会自动收回","color":"gray","italic":true}]
