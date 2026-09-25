# ============================================================
# sweetdream:api/effect —— 给目标施加状态效果(公开接口)
# ------------------------------------------------------------
# 【调用模板】
#   data modify storage zx:in arg set value {target:"@e[type=!#sweetdream:no_damage,distance=..3]", effect:"minecraft:instant_damage", duration:1}
#   function sweetdream:api/effect
#   /data get storage zx:out r.applied
# 【入参】
#   target    : 选择器字符串(必填)
#   effect    : 效果 ID, 默认 minecraft:instant_damage
#   duration  : 秒数, 默认 1; 永久填 "infinite"
#   amplifier : 等级, 默认 0
#   hide      : 是否隐藏粒子, 默认 "false"
# 【duration 是字符串还是数字都行】宏会把它渲染成文本再拼进命令,
#   所以 1 和 "infinite" 两种写法都能直接过。
# ============================================================

data modify storage zx:work a set value {target:"",effect:"minecraft:instant_damage",duration:1,amplifier:0,hide:"false"}
data modify storage zx:work a merge from storage zx:in arg

data modify storage zx:out r.applied set value 0b
execute unless data storage zx:work a{target:""} run function sweetdream:internal/effect/go with storage zx:work a
