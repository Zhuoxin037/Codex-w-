#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""_chk_uuid_lookup.py —— 禁止再用「NBT 反查 UUID」的写法(守门)

【守什么】
  `@a[nbt={UUID:[I;$(u0),$(u1),$(u2),$(u3)]}]` 这类写法, 引擎要对**候选逐个**
  做一次整份实体 NBT 序列化(Entity.saveWithoutId)。玩家 NBT 里装着整个背包的
  DataComponents —— 本包装备 lore / custom_data 极大, spark 实测
  **一次 ≈ 10 ms**(2026-10-20 采样; 见 internal/damage/who 头注释)。

【真实事故 2026-10-23(第五次卡顿)】
  那次只把 internal/damage/deal 一条链换成了计分项比较, 其余调用点没动:
    · internal/damage/one 的受击侧钩子(候潮/潮线/焦衣/燧行/缝心/绯缝/殓丝/圣骸)
      ≈ 20 次 / 命中;
    · 沉锚的牵引 + 飞锚表现 **每刻 9~12 次**。
  ⇒ 半径 6 的超限天穹打 10 只、每只 3 层升痕 = 30 次命中 × 20+ 次反查 ⇒
  一次落地**几秒顿帧**。玩家原话: "用了之后人物直接卡住, 然后过了几秒再瞬间
  结算伤害"。

【正解】
  · 反查**玩家**: `sweetdream:lib/u_by`(灌 zx:work ub{u0..u3} -> 认 @a[tag=zx.ub]),
    走 manacore.u0..u3 四个整数比较, 零 NBT。
  · 反查**生物**: 生成/锁定时打标签(如沉锚的 zx.an_lock + scores={zx.an_own=$(u0)})。
  · 读坐标: 用 `facing entity …` / `at @e[…]`, 别 `data get entity <玩家> Pos[n]`。

【怎么查】
  ① 硬错: 任何非注释行出现 `@a[nbt={UUID` / `@a[nbt={UUID` 的等价写法。
  ② 硬错: `data get entity @a[...]` / `data modify ... from entity @a[...]`
     (同样触发整份玩家 NBT 序列化)。
  ③ 提示(不算问题): `@e[nbt={UUID` —— 非玩家实体的 NBT 小得多, 但每刻跑一样会拖;
     目前剩下的都在"跟随类表现"里, 逐条排期中。
"""
import os
import re
import sys

ROOT = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..',
                    'sweetdream', 'data', 'sweetdream', 'function')

PLAYER_NBT_SEL = re.compile(r'@a\[[^\]]*nbt=\{UUID')
PLAYER_DATA = re.compile(r'data (?:get|modify) (?:entity @a\[|[^ ]* from entity @a\[)')
ENTITY_NBT_SEL = re.compile(r'@e\[[^\]]*nbt=\{UUID')


def main():
    errs = []
    warns = []
    total = 0
    for dp, dn, fn in os.walk(ROOT):
        for f in sorted(fn):
            if not f.endswith('.mcfunction'):
                continue
            p = os.path.join(dp, f)
            total += 1
            rel = os.path.relpath(p, ROOT).replace('\\', '/')
            for i, line in enumerate(open(p, encoding='utf-8'), 1):
                s = line.strip()
                if not s or s.startswith('#'):
                    continue
                if PLAYER_NBT_SEL.search(line):
                    errs.append('%s:%d  玩家 NBT 反查(≈10 ms/次) -> 改 lib/u_by\n      %s'
                                % (rel, i, s[:120]))
                elif PLAYER_DATA.search(line):
                    errs.append('%s:%d  读玩家实体 data(整份 NBT) -> 改计分项/或改判据\n      %s'
                                % (rel, i, s[:120]))
                elif ENTITY_NBT_SEL.search(line):
                    warns.append('%s:%d  %s' % (rel, i, s[:120]))

    for e in errs:
        print('[错] ' + e)
    print('---- 扫描 %d 个 .mcfunction' % total)
    print('---- 硬错 %d 处' % len(errs))
    print('---- 待排期(@e 版, 不计入问题) %d 处' % len(warns))
    if '--verbose' in sys.argv:
        for w in warns:
            print('    · ' + w)
    return 1 if errs else 0


if __name__ == '__main__':
    sys.exit(main())
