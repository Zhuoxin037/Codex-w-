# ============================================================
# sweetdream:equipment/tool/nullify/on_second —— 无效: 逐个玩家的每秒判定(取 uuid)
# ------------------------------------------------------------
# 【执行者】玩家本人(由 second 的 `execute as @a at @s` 传入)
# 【为什么要拆成两个文件】
#   下面要用 uuid 拼存储路径 -> 只能靠宏($(uu)); 而"取 uuid"本身是每个玩家各不相同的,
#   必须在 as @a 的循环里做。宏函数又**必须绑定参数**(不绑 = 一条都不跑, 静默),
#   所以这里(非宏)先取好 uuid 写进 zx:work nf, 再把它交给宏函数 on_go。
#   ★ check.py 的 nowith 规则就是抓这个的, 别把两步合回一个文件。
# 【① 为什么不 return】被 @a 广播调用的函数体里必须有 `items entity @s` 判定
#   (check.py 的 equip 规则, 防"没穿也生效"), 但这里**不能就此收工** ——
#   玩家副手没拿「无效」时, 那份"刚召唤过术阵"的标记也必须被清掉,
#   否则他之后再把「无效」拿上手, 会凭空捡到一次 +20%(见 on_go ③)。
#   所以穿着判定写成 0/1 记进 #nf_on, 与 uuid 一起交给 on_go 去决定。
# ============================================================

scoreboard players set #nf_on zx.meta 0
execute if items entity @s weapon.offhand *[minecraft:custom_data~{zx:["nullify"]}] run scoreboard players set #nf_on zx.meta 1

function sweetdream:lib/uuid
data modify storage zx:work nf.uu set from storage zx:data self.uuid
function sweetdream:equipment/tool/nullify/on_go with storage zx:work nf
