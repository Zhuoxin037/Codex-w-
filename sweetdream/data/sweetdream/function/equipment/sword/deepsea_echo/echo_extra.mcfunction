# ============================================================
# sweetdream:equipment/sword/deepsea_echo/echo_extra —— 【超限】「渊海」免费再重复一次
# ------------------------------------------------------------
# 【宏参数】zx:work de {uuid, ol}   【执行者】施法者
# 【文案】结束后若该技能攻击到了附加了「渊海」的生物则再重复一次, 本次重复
#         不消耗魔力值, 之后该生物不再能触发该被动。
#         之后该技能每攻击到附加了「渊海」的生物都会重复一次。
# 【★ "不再能触发"是**本次技能内**的, 不是永久的 ★】
#   第二句明说"之后该技能**每**攻击到…都会重复一次" —— 如果"不再能触发"是永久
#   的, 那第二句就永远不可能生效。所以 zx.de_spent 只是**这条链**的局部标记,
#   由 finish 清掉, 下次施法重新开始。这样两句都对得上:
#     · 同一次施法里, 一只渊海生物只给你一次免费重复(防无限连锁);
#     · 下次施法它还能再给你一次。
# 【判据】"下一波的源"就是这一波被打到的生物(见 wave_go ⑤), 所以直接看它们
#   里面有没有带「渊海」且本次还没兑现过的。
# ============================================================

# ① 只有超限版有这条
execute unless data storage zx:work de{ol:1b} run return 0

# ② 有"带渊海且本次没兑现过"的吗? 没有就收工
$execute unless entity @e[tag=zx.de_$(uuid),tag=zx.status.yuanhai,tag=!zx.de_spent,limit=1] run return 0

# ③ 这些生物本次已兑现 —— 之后(这条链里)不再触发
$tag @e[tag=zx.de_$(uuid),tag=zx.status.yuanhai,tag=!zx.de_spent] add zx.de_spent

# ④ 免费再来一波: left 抬回 1 + 打上 free(下面 pay_mana 会跳过收费)
$data modify storage zx:data de."$(uuid)".left set value 1
$data modify storage zx:data de."$(uuid)".free set value 1b

# ⑤ 表现: 一声更深的潮涌 + 一圈水花(提示"这是免费追加的那一波")
execute at @s run playsound minecraft:block.conduit.ambient player @a ~ ~ ~ 0.9 0.6
