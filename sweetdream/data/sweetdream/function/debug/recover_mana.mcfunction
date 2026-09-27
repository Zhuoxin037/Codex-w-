# ============================================================
# sweetdream:debug/recover_mana —— 把自己的魔力补满(调试用)
# ------------------------------------------------------------
# 【用法】/function sweetdream:debug/recover_mana
# 【原理】api/mana/consume 传负数 = 反向扣 —— #cur - (-1000) = #cur + 1000,
#   最后被夹回 max_mana, 等价于"补满"。比 set 省一步读上限。
# 【为什么第一行要 lib/uuid】下面那句 data modify 是去
#   zx:data self.uuid 里取 UUID 用的, 而 self 只有 lib/uuid 会写。
#   不先取一次的话, 它只能靠"上一个技能残留下来的 UUID"——
#   /reload 之后直接用会因为没有这个路径而报错、整个函数中断。
# ============================================================

# 先拿到自己的 UUID
function sweetdream:lib/uuid
execute unless data storage zx:data self{ok:1b} run return fail

data modify storage manacore:in arg set value {uuid:"",value:-1000.0}
data modify storage manacore:in arg.uuid set from storage zx:data self.uuid
function manacore:api/mana/consume
