# ============================================================
# sweetdream:upgrade/api/uncolor_give —— 返还"被消的那条 + 它的全部前置"(宏 {id})
# ------------------------------------------------------------
# 【宏参数】zx:work uc {id} = 被消那条的石头 id(fit_uncolor 抓的, 全程不改)
# 【★ 2026-10-07 改: 整条链一起还 ★】玩家口径 —— "拆 β / Ω 时要把它低级的也还回来":
#   敲 β 的前提是先敲过 α(替换制下 α 已经被 β 顶掉、不在物品上了),
#   所以消掉 β 时玩家实际损失的是 α+β **两颗**。于是沿定义表的 req 链往上递归,
#   每级还一颗(Ω -> β -> α, 链顶 req 为空即停)。
# 【为什么"物品上还留着的"不还】老物品(旧规则敲的, 同系可能残留两条)消掉最后一条后,
#   留下的那条还在物品上 —— 再还一颗就是**凭空多发**。所以 uncolor_go 把"留在物品上
#   的 id"记进 zx:work kept 键集, 这里跳过它们。
# 【为什么用 ucnext 而不是改 uc.id】uc.id 要留给 uncolor_msg 显示"消掉的是哪条",
#   递归游标放另一个节点, 两边互不干扰。
# 【防止 req 写错成环】带深度计数 #uc_d(uncolor_go 归零), 超过 5 层直接停
#   (正常链最长 3 层: α/β/Ω)。
# 【执行者】玩家 —— item/<id> 里全是 give @s, 正好落进背包(满了掉地上)。
# ============================================================

# 这一级: 物品上本来就还留着 -> 不还(免得凭空多发)
$execute unless data storage zx:work kept."$(id)" run function sweetdream:upgrade/item/$(id)

# 沿 req 链往上走一级(链顶的 req = "" -> 停)
scoreboard players add #uc_d zx.meta 1
execute if score #uc_d zx.meta matches 6.. run return 0
data modify storage zx:work ucnext.id set value ""
$data modify storage zx:work ucnext.id set from storage zx:config updef."$(id)".req
execute unless data storage zx:work ucnext{id:""} run function sweetdream:upgrade/api/uncolor_give with storage zx:work ucnext
