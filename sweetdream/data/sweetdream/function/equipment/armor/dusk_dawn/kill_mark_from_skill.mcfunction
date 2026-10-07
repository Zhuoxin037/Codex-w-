# ============================================================
# sweetdream:equipment/armor/dusk_dawn/kill_mark_from_skill —— 技能击杀这条路的入口(宏)
# ------------------------------------------------------------
# 【宏参数】zx:work a {u0,u1,u2,u3} = 攻击者的 UUID 四个整数
# 【执行者】刚被打死的那只生物(伤害接口打完发现它死了、而且它带标签)
# 【做什么】拿 UUID 反查出攻击者, 把这笔账记到他头上(kill_mark_go)。
#   这样"技能打死的带标签生物"一定算数, 不用赌进度条件的写法。
# 【★ 先数 X 再切身份 ★】超限版要"100×X（X 为死者身上的效果数量）", 而本函数
#   进来时 @s **就是那只死者** —— 这是唯一能直接数它的时机, 切到玩家之后就没了。
# ============================================================

$execute unless entity @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] run return 0
function sweetdream:equipment/armor/dusk_dawn/kill_count
$execute as @a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]},limit=1] run function sweetdream:equipment/armor/dusk_dawn/kill_mark_go
