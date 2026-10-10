# ============================================================
# sweetdream:equipment/sword/hengdao/kill_check —— 「这一下有没有把它打死」
# ------------------------------------------------------------
# 【执行者】被打的那一只生物(由 dash_end 用 `as @e[tag=zx.hd_hit]` 逐个切过来)
# 【出参】#hd_k zx.meta = 1 表示"这一波里有东西被打死了"
# 【★ 2026-10-08: 本函数现在是**兜底**, 主判据是 dash_end ⑥ 的人数差 ★】
#   生物死掉之后会被移出实体列表 —— 那时它连 `@e[tag=zx.hd_hit]` 都进不去,
#   所以"谁死了"主要靠打之前/打之后点人数(N1 < N0)来判。
#   这里只补一种情况: 它**还在场上**(死亡动画那几刻)但血已经 <= 0。
# 【为什么不用选择器谓词 nbt={Health:0.0f}】
#   那个写法实测不稳(血量是浮点、且死角同下), 而且"读不到就当死了"的兜底
#   在谓词里根本表达不出来 —— 用计分项先把值置 -1 再读才做得到。
# 【现在的判法】把它的 Health 读出来比:
#   ① 先置 #hd_hp = -1;
#   ② `data get entity @s Health 100` 读不到(实体已被移除)时, store 那行**不执行**,
#      于是保持 -1 —— 这一路也算"死了";
#   ③ 读到了就是血量×100, 活着必然 > 0, 被打死就是 0 ⇒ `matches ..0` 命中。
#   两条路都覆盖, 不依赖"死亡实体还能不能被选择器选中"。
# ============================================================

scoreboard players set #hd_hp zx.meta -1
execute store result score #hd_hp zx.meta run data get entity @s Health 100
execute if score #hd_hp zx.meta matches ..0 run scoreboard players set #hd_k zx.meta 1
