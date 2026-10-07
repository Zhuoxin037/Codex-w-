# ============================================================
# sweetdream:equipment/axe/skyvault/aoe —— 冲击伤害的宏层
# ------------------------------------------------------------
# 【宏参数】zx:work sv {tag}   【执行者】施法者
#   tag = 目标选择器字符串(这里就是半径 5 内全体 "@e[tag=zx.sv_aoe]")
# 【通道】max_mana_mul(基数 = 面板最大魔力)
# 【★ 每层「升痕」的 +5% 不在这里算 ★】那部分改走公共加伤钩子
#   internal/damage/stg_mul(按**每个目标自己**的层数、且要求"来自更高处"),
#   所以这里只要打一遍全体就行 —— 不再按层数分组。
# 【加成】2026-10-07 起「风声」并入 mm 通道的通用加成(风声 / 忘川彼岸 / 无效),
#   由 lib/mm_add/hook_calc 挂在 damage_calc 事件里统一折进加算池 —— 所以这里
#   不需要再也自己调一行(旧版那句 lib/max_mana_bonus 已删)。
# 【⚠️ 必须 with storage zx:work sv 调用】传 zx:data self 会让宏函数一条都不跑(静默)。
# ============================================================

$execute if entity $(tag) run data modify storage manacore:in arg set value {uuid:"",max_mana_mul:0.12}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
$execute if entity $(tag) run function manacore:api/damage/calc
$execute if entity $(tag) run data modify storage zx:in arg set value {target:"$(tag)",read:"manacore"}
$execute if entity $(tag) run function sweetdream:api/damage
