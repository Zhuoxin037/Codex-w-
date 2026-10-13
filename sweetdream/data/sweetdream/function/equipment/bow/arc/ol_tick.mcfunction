# ============================================================
# sweetdream:equipment/bow/arc/ol_tick —— 超限·电弧: 放电锚每秒一跳(外壳)
# ------------------------------------------------------------
# 【谁调用它】lib/second: execute in <维度> as @e[type=marker,tag=zx.arc_w] at @s run ...
# 【执行者/位置】放电锚(marker)
# 【它做什么】把锚上的 data.zx 抬进 zx:work aw, 交给宏叶子 ol_tick_go
# 【★ 为什么拆两层】宏参数只能由调用处的 `with storage` 绑定; 而锚的数据要"先
#   set from entity, 再 with storage", 这是包里的固定写法(同 fissure/field_tick)。
# 【★ 为什么先清空 aw】`set from entity @s data.zx` 在**源不存在**时不会写入、
#   于是 aw 会留下上一次调用者塞进去的旧值 ⇒ 宏叶子会拿旧参数跑。先置空最稳。
# ============================================================

# ① 把锚上的 NBT 抬进宏节点(先清空, 见头注)
data modify storage zx:work aw set value {}
data modify storage zx:work aw set from entity @s data.zx

# ② ★ 自愈: 2026-10-12 修宏参数之前生成的锚把 UUID 存成了列表(a/b/u), 宏参数
#    ("只能取键")读不到 ⇒ 这种锚永远收不了尾(现场: zx.arc_wt 恒为 3), 直接回收。
#    ★ 判据读的是 storage 而不是 entity —— kill 之后 @s 就取不到了。
#    正常锚(ol_spawn 逐键写 a0..b3)必带 a0, 不会被误杀。
execute unless data storage zx:work aw.a0 run kill @s
execute unless data storage zx:work aw.a0 run return 0

# ③ 宏叶子: 逐秒一跳(重判配对 + 3 格宽电线 + 伤害 + 落雷) + 计时收尾
function sweetdream:equipment/bow/arc/ol_tick_go with storage zx:work aw
