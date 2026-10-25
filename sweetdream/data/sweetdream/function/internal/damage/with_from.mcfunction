# ============================================================
# sweetdream:internal/damage/with_from —— 带"攻击者归属"的打伤害
# ------------------------------------------------------------
# 【宏参数】sweetdream:work a {target,num_str,type,u0,u1,u2,u3}
# 【和 internal/damage_go 的区别】这一份会在 /damage 后面补 by <攻击者>,
#   于是击杀会被记在攻击者头上(死亡信息、经验掉落归属)。
# 【为什么要用 u0..u3 拼选择器】UUID 文本没法写进选择器, 而玩家记录里存了
#   UUID 的 4 个 32 位整数, 用它们能反查出玩家实体。
# 【为什么第二行要有】万一那个选择器选不到人(玩家刚好离线), by 会指向空,
#   整条命令就会失败、一点伤害都打不出。所以选不到时退回"无归属"的写法。
# 【为什么选择器要写两遍, 不先存进节点再引用】宏变量在"函数被调用那一刻"就
#   固定了。在函数体里才写进节点的 from, 这一层是引用不到的(会报缺少传入参数)。
#   所以直接内联, 别绕。
# 【为什么还要 execute as】/damage 的目标参数只收单个实体, 用 execute as
#   把范围选择器逐个展开成 @s。
# 【★ 真正的伤害动作现在在 internal/damage/one ★】
#   因为黄昏黎明之交界 需要"打之前看它带不带通用标签, 打完之后看它死没死" ——
#   只有以"单个目标"身份执行才做得了这些检查, 所以这里只负责把范围拆成一个个人。
# 【★ one 现在不含宏行了 ★】真正的 /damage 搬进了 internal/damage/deal 那个宏,
#   one 自己会去读 zx:work a。所以这里**裸调** one 即可(不必再 with storage)。
# 【★ 兜底补 u0..u3 ★】有的调用点(流光/超限流光)只写了 num/target/type, 没带 u0..u3。
#   宏参数缺字段会让 deal 那条宏"缺少传入参数"整条调用失败 -> 伤害**静默消失**。
#   这里补默认 0。
# ============================================================

execute unless data storage zx:work a.u0 run data modify storage zx:work a.u0 set value 0
execute unless data storage zx:work a.u1 run data modify storage zx:work a.u1 set value 0
execute unless data storage zx:work a.u2 run data modify storage zx:work a.u2 set value 0
execute unless data storage zx:work a.u3 run data modify storage zx:work a.u3 set value 0

# ============================================================
# 【★★★ 把这一批的完整入参抄进专用基准节点 zx:work ob ★★★】
# ------------------------------------------------------------
# 【为什么要抄】一次范围伤害会 `execute as <选择器>` 逐个目标打。而 zx:work a 是
#   **全包共用的一个临时节点**(226 处引用: 流光/法球/物品备份/击杀记账/调试…),
#   任何一次嵌套调用都可能往它里面写东西。所以"这一批的原始伤害"不能只留在 a 里,
#   必须放一个**别的函数一律不碰**的节点 —— 就是 ob。
# 【谁在用 ob】只有这里写、internal/damage/one 读(每只目标开工时复原)。
# 【为什么用"整体拷贝"而不是挑几个字段】one 每次都要把 deal 需要的入参
#   (num_str / type / u0..u3 / damage)复原成"这一批的样子"; 整体抄一份最省事、
#   也不会漏字段。ob 是一次性快照, 下一批直接覆盖, 不需要清理。
# 【★ 2026-10-04 第三轮修复 ★】
#   前两轮用的是"就地改 a.damage/a.num_str, 打完再还原"。还原**本身是对的**,
#   但它有个致命前提: 循环中途没人动 a。只要有一次嵌套调用(击杀记账 /
#   物品备份 / 升级结算 / 流光回调…)碰了 a, 还原就失手 —— 表现就是
#   "升痕加伤有时漏给没升痕的目标", 随机、难复现(玩家原话: 有时候生效有时候不)。
#   换成"从 ob 复原"之后, 无论中途谁动过 a, 每只目标都在开打前被重新拉回基准值。
# ============================================================

data modify storage zx:work damage_stack append value {previous:{},input:{}}
data modify storage zx:work damage_stack[-1].previous set from storage zx:work ob
data modify storage zx:work damage_stack[-1].input set from storage zx:work a
data modify storage zx:work ob set from storage zx:work a

# ============================================================
# 【★ 攻击者 Y(×100): 这一批只反查一次 ★】(2026-10-23 第五次卡顿修复)
# ------------------------------------------------------------
# 【为什么】「升痕」加伤要判"这一击是不是来自更高处", 得拿攻击者 Y 和目标 Y 比。
#   原来 stg_mul 里写的是 `data get entity @a[nbt={UUID:...}] Pos[1]` —— 那是
#   **整份玩家 NBT 序列化**(≈10 ms, 见 lib/u_by 头注释)。范围伤害 `execute as`
#   逐个目标打 ⇒ 打 10 只、每只 3 层升痕就是 30 次 ≈ 0.3 秒, 全压在同一刻。
# 【做法】这里(循环之前)反查一次攻击者, 把 Y×100 存进 #stg_ay, 并冻进 ob.ay;
#   internal/damage/one 每只目标开工时从 ob.ay 复原 —— 嵌套伤害改过 #stg_ay
#   也不会串味(ob 是本批不可变快照, 与现行约定一致)。
# 【代价】一批一次 `data get entity` + 一次零 NBT 的计分项反查; 原本是每只一次。
# ============================================================
data modify storage zx:work ub set value {u0:0,u1:0,u2:0,u3:0}
data modify storage zx:work ub.u0 set from storage zx:work a.u0
data modify storage zx:work ub.u1 set from storage zx:work a.u1
data modify storage zx:work ub.u2 set from storage zx:work a.u2
data modify storage zx:work ub.u3 set from storage zx:work a.u3
function sweetdream:lib/u_by
scoreboard players set #stg_ay zx.meta 0
execute as @a[tag=zx.ub,limit=1] store result score #stg_ay zx.meta run data get entity @s Pos[1] 100
execute store result storage zx:work ob.ay int 1 run scoreboard players get #stg_ay zx.meta

# ============================================================
# 【★★★ 把"本次技能走的是哪条倍率通道"一并冻进 ob ★★★】(2026-10-16 批 15-4)
# ------------------------------------------------------------
# 【为什么要】燧行套装(烟履+燧帽)的加成条件是"基础攻击力类技能伤害", 判据就是
#   三条通道里的 attack_mul > 0。而通道字段**不在 zx:work a 里** —— 它在
#   manacore:work a(算伤害用的入参), 由 lib/dmg_ch 在 #manacore:event/damage_calc
#   **最前面**拍成快照 zx:work ch 保存下来(那是"这一次走了哪条通道"的唯一凭据)。
# 【为什么在这里冻、不在 one 里直接读 ch】
#   · ch 是**全局临时节点**(所有伤害共用一份)。范围伤害会 `execute as` 逐个目标打,
#     前一只的收尾钩子(圣骸 skill_kill / 殓丝 / 焦衣…)可能触发**新的 calc**,
#     把 ch 换成别人的通道 —— 那样同一发技能的第 2 只目标就会读到错的通道(随机、难复现)。
#   · 冻进 ob 之后, 同一次投递的每只目标读到的是**同一个值**; 而 ob 每次都在
#     上一行被整份覆盖, 所以也绝不会把上一发的通道带过来。
# 【为什么只抄 attack_mul】目前只有燧行要判通道; 以后要判 mm / oth, 照抄一行即可。
# 【静默不生效 = 安全的一边】用**存好的数字**直接投递的伤害(如裂缝 field_tick 每秒一跳)
#   前面没有 calc, 这一行取不到值就不写 ⇒ 下游 data get 读到 0 ⇒ 判成"不算基础攻击力类"。
#   宁可少给, 不可能多给。
# ============================================================
execute if data storage zx:work ob.channel_atk run data modify storage zx:work ob.attack_mul set from storage zx:work ob.channel_atk
execute unless data storage zx:work ob.attack_mul run data modify storage zx:work ob.attack_mul set from storage zx:work ch.attack_mul

# ★ 倾囊超限（2026-10-23 批 K8）：8 秒「固定伤害追伤」窗口 ★
#   只判两件事：这一笔是固定伤害（fixed:1b）+ 场上确实有窗口开着（#ps_live ≥ 1）。
#   两个都不成立时只多两条计分项判定，不做玩家反查（反查 UUID 是热路径，见 ol_add）。
#   ★ 算出结果只写进**专用节点 zx:work psadd**，绝不碰 ob（ob 是这一批的不可变基准，
#     谁都能写它，范围伤害就会串味）；真正加进这一笔的地方在 one 里（ol_apply）。
#   ★ psadd 每笔进来先清，避免上一笔的追伤串到这一笔。
data remove storage zx:work psadd
execute if data storage zx:work ob{fixed:1b} if score #ps_live zx.meta matches 1.. run function sweetdream:equipment/staff/pour_sack/ol_add with storage zx:work ob

$execute as $(target) run function sweetdream:internal/damage/one

data modify storage zx:work ob set from storage zx:work damage_stack[-1].previous
data modify storage zx:work a set from storage zx:work damage_stack[-1].input
data remove storage zx:work damage_stack[-1]
