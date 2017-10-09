//
//  Editor.swift
//  EditorCore
//
//  Created by virus1993 on 2017/10/9.
//  Copyright © 2017年 ascp. All rights reserved.
//

import UIKit

public typealias Clourse = (UIImage) -> Void

//图层
enum DrawViewType {
    case raw
    case draw
    case middle
}

public class DrawCoreViewController: UIViewController {
    let DrawViewTagStart:UInt = 100
    var viewTagValue:UInt = UInt()
    var selectedImage:UIImageView = UIImageView()
    var drawView:UIImageView = UIImageView()
    var oneTimeView:UIImageView = UIImageView()
    var startPoint:CGPoint = CGPoint()
    var endPoint:CGPoint = CGPoint()
    var movePoint:CGPoint = CGPoint()
    var rectType = DrawRectType.radio
    
    var originImage:UIImage = UIImage()
    var paths:[DrawPath] = [DrawPath]()
    var text = ""
    var color:UIColor = UIColor()
    
    var backClourse: Clourse?
    
    required public init?(image : UIImage, clourse : @escaping Clourse) {
        super.init(nibName: nil, bundle: nil)
        backClourse = clourse
        originImage = image
        color = ColorComponment.colors.first!.color
        viewTagValue = DrawViewTagStart
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.black
        
        let width = originImage.size.width > view.frame.size.width ? view.frame.size.width : originImage.size.width
        let height = originImage.size.height * width / originImage.size.width
        
        selectedImage.frame = CGRect(x: 0, y: 64, width: width, height: height)
        selectedImage.image = originImage
        selectedImage.center = view.center
        view.addSubview(selectedImage)
        
        drawView.frame = selectedImage.frame
        drawView.image = UIImage()
        drawView.backgroundColor = UIColor.clear
        drawView.isUserInteractionEnabled = true
        drawView.layer.masksToBounds = true
        view.addSubview(drawView)
        
        oneTimeView = UIImageView()
        drawView.addSubview(oneTimeView)
        
        
        let leftBtn = UIButton(frame: CGRect(x: 5, y: 28, width: 100, height: 60))
        leftBtn.backgroundColor = UIColor.white
        leftBtn.setTitle("取消", for: UIControlState())
        leftBtn.setTitleColor(UIColor.blue, for: UIControlState())
        leftBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        leftBtn.layer.borderColor = UIColor.blue.cgColor
        leftBtn.layer.borderWidth = 1
        leftBtn.layer.cornerRadius = 4
        leftBtn.addTarget(self, action: #selector(self.goBack(_:)), for: .touchUpInside)
        view.addSubview(leftBtn)
        
        let rightBtn = UIButton(frame: CGRect(x: view.frame.size.width - 105, y: 28, width: 100, height: 60))
        rightBtn.backgroundColor = UIColor.white
        rightBtn.setTitle("完成", for: UIControlState())
        rightBtn.setTitleColor(UIColor.blue, for: UIControlState())
        rightBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        rightBtn.layer.borderColor = UIColor.blue.cgColor
        rightBtn.layer.borderWidth = 1
        rightBtn.layer.cornerRadius = 4
        rightBtn.addTarget(self, action: #selector(self.save(_:)), for: .touchUpInside)
        view.addSubview(rightBtn)
        
        let rollbackBtn = UIButton(frame: CGRect(x: leftBtn.frame.origin.x + leftBtn.frame.size.width + 5, y: leftBtn.frame.origin.y, width: view.frame.size.width - (leftBtn.frame.size.width + rightBtn.frame.size.width + 4 * 5), height: leftBtn.frame.size.height))
        rollbackBtn.backgroundColor = UIColor.white
        rollbackBtn.setTitle("撤销", for: UIControlState())
        rollbackBtn.setTitleColor(UIColor.blue, for: UIControlState())
        rollbackBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        rollbackBtn.layer.borderColor = UIColor.blue.cgColor
        rollbackBtn.layer.borderWidth = 1
        rollbackBtn.layer.cornerRadius = 4
        rollbackBtn.addTarget(self, action: #selector(self.rollback(_:)), for: .touchUpInside)
        view.addSubview(rollbackBtn)
        
        let upBtn = UIButton(frame: CGRect(x: 5, y: view.frame.size.height - 65, width: 100, height: 60))
        upBtn.backgroundColor = UIColor.white
        upBtn.setTitle(rectType.rawValue, for: UIControlState())
        upBtn.setTitleColor(UIColor.blue, for: UIControlState())
        upBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        upBtn.layer.borderColor = UIColor.blue.cgColor
        upBtn.layer.borderWidth = 1
        upBtn.layer.cornerRadius = 4
        upBtn.addTarget(self, action: #selector(self.shap(_:)), for: .touchUpInside)
        view.addSubview(upBtn)
        
        let downBtn = UIButton(frame: CGRect(x: view.frame.size.width - 105, y: view.frame.size.height - 65, width: 100, height: 60))
        downBtn.backgroundColor = UIColor.white
        downBtn.setTitle(ColorComponment.colors.first!.name, for: UIControlState())
        downBtn.setTitleColor(UIColor.blue, for: UIControlState())
        downBtn.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        downBtn.layer.borderColor = UIColor.blue.cgColor
        downBtn.layer.borderWidth = 1
        downBtn.layer.cornerRadius = 4
        downBtn.addTarget(self, action: #selector(self.colorChange(_:)), for: .touchUpInside)
        view.addSubview(downBtn)
    }
    
    //MARK: 返回
    @objc fileprivate func goBack(_ button : UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: 保存
    @objc fileprivate func save(_ button : UIButton) {
        let alert = UIAlertController(title: "请稍等", message: "正在载入图片", preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        drawInBackgroundView()
        if backClourse != nil {
            backClourse!(originImage)
        }
        alert.dismiss(animated: true, completion: {
            self.goBack(button)
        })
    }
    
    //MARK: 撤销
    @objc fileprivate func rollback(_ button : UIButton) {
        if viewTagValue > DrawViewTagStart {
            guard let imageView = drawView.viewWithTag(Int(viewTagValue - 1)) as? UIImageView else {
                return
            }
            imageView.removeFromSuperview()
            paths.remove(at: paths.count - 1)
            viewTagValue -= 1
        }
    }
    
    //MARK: 形状
    @objc fileprivate func shap(_ button : UIButton) {
        let hander : ((UIAlertAction) -> Swift.Void) = {
            action in
            guard let btnTitle = action.title, let type = DrawRectType(rawValue: btnTitle) else {
                return
            }
            self.rectType = type
            button.setTitle(type.rawValue, for: UIControlState())
            switch type {
            case .radio, .cub:
                break
            case .text:
                self.addText(button)
                break
            }
        }
        let alert = UIAlertController(title: "请选择图形", message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: {
            action in
            alert.dismiss(animated: true, completion: nil)
        })
        var actions = [DrawRectType.cub, DrawRectType.radio, DrawRectType.text].map({
            return UIAlertAction(title: $0.rawValue, style: .default, handler: hander)
        })
        
        actions.append(cancelAction)
        actions.forEach({ alert.addAction($0) })
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: 颜色改变
    @objc fileprivate func colorChange(_ button : UIButton) {
        let alert = UIAlertController(title: "请选择颜色", message: nil, preferredStyle: .actionSheet)
        for item in ColorComponment.colors {
            let action = UIAlertAction(title: item.name, style: .default, handler: {
                action in
                self.color = item.color
                button.setTitle(item.name, for: UIControlState())
            })
            alert.addAction(action)
        }
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: 添加文字
    fileprivate func addText(_ button : UIButton) {
        let alert = UIAlertController(title: "请输入文字", message: nil, preferredStyle: .alert)
        alert.addTextField(configurationHandler: {
            textField in
            textField.placeholder = "填写文字"
        })
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: {
            action in
            if let textFields = alert.textFields {
                if let text = textFields[0].text, text != "" {
                    self.text = text
                }
            }
            self.rectType = .text
            alert.dismiss(animated: true, completion: nil)
        })
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: {
            action in
            alert.dismiss(animated: true, completion: nil)
        })
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: 触摸事件
    override public func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if let imageView = touch?.view as? UIImageView, imageView == drawView {
            startPoint = (touch?.location(in: imageView))!
        }
    }
    
    override public func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if let imageView = touch?.view as? UIImageView, imageView == drawView {
            movePoint = (touch?.location(in: imageView))!
            DispatchQueue.global().async(execute: {
                DispatchQueue.main.async(execute: {
                    self.drawNewWay(.draw, rectType: self.rectType, color: self.color)
                })
            })
        }
    }
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first
        if let imageView = touch?.view as? UIImageView, imageView == drawView {
            endPoint = (touch?.location(in: imageView))!
            DispatchQueue.global().async(execute: {
                DispatchQueue.main.async(execute: {
                    self.drawNewWay(.middle, rectType: self.rectType, color: self.color)
                })
            })
        }
    }
    
    //MARK: 绘图方法
    fileprivate func drawNewWay(_ viewType : DrawViewType, rectType : DrawRectType, color : UIColor) {
        var finishedPoint:CGPoint = CGPoint.zero
        var tmpView:UIImageView = UIImageView()
        var rect:CGRect = CGRect.zero
        
        switch viewType {
        case .draw:
            finishedPoint = movePoint
            tmpView = oneTimeView
        case .middle:
            finishedPoint = endPoint
            oneTimeView.image = nil
            drawView.insertSubview(tmpView, belowSubview: oneTimeView)
        default:
            break
        }
        
        rect.origin = CGPoint(x: finishedPoint.x > startPoint.x ? startPoint.x:finishedPoint.x, y: finishedPoint.y > startPoint.y ? startPoint.y:finishedPoint.y)
        rect.size = CGSize(width: fabs(finishedPoint.x - startPoint.x), height: fabs(finishedPoint.y - startPoint.y))
        tmpView.frame = rect
        
        tmpView.image = drawShap(rectType, rect: CGRect(x: 2.5, y: 2.5, width: rect.size.width - 5, height: rect.size.height - 5), adjustFont: false, color: color, text: text, imageSize: selectedImage.frame.size);
        
        //手指绘图结束则纪录该绘图信息
        if .middle == viewType {
            var red:CGFloat = CGFloat()
            var green:CGFloat = CGFloat()
            var blue:CGFloat = CGFloat()
            var alpha:CGFloat = CGFloat()
            
            color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            switch rectType {
            case .text:
                let path = DrawPath(rect: rect, type: rectType, red: red, green: green, blue: blue, alpha: alpha, text: text)
                paths.append(path)
                break
            default:
                let path = DrawPath(rect: rect, type: rectType, red: red, green: green, blue: blue, alpha: alpha)
                paths.append(path)
                break
            }
            tmpView.tag = Int(viewTagValue);
            viewTagValue += 1
        }
    }
    
    //MARK: 绘制背景
    fileprivate func drawInBackgroundView() {
        if let image = drawRawView(originImage: originImage, drawSize: drawView.frame.size, paths: paths) {
            originImage = image
        }
    }
}
