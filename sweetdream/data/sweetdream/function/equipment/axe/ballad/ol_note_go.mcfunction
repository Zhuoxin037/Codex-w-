# ============================================================
# sweetdream:equipment/axe/ballad/ol_note_go —— 「音符」到点: 铺路径 + 结算 + 自毁(宏)
# ------------------------------------------------------------
# 【宏参数】zx:work ntgo {dmg,sx,sy,sz,u0,u1,u2,u3}(从 marker 的 data.zx 整份拷来)
#   ★ u0..u3 必须在 marker NBT 里就是**四个独立整数**: 存成 u:[I;..] 数组的话
#     $(u0) 在 storage 里找不到同名键 -> 整条宏失败, 伤害静默消失。
# 【执行者】音符 marker   【位置】终点(= 锁定生物当初的位置)
# 【设计原文】"1 秒后向锁定到该生物的位置发射出去并对路径上的生物造成相当于
#   自身基础攻击力 x X 的真实伤害，在到达该生物原先的位置后自毁。"
# 【★ 起点 -> 终点: facing entity @s feet + 自递归铺球 ★】
#   @s 在整个递归里都是这个 marker(execute positioned 不改执行者), 所以
#   `facing entity @s feet` 一路都指向终点, 递归只需要 `positioned ^ ^ ^1.5`。
#   (同 hook/ol_line、归途/ol_line 的写法; 递归行**不能**带 at @s)
# 【★ 第一个采样点跳开 1.5 格、半径 1.3 ★】起点就是施法者脚下, 直接在起点铺
#   半径 1.5 的球会把**施法者自己**算进"路径上的生物"。跳开 1.5、半径收到 1.3
#   之后, 到自己的距离恒 > 1.3, 不会自伤; 只漏掉"紧贴脚底 0.2 格内"的敌人。
# ============================================================

# ① 铺球: 起点 -> 终点(先绝对定位到起点, 再沿朝向前进 1.5 格开始采样)
#   ★ 标签清理也要带 distance=0.. ★ 本函数在"三维度各跑一次"的调用链上,
#     裸 @e 会跨维度搜(清到别的维度的同名标签), check 规则也盯着这一条。
tag @e[tag=zx.nt_hit,distance=0..] remove zx.nt_hit
scoreboard players set #nt_step zx.meta 0
$execute positioned $(sx) $(sy) $(sz) facing entity @s feet positioned ^ ^ ^1.5 run function sweetdream:equipment/axe/ballad/ol_note_line

# ② 投递真伤(数值 = 基础攻击力 × X, 施法者身份 -> 击杀归属正确)
data modify storage zx:work a set value {target:"@e[tag=zx.nt_hit,distance=0..]",type:"sweetdream:true_damage"}
execute store result storage zx:work a.num int 1 run scoreboard players get @s zx.nt_d
function sweetdream:lib/num/plain
$data modify storage zx:work a.u0 set value $(u0)
$data modify storage zx:work a.u1 set value $(u1)
$data modify storage zx:work a.u2 set value $(u2)
$data modify storage zx:work a.u3 set value $(u3)
execute if entity @e[tag=zx.nt_hit,distance=0..,limit=1] run function sweetdream:internal/damage/with_from with storage zx:work a
tag @e[tag=zx.nt_hit,distance=0..] remove zx.nt_hit

# ③ 表现 + 自毁
particle minecraft:end_rod ~ ~0.3 ~ 0.3 0.4 0.3 0.05 12 normal
playsound minecraft:block.note_block.chime player @a ~ ~ ~ 0.5 1.8
kill @s
