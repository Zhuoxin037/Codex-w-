# ============================================================
# sweetdream:internal/itembackup/restore —— 把【队首】那件武器还回玩家指定槽(宏 {uuid,dst})
# ------------------------------------------------------------
# 【宏参数】uuid = zx uuid 文本(定位存储键)
#           dst  = 目标槽位文本("weapon.offhand" | "hotbar.<0-8>" | "inventory.<0-26>")
# 【取哪件】zx:ret p."<uuid>".q[0].item —— **队首**那一件(不是"按 src 读固定快照")。
# 【谁调用它】effect_2 的首选槽/兜底扫描各行(各带自己的 dst)
# 【★ 三条铁律(N08, 2026-10-11)★】
#   ① 【绝不覆盖】只在 `dst 为空` 时才写 —— item replace 是覆盖式的, 不判空就会
#      把玩家当前放在那一格的另一件物品**直接吃掉**(不落地、找不回)。这是 N08 的根。
#   ② 【落地才算数】置 #ret_ok=1 只有"临时架真拿到货 **且** 目标槽为空 **且** 已写回"。
#      不靠"看到任意 itemreplace 物品"(旧写法会把"目标格本来就有另一件 itemreplace
#      物品"误判成成功 ⇒ 提前放弃 ⇒ 武器留在外面丢失)。
#   ③ 【失败=保留】dst 被占 / 快照缺失 => 什么都不写、#ret_ok 留 0 => 交给 recover
#      每秒重试。最坏 = 降级成"继续等待", 永远不会变成"武器/被覆盖物消失"。
# 【★ 本文件**不出队、不销账** ★】出队是 effect_2 的活(它还要据"出没出队"重算
#   队首镜像 zx.ret_slot / 清 zx.ret_pend)。本文件只负责"写这一格 + 置标志"。
# ------------------------------------------------------------
# 【★ O03(2026-10-11)为什么要临时盔甲架 ★】
#   item replace 的**源只能是 block/entity**, 存储里的快照没法直接还到玩家手上。
#   所以: 就地召一个隐形 Marker 架 -> 把快照写进它的主手 -> item replace 还给
#   玩家 -> 杀掉。架子活在玩家脚边(必然已加载), 用完即毁 —— 没有常驻实体、
#   没有强加载依赖、没有"架子找不到了武器消失"这类时序坑。
#   (召唤 NBT 与 data modify equipment.mainhand 的写法先例:
#    station/api/apply_go 的 zx.st_tmp 临时架。)
# 【★ 判空写法(实测定案, 全包禁止 `items … air`): 空槽不是物品栈, 任何物品谓词
#   都匹配不到它 ⇒ 判空只能用 `unless items … *`。check.py `airpred` 规则守着。】
# ============================================================

# ① 防串味: 先清掉可能残留的临时架(上一个玩家/上一次没杀干净)
kill @e[tag=zx.ret_tmp]

# ② 就地召临时架
execute at @s run summon minecraft:armor_stand ~ ~ ~ {Tags:["zx.ret_tmp"],Marker:1b,Invisible:1b,NoGravity:1b,Invulnerable:1b,Silent:1b,Small:1b}

# ③ 队首那件武器 -> 临时架主手
$data modify entity @e[tag=zx.ret_tmp,limit=1] equipment.mainhand set from storage zx:ret p."$(uuid)".q[0].item

# ④ 安全闸: "临时架真拿到东西 且 目标槽为空" => 置落地标志 #ret_ok = 1(否则 0)
#    ★ 不判空就 item replace = 把玩家放在那一格的另一件物品直接吃掉(N08)。
#    ★ #ret_ok 是 zx.meta 上的假玩家(不用新建 objective); 本行先归零。
scoreboard players set #ret_ok zx.meta 0
$execute if items entity @e[tag=zx.ret_tmp,limit=1] weapon.mainhand * unless items entity @s $(dst) * run scoreboard players set #ret_ok zx.meta 1

# ⑤ 落地: 写回玩家目标槽(绝不覆盖非空槽)
$execute if score #ret_ok zx.meta matches 1 run item replace entity @s $(dst) from entity @e[tag=zx.ret_tmp,limit=1] weapon.mainhand

# ⑥ 收尾
kill @e[tag=zx.ret_tmp]
