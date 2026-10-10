import json, sys
from pathlib import Path
funcs=json.loads((Path(__file__).parent/'functions.json').read_text(encoding='utf-8'))
for pat in sys.argv[1:]:
    for k,v in funcs.items():
        if k == pat or pat.endswith('*') and k.startswith(pat[:-1]):
            print('\nFILE',k,v['path'])
            for n,s in v['lines']:
                print(f'{n}: {s[:650]}'+(' ...' if len(s)>650 else ''))
