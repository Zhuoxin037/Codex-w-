# ============================================================
# sweetdream:equipment/axe/dream_reader/pet_bind —— 认领一只生物(执行者 = 被认领的生物)
# ------------------------------------------------------------
# 【谁调用它】pet_tick ④b(`at @s as @e[候选] run function ...`, 逐只送进来)
# 【它做什么】
#   ① 打**通用占位标记** zx.dr_claim —— 让"同一刻排在后面的入梦体"挑不到它;
#   ② 把**自己的 UUID** 写进 storage `zx:work bind`, 回传给它那只入梦体抄进 data.zx.tg。
# 【为什么靠 storage 回传】本函数的执行者是"目标", 上下文里查不到"是哪只入梦体把我招来的"
#   (按距离找最近的那只不可靠: 招我的不一定是离我最近的那只)。而 pet_tick 是**逐个**跑的,
#   下一只入梦体会在自己的 pet_tick 开头 `data remove` 掉这个槽, 所以顺序上不会串味。
# 【和 zx.dr_c<id> 那种"带编号标记"的区别】编号标记清不掉(名字动态, core/tick 没法批量 clear),
#   会永久残留在生物身上; 存 uuid 到**入梦体自己**身上则随 marker 消失而消失, 没有残留。
# ============================================================

tag @s add zx.dr_claim
data modify storage zx:work bind set from entity @s UUID
