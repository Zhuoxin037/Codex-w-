# ============================================================
# 效果二: 施加者基础攻击力 ×2 的**无来源真实伤害**
# ------------------------------------------------------------
# 【执行者】被打中的那只生物
# 【数值从哪来】hurt 第 ③ 步已经算好并转成纯数字字符串, 存在
#   zx:work a.num_str。这里**只补 target 和 type**, 不能整块 set value ——
#   那会把算好的 num_str 一起冲掉。
# 【为什么用 internal/damage/go 而不是 with_from】文案写的是"无来源",
#   go 不补 by <攻击者>, 于是击杀不记在玩家头上(数值一样, 只差死亡提示
#   和经验归属)。with_from 会补 by, 那是另一条路。
# 【为什么用 sweetdream:true_damage】本包注册的伤害类型, 同时进了
#   minecraft:bypasses_armor(真·穿甲)和 minecraft:bypasses_cooldown
#   (不被受伤无敌帧吃掉), 这才叫"真实伤害"。
#   ⚠️ damage_type 是**注册表**内容: 新增/改动后要**退出世界重进**,
#      /reload 不会补(根 README 的已知问题里记过)。
# ============================================================

data modify storage zx:work a.target set value "@s"
data modify storage zx:work a.type set value "sweetdream:true_damage"
function sweetdream:internal/damage/go with storage zx:work a
