# ============================================================
# sweetdream:equipment/staff/final_revelation/beam_new —— 生成一根光柱实体
# ------------------------------------------------------------
# 【谁调用它】beam_go ③ —— "我"名下没有光柱时(第一次放 / 旧的没了)
# 【执行者】施法玩家
# 【生成点】眼睛下 0.12、视线前方 8 格 = 16 格长光条的中点。
# 【脸前法阵】模型 z=0.55 对应脸前 0.55 格，中心在眼下 0.12 格；直径 2 格。
#   旧偏置 0.45 收至 0.12，使发射位置贴近脸部；判定 scan 不随外观移动。
# 【为什么 scale 是 [1,1,16]】模型 fr_beam 的条子沿 model Z 轴铺 0..16px,
#   display 上以实体位置为中心 ⇒ 16px=1 格 × z scale 16 = 前后各 8 格。
#   x/y 的粗细直接在模型里画(外辉 12px=0.75 格 / 亮核 6px=0.375), 不用 scale 放大,
#   免得壳的厚度跟着 z 一起变形。
#   ★ 贴图是"四边渐隐"的软边图(见 _gen_fr_beam.py) —— 两端自然收细, 不是平头的棍子。
# 【归属】UUID 四 int 写进 data.zx.fr(照抄 styx_walk/sea_spawn) ——
#   玩家那边不存任何东西, 全靠实体自己记住主人。
# 【亮度】sky/block 全 15: 贴图本身不发光, 不拉满就是灰白而不是"圣光白"。
# ============================================================

execute at @s anchored eyes positioned ^ ^-0.12 ^8 run summon minecraft:item_display ~ ~ ~ {Tags:["zx.fr_beam","zx.fr_beam_new"],item:{id:"minecraft:stick",count:1,components:{"minecraft:item_model":"sweetdream:fr_beam"}},brightness:{sky:15,block:15},interpolation_duration:0,transformation:{translation:[0.0f,0.0f,0.0f],scale:[1.0f,1.0f,16.0f],left_rotation:[0.0f,0.0f,0.0f,1.0f],right_rotation:[0.0f,0.0f,0.0f,1.0f]}}
execute at @s anchored eyes positioned ^ ^-0.12 ^8 run tp @n[type=minecraft:item_display,tag=zx.fr_beam_new] ~ ~ ~ ~ ~

# 归属 + 初始寿命
data modify entity @n[limit=1,tag=zx.fr_beam_new] data.zx.fr set value {u0:0,u1:0,u2:0,u3:0}
data modify entity @n[limit=1,tag=zx.fr_beam_new] data.zx.fr.u0 set from entity @s UUID[0]
data modify entity @n[limit=1,tag=zx.fr_beam_new] data.zx.fr.u1 set from entity @s UUID[1]
data modify entity @n[limit=1,tag=zx.fr_beam_new] data.zx.fr.u2 set from entity @s UUID[2]
data modify entity @n[limit=1,tag=zx.fr_beam_new] data.zx.fr.u3 set from entity @s UUID[3]
scoreboard players set @n[limit=1,tag=zx.fr_beam_new] zx.fr_ref 3
tag @n[limit=1,tag=zx.fr_beam_new] remove zx.fr_beam_new

# 【音效 2026-10-08 新增】光条成形的那一下。
#   ★ 与天使核心圣光柱用**同一套"三层"口径**(亮片 + 力量感 + 低频托底) ——
#     两件装备的"光"听起来才像一家人的(用户 2026-10-08: "音效没有啥感觉, 没力气")。
#   ★ 位置定在**光条前段**(前方 4 格、眼下方 0.12): 响在光上而不是响在自己脑袋里。
#     也必须带 ^-0.12 —— 与坑 69 同一个理由(轴线上的声源听起来就在自己身上)。
#   ★ 只有"我还没有光柱"时才会走到这里(beam_go ③), 所以最多 6 秒响一次, 不刷屏。
execute at @s anchored eyes positioned ^ ^-0.12 ^4 run playsound minecraft:block.amethyst_block.chime player @a ~ ~ ~ 0.55 1.15
execute at @s anchored eyes positioned ^ ^-0.12 ^4 run playsound minecraft:block.beacon.activate player @a ~ ~ ~ 0.60 1.20
execute at @s anchored eyes positioned ^ ^-0.12 ^4 run playsound minecraft:entity.lightning_bolt.impact player @a ~ ~ ~ 0.35 1.50
