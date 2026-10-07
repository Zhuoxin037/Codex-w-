# ============================================================
# sweetdream:equipment/armor/lightless_sea/on_cast_ls —— 施放技能: 暗潮
# ------------------------------------------------------------
# 【谁调用它】garden_sea/observe(#manacore:event/cooldown_start 链上, 已判穿着)
#   @s = 施法者本人
# 【上限】同一释放者名下最多 3 片"暗潮" —— 开头先跑 cap(宏), 超出时最早那片被 kill。
# 【文案】自身每使用一次技能都会在自身位置生成一个半径 4 格的"暗潮",
#   在"暗潮"范围内的生物将获得常态的缓慢Ⅱ。8 秒后"暗潮"自毁。
# 【本体】item_display(逻辑 + 视觉一体) —— 一块直径 8 格的**海面平图**:
#   · 底层 tide_deep: 深暗海水, 圆形裁边 + 波纹锯齿(静态)
#   · 上层 tide_ripple: 16 帧动画贴图, 向外扩散的青色波纹(composite 叠两层)
#   粒子只留少量气泡/暗流做点缀 —— 大面积表现交给模型, 不再靠 30 个/次的瀑布粒子。
#   ★ 平图坐标: 物品模型 [0,16] 以实体位置为中心, scale 8 → 1 格模型 = 8 格宽;
#   y 方向 scale 保持 1, 平面厚度 0.5 像素(≈0.03 格), translation +0.02 抬离地面防闪面。
# 【扩散动画】召唤时 scale 只有 [0.6,1,0.6](中心一小圈), 由**通用逐帧库**
#   (lib/anim_step + zx:anim 表的 spread 轨道)每刻铺一帧, 14 帧 = 0.7 秒铺到满径 8 格。
#   实体的 data.zx.anim 写着 {field,track,key,dir}, 帧号 zx.ls_anim 从这里 set 14 起步。
#   ★ interpolation_duration 保持 0(收到即生效): 关键帧由服务端逐帧下发, 不靠客户端
#     补间 —— 原先用 interpolation_duration:10 补间实测根本没动画(见 lib/anim_step)。
# 【退场】寿命到了由 tide_tick 换成 shrink 轨道收拢(退潮, 同样 14 帧), dir="out"。
#   ★ 判定不受动画影响: 缓慢Ⅱ/套装伤害看的是 `distance=..4`, 服务端数据已是终态。
# 【归属】同朽木: data.zx.ls 存 uuid + u0..u3(套装伤害的反查用; 上限计数也靠它们)。
# ============================================================

# ① 上限: 同一释放者名下最多 3 片, 超出时最早那片消失(cap 是宏, 读 @s 的 UUID)
data modify storage zx:work cp set value {u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work cp.u0 set from entity @s UUID[0]
data modify storage zx:work cp.u1 set from entity @s UUID[1]
data modify storage zx:work cp.u2 set from entity @s UUID[2]
data modify storage zx:work cp.u3 set from entity @s UUID[3]
function sweetdream:equipment/armor/lightless_sea/cap with storage zx:work cp

# ② 自身位置召唤暗潮(先只有中心一小圈, 之后由通用逐帧库每刻推一帧 → 从中心扩散)
summon minecraft:item_display ~ ~ ~ {Tags:["zx.ls_tide","zx.ls_new"],item:{id:"minecraft:stick",count:1,components:{"minecraft:item_model":"sweetdream:tide"}},brightness:{sky:7,block:7},interpolation_duration:0,transformation:{translation:[0.0f,0.02f,0.0f],scale:[0.6f,1.0f,0.6f],left_rotation:[0.0f,0.0f,0.0f,1.0f],right_rotation:[0.0f,0.0f,0.0f,1.0f]}}

# ③ 归属
data modify entity @n[limit=1,tag=zx.ls_new] data.zx.ls set value {uuid:"",u0:0,u1:0,u2:0,u3:0}
data modify entity @n[limit=1,tag=zx.ls_new] data.zx.ls.uuid set from storage zx:data self.uuid
data modify entity @n[limit=1,tag=zx.ls_new] data.zx.ls.u0 set from entity @s UUID[0]
data modify entity @n[limit=1,tag=zx.ls_new] data.zx.ls.u1 set from entity @s UUID[1]
data modify entity @n[limit=1,tag=zx.ls_new] data.zx.ls.u2 set from entity @s UUID[2]
data modify entity @n[limit=1,tag=zx.ls_new] data.zx.ls.u3 set from entity @s UUID[3]

# ④ 寿命: 8 秒
scoreboard players operation @n[limit=1,tag=zx.ls_new] zx.ls_end = #now manacore.meta
scoreboard players add @n[limit=1,tag=zx.ls_new] zx.ls_end 160

# 扩散动画: 帧号 14 起步 + 告诉通用逐帧库怎么动(字段/轨道/帧号计分项/方向)
#   ★ 先写 data.zx.anim 再加 zx.anim 标签 —— 四个宏参数缺一个, anim_step 就一条都不跑。
scoreboard players set @n[limit=1,tag=zx.ls_new] zx.ls_anim 14
data modify entity @n[limit=1,tag=zx.ls_new] data.zx.anim set value {field:"scale",track:"spread",key:"zx.ls_anim",dir:"in"}
tag @n[limit=1,tag=zx.ls_new] add zx.anim

# ⑤ 摘"新召唤"标记 + 表现(水花炸开 + 暗流下沉, 平图本体负责大面积海面)
tag @n[limit=1,tag=zx.ls_new] remove zx.ls_new
particle minecraft:bubble ~ ~0.15 ~ 2.2 0.2 2.2 0.04 18 normal
particle minecraft:current_down ~ ~1.0 ~ 2.4 0.7 2.4 0.015 12 normal
particle minecraft:bubble_pop ~ ~0.3 ~ 1.5 0.3 1.5 0.01 10 normal
playsound minecraft:block.conduit.ambient player @a ~ ~ ~ 0.8 1.2
playsound minecraft:block.water.ambient player @a ~ ~ ~ 0.9 0.7
