# ============================================================
# sweetdream:debug/equip_mark —— 把一个装备 id 记进"在身名单"(宏参数 {id})
# ------------------------------------------------------------
# 【为什么存在】id 是运行时读出来的, 要拼进 storage 路径必须用宏变量。
# 【宏参数从哪来】debug/equip_scan 读出槽位上的 id 后
#   `function ... with storage zx:work es` 传进来。
#   ⚠️ **不要**写成 `with storage zx:data self` —— 那个写法会让宏函数
#     一条命令都不跑(静默), 2026-10-03 栽过。一律用 zx:work 传。
# ============================================================

$data modify storage zx:work eq.$(id) set value 1b
