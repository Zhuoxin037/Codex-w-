# ------------------------------------------------------------
# internal/cooldown/increase_sec —— increase 的秒 -> tick 换算
# 【★ 只负责"换算", 不负责"增" ★】理由与修法见 reduce_sec 头部的事故说明(2026-10-08):
#   原来这里也调了一次 increase_body, 而调用方的第二条守卫读的又是被本函数改写过的 #amt,
#   ⇒ 以 {seconds:...} 传参的"增冷却"同样会加 **2 倍**。现在 increase_body 在调用方
#   (internal/cooldown/increase) 末尾只剩**一个**调用点。
# ------------------------------------------------------------
execute store result score #amt manacore.math run data get storage manacore:work a.seconds 20
