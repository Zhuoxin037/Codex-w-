# -*- coding: utf-8 -*-
"""生成 debug/diff_go.mcfunction 与 debug/snap_save.mcfunction —— 数值快照对比。

【为什么要生成】要对比的每一项都得写死一段"读旧值 -> 读新值 -> 写新快照 -> 打印"，
Minecraft 没有循环，所以只能一行为一项。项数一多就必须由脚本产出，
顺便和 lib/reg/build 的注册表保持一致(注册表加一行，重跑一次，diff 自动跟上)。

用法: python .workbuddy/gen_diff.py
"""
import io
import os
import re

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FN = os.path.join(ROOT, 'sweetdream', 'data', 'sweetdream', 'function')

# ------------------------------------------------------------
# 不在注册表里、但值得盯的面板/原版数值。
#   kind = score -> 读玩家自己的计分项
#   kind = path  -> 读 manacore:players."<uuid>".<path>(双精度)
#   kind = attr  -> 读原版 attribute
# ------------------------------------------------------------
EXTRA = [
    ('魔力上限',     'path', 'stats.max_mana'),
    ('基础攻击力',   'path', 'stats.base_attack'),
    ('技能倍率',     'path', 'stats.skill_multiplier'),
    ('独立乘区',     'path', 'stats.independent_multiplier'),
    ('固定伤害',     'path', 'stats.custom_damage'),
    ('面板生命上限', 'path', 'stats.max_health'),
    ('冷却缩减',     'path', 'stats.cooldown_reduction'),
    ('原版攻击力',   'attr', 'minecraft:attack_damage'),
    ('原版生命上限', 'attr', 'minecraft:max_health'),
    ('原版护甲',     'attr', 'minecraft:armor'),
    ('原版移速',     'attr', 'minecraft:movement_speed'),
]

# 快照里每一项的键名(纯数字, 免得中文当 NBT 键)
def slot(i):
    return 'o%d' % i


def read(p):
    with io.open(p, encoding='utf-8') as f:
        return f.read()


def reg_rows():
    """从 lib/reg/build 里抠出 b / a 两张表的 (标签, 计分项)。

    ⚠️ 必须跳过注释行 —— 文件头部的"用法示例"里也有一模一样的 append 写法,
    用宽松正则会把示例当成真行(第一版就栽在这, 多出一个 "分类 · 名字")。
    """
    build = read(os.path.join(FN, 'lib', 'reg', 'build.mcfunction'))
    rows = []
    for line in build.splitlines():
        if line.lstrip().startswith('#'):
            continue
        m = re.search(r'storage zx:reg ([ab]) append value \{l:"([^"]*)",o:"([^"]*)"', line)
        if m:
            rows.append((m.group(2), 'score', m.group(3)))
    return rows


def all_rows():
    return reg_rows() + list(EXTRA)


def cur_score(kind, arg):
    """把"当前值"算进 #d_new 的裸命令(不带 $, 不含宏变量之外的替换)。"""
    if kind == 'score':
        return 'scoreboard players operation #d_new zx.meta = @s %s' % arg
    # ⚠️ `execute store result score <目标> <计分项>` **没有 scale 参数**
    #    (只有 `store result storage <目标> <路径> <类型> <scale>` 才有)。
    #    第一版生成器把 storage 形式的那个 `1` 抄到了 score 形式后面,
    #    结果是 diff_go 整个函数加载失败(解析器只报第一处, 见 2026-10-03 日志)。
    #    data get 自己的 scale 默认就是 1, 也不需要写。
    if kind == 'path':
        return ('execute store result score #d_new zx.meta run data get storage '
                'manacore:players."$(uuid)".%s' % arg)
    if kind == 'attr':
        return 'execute store result score #d_new zx.meta run attribute @s %s get' % arg
    raise ValueError(kind)


def store_score(key):
    """把 #d_new 写进快照的第 key 项。"""
    return ('execute store result storage zx:data snap."$(uuid)".%s int 1 '
            'run scoreboard players get #d_new zx.meta' % key)


HEAD_DIFF = u'''# ============================================================
# sweetdream:debug/diff_go —— 快照对比的正文(宏参数 {uuid})
# ------------------------------------------------------------
# 【这个文件是生成的】改动看 .workbuddy/gen_diff.py, 然后跑
#   python .workbuddy/gen_diff.py
# 【★ 为什么"第一次按"的判断在这一层 ★】
#   快照是按 uuid 存的(zx:data snap."<uuid>")。上一层的 diff 是普通函数,
#   手上没有展开好的 uuid, 只能判断"snap 这个节点在不在"(任何人存过都算在),
#   判断不出"**你**存过没有"。所以这句必须放在宏层。
# 【它干什么】逐项比 "现在 @s 身上的值" 和 "上次存下的值":
#     一样 -> 什么都不打(静默)
#     不同 -> 打一行 "旧 -> 新", 并**顺手把新值写进快照**
#   于是连按两次就能看到"这一段期间变了什么"。典型用法:
#     换装备前按一次 -> 换完再按一次 -> 所有跟着变的账本一行行自己冒出来。
# 【为什么每项 6 行】没有循环, 只能一行为一项:
#     ① (计分项先补 0, 免得读不出来)  ② 读新值到 #d_new
#     ③ 读旧值到 #d_old(快照里没有就当 0)  ④ 把新值写回快照
#     ⑤ 不一样才打印  ⑥ 记一下有几项变了
# 【数值精度】全部按整数比(小数被截断)。对"换装有没有生效"这个用途足够了;
#   要看精确小数用 /trigger zx.dbg_stats。
# 【快照存哪】zx:data snap."<uuid>".o0 / o1 / ..., 见 gen_diff.py 的 EXTRA 与
#   lib/reg/build 的表(两边顺序加起来就是键的序号)。
# 【★ 宏参数从哪来 ★】上一层(debug/diff)会先把 uuid 抄进 zx:work df,
#   再用 `with storage zx:work df` 调这个函数。
#   ⚠️ 绝不能写成 `with storage zx:data self` —— 实测那个写法会让整个宏函数
#      **一条命令都不跑**(静默, 连日志都不报), 2026-10-03 栽过。
#      全项目能正常工作的宏调用清一色是 `with storage zx:work <临时节点>`
#      或 `with storage zx:reg <表项>`; 照这个来。
# ============================================================

# ---- 第一次按: 只存快照, 不比较(没有"上一次"可比) ----
$execute unless data storage zx:data snap."$(uuid)" run tellraw @s [{"text":"[调试] 第一次按: 已存下当前快照。","color":"aqua"}]
$execute unless data storage zx:data snap."$(uuid)" run tellraw @s [{"text":"换一件装备, 再按一次 /trigger zx.dbg_diff 就能看到变了什么。","color":"gray"}]
$execute unless data storage zx:data snap."$(uuid)" run function sweetdream:debug/snap_save with storage zx:work df
$execute unless data storage zx:data snap."$(uuid)" run return 0

# ---- 之后每次: 比较 + 更新快照 ----
tellraw @s [{"text":"========== 和上次快照比 ==========","color":"gold"}]
tellraw @s [{"text":"(只列变了的那几项; 比完之后快照已经更新成本次的值)","color":"dark_gray","italic":true}]
scoreboard players set #d_n zx.meta 0
'''

HEAD_SAVE = u'''# ============================================================
# sweetdream:debug/snap_save —— 把当前所有要盯的值存成快照(宏参数 {uuid})
# ------------------------------------------------------------
# 【这个文件是生成的】改动看 .workbuddy/gen_diff.py, 然后跑
#   python .workbuddy/gen_diff.py
# 【它只写 zx:data snap."<uuid>", 不碰面板】随便按。
# 【为什么先 scoreboard players add ... 0】计分板里"没这个玩家的分"和
#   "分是 0"是两种状态, 直接 store 会失败并往日志里刷错。先 add 0 把它建出来。
# ============================================================

$data modify storage zx:data snap."$(uuid)" set value {}
'''


def diff_lines(rows):
    out = []
    for i, (label, kind, arg) in enumerate(rows):
        k = slot(i)
        out.append('')
        out.append('# --- %s ---' % label)
        if kind == 'score':
            out.append('scoreboard players add @s %s 0' % arg)
        out.append('$' + cur_score(kind, arg) if '$(uuid)' in cur_score(kind, arg) else cur_score(kind, arg))
        out.append('$execute if data storage zx:data snap."$(uuid)".%s store result score #d_old zx.meta run data get storage zx:data snap."$(uuid)".%s' % (k, k))
        # ⚠️ 这一行也带 $(uuid), 所以同样必须加 $ 前缀 —— 漏了它会变成字面量
        #    "$(uuid)" 的路径, 那条命令永远不生效(而 check.py 会抓出来)。
        out.append('$execute unless data storage zx:data snap."$(uuid)".%s run scoreboard players set #d_old zx.meta 0' % k)
        out.append('$' + store_score(k))
        # ⚠️ 这一行**不含** $(uuid), 所以绝对不能带 $ 前缀。
        #    wiki: "将函数中的一行以 $ 开头即可标记这一行为宏命令, 宏命令还
        #    **必须**以 $() 的形式包含一个或更多的替换段" —— $ 行不带替换段是
        #    非法的, 会让整个函数作废(check.py 第 16 项专门抓这个)。
        #    第一版生成器在这行和下面的 FOOT/HEAD 几行上全都多加了 $。
        out.append('execute unless score #d_old zx.meta = #d_new zx.meta run tellraw @s [{"text":"  %s  ","color":"gray"},{"score":{"name":"#d_old","objective":"zx.meta"},"color":"dark_gray"},{"text":" -> ","color":"gray"},{"score":{"name":"#d_new","objective":"zx.meta"},"color":"white"}]' % label)
        out.append('execute unless score #d_old zx.meta = #d_new zx.meta run scoreboard players add #d_n zx.meta 1')
    return out


def save_lines(rows):
    out = []
    for i, (label, kind, arg) in enumerate(rows):
        k = slot(i)
        if kind == 'score':
            out.append('scoreboard players add @s %s 0' % arg)
            out.append('$execute store result storage zx:data snap."$(uuid)".%s int 1 run scoreboard players get @s %s' % (k, arg))
        elif kind == 'path':
            out.append('$execute store result storage zx:data snap."$(uuid)".%s int 1 run data get storage manacore:players."$(uuid)".%s' % (k, arg))
        elif kind == 'attr':
            out.append('$execute store result storage zx:data snap."$(uuid)".%s int 1 run attribute @s %s get' % (k, arg))
        else:
            raise ValueError(kind)
    return out


FOOT_DIFF = u'''

execute if score #d_n zx.meta matches 0 run tellraw @s [{"text":"  没有任何变化。","color":"dark_gray"}]
tellraw @s [{"text":"(本次共 ","color":"dark_gray","italic":true},{"score":{"name":"#d_n","objective":"zx.meta"},"color":"yellow","italic":true},{"text":" 项有变化)","color":"dark_gray","italic":true}]
'''


def main():
    rows = all_rows()
    print('对比项共 %d 项(注册表 %d + 面板/原版 %d)'
          % (len(rows), len(reg_rows()), len(EXTRA)))
    assert len(rows) <= 90, '快照项太多(上限 90): %d' % len(rows)

    with io.open(os.path.join(FN, 'debug', 'diff_go.mcfunction'), 'w',
                 encoding='utf-8', newline='\n') as f:
        f.write(HEAD_DIFF + '\n'.join(diff_lines(rows)) + FOOT_DIFF)
    print('写出 debug/diff_go.mcfunction')

    with io.open(os.path.join(FN, 'debug', 'snap_save.mcfunction'), 'w',
                 encoding='utf-8', newline='\n') as f:
        f.write(HEAD_SAVE + '\n'.join(save_lines(rows)) + '\n')
    print('写出 debug/snap_save.mcfunction')


if __name__ == '__main__':
    main()
