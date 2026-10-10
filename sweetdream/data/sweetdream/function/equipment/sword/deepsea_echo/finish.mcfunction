# ============================================================
# sweetdream:equipment/sword/deepsea_echo/finish —— 收尾清理(宏参数 {uuid})
# ------------------------------------------------------------
# 【执行者】施法者
# 【清什么】把这次连锁留下的所有标记和状态全部抹掉, 免得残留:
#   · 生物身上带自己 UUID 的"源"标记
#   · zx:data de."<uuid>" 这条状态
#   · 自己身上"还有链在跑"的标签
#   · 两个临时标签(hit / all)
# 【注意】源标记用 tag @e[tag=...] remove 不带 limit —— 这是"批量摘标签",
#   和 data modify entity 那种只收单实体的命令不一样, 多实体是正常用法。
# ============================================================

$tag @e[tag=zx.de_$(uuid)] remove zx.de_$(uuid)
$execute if data storage zx:data de."$(uuid)" run data remove storage zx:data de."$(uuid)"
tag @s remove zx.de_run
# 倒计时也归零 —— core/tick 是靠 zx.de_run 筛人的, 摘了标签其实已经不看了;
# 归零是为了"万一标签还在"(比如手动补过), 也不会立刻又推进一波。
scoreboard players set @s zx.de_t 0
tag @e[tag=zx.de_hit] remove zx.de_hit
tag @e[tag=zx.de_all] remove zx.de_all
# 【超限】"本次已兑现过渊海加成"的生物标记 —— 它是**这条链内**的局部标记,
#   链一结束就清掉, 下次施法重新开始(见 echo_extra 的注释: 不这么做的话
#   文案第二句"之后该技能每攻击到…都会重复一次"就永远不可能生效)。
tag @e[tag=zx.de_spent] remove zx.de_spent

# 收尾音: 潮涌核心关闭的那一声(和起手那声是一对)
execute at @s run playsound minecraft:block.conduit.deactivate player @a ~ ~ ~ 0.7 1.2
