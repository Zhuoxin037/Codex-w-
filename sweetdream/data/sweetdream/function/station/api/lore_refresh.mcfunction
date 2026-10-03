# ============================================================
# sweetdream:station/api/lore_refresh —— 把"装了什么"写回物品的 lore(宏 {x,y,z})
# ------------------------------------------------------------
# 【谁调用它】station/api/apply_go 改完 up / ol 之后、把装备送回副手之前;
#            debug/lore 也调它(给已经敲过的老物品刷新描述)。
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
# 【★ 同系为什么要挑最高一级 ★】
#   α/β/Ω 是"高阶覆盖低阶"(见 upgrade/def/load), 三条都列出来会被误读成叠加。
#   所以先扫一遍记下每系的最高 tier(zx:work mkt."<系名>"),
#   第二遍只渲染"自己的 tier == 本系最高"的那些(也就每条升级一行)。
#
# 【出参】无。结果直接写在工作台那一格的物品上, 由调用方送回副手。
# ============================================================

# ① 原始 lore 只备份一次
#    【为什么要加 if data 那半个条件】物品本来就没 lore 时 "set from" 会失败,
#    虽然不影响结果, 但命令失败在日志/聊天里都可能留痕 —— 先判再拷干净得多。
#    本来就没有任何 lore 的物品补一个空列表, 免得 ② 那步拷不到东西。
$execute if data block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:lore" unless data block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".lore_base run data modify block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".lore_base set from block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:lore"
$execute unless data block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".lore_base run data modify block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".lore_base set value []

# ② 基底: 超限优先(整段替换), 否则从备份还原
#    【两条为什么互斥写】先跑"没超限"那条干净还原, 再让"超限"那条覆盖过去 ——
#    顺序倒过来会把超限 lore 又盖回原描述。
#    【★ 超限还要改名 ★】不只是描述: 物品名也从「流光」变成「超限·流光」
#      (overlimit/api/name_seed), 否则拿在手里跟原来那把看着一模一样。
#      name_seed 要坐标, 所以单独打包一个 nm = {x,y,z,ol} —— 宏参数不能套娃,
#      先把 ol 从物品上读出来, 再带着坐标一起传进去。
$data modify storage zx:work lore set from block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".lore_base
$execute if data block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".ol run data modify storage zx:work mk.ol set from block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".ol
$execute if data block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".ol run function sweetdream:overlimit/api/lore_seed with storage zx:work mk

$data modify storage zx:work nm set value {x:$(x),y:$(y),z:$(z),ol:""}
$execute if data block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".ol run data modify storage zx:work nm.ol set from block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".ol
$execute if data block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".ol run function sweetdream:overlimit/api/name_seed with storage zx:work nm

# ---- ③ 升级一节 ----
#   第一遍: 记下每条升级所属系列里出现过的最高 tier
data remove storage zx:work mkt
data modify storage zx:work mk set value {id:"",ser:"",lab:"",note:""}

$execute if data block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".up[0] run data modify storage zx:work mk.id set from block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".up[0]
$execute if data block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".up[0] run function sweetdream:upgrade/api/lore_mark with storage zx:work mk
$execute if data block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".up[1] run data modify storage zx:work mk.id set from block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".up[1]
$execute if data block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".up[1] run function sweetdream:upgrade/api/lore_mark with storage zx:work mk
$execute if data block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".up[2] run data modify storage zx:work mk.id set from block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".up[2]
$execute if data block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".up[2] run function sweetdream:upgrade/api/lore_mark with storage zx:work mk
$execute if data block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".up[3] run data modify storage zx:work mk.id set from block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".up[3]
$execute if data block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".up[3] run function sweetdream:upgrade/api/lore_mark with storage zx:work mk

#   有小标题才加(一件升级都没有就别留个孤零零的 ✦ 升级)
$execute if data block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".up[0] run data modify storage zx:work lore append value {"text":" ","italic":false}
$execute if data block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".up[0] run data modify storage zx:work lore append value {"text":"✦ 升级","color":"gold","bold":true,"italic":false}

#   第二遍: 只渲染"本系最高 tier"的那几条
$execute if data block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".up[0] run data modify storage zx:work mk.id set from block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".up[0]
$execute if data block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".up[0] run function sweetdream:upgrade/api/lore_line with storage zx:work mk
$execute if data block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".up[1] run data modify storage zx:work mk.id set from block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".up[1]
$execute if data block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".up[1] run function sweetdream:upgrade/api/lore_line with storage zx:work mk
$execute if data block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".up[2] run data modify storage zx:work mk.id set from block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".up[2]
$execute if data block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".up[2] run function sweetdream:upgrade/api/lore_line with storage zx:work mk
$execute if data block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".up[3] run data modify storage zx:work mk.id set from block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".up[3]
$execute if data block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:custom_data".up[3] run function sweetdream:upgrade/api/lore_line with storage zx:work mk

# ---- ④ 写回物品 ----
#    (★ 这里**没有**"超限一节"了: 超限的描述已经在 ② 里整段替换掉了,
#      再补一行标题就重复了。超限+升级同时存在时, 升级那几行仍会跟在
#      超限描述后面 —— 升级效果是真实叠加的, 必须看得见。)
$data modify block $(x) $(y) $(z) Items[{Slot:0b}].components."minecraft:lore" set from storage zx:work lore
