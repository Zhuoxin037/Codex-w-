from pathlib import Path
from PIL import Image
import numpy as np
O=Path('D:/数据包/模型设计/爆裂黎明_建模_20261014/阶段八_原作弹道与命中特效')
atlas=Image.new('RGBA',(256,256));yy,xx=np.mgrid[:128,:128];x=(xx-63.5)/63.5;y=(yy-63.5)/63.5;r=np.hypot(x,y);a=np.arctan2(y,x)
for style in range(4):
 if style==0:
  core=np.exp(-(r/.21)**2);haze=np.exp(-(r/.52)**2)*.7;rgb=np.zeros((128,128,3));rgb[:]=[76,49,167];rgb=rgb*(1-core[:,:,None])+np.array([255,245,255])[None,None,:]*core[:,:,None];alpha=np.clip(core*260+haze*100,0,255)
 elif style==1:
  # Small curling red smoke fleck, used on six local three-dimensional sections.
  axis=.15*np.sin(x*3.5);d=np.abs(y-axis);mask=np.clip(1-d/(.40+.12*np.cos(x*4)),0,1)**.35*np.clip(1-np.abs(x),0,1)**.3
  crest=np.exp(-((y-axis+.14)/.07)**2);rgb=np.array([16,4,20])[None,None,:]*(1-crest[:,:,None])+np.array([255,28,48])[None,None,:]*crest[:,:,None];alpha=mask*230
 elif style==2:
  wave=np.exp(-((r-(.52+.035*np.sin(a*5)))/.13)**2);wave*=.40+.60*np.sin(a*3+.6)**2;core=np.exp(-(r/.44)**2)*.2;rgb=np.zeros((128,128,3));rgb[:]=[85,54,197];rgb[:,:,2]+=wave*50;alpha=np.clip((wave+core)*180,0,210)
 else:
  mask=np.clip(1-np.abs(x)*1.3-np.abs(y)*.35,0,1)**.45*np.exp(-(y/.7)**4);hot=np.exp(-((x/.25)**2+(y/.45)**2));rgb=np.array([236,24,56])[None,None,:]*(1-hot[:,:,None])+np.array([255,178,207])[None,None,:]*hot[:,:,None];alpha=mask*250
 mask=np.clip((1-r)*10,0,1) if style in [0,2] else np.sin((xx/127)*np.pi)**.4*np.sin((yy/127)*np.pi)**.5
 rgba=np.dstack([np.uint8(np.clip(rgb,0,255)),np.uint8(np.clip(alpha*mask,0,255))]);rgba[[0,-1],:,3]=0;rgba[:,[0,-1],3]=0;atlas.paste(Image.fromarray(rgba),((style%2)*128,(style//2)*128))
atlas.save(O/'爆裂黎明_命中核心_材质.png');print('Saved centre-flash, red curl, pressure and ember materials.')
