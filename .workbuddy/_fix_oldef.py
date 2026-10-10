# -*- coding: utf-8 -*-
"""
_fix_oldef.py —— 重建 overlimit/def/load 里「超限·脑髓蛭 / 超限·脊骨共生」两条定义行
--------------------------------------------------------------------------
【为什么单独一个脚本】这两行的 lore 里全是中文 + 「」 + ×，用 shell heredoc 写
  会被 Windows 的转义/路径转换毁掉(\\1 -> /1/)。写成文件跑才干净。
【幂等】找到 oldef."brain_leech" / oldef."spine_symbiote" 那两行整行替换。
用法: python .workbuddy/_fix_oldef.py [--check]
"""
import io
import os
import sys

ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
P = os.path.join(ROOT, 'sweetdream', 'data', 'sweetdream', 'function',
                 'overlimit', 'def', 'load.mcfunction')

HEAD = '{"text":"%s","color":"gold","bold":true,"italic":false}'
BODY = '{"text":"%s","color":"gray","italic":false}'
PAD = '{"text":" ","italic":false}'

BRAIN = [
    HEAD % '✦ 被动技能',
    BODY % '自身魔力值上限 -120，自身每秒额外恢复 5 点魔力值。',
    PAD,
    HEAD % '✦ 蛊虫',
    BODY % '当魔力值满后，自身基础攻击力增加相当于自身魔力值上限 ×0.05 的值，'
           '且每次攻击后都会为自身增加 5 秒相当于自身魔力值上限 ×0.02 的基础'
           '攻击力，并为自身附加一层「蛊虫」。',
    BODY % '当「蛊虫」达到 10 层后，自身不再增加基础攻击力及「蛊虫」，改为每次'
           '攻击消耗一层「蛊虫」并为自身增加 10 秒相当于自身魔力值上限 ×0.05 的'
           '基础攻击力（该效果在魔力值未满时也生效）。「蛊虫」消耗至 0 层后重新'
           '开始积累。',
    PAD,
    HEAD % '✦ 套装效果',
    BODY % '● 脊骨共生',
    BODY % '● 脑髓蛭',
    PAD,
    BODY % '自身魔力值满后获得抗性提升Ⅱ及再生Ⅱ。',
]

SPINE = [
    HEAD % '✦ 被动技能',
    BODY % '自身魔力值上限 -180，每次击杀生物都会恢复自身 80 点魔力值。当魔力'
           '值满后，自身获得相当于自身魔力值上限 ×0.05 的护甲值以及最大生命值。',
    BODY % '每次击杀生物后，自身获得 20 秒相当于自身魔力值上限 ×0.02 的护甲值'
           '以及最大生命值。若触发该被动时自身也处于【脑髓蛭】的「蛊虫」状态，'
           '则额外获得 5 秒抗性提升Ⅴ。',
    PAD,
    HEAD % '✦ 套装效果',
    BODY % '● 脑髓蛭',
    BODY % '● 脊骨共生',
    PAD,
    BODY % '自身魔力值满后获得抗性提升Ⅱ及再生Ⅱ。',
]


def line(oid, label, note, lore):
    # ★ 这两件的超限名颜色 = 它们**本名**的颜色, 本来就是 light_purple
    #   (brain_leech / spine_symbiote 的 give 里 item_name.color 就是 light_purple),
    #   所以这里写死不冲突。别的装备要跟本名颜色走 —— 见 overlimit/def/load 头部。
    return ('data modify storage zx:config oldef."%s" set value '
            '{label:"%s",name:{"text":"%s","bold":true,"color":"light_purple"},'
            'note:"%s",dmg:0.0,mana:0.0,cd:0.0,lore:[%s]}'
            % (oid, label, label, note, ','.join(lore)))


NEW = {
    'brain_leech': line('brain_leech', '超限·脑髓蛭', '蛊虫叠层: 攻击力随层数滚起来', BRAIN),
    'spine_symbiote': line('spine_symbiote', '超限·脊骨共生', '击杀滚护甲与生命, 与蛊虫联动', SPINE),
}


def main():
    check = '--check' in sys.argv
    src = io.open(P, encoding='utf-8').read()
    out = []
    hit = 0
    for ln in src.split('\n'):
        done = False
        for k, v in NEW.items():
            if ln.startswith('data modify storage zx:config oldef."%s"' % k):
                hit += 1
                if ln != v:
                    print('[changed] oldef."%s"  %d -> %d 字节' % (k, len(ln), len(v)))
                    if not check:
                        ln = v
                else:
                    print('[same   ] oldef."%s"' % k)
                done = True
                break
        out.append(ln)
    if hit != 2:
        print('!! 只找到 %d 条(应为 2)—— 文件结构变了?' % hit)
    if not check:
        io.open(P, 'w', encoding='utf-8', newline='\n').write('\n'.join(out))
        print('已写回')


if __name__ == '__main__':
    sys.stdout = io.TextIOWrapper(sys.stdout.buffer, encoding='utf-8', errors='replace')
    main()
