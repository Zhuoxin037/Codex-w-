# ============================================================
# internal/debug/purge_registry —— 按"UUID 终身清单"清掉索引之外的残留记录
# ------------------------------------------------------------
# 【为什么需要它】debug/reset_all 先靠 index/foreach 遍历**索引**里的玩家;
#   而 internal/leave/body 会在玩家离线时删掉他的索引条目(槽位要回收再利用),
#   于是"离线玩家的 players 记录"落在索引之外, 遍历不到
#   ⇒ 只看索引的话, 清档只清了在线的人, 离线的人下次上线还是老数据。
# ------------------------------------------------------------
# 【★ 2026-10-10 踩坑记录(务必别写回去)★】
#   曾经想用"不带路径"的写法删掉整个存储根: `data remove storage manacore:players`。
#   结果: **整个函数加载失败**, 游戏日志里是
#     Failed to load function manacore:debug/reset_all
#     Whilst parsing command on line 23: 未知或不完整的命令, 错误见下
#       at position 36: ...re:players<--[HERE]
#   原因: 官方语法是 `/data remove (block|entity|storage) <path>` ——
#     <path> 是**必填**参数(不给就是"命令不完整");
#     `/data modify (block|entity|storage) <targetPath> …` 的 <targetPath> 同样必填。
#     ⇒ **命令存储的"根"在纯命令层面删不掉**, 只能一个一个键地删。
#   守门: check.py 的 datarm 规则(不带 path 的 data remove)与
#     dstore 规则(id 与路径粘连)会把这类写法拦在仓库里。
# ------------------------------------------------------------
# 【所以改用】一张可遍历的"终身清单": manacore:players_all.list(**裸 uuid 字符串**列表)。
#   登记发生在**记录诞生处**(共 5 处, 每处一行):
#     internal/player/create(API 按需建记录)、internal/join/new(新玩家)、
#     internal/debug/reset_one(管理员重置)、
#     internal/uuid/migrate 与 internal/uuid/join(旧键迁移时新建的键)。
#   ★ 为什么不在 join/register 或 leave/body 登记: 那两处**每次上线/离线都会跑**,
#     而清单元素是裸字符串、**没法判重**(判重需要 `list[{u:"…"}]` 这种列表过滤谓词,
#     本包没有先例、也无法离线验证) ⇒ 会让清单每上线一次就长一条。
#     放在"建记录处"则天然唯一: 那些地方都是 `unless data … players "$(uuid)"` 之后
#     才建记录, 同一条记录一辈子只登记一次。
#   ★ **以后新增"建 players 记录"的地方, 必须同样登记一行**(否则那条记录清不到)。
# 【边界】本次改动之前就已离线的老记录不在清单里(纯命令枚举不出未知键),
#   他们下次上线 / 被 reset 时会自动补进清单。
# 【宏参数】无
# ============================================================
scoreboard players set #pli manacore.meta 0
# ★ 会整份覆盖 manacore:work.a —— 调用方(debug/reset_all)在此之后只用
#   free_slots / 计分项 / @a 选择器, 不再读它的 i/uuid 字段, 所以是安全的。
data modify storage manacore:work a set value {i:0,uuid:""}
# 清单为空时 _go 的首行守卫直接返回, 这里不会出错
function manacore:internal/debug/purge_registry_go with storage manacore:work a
# 清单本身也清掉(下一次从空开始)
data modify storage manacore:players_all list set value []
