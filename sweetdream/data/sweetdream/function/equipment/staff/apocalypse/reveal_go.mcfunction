# ============================================================
# sweetdream:equipment/staff/apocalypse/reveal_go —— 灾示的 8 格 AoE
# ------------------------------------------------------------
# 【谁调用它】reveal(执行者 = 玩家; 当前页有魔力才进来)
# 【伤害】当前页记录魔力(zx.ap_cur, ×100 定点整数) ×0.5:
#   store ... double 0.005 = 定点值 ×0.005, 一步到位(÷100 还原 ×0.5)。
# 【最后一次 ×1.5】灧行时刻 ap_on ∈ {8,5,3}(tick_go 先干活后扣状态,
#   三次灾示分别在 s3/s6/s9, 对应 8/5/3) —— 最后一次必然 ap_on = 3,
#   `matches ..3` 精确命中、与手里有几页无关(1/2/3 页的最后一次都在 s9)。
#   ×0.5 × 1.5 = ×0.75 → double 0.0075。
# 【口径】基数是"页记录的消耗量", 不是任何面板值 → 走不了 calc 通道,
#   直接数值经 with_from 打出; type 兜底 player_attack、被全包配置覆盖。
# 【归属】执行者是玩家 → u0..u3 直接从 @s UUID 抄, 击杀记玩家头上。
# 【>500 光效】该页记录的消耗超过 500(定点 50001..) → 本次灾示额外
#   使目标获得 5 秒发光与虚弱Ⅱ。只对本次目标(ap_area)生效。
# ============================================================

# 模型脉冲跟随真实灾示事件，避免秒计时相位与独立动画计时不同步。
function sweetdream:equipment/staff/apocalypse/visual/reveal

# ① 圈目标: 自身 8 格全部生物(先清残留; no_damage 含玩家, 不会圈到自己)
tag @e[tag=zx.ap_area] remove zx.ap_area
tag @e[type=!#sweetdream:no_damage,distance=..8] add zx.ap_area

# ② 组伤害入参(数值模式; type 跟随全包默认配置)
data modify storage zx:work a set value {target:"@e[tag=zx.ap_area]",damage:0.0,type:"minecraft:player_attack",u0:0,u1:0,u2:0,u3:0}
execute if data storage zx:config damage_type run data modify storage zx:work a.type set from storage zx:config damage_type

# ③ 换算伤害: 正常 ×0.5 / 最后一次 ×1.5(见头注释)
execute if score @s zx.ap_on matches 4.. store result storage zx:work a.num double 0.005 run scoreboard players get @s zx.ap_cur
execute if score @s zx.ap_on matches ..3 store result storage zx:work a.num double 0.0075 run scoreboard players get @s zx.ap_cur
function sweetdream:lib/num/plain

# ④ 归属: 从执行者(玩家)的 UUID 抄
data modify storage zx:work a.u0 set from entity @s UUID[0]
data modify storage zx:work a.u1 set from entity @s UUID[1]
data modify storage zx:work a.u2 set from entity @s UUID[2]
data modify storage zx:work a.u3 set from entity @s UUID[3]

# ⑤ 打出去
function sweetdream:internal/damage/with_from with storage zx:work a

# ⑥ >500 光效: 发光 5 秒 + 虚弱Ⅱ(amp 1) 5 秒, 只对本次目标
execute if score @s zx.ap_cur matches 50001.. run effect give @e[tag=zx.ap_area] minecraft:glowing 5 0 true
execute if score @s zx.ap_cur matches 50001.. run effect give @e[tag=zx.ap_area] minecraft:weakness 5 1 true

# ⑦ 表现(执行者就是玩家, 位置已生效)
function sweetdream:equipment/staff/apocalypse/visual/world_burst

# ⑧ ★ 灾示打完 -> 把"当前页"清掉: 一页只对应一次灾示 ★
#   2026-10-06 真实反馈: "不管有几层启示都会触发三次技能效果" ——
#   ap_cur 只在 consume_page 里被赋新值、只在 end_state 里清 0, 于是手里只有
#   1 页时, s3 打完它 ap_cur 还留着那个数, s6/s9 两次灾示照旧用它再打两遍
#   (灾示次数完全与页数无关)。清 0 之后: 1 页 = s3 一次 / 2 页 = s3+s6 两次 /
#   3 页 = s3+s6+s9 三次 —— 次数恒等于页数。
#   ★ ×1.5 的判据不受影响(仍是 ap_on ≤ 3, 只有三页才有第 3 次灾示)。
#   ★ 必须排在 ⑦ 之后: 上面 ③ 算伤害、⑥ 判 >500 都还要用 ap_cur。
scoreboard players set @s zx.ap_cur 0
