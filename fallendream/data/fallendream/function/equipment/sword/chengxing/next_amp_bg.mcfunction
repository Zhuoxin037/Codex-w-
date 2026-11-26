# ============================================================
# fallendream:equipment/sword/chengxing/next_amp_bg —— 海棠强化漩涡的只读探测（宏叶子）
# ------------------------------------------------------------
# 【谁调】chengxing/next_amp ⑦，with storage zx:work cxn
# 【为什么单独一个文件】含 $(u0).. 的行只能活在宏函数里；next_amp 是普通函数，
#   混写会让整段宏行作废（N09 事故，见 begonia/emp_find 头注释）。
# 【★ 只读 ★】不调用 begonia/emp_put —— 那是往加算池写 +20 的结算口，调了会白送一份。
# 【出参】#cx_bg = 1200（有）/ 0（没有）
# ============================================================

scoreboard players set #cx_bg zx.meta 0
$execute if entity @e[tag=zx.bg_vtx,tag=zx.bg_emp,nbt={data:{zx:{bg:{ol:1b,u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}}}},distance=..6,limit=1] run scoreboard players set #cx_bg zx.meta 1200
