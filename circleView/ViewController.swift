//
//  ViewController.swift
//  circleView
//
//  Created by Ethan.Wang on 2018/8/17.
//  Copyright © 2018年 Ethan. All rights reserved.
//

import UIKit

struct ScreenInfo {
    static let Frame = UIScreen.main.bounds
    static let Height = Frame.height
    static let Width = Frame.width
    static let navigationHeight:CGFloat = navBarHeight()

    static func isIphoneX() -> Bool {
        return UIScreen.main.bounds.equalTo(CGRect(x: 0, y: 0, width: 375, height: 812))
    }
    static private func navBarHeight() -> CGFloat {
        return isIphoneX() ? 88 : 64;
    }
}
// 子view比例
let MENURADIUS = 0.5 * ScreenInfo.Width
// 中心view比例
let PROPORTION: Float = 0.65

func DIST(pointA: CGPoint, pointB: CGPoint) -> CGFloat{
    let x = (pointA.x - pointB.x) * (pointA.x - pointB.x)
    let y = (pointA.y - pointB.y) * (pointA.y - pointB.y)
    return CGFloat(sqrtf(Float(x + y)))
}

class ViewController: UIViewController {

    private var beginPoint: CGPoint?
    private var orgin: CGPoint?
    private var a: CGFloat?
    private var b: CGFloat?
    private var c: CGFloat?
    private var subArray: [String] = ["1","2","3","4","5","6","7","8","1","2","3","4","5","6","7","8","1","2","3","4","5","6","7","8"]
    // 背景view
    private var contentView: UIView?
    // 中心view
    private var circleView: UIImageView?
    // 子view Array
    private var viewArray: [EWSubView] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setContentView()
        updateCircleViews()
        // Do any additional setup after loading the view, typically from a nib.
    }

    /// 添加背景view,也是旋转的view
    private func setContentView() {
        setCircleView()
        contentView = UIView(frame: CGRect(x: 0, y: 0, width: ScreenInfo.Width, height: ScreenInfo.Width))
        contentView?.center = self.view.center
        self.view.addSubview(contentView!)
        contentView!.addSubview(circleView!)
    }
    /// 添加中间圆形view
    private func setCircleView(){
        let view = UIImageView(frame: CGRect(x: 0.5 * CGFloat(1 - PROPORTION) * ScreenInfo.Width + 10, y: 0.5 * CGFloat(1 - PROPORTION) * ScreenInfo.Width + 10, width: ScreenInfo.Width * CGFloat(PROPORTION) - 20, height: ScreenInfo.Width * CGFloat(PROPORTION) - 20))
        /// 为了适配保证size变化center不变
        let centerPoint = view.center
        view.frame.size = CGSize(width: ScreenInfo.Width * CGFloat(PROPORTION) - 40, height: ScreenInfo.Width * CGFloat(PROPORTION) - 40)
        view.center = centerPoint
        view.image = UIImage(named: "11")
        view.layer.cornerRadius = view.frame.width*0.5
        view.layer.masksToBounds = true
        view.isUserInteractionEnabled = true
        circleView = view
    }
    /// 布局旋转的子view
    private func rotationCircleCenter(contentOrgin: CGPoint,
                                      contentRadius: CGFloat,subnode: [String]){
        // 添加比例,实现当要添加的子view数量较多时候可以自适应大小.
        var scale: CGFloat = 1
        if subnode.count > 10 {
            scale = CGFloat(CGFloat(subnode.count) / 13.0)
        }

        for i in 0..<subnode.count {
            let x = contentRadius * CGFloat(sin(.pi * 2 / Double(subnode.count) * Double(i)))
            let y = contentRadius * CGFloat(cos(.pi * 2 / Double(subnode.count) * Double(i)))
            // 当子view数量大于10个,view.size变小,防止view偏移,要保证view.center不变.
            let view = EWSubView(frame: CGRect(x:contentRadius + 0.5 * CGFloat((1 + PROPORTION)) * x - 0.5 * CGFloat((1 - PROPORTION)) * contentRadius, y: contentRadius - 0.5 * CGFloat(1 + PROPORTION) * y - 0.5 * CGFloat(1 - PROPORTION) * contentRadius, width: CGFloat((1 - PROPORTION)) * contentRadius, height: CGFloat((1 - PROPORTION)) * contentRadius), imageName: subnode[i])
            let centerPoint = view.center
            view.frame.size = CGSize(width: CGFloat((1 - PROPORTION)) * contentRadius / scale , height: CGFloat((1 - PROPORTION)) * contentRadius / scale)
            view.center = centerPoint
            view.drawSubView()
            // 这个tag判断view是不是在最下方变大状态,非变大状态0,变大为1
            view.tag = 0
            // 获取子view在当前屏幕中的rect.来实现在最下方的那个变大
            let rect = view.convert(view.bounds, to: UIApplication.shared.keyWindow)
            let viewCenterX = rect.origin.x + (rect.width) / 2
            if viewCenterX > self.view.center.x - 20 && viewCenterX < self.view.center.x + 20 && rect.origin.y > (contentView?.center.y)! {
                view.transform = view.transform.scaledBy(x: 1.5, y: 1.5)
                view.tag = 1
            }
            contentView?.addSubview(view)
            viewArray.append(view)
        }
    }

    private func updateCircleViews() {
        self.rotationCircleCenter(contentOrgin: CGPoint(x: MENURADIUS, y: MENURADIUS), contentRadius: MENURADIUS,subnode:subArray)
    }
    /// 获取手指触摸位置,超过范围不让旋转交互
    private func touchPointInsideCircle(center: CGPoint, radius: CGFloat, targetPoint: CGPoint) -> Bool{
        let dist = DIST(pointA: targetPoint, pointB: center)
        return (dist <= radius)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        beginPoint = touches.first?.location(in: self.view)
    }
    /// 核心旋转方法,具体办法是背景view旋转,中心view和子view同角度反向旋转,实现动画效果
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let contentView = contentView else { return }
        guard let circleView = circleView else { return }
        orgin = CGPoint(x: 0.5 * ScreenInfo.Width, y: MENURADIUS + 0.17 * ScreenInfo.Height)
        let currentPoint = touches.first?.location(in: self.view)
        if self.touchPointInsideCircle(center: orgin!, radius: MENURADIUS*1.45, targetPoint: currentPoint!){
            b = DIST(pointA: beginPoint!, pointB: orgin!)
            c = DIST(pointA: currentPoint!, pointB: orgin!)
            a = DIST(pointA: beginPoint!, pointB: orgin!)
            let angleBegin = atan2(beginPoint!.y - orgin!.y, beginPoint!.x - orgin!.x)
            let angleAfter = atan2(currentPoint!.y - orgin!.y, currentPoint!.x - orgin!.x)
            let angle = angleAfter - angleBegin
            // 背景view旋转
            contentView.transform = contentView.transform.rotated(by: angle)
            // 中心view反向旋转
            circleView.transform = circleView.transform.rotated(by: -angle)
            for i in 0..<viewArray.count {
                // 子view反向旋转
                viewArray[i].transform = viewArray[i].transform.rotated(by: -angle)
                // 判断实现最下方的子view变大
                let rect = viewArray[i].convert(viewArray[i].bounds, to: UIApplication.shared.keyWindow)
                let viewCenterX = rect.origin.x + (rect.width) / 2
                if viewCenterX > self.view.center.x - 20 && viewCenterX < self.view.center.x + 20 && rect.origin.y > contentView.center.y {
                    if viewArray[i].tag == 0{
                        viewArray[i].transform = viewArray[i].transform.scaledBy(x: 1.5, y: 1.5)
                        viewArray[i].tag = 1
                        contentView.bringSubview(toFront: viewArray[i])
                    }
                }
                else {
                    if viewArray[i].tag == 1 {
                        viewArray[i].transform = viewArray[i].transform.scaledBy(x: 1/1.5, y: 1/1.5)
                        viewArray[i].tag = 0
                        contentView.sendSubview(toBack: viewArray[i])
                    }
                }
            }
            beginPoint = currentPoint
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

class EWSubView: UIView {
    var imageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleToFill
        return view
    }()

    init(frame: CGRect, imageName: String?) {
        super.init(frame: frame)
        self.imageView.image = UIImage(named: imageName!)
        self.layer.masksToBounds = true
        self.addSubview(imageView)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func drawSubView(){
        self.layer.cornerRadius = self.frame.width / 2
        self.imageView.frame = CGRect(x: 0, y:0 , width: self.frame.width, height: self.frame.width)
    }

}
