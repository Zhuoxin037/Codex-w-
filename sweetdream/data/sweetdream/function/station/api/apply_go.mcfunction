# ============================================================
# sweetdream:station/api/apply_go —— 真正动手(宏: st 里带 kind/id/cat/of)
# ------------------------------------------------------------
# 【先校验】升级走 upgrade/api/fit(查定义/类别/槽位/重复);
#   无色石走 upgrade/api/fit_uncolor(查 up 非空 + 抓要消的那条);
#   超限走 overlimit/api/fit(查定义/是不是这把武器/敲没敲过)。
# 【校验不过】什么都不改, 直接把 reason 交给调用方(材料会被退回)。
#
# 【★ 改物品 NBT 的中转为什么是"临时盔甲架"、不再是"工作台箱子" ★】(2026-10-08 改)
#   老做法: `setblock 0 -59 2 minecraft:chest` 放一个箱子, 副手装备塞进去、在
#     **方块 NBT** 上改完再塞回副手, 收工再 setblock air。
#   问题: ① 世界里凭空多出一个箱子(上古版本"用箱子当升级台"的残留, 玩家报的就是它);
#          ② 依赖某个固定坐标 + forceload + 主世界, 玩家在下界/末地敲、或者那个
#             位置被别的方块占了, 整条链就断。
#   现在: summon 一个**盔甲架**(跟着玩家所在维度走) -> 物品挪到它主手 -> 改 NBT
#         -> 挪回副手 -> kill。不在世界里留下任何东西。
#   【为什么非得中转一趟】玩家自己的物品 NBT **写不进去**: 主手那格 SelectedItem
#     是只读的虚拟路径(写进去不报错、也不生效, 见 equipment/sword/myriad/swap_post
#     头注释)。而**实体**的槽位 NBT(`equipment.mainhand`)是能写的 —— 盔甲架是
#     生物, 属于这一边。同一套写法已经在 myriad/swap_post 里用过一次。
#
# 【为什么只改那几个字段】整份物品挪出去再挪回来, 途中只动 up / ol / 名字 / 描述;
#   zx、skill 和其它组件原样保留(item modify 只能整段替换 custom_data, 会把那些
#   字段冲掉, 所以不用它)。
# 【★ 同一时刻只会有一个架子 ★】下面这一整段是同步跑完的(没有 schedule),
#   所以不存在"两个玩家各有一个 zx.st_tmp 互相串味"的情况; 开头的 kill 只是
#   万一上一轮异常退出时留下的保险。
# ============================================================

execute if data storage zx:work st{kind:"upgrade"} run function sweetdream:upgrade/api/fit with storage zx:work st
execute if data storage zx:work st{kind:"uncolor"} run function sweetdream:upgrade/api/fit_uncolor with storage zx:work st
execute if data storage zx:work st{kind:"overlimit"} run function sweetdream:overlimit/api/fit with storage zx:work st
execute unless data storage zx:out r{ok:1b} run return 0

# ⓪ 【中转架】Marker 盔甲架 = 看不见 + 没有碰撞体积; 用完立刻 kill, 不留任何痕迹
#     位置就在玩家身上 —— 实体选择器默认在 @s 所在维度找, 下界/末地也没问题
kill @e[tag=zx.st_tmp]
execute at @s run summon minecraft:armor_stand ~ ~ ~ {Tags:["zx.st_tmp"],Marker:1b,Invisible:1b,NoGravity:1b,Invulnerable:1b,Silent:1b,Small:1b}

# ① 武器上中转架
item replace entity @e[tag=zx.st_tmp,limit=1] weapon.mainhand from entity @s weapon.offhand

#    【空手兜底】副手是空的(或这一步没成)就什么也别改 —— 直接拆架收工,
#     免得后面几步把 NBT 写到"空气"上、最后再把副手清成空气。
execute unless items entity @e[tag=zx.st_tmp,limit=1] weapon.mainhand * run kill @e[tag=zx.st_tmp]
execute unless items entity @e[tag=zx.st_tmp,limit=1] weapon.mainhand * run return 0

# ② 只动一个字段: 升级 = **重建 up 列表**(同系替换占一槽, 2026-10-07 槽位改版,
#    见 upgrade/api/up_rebuild —— 不再是盲目 append); 超限 = 写 ol;
#    无色石 = 删掉最后一条升级 + 返还石头(fit_uncolor 已把要还的石头 id 抓到
#    zx:work uc.id, 见 upgrade/api/uncolor_go)。
#    ★ 第一次敲的时候物品上**根本没有 up 这个键**, 直接 append 会失败(静默):
#      材料照样被消耗、但装备上什么都没写上去。所以先补一个空列表再动手。
execute if data storage zx:work st{kind:"upgrade"} unless data entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".up run data modify entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".up set value []
execute if data storage zx:work st{kind:"upgrade"} run function sweetdream:upgrade/api/up_rebuild with storage zx:work st
execute if data storage zx:work st{kind:"uncolor"} run function sweetdream:upgrade/api/uncolor_go with storage zx:work st
$execute if data storage zx:work st{kind:"overlimit"} run data modify entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".ol set value "$(of)"

# ②.4 【★ 标签(批 A): 超限形态 = 基础标签 + "overlimit" ★】(2026-10-10)
#      物品的 custom_data.tags 是 give 时按 _tags_data.py 写好的基础标签;
#      敲超限这一刻给它**追加**一个 "overlimit" 词 —— 以后的肉鸽地图就能一句
#      `custom_data~{tags:["overlimit"]}` 捞出所有超限形态。
#      【为什么只追加这一个词】"超限换机制"的差异(如海棠超限不清渊海改附加)
#      在 tag 粒度上不额外表达 —— 用户 2026-10-10 定: 用**专设标记词**即可。
#      【先补空列表】万一物品上根本没有 tags(give 直接带, 但老物品可能没有),
#      对不存在的键 append 会**静默失败** ⇒ 先判后补。
#      【一次性】overlimit/api/fit 已保证"没敲过才放行", 所以不会重复追加。
execute if data storage zx:work st{kind:"overlimit"} unless data entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".tags run data modify entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".tags set value []
execute if data storage zx:work st{kind:"overlimit"} run data modify entity @e[tag=zx.st_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".tags append value "overlimit"

# ②.5 【名字和描述都要跟着变】光改数据、物品看上去还是老样子, 拿着会以为没生效。
#      交给 station/api/lore_refresh 整段重建:
#        · 没超限 -> 原描述(custom_data.lore_base) + 升级一节, 名字不动
#        · 敲了超限 -> 名字换成 oldef.<ol>.name(超限·XX),
#                      **描述整段换成** oldef.<ol>.lore + 升级一节
#          (超限把技能整个换掉了, 只追加一行的话玩家仍然只看到旧技能)
#      重建是幂等的, 敲几次都不会堆出重复标题。
function sweetdream:station/api/lore_refresh with storage zx:work st

# ③ 武器回副手
#    【为什么用 if items 兜一层】只认"中转槽里有没有东西", 不依赖上面那些
#      NBT 路径写对了没有 —— 就算 ② 全都没成, 装备也会原样回到副手,
#      绝不会因为半途失败让装备消失。
execute if items entity @e[tag=zx.st_tmp,limit=1] weapon.mainhand * run item replace entity @s weapon.offhand from entity @e[tag=zx.st_tmp,limit=1] weapon.mainhand

# ④ 拆架(不依赖任何方块/坐标/维度, 世界里什么都不留)
kill @e[tag=zx.st_tmp]
