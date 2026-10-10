# ============================================================
# sweetdream:debug/charge_unstick —— 一次性清理: 把"焊在身上"的第二形态加成退回去
# ------------------------------------------------------------
# 【什么时候用】2026-10-10 之前进过第二形态的号。那版是**只加不收**的, 而加成是
#   `manacore:api/stats/add` 加在**玩家存档属性**上的(不是效果, 不会自己过期)
#   ⇒ 即使你根本没在超载, 攻击力翻倍 / 最大魔力 +50% 也一直挂着。
#   修好之后(mode_on 记账本 + mode_off 按账本收)**新**一轮超载会自动回收;
#   但**旧**的那一笔没有账本(mode_off 会提示你来跑这个), 只能反推。
# 【反推的依据】旧版 mode_on 有 `if chg_mode matches 1 return 0` 幂等门 ⇒ **一辈子只加过一次**:
#   · base_attack: 加的是"加之前它自己" ⇒ 现值 = 2 × 原值 ⇒ 该退 现值 × 0.5;
#   · max_mana:   加的是 0.5 × 原值       ⇒ 现值 = 1.5 × 原值 ⇒ 该退 现值 × (1/3)。
# 【⚠ 前提】中间**没换过装备 / 没被别的东西改过这两项属性** —— 否则反推的基数不对。
#   所以本函数会**打印清理前后的数值**, 你自己扫一眼对不对:
#   · 不对(比如清完反而变得离谱) → 用 `manacore:api/stats/set` 手动写回正确值即可;
#   · 拿不准就先别跑, 直接 `/scoreboard players set @s zx.chg_mode 0` 只停掉自伤/落点/冻结。
# 【它只动这两项属性 + 三个计分项】不动别的。
# ============================================================

# ① 拿 uuid
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run tellraw @s [{"text":"[unstick] 你还没注册完成(uuid 是空的) —— 等一秒再试","color":"red"}]
execute unless data storage zx:data self{ok:1b} run return fail

# ② 读当前基础攻击力 -> 打印 -> 退 现值 × 0.5
data modify storage manacore:in arg set value {uuid:"",key:"base_attack"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
data modify storage zx:work chg_dbg.atk set from storage manacore:out r.value
tellraw @s [{"text":"[unstick] 清理前 基础攻击力 = ","color":"gray"},{"nbt":"chg_dbg.atk","storage":"zx:work","color":"aqua"}]
#   ★ 先归零再 store: data get 失败时 store 不执行, 会留着上一次的值。
scoreboard players set #chg_neg zx.meta 0
execute store result score #chg_neg zx.meta run data get storage manacore:out r.value 100
scoreboard players operation #chg_u zx.meta = #chg_neg zx.meta
scoreboard players set #chg_neg zx.meta 0
scoreboard players operation #chg_neg zx.meta -= #chg_u zx.meta
data modify storage manacore:in arg set value {uuid:"",key:"base_attack",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
#   ×100 的账 × 0.005 = 现值 × 0.5(取负 = 退回去)
execute store result storage manacore:in arg.value double 0.005 run scoreboard players get #chg_neg zx.meta
function manacore:api/stats/add

# ③ 读当前最大魔力 -> 打印 -> 退 现值 ÷ 3
data modify storage manacore:in arg set value {uuid:"",key:"max_mana"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
data modify storage zx:work chg_dbg.mm set from storage manacore:out r.value
tellraw @s [{"text":"[unstick] 清理前 最大魔力值 = ","color":"gray"},{"nbt":"chg_dbg.mm","storage":"zx:work","color":"aqua"}]
scoreboard players set #chg_neg zx.meta 0
execute store result score #chg_neg zx.meta run data get storage manacore:out r.value 100
scoreboard players operation #chg_u zx.meta = #chg_neg zx.meta
scoreboard players set #chg_neg zx.meta 0
scoreboard players operation #chg_neg zx.meta -= #chg_u zx.meta
data modify storage manacore:in arg set value {uuid:"",key:"max_mana",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
#   ×100 的账 × 0.0033333 = 现值 × (1/3)(取负 = 退回去)
execute store result storage manacore:in arg.value double 0.0033333 run scoreboard players get #chg_neg zx.meta
function manacore:api/stats/add

# ④ 复位形态与账本(旧加成没有账本, 这里只是把它们清干净, 免得下次 mode_off 又走空账本分支)
scoreboard players set @s zx.chg_mode 0
scoreboard players set @s zx.chg_atk 0
scoreboard players set @s zx.chg_mm 0

# ⑤ 再读一遍 -> 打印, 给你核对
data modify storage manacore:in arg set value {uuid:"",key:"base_attack"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
data modify storage zx:work chg_dbg.atk set from storage manacore:out r.value
data modify storage manacore:in arg set value {uuid:"",key:"max_mana"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
data modify storage zx:work chg_dbg.mm set from storage manacore:out r.value
tellraw @s [{"text":"[unstick] 清理后 基础攻击力 = ","color":"gray"},{"nbt":"chg_dbg.atk","storage":"zx:work","color":"green"},{"text" : " / 最大魔力值 = ","color":"gray"},{"nbt":"chg_dbg.mm","storage":"zx:work","color":"green"}]
tellraw @s [{"text":"[unstick] 形态已复位(chg_mode=0)。数值不对就用 manacore:api/stats/set 写回。","color":"gray","italic":true}]
