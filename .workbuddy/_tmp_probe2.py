import re, glob, sys, os
sys.stdout.reconfigure(encoding='utf-8')
os.chdir(r'D:/数据包')

print('=== lib/find_by 头 ===')
t = open('sweetdream/data/sweetdream/function/lib/find_by.mcfunction', encoding='utf-8').read()
print(t[:1200])

print('\n=== 击飞/Motion 用法 ===')
for f in glob.glob('sweetdream/data/sweetdream/function/equipment/**/*.mcfunction', recursive=True):
    s = open(f, encoding='utf-8').read()
    if 'Motion' in s:
        for line in s.splitlines():
            if 'Motion' in line and not line.strip().startswith('#'):
                print(f.split('equipment/')[-1], '|', line[:150])
                break
