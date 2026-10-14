# 宏参数来自玩家 self.uuid；只写这个 UUID 主人的 marker。
$data modify entity @e[type=minecraft:marker,tag=zx.el_wisp,nbt={data:{zx:{el:{uu:"$(uuid)"}}}},distance=0..,limit=1] data.zx.el.x set from storage zx:elvis target[0]
$data modify entity @e[type=minecraft:marker,tag=zx.el_wisp,nbt={data:{zx:{el:{uu:"$(uuid)"}}}},distance=0..,limit=1] data.zx.el.y set from storage zx:elvis target[1]
$data modify entity @e[type=minecraft:marker,tag=zx.el_wisp,nbt={data:{zx:{el:{uu:"$(uuid)"}}}},distance=0..,limit=1] data.zx.el.z set from storage zx:elvis target[2]
