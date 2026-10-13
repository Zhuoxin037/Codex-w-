# ============================================================
# sweetdream:equipment/staff/begonia/emp_find —— 找"我自己增强过的漩涡"(宏叶子)
# ------------------------------------------------------------
# 【谁调用它】begonia/hook_calc ④:
#       execute at @s run function sweetdream:equipment/staff/begonia/emp_find \
#                with storage zx:work bgc
# 【宏参数】zx:work bgc {u0,u1,u2,u3} = 施法者 UUID 的 4 个 int
# 【执行者/位置】施法者玩家本人 / **他的坐标**(distance 就是按执行位置量的)
# 【★ 为什么单独一个文件(N09, 2026-10-11)★】
#   含 `$(…)` 的行只能活在**宏函数**里, 而本 hook 的入口是
#   `#manacore:event/damage_calc` 的**无参**派发 —— 宏行留在"被标签直接引用的函数"
#   里就是**死代码**(整段不执行, 零日志)。拆出来后:
#     · hook_calc  = 普通函数(被标签引用, 不含任何 $(…));
#     · emp_find   = 宏叶子(只由 hook_calc 用 with storage 调)。
#   守门: check.py 新桶 `tagmacro` 会拦住"标签引用的函数里又写回宏行"。
# ============================================================

# 6 格内有没有"我自己增强过的漩涡"
#   增强 = tag zx.bg_emp; 归属 = data.zx.bg.{ol:1b, u0..u3 == 我的 UUID 四 int}
#   命中就调 emp_put 往 mm 加算池写 +20(见 emp_put 头注释)。
$execute if entity @e[tag=zx.bg_vtx,tag=zx.bg_emp,nbt={data:{zx:{bg:{ol:1b,u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}}}},distance=..6,limit=1] run function sweetdream:equipment/staff/begonia/emp_put
