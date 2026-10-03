# 文件: sweetdream/function/lib/uuid.mcfunction
# 用途: 把"当前执行者"的 uuid 取出来, 存进自己的节点
# 前提: 必须以玩家身份执行 (@s 是那个玩家)
#
# 【出参】zx:data self = {uuid:"<uuid 文本>", ok:1b}
#   没拿到时 = {uuid:"", ok:0b} —— 调用方用 `if data storage zx:data self{ok:1b}` 判断
#
# 【★ 为什么 ok 要单独判一次 ★】
#   前置包的 api/player/self_uuid 在"没拿到"时会写 r.uuid = ""(空串),
#   但也可能**压根没写 r.uuid 这个键**。第一版只判了 "r.uuid 是不是空串":
#     源路径不存在 -> `unless ... r{uuid:""}` 成立 -> 去 copy 失败(uuid 仍是 "")
#     -> 但下面那句 set ok=1b 却成功了
#   于是变成 **uuid 是空的、ok 却是 1** 的诡异状态: 守卫放行, 后面按
#   `manacore:players.""` 拼路径 -> 宏展开直接炸, 整个宏函数一条命令都不跑,
#   而且一个字都不报(2026-10-03 stats/wind/diff 三个入口全中)。
#   现在 ok 直接由"uuid 到底有没有值"决定, 那种状态不可能再出现。
# ============================================================

data modify storage zx:data self set value {uuid:"",ok:0b}
function manacore:api/player/self_uuid

# ① 先真把 uuid 拷回来(源键不存在 / 是空串, 这句话都会失败, uuid 保持 "")
execute if data storage manacore:out r.uuid unless data storage manacore:out r{uuid:""} run data modify storage zx:data self.uuid set from storage manacore:out r.uuid

# ② ok 只看结果: 拷回来了才算成功
execute if data storage zx:data self.uuid unless data storage zx:data self{uuid:""} run data modify storage zx:data self.ok set value 1b
