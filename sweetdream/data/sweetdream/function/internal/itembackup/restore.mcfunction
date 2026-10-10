# ============================================================
# sweetdream:internal/itembackup/restore —— 从存储快照把武器还回玩家(宏 {uuid,src,dst})
# ------------------------------------------------------------
# 【宏参数】uuid = zx uuid 文本(定位快照键) / src = "mainhand"|"offhand"(取哪份快照)
#           dst = 目标槽位文本("weapon.offhand" | "weapon.mainhand" | "hotbar.<0-8>")
# 【谁调用它】effect_2 的 ①②③ 三条分支(各带自己的 src/dst)
# 【★ O03(2026-10-11)为什么要临时盔甲架 ★】
#   item replace 的**源只能是 block/entity**, 存储里的快照没法直接还到玩家手上。
#   所以: 就地召一个隐形 Marker 架 -> 把快照写进它的主手 -> item replace 还给
#   玩家 -> 杀掉。架子活在玩家脚边(必然已加载), 用完即毁 —— 没有常驻实体、
#   没有强加载依赖、没有"架子找不到了武器消失"这类时序坑。
#   (召唤 NBT 与 data modify equipment.mainhand 的写法先例:
#    station/api/apply_go 的 zx.st_tmp 临时架。)
# 【安全闸】③ 写不进(快照不存在/为空)时, ④ 的 `if items ... *` 判不成立 =>
#   什么都不还 —— 不会把玩家槽位清成空气。这是最后一道保险, 和老版
#   "先检查架子上有没有东西"等价。
# 【为什么还完就删快照】删掉后 recover 的重试不会再"复活"一份; 万一 ④ 的
#   到位判定误判(见 effect_2 ④ 注), 后果仍是"提前放弃", 比刷装备轻。
# ============================================================

# ① 防串味: 先清掉可能残留的临时架(上一个玩家/上一次没杀干净)
kill @e[tag=zx.ret_tmp]

# ② 就地召临时架
execute at @s run summon minecraft:armor_stand ~ ~ ~ {Tags:["zx.ret_tmp"],Marker:1b,Invisible:1b,NoGravity:1b,Invulnerable:1b,Silent:1b,Small:1b}

# ③ 快照 -> 临时架主手
$data modify entity @e[tag=zx.ret_tmp,limit=1] equipment.mainhand set from storage zx:ret p."$(uuid)".$(src)

# ④ 临时架真拿到东西才还(item replace from 空槽 = 把玩家槽位清成空气)
$execute if items entity @e[tag=zx.ret_tmp,limit=1] weapon.mainhand * run item replace entity @s $(dst) from entity @e[tag=zx.ret_tmp,limit=1] weapon.mainhand

# ⑤ 还成功 => 快照使命完成, 删掉(防 recover 重试时"复活"旧快照)
$execute if items entity @e[tag=zx.ret_tmp,limit=1] weapon.mainhand * run data remove storage zx:ret p."$(uuid)".$(src)

# ⑥ 收尾
kill @e[tag=zx.ret_tmp]
