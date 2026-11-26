import re, sys, os
sys.stdout.reconfigure(encoding='utf-8')
os.chdir(r'D:/数据包')
for f in ['equipment/sword/verdict/give.mcfunction', 'equipment/sword/hush/give.mcfunction']:
    t = open('fallendream/data/fallendream/function/' + f, encoding='utf-8').read()
    i = t.find('give @s ')
    body = t[i:]
    m = re.search(r'custom_data=\{.*?\}', body)
    print('==', f)
    print('custom_data:', m.group(0)[:300] if m else None)
    print('consumable:', re.search(r'consumable=\{[^}]*\}', body).group(0) if 'consumable' in body else None)
    print('tail:', body[-260:])
