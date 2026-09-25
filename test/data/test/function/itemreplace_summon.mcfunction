# ============================================================
# test:itemreplace_summon —— 召唤一个"名字是自己的 UUID"的盔甲架
# ------------------------------------------------------------
# 【用法】以玩家身份执行: /function test:itemreplace_summon
# 【注意: 它是每刻都在跑的】test:main_itemreplace 这个进度的触发器是 "tick",
#   而函数第一行会把它撤销掉, 于是下一 tick 又会被授予 —— 这是"用进度做每刻
#   循环"的经典写法。所以本函数里【不要】写 tellraw 之类的反馈, 会每刻刷屏。
# 【流程】撤进度 -> 取自己的 UUID -> 交给宏函数做"查重 + 召唤"
# 【为什么不能直接写 {"nbt":"uuid","storage":"test:data"}】
#   那种写法属于"文本组件", 只在【服务器】渲染文字时才会去读存储
#   (tellraw / title / bossbar 之类)。而实体名字是发给【客户端】渲染的,
#   客户端读不到服务器上的命令存储, 所以它永远不会显示成你的 UUID。
#   想让动态值进 NBT, 只能在召唤这一刻用宏把它"烤"成字面量。
#   另外原写法里 CustomName 写成了 [{...}] 列表, 那也不是 CustomName 要的形状。
# ============================================================

# 允许进度 test:main_itemreplace 再次触发
advancement revoke @s only test:main_itemreplace

# ① 拿到自己的 UUID(进服约 1 秒后才会注册完成)
#    拿不到就安静跳过(进服头一秒会走到这里, 不要在这里发消息)
function test:uuid
execute unless data storage test:data self{ok:1b} run return fail

# ② 把 UUID 写进宏节点, 再由宏函数负责查重和召唤
#    宏变量写在"被调用的那个函数"里, 所以这里要用 with storage 把参数传过去
data modify storage test:work a.uuid set from storage test:data self.uuid
function test:internal/summon_named_stand with storage test:work a
