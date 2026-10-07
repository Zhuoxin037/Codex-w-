# ============================================================
# sweetdream:debug/form_add —— 给自己 +1 个术阵(调试用)
# ------------------------------------------------------------
# 【用法】/function sweetdream:debug/form_add      (以玩家身份执行)
#   菜单里也有: /trigger zx.dbg_menu -> 「自己的术阵 +1」
# 【干什么】用前置包的 api/formation/create 在自己名下登记一个**空术阵**:
#   只占一个位子, 不生成实体 / 不放粒子 / 不打伤害 —— 纯粹给"看数量"的效果当靶子
#   (比如共振: 术阵越多伤害越高, 想验它的倍率就得有个办法改数量)。
# 【为什么不设时长】duration 传 0 = 框架语义的"永久术阵"(不写 end 字段, 不会自己
#   到点消失)。调试时最烦的就是数着数着它没了 —— 想摘掉就用 form_del(-1 那条)。
#   ⚠️ 代价: 忘了摘会一直占着术阵上限(默认 3), 真技能就召不出来了。
# 【上限】受你自己 stats.formation_limit 约束(默认 3); 满了会建失败并告诉你几 / 几。
# ============================================================

function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run tellraw @s [{"text":"还没注册完成(uuid 是空的), 等一秒再试","color":"red"}]
execute unless data storage zx:data self{ok:1b} run return fail

# 宏参数一律先抄进 zx:work 再传(直接传 zx:data self 会让宏函数一条命令都不跑)
data modify storage zx:work fm set value {uuid:"",i:0}
data modify storage zx:work fm.uuid set from storage zx:data self.uuid

# ① 找第一个空槽位(结果进 #fm_slot; -1 = 八个槽都有东西)
function sweetdream:debug/form_pick_free with storage zx:work fm
execute if score #fm_slot zx.meta matches -1 run tellraw @s [{"text":"[术阵] 八个槽位全满了, 加不进去","color":"red"}]
execute if score #fm_slot zx.meta matches -1 run return 0

# ② 真的建(槽号进宏, 顺便当 id 的后缀 —— 同一个槽位不可能建进去两次)
execute store result storage zx:work fm.i int 1 run scoreboard players get #fm_slot zx.meta
function sweetdream:debug/form_add_go with storage zx:work fm
