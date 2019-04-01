# EWCircleView
[![996.icu](https://img.shields.io/badge/link-996.icu-red.svg)](https://996.icu)

Swift轮转动画

# 实现效果: 
静止时:子view对称排列,允许动态添加,0~24个都能较好的显示.

旋转时:中心view不动,子view随手势旋转,最下方子view变大突出.

# 实现思路:
所有的控件全部加到一个大的背景view上,本质上旋转的是这个背景view,在旋转背景view的同时,让它所有的子控件反向旋转,就实现了现在这种效果.

通过touchMove方法来获取手势,使用transform实现动画效果.

最下方的view变大是循环判断子view.frame.x,当它处于一个范围,并且frame.y小于中心view.frame.y的时候.修改它的transform,来使其变大,并且修改它的tag来标记它已经属于变大状态,当它frame.x超出了预定范围,使其还原.

# 实现方式:
1. 添加背景透明view,中心圆圈view.

2. 添加周围旋转子view.

3. 添加旋转方法.

4. 交互优化.


![效果图预览](https://github.com/WangLiquan/circleView/raw/master/images/demonstration.gif)

# 另:
也有使用pop框架来实现,长按中心按钮使周围子View旋转效果.项目为[EWCircleView-pop](https://github.com/WangLiquan/EWCircleView-pop),可供参考.
