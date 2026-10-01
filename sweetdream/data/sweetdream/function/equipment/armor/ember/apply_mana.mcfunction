# ============================================================
# sweetdream:equipment/armor/ember/apply_mana —— 给魔力上限加/减 240
# ------------------------------------------------------------
# 【入参】#em_diff = 要加的差值(穿上是 +240, 脱下是 -240)  【执行者】玩家
# 【为什么用差值】面板只有一个 max_mana, 没有加成层; 直接 set 会冲掉
#   静脉泵/桂冠/焚舟等别的来源给的上限。差值写法只动自己这一份。
# 【最后读一次再 set 回去】上限变小时当前魔力可能超过新上限,
#   api/mana/set 会自动夹到 [0,max]。
# ============================================================

data modify storage manacore:in arg set value {uuid:"",key:"max_mana",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #em_diff zx.meta
function manacore:api/stats/add

# 记账: zx.em_mana = 已经加进面板的数值
scoreboard players operation @s zx.em_mana += #em_diff zx.meta

# 夹紧当前魔力
data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.value set from storage manacore:out r.value
function manacore:api/mana/set
