# ============================================================
# sweetdream:equipment/staff/final_revelation/beam_new —— 生成一根光柱实体
# ------------------------------------------------------------
# 【谁调用它】beam_go ③ —— "我"名下没有光柱时(第一次放 / 旧的没了)
# 【执行者】施法玩家
# 【生成点】眼睛下 0.45、视线前方 8 格 = 16 格长光条的中点。
# 【为什么 scale 是 [1,1,16]】模型 fr_beam 的条子沿 model Z 轴铺 0..16px,
#   display 上以实体位置为中心 ⇒ 16px=1 格 × z scale 16 = 前后各 8 格。
#   x/y 的粗细直接在模型里画(外辉 12px=0.75 格 / 亮核 6px=0.375), 不用 scale 放大,
#   免得壳的厚度跟着 z 一起变形。
#   ★ 贴图是"四边渐隐"的软边图(见 _gen_fr_beam.py) —— 两端自然收细, 不是平头的棍子。
# 【归属】UUID 四 int 写进 data.zx.fr(照抄 styx_walk/sea_spawn) ——
#   玩家那边不存任何东西, 全靠实体自己记住主人。
# 【亮度】sky/block 全 15: 贴图本身不发光, 不拉满就是灰白而不是"圣光白"。
# ============================================================

execute at @s anchored eyes positioned ^ ^-0.45 ^8 run summon minecraft:item_display ~ ~ ~ {Tags:["zx.fr_beam","zx.fr_beam_new"],item:{id:"minecraft:stick",count:1,components:{"minecraft:item_model":"sweetdream:fr_beam"}},brightness:{sky:15,block:15},interpolation_duration:0,transformation:{translation:[0.0f,0.0f,0.0f],scale:[1.0f,1.0f,16.0f],left_rotation:[0.0f,0.0f,0.0f,1.0f],right_rotation:[0.0f,0.0f,0.0f,1.0f]}}

# 归属 + 初始寿命
data modify entity @n[limit=1,tag=zx.fr_beam_new] data.zx.fr set value {u0:0,u1:0,u2:0,u3:0}
data modify entity @n[limit=1,tag=zx.fr_beam_new] data.zx.fr.u0 set from entity @s UUID[0]
data modify entity @n[limit=1,tag=zx.fr_beam_new] data.zx.fr.u1 set from entity @s UUID[1]
data modify entity @n[limit=1,tag=zx.fr_beam_new] data.zx.fr.u2 set from entity @s UUID[2]
data modify entity @n[limit=1,tag=zx.fr_beam_new] data.zx.fr.u3 set from entity @s UUID[3]
scoreboard players set @n[limit=1,tag=zx.fr_beam_new] zx.fr_ref 3
tag @n[limit=1,tag=zx.fr_beam_new] remove zx.fr_beam_new
