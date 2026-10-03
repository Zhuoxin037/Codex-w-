# ============================================================
# sweetdream:debug/wg_row —— 风行"下次技能加成"那一行(宏参数 {uuid})
# ------------------------------------------------------------
# 【为什么单独拆一个文件】wg_bonus 存在 zx:data wg_bonus."<uuid>",
#   路径里带 uuid, 只能靠宏拼 —— 而 debug/stats 这个文件刻意保持"零宏"。
# 【宏参数从哪来】调用方(debug/stats)把 uuid 抄进 zx:work sd, 然后
#   `function sweetdream:debug/wg_row with storage zx:work sd`。
#   ⚠️ **不要**写成 `with storage zx:data self` —— 实测那个写法会让整个宏
#     函数一条命令都不跑(静默), 2026-10-03 栽过。一律用 zx:work 传。
# ============================================================

$execute if data storage zx:work eq.wind_ontheground if data storage zx:data wg_bonus."$(uuid)" run data modify storage zx:work pl.wg_bonus set from storage zx:data wg_bonus."$(uuid)"
data modify storage zx:work nr set value {k:"wg_bonus",l:"下次技能加成",c:"light_purple",s:"(比例, 0.15 = +15%)"}
execute if data storage zx:work pl.wg_bonus run function sweetdream:debug/num_row with storage zx:work nr
