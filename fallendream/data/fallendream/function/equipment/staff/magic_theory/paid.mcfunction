# ============================================================
# fallendream:equipment/staff/magic_theory/paid —— 超限·导轨打空后的补射
# ------------------------------------------------------------
# 【执行者】玩家
# 【成立条件】zx.mt_ol=1 / 导轨已经 0 枚 / 主动仍在冷却中 / 补射次数 < 2
# 【口径】「导轨消耗完后若技能未冷却完成, 则使用技能时可以消耗 80 魔力值
#   来发射一颗该技能的子弹, 每个技能冷却期间最多两次」
#     · 不消耗「导轨」(本来就没有了), 也不碰冷却
#     · 计数 zx.mt_paid 在 active 开新一轮时归零 ⇒ "每个冷却期间"天然成立
# 【★ 不能调 api/skill/check】它会把"在冷却中"判成不可释放, 这条分支永远进不来;
#   这里只需要「够不够蓝」, 所以直接走 lib/mana/pay 的返回。
# ============================================================
execute if score @s zx.mt_paid matches 2.. run return 0
function fallendream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
# 冷却已经走完 → 这不是补射场景(玩家该走 ③ 正常开新一轮)
data modify storage manacore:in arg set value {uuid:"",skill:"fallendream:magic_theory"}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/cooldown/check
execute if data storage manacore:out r{ready:1b} run return 0
data modify storage manacore:in arg set value {uuid:"",value:80.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function fallendream:lib/mana/pay
execute unless data storage manacore:out r{success:1b} run return 0
scoreboard players add @s zx.mt_paid 1
function fallendream:equipment/staff/magic_theory/fire
