# ============================================================
# sweetdream:equipment/sword/myriad/swap_post —— 换手**之后**: 把丢掉的东西补回物品
# ------------------------------------------------------------
# 【宏参数】zx:work mqk {v, h}
#      v = 换完之后手里是哪一把: "myriad" / "qiansan"(取 oldef."<v>" 那份定义)
#      h = 动哪只手: "weapon.mainhand" / "weapon.offhand"
# 【谁调用它】equipment/sword/myriad/swap 的最后一行
#
# 【★ 为什么必须"物品 -> 中转 -> 改 -> 回手"这条链 ★】
#   玩家的物品 NBT **不能直接写**: 主手那格 SelectedItem 是只读的虚拟路径
#   (写进去不报错、也不生效), ItemInventory / Inventory 那套老写法改完不同步。
#   唯一能落地的办法是: 把整份物品挪到一个**真实体**的槽位上改, 再整份挪回来。
#
# 【★ 中转为什么用临时盔甲架、不用方块 ★】(2026-10-08 改)
#   上一版照抄 station/api/apply_go 那套"工作台箱子"(0,-59,2 自动 setblock 一个箱子)。
#   敲石头那种低频操作用它可以, 但**换手是每次放技能都跑一次的战斗路径**:
#     ① 依赖世界里存在某个方块 —— 被玩家挖掉 / 被别的功能占位就整条断掉;
#     ② 箱子坐标要靠 forceload + in overworld 兜底, 多一层"看不见的耦合"。
#   盔甲架是实体, 跟着玩家所在维度走, 不在世界里留下任何东西, 用完 kill。
#
# 【补三样】① custom_data.up(升级石列表, 普通版也一样会丢, 所以无条件补)
#           ② custom_data.ol(超限标记, 只有超限版有)
#           ③ item_name + lore(超限版整段换成 oldef."<v>" 那份)
# 【丢刀的兜底】⑤ 那句只看"中转槽里有没有东西" —— 就算 ③④ 因为路径写错全没成,
#   刀也会原样回到手里(最坏是 up / ol 没补上), 绝不会因为半途失败让武器消失。
# ============================================================

# ⓪ 换成了吗? 手里不是预期那把(这 3 tick 里丢了/换手了)就什么都不做
$execute unless items entity @s $(h) *[minecraft:custom_data~{zx:["$(v)"]}] run data remove storage zx:work mq_up
$execute unless items entity @s $(h) *[minecraft:custom_data~{zx:["$(v)"]}] run return 0

# ① 临时盔甲架(Marker = 看不见 + 没有碰撞体积; 用完立刻 kill, 不留任何痕迹)
#     位置就在玩家身上 —— 实体选择器默认在 @s 所在维度找, 下界/末地也没问题
execute at @s run summon minecraft:armor_stand ~ ~ ~ {Tags:["zx.mq_tmp"],Marker:1b,Invisible:1b,NoGravity:1b,Invulnerable:1b,Silent:1b,Small:1b}

# ② 武器上中转架
$item replace entity @e[tag=zx.mq_tmp,limit=1] weapon.mainhand from entity @s $(h)

# ③ 【升级石】没敲过石头时 mq_up 这个键不存在, 这条自然不跑
execute if data storage zx:work mq_up run data modify entity @e[tag=zx.mq_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".up set from storage zx:work mq_up

# ④ 【超限·标记】只有超限版写(基础版写了就变超限了)
execute if score @s zx.mq_ol matches 1 run data modify entity @e[tag=zx.mq_tmp,limit=1] equipment.mainhand.components."minecraft:custom_data".ol set value "myriad"

#    【超限·名字】oldef."<v>".name 就是完整的文本组件, 整段拷
$execute if score @s zx.mq_ol matches 1 if data storage zx:config oldef."$(v)".name run data modify entity @e[tag=zx.mq_tmp,limit=1] equipment.mainhand.components."minecraft:item_name" set from storage zx:config oldef."$(v)".name

#    【超限·描述】整段替换(不是追加): 有定义才写, 免得万一漏了把物品变成没描述
$execute if score @s zx.mq_ol matches 1 if data storage zx:config oldef."$(v)".lore run data modify entity @e[tag=zx.mq_tmp,limit=1] equipment.mainhand.components."minecraft:lore" set from storage zx:config oldef."$(v)".lore

# ⑤ 武器回手(用 if items 判"中转槽有东西", 不依赖任何 NBT 路径写对了没有)
$execute if items entity @e[tag=zx.mq_tmp,limit=1] weapon.mainhand * run item replace entity @s $(h) from entity @e[tag=zx.mq_tmp,limit=1] weapon.mainhand

# ⑥ 拆架(这一整套是同步跑完的, 不存在"两个玩家各有一个架子同时存在"的情况)
kill @e[tag=zx.mq_tmp]

data remove storage zx:work mq_up
