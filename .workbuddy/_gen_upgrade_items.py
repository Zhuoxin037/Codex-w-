# -*- coding: utf-8 -*-
"""批量生成升级石的三件套: 物品 give / 敲入函数 / consume_item 进度

【改了东西怎么重跑】 python .workbuddy/_gen_upgrade_items.py
【lore 排版】★ 不要手写版式 ★ 直接构造文本组件列表, 交给 .workbuddy/lore_fmt.py
   统一规范化(数字两侧留白 / 乘号写 × / 等级写罗马数字 / 按 37 半角宽折行)。
   手抄字符串迟早会和装备那边长得不一样 —— check.py 规则 31 会拿规范器的输出
   逐字比对, 对不上就报错。
【为什么 max_stack_size=1】 这些底板本身能堆 16/64, 材料必须独占一格。
   注意: 带 max_damage 的物品(剑/甲/斧/弩)不能加这个组件, 所以本表全是碎片类底材。

【★ 为什么底座统一 recovery_compass(追溯指针)★】 ★这条最重要, 别再换回去★
   之前踩过两次坑: 先是 nether_star -> 玩家会拿它去造信标;
   再是 *_smithing_template -> 原版会在 tooltip 里追加锻造介绍(改不掉), 还会在锻造台被消耗。
   **选底座的第一原则是"它不是任何配方的被消耗者"**:
     nether_star(信标) / 海晶碎片&砂粒(海晶系列) / 紫水晶碎片(紫水晶块等) / 回响碎片(追溯指针) /
     XXX_smithing_template(锻造台) —— 全都有被吃掉的用途。
   追溯指针只有"被造出来"这一个方向(指南针+回响碎片), 没有配方会把它当原料吃掉。
【代价】底座一样 -> 必须靠 custom_model_data 换模型, 否则 21 块石头长得一模一样。
   模型定义 + 图标贴图由 .workbuddy/_gen_stone_icons.py 生成到资源包, 编号见下表 CMD。
   ⚠️ 三处编号必须对得上: 各 give 里写 floats:[N]、_gen_stone_icons.py 的 CMD、
   资源包 recovery_compass.json 的 entries.threshold —— 由 _chk_stone_icons.py 守着。
   本脚本只负责**最早那 6 块**(编号 1..6); 8..19 的四系新升级石与 7/20/21 三块超限石
   的 give 是另外写的, 但它们同样要在 _gen_stone_icons.py 的 CMD 表里登记。
"""
import io, os, importlib.util

BASE = "D:/数据包/sweetdream/data/sweetdream"

_spec = importlib.util.spec_from_file_location(
    'lore_fmt', os.path.join(os.path.dirname(os.path.abspath(__file__)), 'lore_fmt.py'))
LF = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(LF)

# 和 _gen_stone_icons.py 的 CMD 表一一对应(编号 -> 图标)
CMD = {"mana_up_a": 1, "mana_up_b": 2, "mana_up_o": 3,
       "mana_gain_a": 4, "mana_gain_b": 5, "mana_gain_o": 6}

# id: (物品, 名字, 颜色, 适用范围, 效果文案[按行拆好], 前置id)
UP = {
    "mana_up_a": ("recovery_compass", "魔力提升·α", "light_purple", "盔甲",
                  ["自身魔力值上限+20。"], ""),
    "mana_up_b": ("recovery_compass", "魔力提升·β", "dark_purple", "盔甲",
                  ["自身魔力值上限+30，且每秒额外", "恢复2点魔力值。"], "mana_up_a"),
    "mana_up_o": ("recovery_compass", "魔力提升·Ω", "white", "盔甲",
                  ["自身魔力值上限+40，且每秒额外", "恢复5点魔力值。"], "mana_up_b"),
    "mana_gain_a": ("recovery_compass", "魔力增殖·α", "aqua", "剑、斧",
                    ["每次攻击都会为自身恢复", "5魔力值。"], ""),
    "mana_gain_b": ("recovery_compass", "魔力增殖·β", "aqua", "剑、斧",
                    ["每次攻击都会为自身恢复", "9魔力值。"], "mana_gain_a"),
    "mana_gain_o": ("recovery_compass", "魔力增殖·Ω", "aqua", "剑、斧",
                    ["每次攻击都会为自身恢复", "1.5%魔力值。"], "mana_gain_b"),
}

CONSUMABLE = ('consumable={animation:"none",consume_seconds:0,has_consume_particles:false,'
              'sound:"block.bamboo_wood_button.click_off"}')


def head(text):
    return {'text': text, 'color': 'gold', 'bold': True, 'italic': False}


def info_pair(label1, value1, color1, label2, value2, color2):
    """一行里拼两组「标签 值」——和装备 lore 里"魔力 / 冷却"那行同一个写法"""
    return {'text': '', 'italic': False, 'extra': [
        {'text': label1, 'color': 'gray'}, {'text': value1, 'color': color1},
        {'text': '   ·   ', 'color': 'dark_gray'},
        {'text': label2, 'color': 'gray'}, {'text': value2, 'color': color2}]}


def gray(text):
    return {'text': text, 'color': 'gray', 'italic': False}


def blank():
    return {'text': ' ', 'italic': False}


def lore_lines(name, scope, effect, req_name):
    """统一排版: ✦ 升级石 / 适用·前置 / 空 / 效果

    ★ 版式由 lore_fmt 决定 ★ —— 这里只给"逻辑内容", 换行和留白交给规范器。
    (收尾的"用法：…"两行 2026-10-04 按玩家要求删掉了: 右键怎么用是包内常识。)
    """
    req_text = ("需要「%s」" % req_name) if req_name else "无"
    req_color = "red" if req_name else "aqua"
    out = [
        head('✦ 升级石'),
        info_pair('适用于 ', scope, 'yellow', '前置 ', req_text, req_color),
        blank(),
    ]
    for l in effect:
        out.append(gray(l))
    return LF.json_to_snbt(LF.rebuild(out))


def w(path, text):
    os.makedirs(os.path.dirname(path), exist_ok=True)
    # ★ newline="\n" ★ 不加的话 Windows 上会写成 CRLF, 和 lore_fmt 写出的
    #   LF 混在一起 —— 内容一样但每次重跑都有一堆假 diff, 看不清真正的改动。
    io.open(path, "w", encoding="utf-8", newline="\n").write(text)
    print("wrote", path)


for uid, (item, name, color, scope, effect, req) in UP.items():
    req_name = UP[req][1] if req else ""
    lore = lore_lines(name, scope, effect, req_name)

    # ---- 物品 ----
    give = (
        '# ============================================================\n'
        '# sweetdream:upgrade/item/%s —— 给一块「%s」\n'
        '# ------------------------------------------------------------\n'
        '# 【custom_data】只写一个标记 up_%s :\n'
        '#   进度 advancement/upgrade/%s 靠它认"右键用掉了哪块石头"。\n'
        '# 【为什么不带 itemreplace】那是"通用回手线"的标记(右键用完还手),\n'
        '#   材料是一次性消耗品, 带上它会被还回来 —— 敲失败时才需要还(见 apply/%s)。\n'
        '# 【consumable 不能删】没有它右键不会触发 consume_item 进度。\n'
        '# 【底板】统一 recovery_compass(追溯指针)—— 唯一不会被任何配方当原料吃掉的底座。\n'
        '#   custom_model_data 是它的"图标编号", 资源包靠这个换外观,\n'
        '#   编号表和 .workbuddy/_gen_stone_icons.py 的 CMD 一一对应, 改一边要改两边。\n'
        '#   ★ 必须写成 floats:[2.0f]: component 的 floats 是 Float 列表,\n'
        '#     直接给 [2] 是整型列表, 会被 codec 拒掉。\n'
        '# ============================================================\n\n'
        'give @s %s[max_stack_size=1,item_name={text:"%s",bold:true,color:%s},lore=%s,'
        'custom_data={zx:["up_%s"]},custom_model_data={floats:[%d.0f]},%s]\n'
    ) % (uid, name, uid, uid, uid,
         item, name, color, lore, uid, CMD[uid], CONSUMABLE)
    w(BASE + "/function/upgrade/item/%s.mcfunction" % uid, give)

    # ---- 敲入函数 ----
    apply_f = (
        '# ============================================================\n'
        '# sweetdream:upgrade/apply/%s —— 右键用掉这块「%s」去敲副手的装备\n'
        '# ------------------------------------------------------------\n'
        '# 【谁调用它】进度 sweetdream:upgrade/%s(consume_item), 以玩家身份\n'
        '# 【流程】①撤销进度(不撤的话这个进度一辈子只触发一次)\n'
        '#         ②把 kind/id/cat/cat2 交给 station/api/apply 统一处理\n'
        '#         ③成功 = 这次消耗成立; 失败 = 把材料还回去 + 说明原因\n'
        '# 【为什么 cat/cat2 要一起来】能不能装要看类别, 而拼物品谓词只能走宏,\n'
        '#   所以在这里从定义表读出来一起传进去。\n'
        '# ============================================================\n\n'
        'advancement revoke @s only sweetdream:upgrade/%s\n\n'
        'data modify storage zx:work st set value {kind:"upgrade",id:"%s",cat:"",cat2:"",of:""}\n'
        'data modify storage zx:work st.cat set from storage zx:config updef."%s".cat\n'
        'data modify storage zx:work st.cat2 set from storage zx:config updef."%s".cat2\n'
        'function sweetdream:station/api/apply\n\n'
        'execute if data storage zx:out r{ok:1b} run function sweetdream:upgrade/api/done with storage zx:work st\n'
        'execute if data storage zx:out r{ok:0b} run function sweetdream:upgrade/item/%s\n'
        'execute if data storage zx:out r{ok:0b} run function sweetdream:upgrade/api/refuse with storage zx:work st\n'
    ) % (uid, name, uid, uid, uid, uid, uid, uid)
    w(BASE + "/function/upgrade/apply/%s.mcfunction" % uid, apply_f)

    # ---- 进度 ----
    adv = (
        '{\n'
        '    "criteria": {\n'
        '        "%s": {\n'
        '            "trigger": "consume_item",\n'
        '            "conditions": {\n'
        '                "item": {\n'
        '                    "predicates": {\n'
        '                        "minecraft:custom_data": {\n'
        '                            "zx": [\n'
        '                                "up_%s"\n'
        '                            ]\n'
        '                        }\n'
        '                    }\n'
        '                }\n'
        '            }\n'
        '        }\n'
        '    },\n'
        '    "rewards": {\n'
        '        "function": "sweetdream:upgrade/apply/%s"\n'
        '    }\n'
        '}\n'
    ) % (uid, uid, uid)
    w(BASE + "/advancement/upgrade/%s.json" % uid, adv)

print("done")
