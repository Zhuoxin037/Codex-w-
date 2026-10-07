# ============================================================
# sweetdream:equipment/armor/withered_garden/wood_spawn —— 召唤一只"朽木"
# ------------------------------------------------------------
# 【谁调用它】on_cast_gd(执行位置 = 被选中的渊海生物处; @s 仍是施法玩家)
# 【上限】同一释放者名下最多 3 棵"朽木" —— 开头先跑 cap(宏), 超出时最早那棵被 kill。
# 【朽木本体】item_display 顶着一棵**自定义枯木模型**(sweetdream:withered_wood) ——
#   枯树干 + 六向枯枝 + 露地树根 + 紫菌/苔藓, **约 5.25 格高、4.1 格展幅**(高瘦立姿)。
#   为什么用 item_display 而不是 block_display: block_display 只能摆原版方块,
#   自定义模型必须挂在一件物品的 item_model 组件上, 由 item_display 渲染。
#   ★ 物品模型坐标系: [0,16] 以实体位置为中心(渲染器自带 -0.5 平移) ——
#   模型底 y=0 落在 -0.5*s 格, 所以 translation[1] = scale/2 = 2.5 才立在地面上。
#   ★ **改 scale 必须同步 translation[1] = scale[1]/2**, 否则陷地/悬空。
#   ★ 模型是按"5 格高"设计的(_gen_wood_tide.py), **等比 scale 5.0** ——
#     不要用非等比 scale 拉高旧模型, 阶梯状的枝会被拉成悬空的板子。
# 【召唤动画】先埋在地下(translation y = -2.75 → 树顶刚好齐地面), 再由**通用逐帧库**
#   (lib/anim_step + zx:anim 表的 rise_y 轨道) 每刻顶一帧, 14 帧 = 0.7 秒破土升起。
#   实体的 data.zx.anim 写着 {field,track,key,dir}, 帧号 zx.gw_anim 从这里 set 14 起步。
#   ★ interpolation_duration 保持 0(收到即生效): 关键帧由服务端逐帧下发, 不靠客户端补间
#     —— 补间在 1.21.5 实测靠不住(MC-259926 / MC-260874), 见 lib/anim_step 头注释。
#   ★ 逐帧是**纯表现**: 服务端第一刻起树就在最终位置参与判定。
# 【退场】寿命到了不是直接 kill —— wood_tick 会换成 sink_y 轨道把它沉回地里(同样 14 帧),
#   dir 改成 "out", 动画走完由 anim_step 收掉。见 wood_tick ①。
# 【随机朝向】lib/rnd 出 #rnd, %4 后四档绕 Y 旋转 —— 枯木不再千篇一律一个朝向。
# 【归属】data.zx.gd 里存施法者的 uuid(字符串)和 u0..u3(四个 32 位 int,
#   每 2 秒的反查玩家靠它们拼选择器, 见 wood_set; 上限计数也靠它们, 见 cap)。
# 【寿命】计分项 zx.gw_end = 框架时钟 #now + 160(8 秒), wood_tick 到点自毁。
# ============================================================

# ① 上限: 同一释放者名下最多 3 棵, 超出时最早那棵消失(cap 是宏, 读 @s 的 UUID)
data modify storage zx:work cp set value {u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work cp.u0 set from entity @s UUID[0]
data modify storage zx:work cp.u1 set from entity @s UUID[1]
data modify storage zx:work cp.u2 set from entity @s UUID[2]
data modify storage zx:work cp.u3 set from entity @s UUID[3]
function sweetdream:equipment/armor/withered_garden/cap with storage zx:work cp

# ② 召唤(先埋在地下, 之后由通用逐帧库每刻推一帧 → 破土升起)
summon minecraft:item_display ~ ~ ~ {Tags:["zx.gw_wood","zx.gw_new"],item:{id:"minecraft:stick",count:1,components:{"minecraft:item_model":"sweetdream:withered_wood"}},brightness:{sky:10,block:10},shadow_radius:1.8f,shadow_strength:0.6f,view_range:2.0f,interpolation_duration:0,transformation:{translation:[0.0f,-2.75f,0.0f],scale:[5.0f,5.0f,5.0f],left_rotation:[0.0f,0.0f,0.0f,1.0f],right_rotation:[0.0f,0.0f,0.0f,1.0f]}}

# 随机朝向(四档, 各差 90°)
function sweetdream:lib/rnd
scoreboard players operation #rot zx.meta = #rnd zx.meta
scoreboard players operation #rot zx.meta %= #4 zx.meta
execute if score #rot zx.meta matches 0 run data modify entity @n[limit=1,tag=zx.gw_new] transformation.right_rotation set value [0.0f,0.0f,0.0f,1.0f]
execute if score #rot zx.meta matches 1 run data modify entity @n[limit=1,tag=zx.gw_new] transformation.right_rotation set value [0.0f,0.7071068f,0.0f,0.7071068f]
execute if score #rot zx.meta matches 2 run data modify entity @n[limit=1,tag=zx.gw_new] transformation.right_rotation set value [0.0f,1.0f,0.0f,0.0f]
execute if score #rot zx.meta matches 3 run data modify entity @n[limit=1,tag=zx.gw_new] transformation.right_rotation set value [0.0f,0.7071068f,0.0f,-0.7071068f]

# 归属: uuid(字符串) + u0..u3(@s UUID 的四个 int, 宏反查用)
data modify entity @n[limit=1,tag=zx.gw_new] data.zx.gd set value {uuid:"",u0:0,u1:0,u2:0,u3:0}
data modify entity @n[limit=1,tag=zx.gw_new] data.zx.gd.uuid set from storage zx:data self.uuid
data modify entity @n[limit=1,tag=zx.gw_new] data.zx.gd.u0 set from entity @s UUID[0]
data modify entity @n[limit=1,tag=zx.gw_new] data.zx.gd.u1 set from entity @s UUID[1]
data modify entity @n[limit=1,tag=zx.gw_new] data.zx.gd.u2 set from entity @s UUID[2]
data modify entity @n[limit=1,tag=zx.gw_new] data.zx.gd.u3 set from entity @s UUID[3]

# 寿命: 8 秒
scoreboard players operation @n[limit=1,tag=zx.gw_new] zx.gw_end = #now manacore.meta
scoreboard players add @n[limit=1,tag=zx.gw_new] zx.gw_end 160

# 升起动画: 帧号 14 起步 + 告诉通用逐帧库怎么动(字段/轨道/帧号计分项/方向)
#   ★ 先写 data.zx.anim 再加 zx.anim 标签 —— 四个宏参数缺一个, anim_step 就一条都不跑。
scoreboard players set @n[limit=1,tag=zx.gw_new] zx.gw_anim 14
data modify entity @n[limit=1,tag=zx.gw_new] data.zx.anim set value {field:"translation",track:"rise_y",key:"zx.gw_anim",dir:"in"}
tag @n[limit=1,tag=zx.gw_new] add zx.anim

# 摘"新召唤"标记 + 表现(破土而出: 碎屑 + 灰烬沿树身上升 + 孢子绕冠)
#   ★ 粒子高度要跟着树走: 树 ~5.25 格高, 灰烬给到 1.4±2.0(贴着树身), 孢子撒在 4.2(树冠带)
tag @n[limit=1,tag=zx.gw_new] remove zx.gw_new
particle minecraft:composter ~ ~0.3 ~ 0.9 0.3 0.9 0.02 18 normal
particle minecraft:ash ~ ~1.4 ~ 0.7 2.0 0.7 0.01 18 normal
particle minecraft:spore_blossom_air ~ ~4.2 ~ 0.9 0.8 0.9 0.005 10 normal
playsound minecraft:block.wood.place player @a ~ ~ ~ 0.7 0.6
playsound minecraft:block.azalea_leaves.break player @a ~ ~ ~ 0.6 0.7
