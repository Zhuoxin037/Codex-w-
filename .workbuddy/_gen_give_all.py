# -*- coding: utf-8 -*-
"""
生成 sweetdream:debug/give_all —— "把至今全部的东西装进潜影盒给自己"。

【★ 为什么不能手抄一遍物品组件 ★】
  每件装备的 components 是一大坨(item_name/lore/custom_data/skill/...),
  手抄一份进 give_all 就等于"同一件物品有两份定义", 以后改装备必然忘同步。
  所以这里改成: **直接调它自己的 give 函数**, 拿到的永远是最新定义。

【东西怎么进盒子】
  give 只会把物品丢进"第一个空格", 槽位不确定 -> 先把 hotbar.0 清空,
  它就必定落在 hotbar.0; 再从那儿 `item replace` 抄进潜影盒方块, 然后清掉。
  用完把玩家原本那一格还回去(先还, 再发盒子, 免得盒子占了 hotbar.0)。

【潜影盒方块怎么变成物品】
  `loot give @s mine <pos> minecraft:diamond_pickaxe`。
  1.21.5 的 blocks/shulker_box 战利品表带
  `copy_components{source:block_entity, include:[custom_name, container, ...]}`,
  所以内容和名字都会跟着走(这条是从本体 jar 里查出来的, 不是猜的)。

【★ 为什么现在按 27 自动分包, 而不是写死两个盒子 ★】
  潜影盒只有 27 格。以前 21 件装备刚好一盒; 2026-10-04 加了 7 把武器后变成
  28 件 —— 写死"一盒装备"就会**悄悄丢掉第 28 件**(超出格子的 item replace 不报错、
  界面也看不出来)。所以改成: 把所有东西按 27 一件一件塞, 塞满就开下一个盒子。
  当前 28 装备 + 7 材料 = 35 件 -> 正好两盒(27 + 8)。
"""
import glob, io

BASE = "D:/数据包/sweetdream/data/sweetdream/function"
OUT = BASE + "/debug/give_all.mcfunction"
BOX_CAP = 27
# 盒子方块坐标(和强化台 0,-59,2 错开; 0,-60,2 留给暂存箱)
#   ★ 每 27 件开一个盒子: 2026-10-07 晚 83 装备 + 31 石头 = 114 件 -> 5 盒。
#     加装备/石头后如果这里不够, 脚本会 assert 报错(不会静默丢件), 照提示补坐标即可。
BOX_POS = ["0 -60 1", "0 -60 3", "0 -60 5", "0 -60 7", "0 -60 9"]
# ★ 只能是**染料色**(白/橙/品红/淡蓝/黄/黄绿/粉/灰/淡灰/青/紫/蓝/棕/绿/红/黑)——
#   潜影盒方块只有这 16 种染色版 + 1 个默认版。写 gold/light_purple/aqua 这种
#   "只有文字组件才认的颜色", setblock 会失败 -> 中转站建不起来 -> 盒子全发不出去。
#   (2026-10-04 踩过: 原来写的就是 gold/light_purple/aqua, 玩家拿到的是空的。)
BOX_COLOR = ["yellow", "purple", "cyan", "red", "lime"]

# ★ 名字用的**文字组件颜色**和方块色名不是一套! ★
#   方块色名 purple / cyan / lime 在文字组件里**不合法**
#   (文字色叫 light_purple / aqua / green)—— 名字会整条被丢弃
#   (日志: "Failed to parse custom name, discarding: Invalid color name: purple"),
#   盒子就没名字了。所以这里单独映射一套合法的文字色。
NAME_COLOR = {"yellow": "yellow", "purple": "light_purple",
              "cyan": "aqua", "red": "red", "lime": "green"}

# 盒 A: 装备(按 盔甲 -> 剑 -> 斧 -> 弓 -> 法杖 -> 工具 排)
A = []
for cat in ("armor", "sword", "axe", "bow", "staff", "tool"):
    A += sorted(glob.glob(BASE + "/equipment/%s/*/give.mcfunction" % cat))
# 盒 B: 强化材料
B = sorted(glob.glob(BASE + "/upgrade/item/*.mcfunction")) + \
    sorted(glob.glob(BASE + "/overlimit/item/*.mcfunction"))

ITEMS = A + B
BOXES = [ITEMS[i:i + BOX_CAP] for i in range(0, len(ITEMS), BOX_CAP)]
assert len(BOXES) <= len(BOX_POS), "盒子数超过预留坐标数, 请给 BOX_POS 再加一个坐标"


def fn(p):
    p = p.replace("\\", "/")
    rel = p[len(BASE) + 1:]           # equipment/armor/brain_leech/give.mcfunction
    rel = rel[: -len(".mcfunction")]
    return "sweetdream:" + rel


def fill(lst, boxpos):
    """每件三行: 给 -> 抄进盒子 -> 清过路位"""
    out = []
    for i, p in enumerate(lst):
        out.append("function " + fn(p))
        out.append("item replace block %(b)s container.%(i)d from entity @s hotbar.0" % {"b": boxpos, "i": i})
        out.append("item replace entity @s hotbar.0 with minecraft:air")
    return out


L = []
A_ = L.append
A_("# ============================================================")
A_("# sweetdream:debug/give_all —— 把「至今全部的东西」打包成潜影盒给自己")
A_("# ------------------------------------------------------------")
A_("# 【这个文件是生成的】改了物品 / 加了新装备, 重跑:")
A_("#     python .workbuddy/_gen_give_all.py")
A_("# 【用法】/function sweetdream:debug/give_all   或   /trigger zx.dbg_give")
A_("#")
A_("# 【为什么是 %d 个盒子】潜影盒只有 %d 格, 而东西一共 %d 件" % (len(BOXES), BOX_CAP, len(ITEMS)))
A_("#   (%d 件装备 + %d 块强化石) —— 按每盒 %d 件自动分包。"
   % (len(A), len(B), BOX_CAP))
A_("#")
A_("# 【怎么做到的】走一个方块当中转站:")
A_("#   ① 在下面这些坐标放空潜影盒方块(和强化台 0,-59,2 错开、同一个区块)")
A_("#   ② 每件东西: 调它自己的 give -> 落到 hotbar.0 -> 抄进盒子 -> 清掉过路位")
A_("#   ③ /loot give @s mine 把潜影盒挖下来(战利品表会带上内容和名字)")
A_("#")
A_("# 【为什么要借 hotbar.0】/give 只丢进「第一个空格」, 槽位不确定;")
A_("#   先把 hotbar.0 清空它就必定落这儿。用完**先还原**、再发盒子,")
A_("#   顺序反了盒子会占掉 hotbar.0、把玩家原来的东西顶掉。")
A_("#")
A_("# 【注意】方块坐标用的是**玩家所在维度**。这套坐标是主世界的固定点,")
A_("#   在下界/末地跑会失败(和强化台一样的限制)。")
A_("# ============================================================")
A_("")
A_("# ---- ① 中转站: 每个盒子一个方块 + 一个暂存箱 ----")
A_("#   【为什么用染色潜影盒】就算名字没写上(见下), 颜色也能一眼分清哪个是哪个。")
for k, pos in enumerate(BOX_POS[:len(BOXES)]):
    A_("setblock %s minecraft:%s_shulker_box replace" % (pos, BOX_COLOR[k % len(BOX_COLOR)]))
A_("setblock 0 -60 2 minecraft:chest replace")
for pos in BOX_POS[:len(BOXES)]:
    A_("data modify block %s Items set value []" % pos)
A_("data modify block 0 -60 2 Items set value []")
# 名字怎么写的两条规矩(都踩过):
# ① **路径**: 1.21.5 里容器的 custom_name 是"隐式组件", 方块实体上就存成
#    根节点的 CustomName(不是 components."minecraft:custom_name" —— 那个是
#    多余的一层垃圾键, 写了也不生效)。
# ② **值必须是 JSON 文本组件本身, 不能再套一层引号** ——
#    `set value '{"text":"..."}'` 会把整串当成**纯字符串**塞进去, 游戏里看到的就是
#    这行 JSON 源码, 而不是渲染后的名字。所以引号一律不加。
for k, pos in enumerate(BOX_POS[:len(BOXES)]):
    txt = '{"text":"sweetdream · 盒%d (%d 件)","color":"%s","italic":false}' % (
        k + 1, len(BOXES[k]), NAME_COLOR[BOX_COLOR[k % len(BOX_COLOR)]])
    A_('data modify block %s CustomName set value %s' % (pos, txt))
A_("#   【兜底提示】要是中转站没建成(区块没加载 / 你不在主世界), 后面全都会")
A_("#   静默失败 —— 与其让你以为发了但没给, 不如直接说出来。")
A_('execute unless block %s #minecraft:shulker_boxes run tellraw @s '
   '[{"text":"[调试] 中转站没建成: 盒子都没发出去。'
   '这条只支持主世界, 且那个坐标的区块得是加载的。","color":"red"}]' % BOX_POS[0])
A_("")
A_("# ---- ② 借 hotbar.0 当过路位(先把它原本的东西存起来) ----")
A_("item replace block 0 -60 2 container.0 from entity @s hotbar.0")
A_("item replace entity @s hotbar.0 with minecraft:air")
A_("")
for k, pos in enumerate(BOX_POS[:len(BOXES)]):
    A_("# ---- ③ 盒 %d: %d 件 ----" % (k + 1, len(BOXES[k])))
    L.extend(fill(BOXES[k], pos))
    A_("")
A_("# ---- ④ 先把玩家原本的 hotbar.0 还回去(再发盒子, 免得被顶掉) ----")
A_("item replace entity @s hotbar.0 from block 0 -60 2 container.0")
A_("")
A_("# ---- ⑤ 把盒子挖下来给自己 ----")
for pos in BOX_POS[:len(BOXES)]:
    A_("loot give @s mine %s minecraft:diamond_pickaxe" % pos)
A_("")
A_("# ---- ⑥ 收尾: 拆掉中转站 ----")
for pos in BOX_POS[:len(BOXES)]:
    A_("setblock %s minecraft:air replace" % pos)
A_("setblock 0 -60 2 minecraft:air replace")
A_('tellraw @s [{"text":"[调试] 已发: %d 件东西, 共 %d 个盒子。","color":"dark_gray"}]'
   % (len(ITEMS), len(BOXES)))

io.open(OUT, "w", encoding="utf-8", newline="\n").write("\n".join(L) + "\n")
print("written:", OUT)
print("共 %d 件东西 / %d 个盒子" % (len(ITEMS), len(BOXES)))
for k, bx in enumerate(BOXES):
    print("  盒%d (%d 件):" % (k + 1, len(bx)))
    for p in bx:
        print("     ", fn(p))
