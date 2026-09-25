# ============================================================
# test:itemreplace_effect_1 —— 消耗触发: 把武器从盔甲架拿回手上
# ------------------------------------------------------------
# 【触发】进度 test:itemreplace(consume_item) 的 rewards
# 【流程】撤进度 -> 取自己的 UUID -> 交给宏函数执行 item replace
# 【这里删掉了什么】原来有一行:
#     schedule function test:a_test 1t
#   包里根本没有 test:a_test 这个函数, 而 /schedule 遇到不存在的函数会
#   直接报错, 报错会【中断当前函数】—— 于是紧跟其后的"回手"那一行
#   永远执行不到。这就是"消耗之后没有回手"的直接原因。
#   而且那行即使能跑也和回手无关: 回手是下一行直接调用的, 不经过 schedule。
# 【真想延迟 1 tick 再回手】不能直接 schedule 一个宏函数(它既没有 @s
#   也没有宏参数)。正确做法是 schedule 一个普通函数, 由它在那之后再
#   按 uuid 把玩家找回来、再调这个宏函数(见教程第 9.3 节)。
# ============================================================

advancement revoke @s only test:itemreplace
function test:uuid
execute unless data storage test:data self{ok:1b} run return fail
schedule function test:a_test 1t
data modify storage test:work a.uuid set from storage test:data self.uuid
function test:itemreplace_effect_2 with storage test:work a
