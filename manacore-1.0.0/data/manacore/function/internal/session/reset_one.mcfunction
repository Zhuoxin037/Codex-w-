# ------------------------------------------------------------
# internal/session/reset_one —— 会话标记清零
# 【宏参数】manacore:work.a {uuid}
# 【用途】core/load 时以 ctrl.mode="reset_session" 遍历索引调用它,
#         让所有在线玩家在下一次秒检查时重新注册(reload 后自愈)。
# ------------------------------------------------------------
$execute if data storage manacore:players "$(uuid)" run data modify storage manacore:players "$(uuid)".session set value 0b
