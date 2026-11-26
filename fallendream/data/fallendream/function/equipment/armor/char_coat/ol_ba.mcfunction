# ============================================================
# fallendream:equipment/armor/char_coat/ol_ba —— 超限·焦衣：把施法者的"基础攻击力"读进 #cc_ba
# ------------------------------------------------------------
# 【执行者】穿超限焦衣的那个玩家
# 【出参】#cc_ba zx.meta = 基础攻击力 ×100（读不到 = 0）
# 【为什么单独拆一个文件】manacore:api/stats/get 要求"执行者就是那个玩家";
#   而调用方 char_coat/ol_hit 的执行者是**挨打的那一只**（@s 必须留作受击者），
#   所以只能 `as <玩家> run function 本文件` 借一次执行者身份。
# 【★ 先清零 ★】`store result` 在 data get 失败时**不执行**，不清零就会把上一个人的
#   数值当成自己的（静默多打一截伤害）。
# ============================================================

function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",key:"base_attack"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/stats/get
scoreboard players set #cc_ba zx.meta 0
execute store result score #cc_ba zx.meta run data get storage manacore:out r.value 100
