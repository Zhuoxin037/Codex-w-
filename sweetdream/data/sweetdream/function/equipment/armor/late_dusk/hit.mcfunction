# ============================================================
# sweetdream:equipment/armor/late_dusk/hit —— 受害者侧入口: 谁会消耗「回光」
# ------------------------------------------------------------
# 【谁调用它】internal/damage/one（受击侧, @s = 挨打的生物, 已确认带着「白昼梦」）
# 【宏参数】zx:work ob 的 u0..u3 = **攻击者**的 UUID（who 的反查输入）
# 【★ 为什么要反查攻击者 ★】"消耗回光"是**攻击者身上**的资源; 而这一层只知道
#   挨打的是谁 ⇒ 必须把动手的人找出来, 再判他穿没穿迟暮。
# 【★ 为什么先打 zx.ld_v 标签 ★】换成攻击者身份之后, 就找不到受害者了;
#   本函数返回时标签要摘干净（one 后面还有别的段要用 @s）。
# ============================================================

# ① 反查攻击者（零 NBT: 4 个整数比较, 见 internal/damage/who 头注释）
#   ★ 这里刻意**只**用宏参数 $(u0)..$(u3) 读 ob, 不写 `data get storage zx:work ob.uN`
#     —— ob 是 internal/damage 专用基准节点, 别的函数去读会被 check 的 obnode 规则拦。
#   ★ 同时把归属抄进自己的节点 zx:work ld, 供后面的 rec_open 用（它没有宏参数）。
$data modify storage zx:work ld set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
data modify storage zx:work who set from storage zx:work ld
function sweetdream:internal/damage/who

# ② 有归属（攻击者是玩家）⇒ 先给受害者打个临时标签, 再切到攻击者身上判装备
tag @s add zx.ld_v
execute as @a[tag=zx.d_by] if items entity @s armor.legs *[minecraft:custom_data~{zx:["late_dusk"]}] run function sweetdream:equipment/armor/late_dusk/consume
tag @s remove zx.ld_v
tag @a[tag=zx.d_by] remove zx.d_by
