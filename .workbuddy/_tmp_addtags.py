# -*- coding: utf-8 -*-
"""把批 20 的 9 件标签登记进 _tags_data.py（幂等）"""
import io, re, sys
sys.stdout.reconfigure(encoding='utf-8')
P = r'D:/数据包/.workbuddy/_tags_data.py'
t = io.open(P, encoding='utf-8').read()

NEW = {
    'oath_victory': ['base_atk', 'max_mana', 'max_hp', 'dash', 'field', 'heal', 'buff'],
    'pivot': ['max_mana', 'formation'],
    'bearing': ['max_mana', 'formation', 'buff', 'indep_mul', 'cd_down'],
    'empty_camp': ['max_mana'],
    'lone_walk': ['max_mana', 'buff', 'indep_mul'],
    'overflow': ['max_mana', 'max_hp', 'heal', 'buff'],
    'intent': ['max_mana', 'max_hp', 'cur_mana', 'buff', 'heal'],
    'air_step': ['max_mana', 'base_atk', 'dash', 'debuff'],
    'breath_hold': ['max_mana', 'formation'],
}

if '"oath_victory"' in t:
    print('already registered')
else:
    anchor = '    "late_dusk":'
    i = t.index(anchor)
    j = t.index('\n', i) + 1
    lines = ['    # ---- 批 20（2026-10-27）胜利誓约 + 8 件终端盔甲 ----\n']
    for k, v in NEW.items():
        lines.append('    "%s": %s,\n' % (k, str(v).replace("'", '"')))
    t = t[:j] + ''.join(lines) + t[j:]
    io.open(P, 'w', encoding='utf-8', newline='\n').write(t)
    print('inserted', len(NEW))

# 自检：词表校验
import importlib.util
spec = importlib.util.spec_from_file_location('td', P)
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)
vocab = {x[0] for x in m.VOCAB}
bad = []
for k, v in NEW.items():
    for tag in v:
        if tag not in vocab:
            bad.append((k, tag))
print('词表外的标签:', bad if bad else '无')
print('登记总数:', len(m.TAGS))
