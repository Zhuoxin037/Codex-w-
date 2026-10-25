# ============================================================
# sweetdream:equipment/sword/gousi/ol_buff_miss —— 超限·钩丝: 没拉到的加成(执行者 = 施法者)
# ------------------------------------------------------------
# 【文案】"若中途未能拉到…且使自身下一次技能伤害 +10%"
# 【★ 次数只补到 1, 而且永不降级 ★】手上已经挂着"三次"(刚拉满)的时候又有一只脱钩,
#   把它改成 1 次等于倒扣两次 —— 那不是文案的意思(它只说"并使…+10%")。
#   所以用 `matches ..0` 门控: 0 次才设成 1, 已经是 1/3 次的不动。
# 【百分点照样 +10】"下一次技能伤害 +10%" 是又一层, 与已有的层相加(封顶 30)。
# ============================================================

scoreboard players add @s zx.gs3p 10
execute if score @s zx.gs3p matches 31.. run scoreboard players set @s zx.gs3p 30
execute if score @s zx.gs3n matches ..0 run scoreboard players set @s zx.gs3n 1
