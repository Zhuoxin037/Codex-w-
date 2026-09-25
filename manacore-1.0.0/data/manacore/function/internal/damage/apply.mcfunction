# ============================================================
# internal/damage/apply —— 把伤害真正打出去
# ------------------------------------------------------------
# 【宏参数】manacore:work.a {uuid,target,type,damage}(from 可选)
#   target : 目标选择器字符串, 例如 "@e[tag=mana_target,distance=..8]"
#   type   : 伤害类型(默认 minecraft:magic, 可绕过护甲)
#   from   : 攻击者选择器, 省略则自动推导(见 from_auto)
# 【为什么要先把数字变成字符串】宏替换会把 double 渲染成 "37.5d",
#   而 /damage 的参数解析器不认 d 后缀。所以先用 lib/num/plain 把
#   "37.5d" 切成 "37.5" 存成字符串 num_str, 再让宏替换进命令里。
# 【命令形态】damage <目标> <数值> <类型> by <攻击者>
#   用的是 1.20.5+ 的 /damage, 能精确指定数值与伤害类型, 远比老办法
#   (造成伤害/瞬间伤害药水)可控。
# ============================================================
execute if data storage manacore:work a.damage run data modify storage manacore:work a.num set from storage manacore:work a.damage
execute unless data storage manacore:work a.damage run data modify storage manacore:work a.num set value 0.0
function manacore:lib/num/plain
execute if data storage manacore:work a.from run function manacore:internal/damage/apply_go with storage manacore:work a
execute unless data storage manacore:work a.from run function manacore:internal/damage/from_auto with storage manacore:work a
