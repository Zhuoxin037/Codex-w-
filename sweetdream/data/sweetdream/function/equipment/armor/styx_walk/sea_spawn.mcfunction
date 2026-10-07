# ============================================================
# sweetdream:equipment/armor/styx_walk/sea_spawn —— 生成一片「暗海」(主片)
# ------------------------------------------------------------
# 【谁调用它】hit(执行位置 = 被打目标处; @s 仍是施法玩家)
# 【暗海本体】minecraft:item_display —— 逻辑 + 视觉一体的一块**直径 6 格海面平图**
#   (主片半径 3 格 ⇒ 直径 6; 次级片半径 2 ⇒ 直径 4, 同形态只差 scale)。
#   做法照无光海·暗潮 (lightless_sea/on_cast_ls):
#   · 模型 = composite 两层 —— 海底(墨黑蓝, 不规则 alpha 裁边)
#     + 波纹(16 帧动画, 幽蓝环向外推)。
#   · 粒子只留少量气泡/墨黑点缀 —— 大面积表现交给模型, 不再靠瀑布粒子。
#   ★ 平图坐标: 物品模型 [0,16] 以实体位置为中心, scale 6 → 直径 6 格;
#     y 方向 scale 保持 1, 平面厚度 0.5 像素, translation +0.02 抬离地面防闪面。
#   ★ 2026-10-06 从 marker 换成 item_display(用户: "希望和暗潮一样有贴图特效")。
#   ★ 2026-10-06 晚: 暗海改**三形态随机**(a 缓湾湖 / b 长湖 / c 半月湖,
#     都是**自然湖泊**式的缓岸轮廓 —— 无尖角/无挖洞/无缺口),
#     见 sea_pick_model + sea_make; 三形态只是贴图不同, 直径与轨道共用。
#     item_display 也在 #sweetdream:no_damage 里, 各处范围圈选天然排除。
# 【数据】data.zx.sea = {uuid(释放者 uuid 文本), u0..u3(四个 32 位 int), r(半径)}
#   · uuid 给"按 uuid 查玩家"用(比如以后要做传送/判归属)
#   · u0..u3 给**宏**拼选择器反查释放者用(见 sea_hurt)
#   · r 是半径 —— sea_area 拿它拼进选择器, 所以主片 3 / 次级片 2 是同一套代码;
#     退场时也靠 r 选收拢轨道(sea_out6 / sea_out4)
# 【寿命】**基础 5 秒 / 硬上限 10 秒**(2026-10-06 用户口径)
#   · zx.sea_end = #now + 100(5 秒) —— 到期由 sea_tick 启动退场动画
#   · zx.sea_cap = #now + 200 —— 硬上限(出生时刻 + 10 秒), 续命(sea_extend +2 秒)只能续到 cap
#   ★ 用"到点时刻"而不是倒计时: 结附时要给**全部**暗海 +2 秒(sea_bind),
#     绝对时刻直接 `+= 40` 就行, 倒计时还得防着"减到负数"。
# 【扩散动画】走通用逐帧库(lib/anim_step + zx:anim 表的 sea_in6 轨道):
#   召唤时 scale 只有 0.6(中心一小圈), 每刻铺一帧, 14 帧 = 0.7 秒铺到直径 6。
#   ★ interpolation_duration 保持 0(收到即生效), 关键帧由服务端逐帧下发。
#   ★ 先写 data.zx.anim 再加 zx.anim 标签 —— 四个宏参数缺一个 anim_step 就不跑。
#   ★ 先写 zx.sea_new 的 data 再摘标签: 摘早了下面的句子就找不到实体。
# 【表现】墨黑(深海墨囊) + 幽蓝魂火(sculk_soul) 两层点缀。
# ============================================================

# ① 随机挑形态 -> 召唤(scale 0.6 = 主片; 模型名由 sea_pick_model 随机覆写)
data modify storage zx:work sea_mk set value {model:"sweetdream:sea_a",scale:"0.6f"}
function sweetdream:equipment/armor/styx_walk/sea_pick_model
function sweetdream:equipment/armor/styx_walk/sea_make with storage zx:work sea_mk

# ② 归属 + 半径
data modify entity @n[limit=1,tag=zx.sea_new] data.zx.sea set value {uuid:"",u0:0,u1:0,u2:0,u3:0,r:3}
data modify entity @n[limit=1,tag=zx.sea_new] data.zx.sea.uuid set from storage zx:data self.uuid
data modify entity @n[limit=1,tag=zx.sea_new] data.zx.sea.u0 set from entity @s UUID[0]
data modify entity @n[limit=1,tag=zx.sea_new] data.zx.sea.u1 set from entity @s UUID[1]
data modify entity @n[limit=1,tag=zx.sea_new] data.zx.sea.u2 set from entity @s UUID[2]
data modify entity @n[limit=1,tag=zx.sea_new] data.zx.sea.u3 set from entity @s UUID[3]

# ③ 寿命: **基础 5 秒**(= 文案里那个 5 秒) + **硬上限 10 秒**(续命只能续到 cap)
#   ★ 用户口径(2026-10-06): "不是改成持续 10 秒, 而是还是 5 秒, 但是上限 10 秒"
#     ⇒ sea_end = #now + 100(5 秒, 到点开始收拢退场)
#       sea_cap = #now + 200(10 秒, 出生时刻 + 200 —— 这个值**终生不变**)
scoreboard players operation @n[limit=1,tag=zx.sea_new] zx.sea_end = #now manacore.meta
scoreboard players add @n[limit=1,tag=zx.sea_new] zx.sea_end 100
scoreboard players operation @n[limit=1,tag=zx.sea_new] zx.sea_cap = #now manacore.meta
scoreboard players add @n[limit=1,tag=zx.sea_new] zx.sea_cap 200

# ④ 扩散动画: 帧号 14 起步 + 告诉通用逐帧库怎么动
scoreboard players set @n[limit=1,tag=zx.sea_new] zx.sea_anim 14
data modify entity @n[limit=1,tag=zx.sea_new] data.zx.anim set value {field:"scale",track:"sea_in6",key:"zx.sea_anim",dir:"in"}
tag @n[limit=1,tag=zx.sea_new] add zx.anim
tag @n[limit=1,tag=zx.sea_new] remove zx.sea_new

# ⑤ 表现(墨黑 + 幽蓝魂火; 平图本体负责大面积海面)
particle minecraft:squid_ink ~ ~0.2 ~ 1.8 0.25 1.8 0.01 14 normal
particle minecraft:sculk_soul ~ ~0.3 ~ 1.8 0.3 1.8 0.02 10 normal
playsound minecraft:block.sculk_shrieker.shriek player @a ~ ~ ~ 0.5 1.5
