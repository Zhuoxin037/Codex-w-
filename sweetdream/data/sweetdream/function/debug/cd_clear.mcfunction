# ============================================================
# sweetdream:debug/cd_clear —— 立刻结束"主手武器"当前的技能冷却
# ------------------------------------------------------------
# 【用法】/function sweetdream:debug/cd_clear
#         或 /trigger zx.dbg_cd
# 【清的是哪一个】主手那把武器**自己身上**带着 custom_data.skill(冷却就是以
#   这个 id 为键存的), 所以不用手填技能名 —— 拿着哪把就清哪把。
#   手里不是本包武器(空手 / 方块 / 别的东西)时没有这个字段, 会直接告诉你。
# 【为什么拆成两层】冷却的键是"<uuid> + <skill>"拼出来的动态路径, 而宏变量
#   在**调用那一刻**就固定了。所以必须先读出来, 再调一次带宏的函数。
# 【它是只读+清冷却】不动别的数据。
# ============================================================

# ① 拿 uuid(下面要把 uuid 和 skill 一起当宏参数传下去)
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run tellraw @s [{"text":"[调试] 你还没注册完成(uuid 是空的) —— 等一秒再试","color":"red"}]
execute unless data storage zx:data self{ok:1b} run return fail

# ② 读主手物品的 skill 字段
#   【为什么要先 remove】空手 / 别的道具时上面那句 data get 会失败, 路径
#     不存在, 而 data modify 失败是**静默**的 —— 不先清掉, 下游会读到上一次
#     残留的技能 id, 于是"空手按一下"也能把上一把武器的冷却清掉。
data remove storage zx:work cd.skill
execute if data entity @s SelectedItem.components."minecraft:custom_data".skill run data modify storage zx:work cd.skill set from entity @s SelectedItem.components."minecraft:custom_data".skill

execute unless data storage zx:work cd.skill run tellraw @s [{"text":"[调试] 主手不是本包武器(读不到 skill) —— 拿着要清冷却的那把再按一次","color":"red"}]
execute unless data storage zx:work cd.skill run return 0

# ③ 交给宏层去清
data modify storage zx:work cd.uuid set from storage zx:data self.uuid
function sweetdream:debug/cd_clear_go with storage zx:work cd
