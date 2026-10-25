# ============================================================
# sweetdream:equipment/staff/polarized_light/cry_scan —— 本束光的「自己的水晶」扫描
# ------------------------------------------------------------
# 【谁调用它】beam ③ / beam_ol ②(执行者 = 施法玩家, 每束光一次)
# 【出参】#pl_has zx.meta = 1 表示这条光线**可能**要照到水晶, 0 = 完全跳过照射判定
#   zx.ch_mine(计分项) = 1 打在被标出的水晶 marker 上(beam_step 每步只按它筛)
# 【★★ 2026-10-20 第二次卡顿修复: 这是本轮最大的一处开销 ★★】
#   原来 beam_step 里每一**步**(0.4 格)都跑一次:
#     $execute as @e[type=marker,tag=zx.ch_cry,distance=..0.6,
#                    nbt={data:{zx:{ch:{u0:$(u0),…}}}}] run scoreboard ... set
#   三个成本叠在一起:
#     ① **nbt={…} 匹配**要把每个候选 marker 的整份 NBT 序列化成 SNBT 再比子树;
#     ② **一步一次宏调用**(`with storage`)—— 每次都要重新读 storage + 对整份
#        函数体做占位符替换 + 把每行重新解析成命令;
#     ③ 一道光 25~32 步 ⇒ 基础版每刻 ~30 次, 超限三道 ~90 次。
#   现在拆成两层:
#     · 归属判定(唯一需要 NBT 匹配的地方)提到**每束光一次**, 就在这里;
#     · 命中者打成计分项 zx.ch_mine, beam_step 每步只做 `scores={zx.ch_mine=1}`
#       + distance 的小范围筛 —— 不碰 NBT, 也不需要宏。
#   ★ 更关键的是 **#pl_has 闸**: 绝大多数战斗里玩家根本没放共鸣水晶,
#     这时 #pl_has=0, beam_step 连那行选择器都不跑 —— 递归退化成纯粒子循环。
# 【为什么每刻都重扫】水晶只有 8 秒寿命、且会被打掉(crystal_end);
#   5 秒光速期间重扫 5~10 次的开销可以忽略(每束光 1 次 NBT 匹配)。
# ============================================================

# ① 默认: 不照射(#pl_has=0 让 beam_step 整行跳过)
scoreboard players set #pl_has zx.meta 0
scoreboard players set #pl_cry zx.meta 0

# ② 13 格内**有没有**水晶(便宜的 tag 筛选; 没有就到此为止, 后面全部不跑)
execute if entity @e[type=minecraft:marker,tag=zx.ch_cry,distance=..13,limit=1] run scoreboard players set #pl_cry zx.meta 1

# ③ 清上一轮残留的 zx.ch_mine(只在确实有水晶时才遍历一次)
execute if score #pl_cry zx.meta matches 1 run scoreboard players set @e[type=minecraft:marker,scores={zx.ch_mine=1}] zx.ch_mine 0

# ④ 备宏参数(施法者 UUID 四 int; 只有打归属时才需要)
execute if score #pl_cry zx.meta matches 1 run data modify storage zx:work pb set value {u0:0,u1:0,u2:0,u3:0}
execute if score #pl_cry zx.meta matches 1 run data modify storage zx:work pb.u0 set from entity @s UUID[0]
execute if score #pl_cry zx.meta matches 1 run data modify storage zx:work pb.u1 set from entity @s UUID[1]
execute if score #pl_cry zx.meta matches 1 run data modify storage zx:work pb.u2 set from entity @s UUID[2]
execute if score #pl_cry zx.meta matches 1 run data modify storage zx:work pb.u3 set from entity @s UUID[3]

# ⑤ 唯一的 NBT 匹配: 每束光一次(原来每步一次 —— 见头注释)
execute if score #pl_cry zx.meta matches 1 run function sweetdream:equipment/staff/polarized_light/cry_match with storage zx:work pb

# ⑥ 真的命中了"自己人的水晶"才打开照射闸
execute if score #pl_cry zx.meta matches 1 if entity @e[type=minecraft:marker,scores={zx.ch_mine=1},limit=1] run scoreboard players set #pl_has zx.meta 1
