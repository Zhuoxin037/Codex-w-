# ============================================================
# sweetdream:equipment/armor/beach_vein/read_skill —— 读出"主手那把的 skill + 自己的 uuid"
# ------------------------------------------------------------
# 【谁调用它】beach_vein/set_cd（潮线套装）—— 用 `as <施法者>` 送进来
# 【执行者】那个玩家
# 【出参】zx:work tw.uuid / zx:work tw.skill
# 【为什么单独一个文件】set_cd 是**宏函数**(要展开施法者 UUID), 而宏函数里不能
#   再嵌一层需要"实时算出来"的路径拼接 —— 把"读"这一步拆出来, set_cd 只管展开。
# 【★ 先 remove 再 get ★】空手 / 非本包武器时路径不存在, `data modify … set from`
#   是**静默失败**的 —— 不先清掉, 下游会读到上一次残留的技能 id, 于是"空手也能减
#   上一把武器的冷却"（debug/cd_clear 头注释记过这个坑, 同一套处理）。
# ============================================================

data remove storage zx:work tw.skill
data remove storage zx:work tw.uuid

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return 0
data modify storage zx:work tw.uuid set from storage zx:data self.uuid

execute if data entity @s SelectedItem.components."minecraft:custom_data".skill run data modify storage zx:work tw.skill set from entity @s SelectedItem.components."minecraft:custom_data".skill
