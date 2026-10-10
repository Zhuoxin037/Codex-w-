import glob, io, os
BASE="D:/数据包/sweetdream/data/sweetdream/function/equipment/armor"
for p in sorted(glob.glob(BASE+"/*/give.mcfunction")):
    s=io.open(p,encoding="utf-8").read()
    j=s.find("custom_data={zx:[")
    k=s.find("]}",j)
    print(os.path.basename(os.path.dirname(p)), "->", s[j:k+2] if j>=0 else "NONE")
