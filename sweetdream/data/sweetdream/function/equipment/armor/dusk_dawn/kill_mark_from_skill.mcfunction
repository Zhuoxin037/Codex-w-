# ============================================================
# sweetdream:equipment/armor/dusk_dawn/kill_mark_from_skill —— 技能击杀这条路的入口(宏)
# ------------------------------------------------------------
# 【宏参数】zx:work a {u0,u1,u2,u3} = 攻击者的 UUID 四个整数
# 【执行者】刚被打死的那只生物(伤害接口打完发现它死了、而且它带标签)
# 【做什么】拿 UUID 反查出攻击者, 把 +100 记到他头上(kill_mark_go)。
#   这样"技能打死的带标签生物"一定算数, 不用赌进度条件的写法。
# ============================================================

$execute unless entity @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] run return 0
$execute as @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] run function sweetdream:equipment/armor/dusk_dawn/kill_mark_go
