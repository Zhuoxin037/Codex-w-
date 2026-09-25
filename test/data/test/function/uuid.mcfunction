# 文件: mypack/function/lib/uuid.mcfunction
# 用途: 把"当前执行者"的 uuid 取出来, 存进自己的节点
# 前提: 必须以玩家身份执行 (@s 是那个玩家)

data modify storage test:data self set value {uuid:"",ok:0b}
function manacore:api/player/self_uuid

# 只有拿到非空 uuid 才算成功
# 注意: 空字符串在 NBT 里依然"存在", 所以不能只用 if data, 必须判断它是不是 ""
execute unless data storage manacore:out r{uuid:""} run data modify storage test:data self.uuid set from storage manacore:out r.uuid
execute unless data storage manacore:out r{uuid:""} run data modify storage test:data self.ok set value 1b

