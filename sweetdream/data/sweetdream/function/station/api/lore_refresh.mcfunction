# ============================================================
# sweetdream:station/api/lore_refresh —— 把"装了什么"写回物品的 lore
# ------------------------------------------------------------
# 【谁调用它】station/api/apply_go 改完 up / ol 之后、把装备送回副手之前;
#            debug/lore 也调它(给已经敲过的老物品刷新描述)。
#
# 【★ 改的是"中转架上的那件" ★】(2026-10-08 改)
#   物品 NBT 不能直接改玩家的槽位, 所以调用方先把装备挪到临时盔甲架
#   (@e[tag=zx.st_tmp,limit=1] 的主手 = equipment.mainhand)上,
#   本函数只负责改**架子上这一件**; 送回副手由调用方做。
#   (2026-10-08 之前改的是 0,-59,2 那个"工作台箱子"里的格子 —— 已废。)
#
# 【★ 为什么不直接 append ★】
#   lore 是一次append就多一行的数据结构, 第二次敲就会出现两份"升级"标题。
#   所以每次都从头重建, 敲几次都只有一份。
#
# 【★ 超限 = 整段替换, 不是追加 ★】(2026-10-04 改)
#   旧做法是"原始描述 + 追加一行 ✦ 超限"。问题: 超限往往**把技能整个换掉了**
#   (流光的右键从"锁定 1 个 ×2"变成"4 个 ×4 + 缓慢"), 而描述里还写着旧技能 ——
#   平时拿着根本看不出自己现在放的是什么。
#   现在的规则:
#     有 ol  -> **改名**成 oldef.<ol>.name + 描述 = oldef.<ol>.lore(**整段**, 原描述一行不留)
#     没 ol  -> 名字不动, 描述 = custom_data.lore_base(原描述备份)
#   两种方式最后都会再追加"升级一节"(升级效果是真实叠加的, 必须看得见)。
#
# 【原始 lore 为什么还要备份】没超限的物品要靠它还原; 即使已经超限也留着,
#   省得以后想看"原本长什么样"的时候没得查。
#
# 【★ 2026-10-14 起描述正文也能"跟着源走" ★】
#   正文不再只能从 lore_base 还原: 先查 `lore/base_dispatch`
#   (由 .workbuddy/_gen_lore_src.py 从发放函数抽出的 id -> 最新名字+描述表),
#   命中就用**源里的最新**文本, 并把 item_name 与 lore_base 一并跟上;
#   没命中才回落。⇒ 改了 give 里的描述, 重跑 `_gen_lore_src.py --write`,
#   拿物品在副手刷一遍即可 —— **不用重新 give / 重新发**。细节见 ② 段注释。
#
# 【★ 同系为什么要挑最高一级 ★】
#   α/β/Ω 是"高阶覆盖低阶"(见 upgrade/def/load), 三条都列出来会被误读成叠加。
#   所以先扫一遍记下每系的最高 tier(zx:work mkt."<系名>"),
#   第二遍只渲染"自己的 tier == 本系最高"的那些(也就每条升级一行)。
#
# 【出参】无。结果直接写在**中转架上那件物品**上, 由调用方送回副手。
# ============================================================

# ① 原始 lore 只备份一次
#    【为什么要加 if data 那半个条件】物品本来就没 lore 时 "set from" 会失败,
#    虽然不影响结果, 但命令失败在日志/聊天里都可能留痕 —— 先判再拷干净得多。
#    本来就没有任何 lore 的物品补一个空列表, 免得 ② 那步拷不到东西。
execute if data entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:lore" unless data entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".lore_base run data modify entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".lore_base set from entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:lore"
execute unless data entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".lore_base run data modify entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".lore_base set value []

# ② 基底: 三档优先级, 从下往上覆盖
#    【2026-10-14 新增 ②-a「硬刷新」—— 为什么】原实现只从 `custom_data.lore_base`
#      还原, 而 lore_base 是"**第一次刷新时从物品身上拷下来的**": 也就是说刷多少遍
#      都只是把当初那份重写一遍。改了 give 里的描述再来刷, 结果**一模一样**
#      (用户报的"刷新了没用"就是这个)。现在改成先查 `lore/base_dispatch`
#      (由 .workbuddy/_gen_lore_src.py 从 154 个发放函数生成的 id -> 最新名字+描述表):
#        · 命中 -> 用**源里的最新**文本, 顺带把 item_name 也换新, 并回写 lore_base;
#        · 没命中(老物品/未收录/非装备) -> 才回落到物品自带的 lore_base。
#    【★ 超限还要改名 ★】物品名从「流光」变成「超限·流光」(overlimit/api/name_seed),
#      所以 ②-c 必须排在 ②-a 的改名**之后** —— 否则超限名会被基础名盖回去。
#
# ---- ②-a 硬刷新: 查源表 (命中则名字/描述一律用最新源) ----
data remove storage zx:work src
execute if data entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".zx[0] run data modify storage zx:work src.id set from entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".zx[0]
data remove storage zx:work base_new
function sweetdream:lore/base_dispatch
#    命中判据 = base_dispatch 往 lore 里写了非空列表 (它自己每次先清空, 见其头注)
execute if data storage zx:work lore[0] run data modify entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:item_name" set from storage zx:work namesrc
#    先把"纯正文"抓一份出来: 稍后 ③ 会往 lore 里 append 升级节, 那份不能进备份
execute if data storage zx:work lore[0] run data modify storage zx:work base_new set from storage zx:work lore
# ---- ②-b 回落: 源表没收录 -> 用物品自带的描述备份 ----
execute unless data storage zx:work lore[0] run data modify storage zx:work lore set from entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".lore_base
# ---- ②-c 超限优先(整段替换) ----
execute if data entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".ol run data modify storage zx:work mk.ol set from entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".ol
execute if data entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".ol run function sweetdream:overlimit/api/lore_seed with storage zx:work mk

data modify storage zx:work nm set value {ol:""}
execute if data entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".ol run data modify storage zx:work nm.ol set from entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".ol
execute if data entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".ol run function sweetdream:overlimit/api/name_seed with storage zx:work nm

# ---- ③ 升级一节 ----
#   第一遍: 记下每条升级所属系列里出现过的最高 tier
data remove storage zx:work mkt
data modify storage zx:work mk set value {id:"",ser:"",lab:"",note:""}

execute if data entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".up[0] run data modify storage zx:work mk.id set from entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".up[0]
execute if data entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".up[0] run function sweetdream:upgrade/api/lore_mark with storage zx:work mk
execute if data entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".up[1] run data modify storage zx:work mk.id set from entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".up[1]
execute if data entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".up[1] run function sweetdream:upgrade/api/lore_mark with storage zx:work mk
execute if data entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".up[2] run data modify storage zx:work mk.id set from entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".up[2]
execute if data entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".up[2] run function sweetdream:upgrade/api/lore_mark with storage zx:work mk
execute if data entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".up[3] run data modify storage zx:work mk.id set from entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".up[3]
execute if data entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".up[3] run function sweetdream:upgrade/api/lore_mark with storage zx:work mk

#   有小标题才加(一件升级都没有就别留个孤零零的 ✦ 升级)
execute if data entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".up[0] run data modify storage zx:work lore append value {"text":" ","italic":false}
execute if data entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".up[0] run data modify storage zx:work lore append value {"text":"✦ 升级","color":"gold","bold":true,"italic":false}

#   第二遍: 只渲染"本系最高 tier"的那几条
execute if data entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".up[0] run data modify storage zx:work mk.id set from entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".up[0]
execute if data entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".up[0] run function sweetdream:upgrade/api/lore_line with storage zx:work mk
execute if data entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".up[1] run data modify storage zx:work mk.id set from entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".up[1]
execute if data entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".up[1] run function sweetdream:upgrade/api/lore_line with storage zx:work mk
execute if data entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".up[2] run data modify storage zx:work mk.id set from entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".up[2]
execute if data entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".up[2] run function sweetdream:upgrade/api/lore_line with storage zx:work mk
execute if data entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".up[3] run data modify storage zx:work mk.id set from entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".up[3]
execute if data entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".up[3] run function sweetdream:upgrade/api/lore_line with storage zx:work mk

# ---- ④ 写回物品 ----
#    (★ 这里**没有**"超限一节"了: 超限的描述已经在 ② 里整段替换掉了,
#      再补一行标题就重复了。超限+升级同时存在时, 升级那几行仍会跟在
#      超限描述后面 —— 升级效果是真实叠加的, 必须看得见。)
data modify entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:lore" set from storage zx:work lore

#    【★ 硬刷新命中时, 把备份也换成最新的纯正文】否则 lore_base 会永远钉在
#      "第一次刷"那一版: 万一以后源表漏收某件(新装备还没重跑生成器), 回落
#      拿到的就是上古文本 —— 又变成"刷新了没用"。
execute if data storage zx:work base_new run data modify entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".lore_base set from storage zx:work base_new

function sweetdream:profession/item_presentation
