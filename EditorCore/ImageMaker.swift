//
//  ImageMaker.swift
//  EditorCore
//
//  Created by virus1993 on 2017/10/9.
//  Copyright © 2017年 ascp. All rights reserved.
//

import Foundation

//图形类型
enum DrawRectType : String {
    case radio = "椭圆"
    case cub = "矩形"
    case text = "文字"
}

///绘图路径
struct DrawPath {
    let rect:CGRect
    let type:DrawRectType
    let red:CGFloat
    let green:CGFloat
    let blue:CGFloat
    let alpha:CGFloat
    var color : UIColor {
        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }
    let text : String?
    init(rect : CGRect, type : DrawRectType,red : CGFloat,green : CGFloat,blue : CGFloat,alpha : CGFloat, text: String? = "") {
        self.rect = rect
        self.type = type
        self.red = red
        self.green = green
        self.blue = blue
        self.alpha = alpha
        self.text = text
    }
}

/// 颜色名称和值
struct ColorComponment {
    let name : String
    let color : UIColor
    static let red = ColorComponment(name: "红色", color: .red)
    static let yellow = ColorComponment(name: "黄色", color: .yellow)
    static let blue = ColorComponment(name: "蓝色", color: .blue)
    static let green = ColorComponment(name: "绿色", color: .green)
    static let gray = ColorComponment(name: "青色", color: .gray)
    static let purple = ColorComponment(name: "紫色", color: .purple)
    static let orange = ColorComponment(name: "橙色", color: .orange)
    static let black = ColorComponment(name: "黑色", color: .black)
    static let white = ColorComponment(name: "白色", color: .white)
    static let colors = [ColorComponment.red, ColorComponment.yellow, ColorComponment.blue, ColorComponment.green, ColorComponment.gray, ColorComponment.purple, ColorComponment.orange, ColorComponment.black, ColorComponment.white]
}

//MARK: 绘制形状
func drawShap(_ type : DrawRectType, rect : CGRect, adjustFont : Bool, color : UIColor, text: String?, imageSize: CGSize) -> UIImage? {
    //开始绘制
    UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0);
    //绘图上下文获取失败则跳转
    guard let context = UIGraphicsGetCurrentContext() else {
        UIGraphicsEndImageContext();
        return nil
    }
    
    context.setStrokeColor(color.cgColor);
    context.setLineWidth(2.5);
    let rect = CGRect(x: 2.5, y: 2.5, width: rect.size.width - 5, height: rect.size.height - 5)
    
    switch type {
    case .radio:
        context.addEllipse(in: rect) //椭圆
    case .cub:
        context.addRect(rect) //矩形
    case .text:
        drawText(rect, adjustFont: adjustFont, color: color, text: text, imageSize: imageSize)
    }
    
    //渲染
    context.drawPath(using: .stroke);
    let image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext()
    
    return image
}

//MARK: 绘制文字
fileprivate func drawText(_ rect : CGRect, adjustFont : Bool, color : UIColor, text: String?, imageSize: CGSize) {
    let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: UIFontTextStyle.body)
    let boldFontDescriptor = fontDescriptor.withSymbolicTraits(.traitBold)
    let font = UIFont(descriptor: boldFontDescriptor!, size: adjustFont ? 16.0 * imageSize.width / UIScreen.main.bounds.size.width:16)
    let paragraphStyle = NSParagraphStyle.default.mutableCopy() as! NSMutableParagraphStyle
    paragraphStyle.lineBreakMode = .byCharWrapping
    paragraphStyle.alignment = .center
    let attributes = [NSAttributedStringKey.foregroundColor:color,//设置文字颜色
        NSAttributedStringKey.font:font,//设置文字的字体
        NSAttributedStringKey.kern:0,//文字之间的字距
        NSAttributedStringKey.paragraphStyle:paragraphStyle//设置文字的样式
        ] as [NSAttributedStringKey : Any]
    let newText = (text ?? "") as NSString
    let szieNewText = newText.boundingRect(with: rect.size, options: .usesLineFragmentOrigin, attributes: attributes, context: nil).size
    let newRect = CGRect(x: rect.origin.x, y: rect.origin.y, width: szieNewText.width, height: szieNewText.height)
    newText.draw(in: newRect, withAttributes: attributes)
}

//MARK: 绘制背景
func drawRawView(originImage: UIImage, drawSize: CGSize, paths: [DrawPath]) -> UIImage? {
    var rect:CGRect = CGRect.zero
    //开始绘制
    UIGraphicsBeginImageContextWithOptions(originImage.size, false, 0.0);
    //绘图上下文获取失败则跳转
    guard let context = UIGraphicsGetCurrentContext() else {
        UIGraphicsEndImageContext();
        return nil
    }
    
    originImage.draw(in: CGRect(x: 0, y: 0, width: originImage.size.width, height: originImage.size.height))
    context.setLineWidth(2.5 * fabs(originImage.size.width / drawSize.width))
    
    for path in paths {
        //转换遮罩层上的大小，对应背景层的大小
        rect.origin.x = path.rect.origin.x / drawSize.width * originImage.size.width;
        rect.origin.y = path.rect.origin.y / drawSize.height * originImage.size.height;
        rect.size.width = path.rect.size.width / drawSize.width * originImage.size.width;
        rect.size.height = path.rect.size.height / drawSize.height * originImage.size.height;
        
        context.setStrokeColor(path.color.cgColor);
        
        switch path.type {
        case .radio:
            context.addEllipse(in: rect) //椭圆
        case .cub:
            context.addRect(rect) //矩形
        case .text:
            drawText(rect, adjustFont: false, color: path.color, text: path.text ?? "", imageSize: originImage.size)
        }
        
        //渲染
        context.drawPath(using: .stroke)
    }
    
    let image = UIGraphicsGetImageFromCurrentImageContext()!
    
    UIGraphicsEndImageContext()
    
    return image
}
