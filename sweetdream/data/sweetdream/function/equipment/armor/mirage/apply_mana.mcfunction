# ============================================================
# sweetdream:equipment/armor/mirage/apply_mana —— 给魔力上限加差值
# ------------------------------------------------------------
# 【入参】#diff = 要加的差值(穿着是 +240, 脱下是 -240)   【执行者】玩家
# 【为什么只加差值】面板的 max_mana 只是一个数, 没有"加成层"; 直接 set 会把
#   余烬/桂冠/异彩给的加成一并冲掉。
# 【★ 脱下时为什么要读一次再 set 回去 ★】脱下会让上限变小, 当前魔力可能
#   已经超过新上限; api/mana/set 会自动夹到 [0,max], 读出来原样 set 一遍
#   就等于夹紧。不这样做的话"魔力条溢出上限", 显示和判定都会怪。
# 【账本】zx.mr_mana 记"本件已经往面板里加了多少", 脱下时按这本账减回去。
# ============================================================

data modify storage manacore:in arg set value {uuid:"",key:"max_mana",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
execute store result storage manacore:in arg.value double 1 run scoreboard players get #diff zx.meta
function manacore:api/stats/add

scoreboard players operation @s zx.mr_mana += #diff zx.meta

data modify storage manacore:in arg set value {uuid:""}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/get
data modify storage manacore:in arg set value {uuid:"",value:0.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
data modify storage manacore:in arg.value set from storage manacore:out r.value
function manacore:api/mana/set
