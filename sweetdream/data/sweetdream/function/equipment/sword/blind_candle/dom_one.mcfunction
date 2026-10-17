# ============================================================
# sweetdream:equipment/sword/blind_candle/dom_one —— 消耗最近那只的「夜火」+ 给自己「烛火」
# ------------------------------------------------------------
# 【谁调用它】cast ⑧   【执行者】**施法者本人**   【位置】他所在处
# 【目标】zx.bcd_src = 本轮命中者里就近挑中的那一个带「夜火」的
# 【★ 身份绝不能换 ★】消耗走统一入口 lib/mark_consume; 余烬只认 **@s**(消耗者),
#   by 默认也是 @s。一旦 `as <目标>`, 余烬就认错人。目标只写成选择器字符串。
#   ★ 而且 ④ 要给**自己**上烛火 —— @s 必须一直是玩家。
# 【★ 只有真的摘掉才给烛火 ★】
#   · ok   = 它身上真有夜火(防"选完到消耗之间被别的效果摘掉")。
#   · done = 穿「永恒」时把标签**补回来**了 = 没消耗掉 -> 不该给烛火。
#   两个字段都由 lib/mark_consume / mark_take 写。
# 【烛火怎么记】绝对到期刻: zx.bcd_cd = 当前刻 + 160(= 8 秒 × 20 刻)。
#   判定写 `if score @s zx.bcd_cd > #now` —— 过期自然失配, 不需要每秒递减,
#   也就不必碰 lib/second。死亡/重生由 event/player_reset 统一清零。
# ============================================================

# ① 消耗它的「夜火」(执行者/身份仍是施法者本人)
data modify storage zx:work a set value {target:"@e[tag=zx.bcd_src,distance=0..,limit=1]",mark:"yehuo"}
function sweetdream:lib/mark_consume

# ② 它身上本来就没有 -> 收工
execute unless data storage zx:work mc{ok:1b} run return 0
# ③ 被「永恒」补回来了 = 没真的消耗 -> 不给烛火
execute if data storage zx:work mc{done:1b} run return 0

# ④ 给自己「烛火」8 秒(= 160 刻后到期)
scoreboard players operation @s zx.bcd_cd = #now manacore.meta
scoreboard players add @s zx.bcd_cd 160

# ⑤ 表现 + 提示
particle minecraft:flame ~ ~1 ~ 0.5 0.6 0.5 0.01 24 normal
particle minecraft:small_flame ~ ~1 ~ 0.4 0.5 0.4 0.02 16 normal
playsound minecraft:block.fire.extinguish player @a ~ ~ ~ 0.7 0.6
tellraw @s [{"text":"烛火燃起（8 秒）","color":"gold"}]
