# ------------------------------------------------------------
# internal/cooldown/reduce_sec —— reduce 的秒 -> tick 换算
# 【★ 只负责"换算", 不负责"减" ★】
#   本函数把 #amt 从"秒"换成"刻"(x20) 之后**就结束**, 不调用 reduce_body ——
#   减冷却由 internal/cooldown/reduce 末尾**唯一的那一处** reduce_body 完成。
#   ★★ 2026-10-08 事故(必读) ★★
#     原来这里的最后一行是 `if #amt matches 1.. run reduce_body`。
#     调用方 internal/cooldown/reduce 是两条"互补守卫":
#         if #amt matches ..0  run reduce_sec     ← 借调本函数
#         if #amt matches 1..  run reduce_body
#     而 #amt 是**同一个计分项**(共享变量)。本函数把 #amt 改写成 秒x20(=100/200) 之后,
#     回到调用方, 第二条守卫读到的已经是**被改写过的值** -> 条件成立 -> reduce_body **再减一遍**。
#     ⇒ 凡是以 {seconds:...} 传参的减冷却, 实际都减了 **2 倍**:
#         调色盘 蓝(-5 秒 -> 实减 10 秒)、风帆 再次使用(3 秒 -> 6 秒)、
#         息影(10 秒 -> 20 秒)、冷却剂Ω / 魔力沸涌(每秒 1 秒 -> 2 秒)。
#     【为什么会这样写】那两条守卫的本意是"ticks 优先, ticks<=0 时才用 seconds",
#       但把"判定变量"和"被分支改写的变量"用了同一个名字 —— 守卫自己把自己顶翻了。
#     【修法】把 *_sec 降级为纯换算, 让 *_body 只剩一个调用点(见 reduce.mcfunction);
#       这样"谁减了几遍"变成一眼可数, 不再依赖两条守卫的先后。
#     【同款】internal/cooldown/increase_sec(增冷却镜像, 已同批修)。
# ------------------------------------------------------------
execute store result score #amt manacore.math run data get storage manacore:work a.seconds 20
