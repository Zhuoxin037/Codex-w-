# ============================================================
# sweetdream:equipment/bow/cold_crow/hook_victim —— 附魔回调: 记下被打中的那只 + 结算
# ------------------------------------------------------------
# 【谁调它】附魔「霜矢」的 post_attack, affected = victim(被打中的生物)
# 【执行者】被打中的那只生物
# 【四件事】
#   ① 把自己标成 zx.cc_v(先清干净再标, 保证只有一个)
#   ② 找射手: 优先用 hook_attacker 标的 zx.cc_pl; 没标上就退回"离受害者最近的玩家"
#   ③ 找"这一发是哪支箭"(逐箭快照的钥匙, 见下)
#   ④ 交给 apply 读快照并结算
# 【为什么排除玩家】范围选择器一直排除玩家; 万一原版把玩家也算成 victim, 别把玩家当受害者。
# 【★ 怎么找到"这一发的那支箭" ★】
#   ① 首选 hook_arrow 标的 zx.cc_arr —— 那是原版直接告诉我们的 damaging_entity,
#      精确无误。
#   ② 万一没标上(效果表顺序变了 / 这次是近战), 就从**受害者自己**身上就近找一支
#      "带快照的箭"(data.zx.cc 存在)。箭刚命中就贴着受害者, 所以"最近的"基本
#      就是它; 而"带快照"这个条件把地上插着的老箭排除掉了 —— 老箭身上没有
#      data.zx.cc, 不会来抢。
#   ③ 还是找不到 -> cc.arrow 指向一个匹配不到的选择器, snap_prep 会跳过它,
#      退回用"射手最近一发"。不会报错, 只是退化成旧行为。
# ============================================================

tag @e[tag=zx.cc_v] remove zx.cc_v
execute unless entity @s[type=minecraft:player] run tag @s add zx.cc_v
execute unless entity @e[tag=zx.cc_v,limit=1] run return 0

data modify storage zx:work cc.target set value "@e[tag=zx.cc_v,limit=1]"
data modify storage zx:work cc.shooter set value "@a[tag=zx.cc_pl,limit=1]"
execute unless entity @a[tag=zx.cc_pl,limit=1] run data modify storage zx:work cc.shooter set value "@p"

execute unless entity @e[tag=zx.cc_arr,limit=1] as @e[type=#sweetdream:cc_arrow,distance=..3,sort=nearest,limit=1] if data entity @s data.zx.cc{ok:1b} run tag @s add zx.cc_arr
data modify storage zx:work cc.arrow set value "@e[tag=zx.cc_arr,limit=1]"

function sweetdream:equipment/bow/cold_crow/apply with storage zx:work cc
