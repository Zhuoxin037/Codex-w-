# ============================================================
# sweetdream:equipment/staff/pour_sack/ol_add —— 倾囊超限：固定伤害追伤（反查施法者）
# ------------------------------------------------------------
# 【谁调用】internal/damage/with_from（固定伤害的**唯一**投递口）
#   调用条件：这一笔带 fixed:1b，且场上确实有人开着窗口（#ps_live ≥ 1）。
# 【为什么在这里反查、不在别处】with_from 的执行者是"谁调用的就是谁"（往往是受害者
#   或一个 marker），手里没有施法者上下文；唯一能认出施法者的是 a.u0..u3（UUID 四个 int）。
# 【★ 成本 ★】@a[nbt={UUID:[I;...]}] 是玩家全量 NBT 反查 ≈10ms/次 ⇒ 所以必须先过
#   `#ps_live` 这道闸：没人开着窗口时这条命令一行都不跑。
# 【★ 宏参数从 zx:work ob 取 ★】with_from 已经把这一批的入参整份冻进 ob，
#   u0..u3 就在里面（缺字段时 with_from 已兜底补 0）。
# ============================================================
$data modify storage zx:work ub set value {u0:$(u0),u1:$(u1),u2:$(u2),u3:$(u3)}
function sweetdream:lib/u_by
execute as @a[tag=zx.ub] at @s if score @s zx.ps_at > #now manacore.meta run function sweetdream:equipment/staff/pour_sack/ol_add_go
