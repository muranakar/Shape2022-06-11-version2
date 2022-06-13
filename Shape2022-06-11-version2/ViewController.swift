//
//  ViewController.swift
//  Shape2022-06-11
//
//  Created by 村中令 on 2022/06/11.
//
// 参考: https://uruly.xyz/%E3%80%90swift-3%E3%80%91calayer%E3%82%92%E7%94%A8%E3%81%84%E3%81%A6%E5%9B%B3%E5%BD%A2%E3%82%92%E7%A7%BB%E5%8B%95%E3%83%BB%E6%8B%A1%E5%A4%A7%E7%B8%AE%E5%B0%8F%E3%81%97%E3%81%A6%E3%81%BF%E3%81%9F/
import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var drawView: DrawView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!

    @IBOutlet weak var leftFirstImageView: UIImageView!
    @IBOutlet weak var leftSecondImageView: UIImageView!
    @IBOutlet weak var leftThirdImageView: UIImageView!
    @IBOutlet weak var leftFourthImageView: UIImageView!
    @IBOutlet weak var leftFifthImageView: UIImageView!
    @IBOutlet weak var rightFirstImageView: UIImageView!
    @IBOutlet weak var rightSecondImageView: UIImageView!
    @IBOutlet weak var rightThirdImageView: UIImageView!
    @IBOutlet weak var rightFourthImageView: UIImageView!
    @IBOutlet weak var rightFifthImageView: UIImageView!

    private let randomNumber = 1...100
    private var imageViews: [UIImageView] {
        [
            leftFirstImageView,
            leftSecondImageView,
            leftThirdImageView,
            leftFourthImageView,
            leftFifthImageView,
            rightFirstImageView,
            rightSecondImageView,
            rightThirdImageView,
            rightFourthImageView,
            rightFifthImageView
        ]
    }

    private var leftImageViews: [UIImageView] {
        return [
            leftFirstImageView,
            leftSecondImageView,
            leftThirdImageView,
            leftFourthImageView,
            leftFifthImageView
        ]
    }

    private var rightImageViews: [UIImageView] {
        return [
            rightFirstImageView,
            rightSecondImageView,
            rightThirdImageView,
            rightFourthImageView,
            rightFifthImageView
        ]
    }
    //選択したレイヤーをいれておく
    private var selectLayer:CALayer!
    //最後にタッチされた座標をいれておく
    private var touchLastPoint:CGPoint!

    override func viewDidLoad() {
        super.viewDidLoad()
        drawView.delegate = self
        segmentedControl.selectedSegmentIndex = 0
        
        imageViews.forEach { imageView in
            drawView.imageViews.append(imageView)
        }

        leftImageViews.forEach { imageView in
            drawView.leftImageViews.append(imageView)
        }

        rightImageViews.forEach { imageView in
            drawView.rightImageViews.append(imageView)
        }

        leftImageViews.forEach { imageView in
            imageView.layer.borderColor = UIColor.tintColor.cgColor
            //線の太さ(太さ)
            imageView.layer.borderWidth = 1
        }
        rightImageViews.forEach { imageView in

            imageView.layer.borderColor = UIColor.black.cgColor
            //線の太さ(太さ)
            imageView.layer.borderWidth = 1
        }

    }

    @IBAction func clearTapped(_ sender: Any) {
        drawView.clear()
    }

    @IBAction func undoTapped(_ sender: Any) {
        drawView.undo()
    }

    @IBAction func createCircle(_ sender: Any) {
        let ovalShapeLayer = CAShapeLayer()
        ovalShapeLayer.strokeColor = UIColor.blue.cgColor  // 輪郭は青
        ovalShapeLayer.fillColor = UIColor.clear.cgColor  // 塗りはクリア
        ovalShapeLayer.lineWidth = 1.0
        ovalShapeLayer.path = UIBezierPath(ovalIn: CGRect(x:30, y:30, width:50, height:50)).cgPath
        self.view.layer.addSublayer(ovalShapeLayer)
    }


    @IBAction func createSquere(_ sender: Any) {
        let rect = CAShapeLayer()
        rect.strokeColor = UIColor.black.cgColor
        rect.fillColor = UIColor.green.cgColor
        rect.lineWidth = 2.0
        rect.path = UIBezierPath(rect:CGRect(x:100,y:100,width:100,height:100)).cgPath
        self.view.layer.addSublayer(rect)
    }




    @IBAction func colorChanged(_ sender: Any) {
        var c = UIColor.black
        switch segmentedControl.selectedSegmentIndex {
        case 1:
            c = UIColor.green
            break
        case 2:
            c = UIColor.red
            break
        default:
            break
        }
        drawView.setDrawingColor(color: c)
    }
}

extension ViewController: ProtocolDrawView {
    func selectedSelectionAlert() {
        present(UIAlertController.checkIsSelection(), animated: true)
    }
}

class DrawView: UIView {
    enum ImageSelectionStatus {
        case rightImage
        case leftImage
        case nothingIsSelected
    }
    var delegate: ProtocolDrawView!
    var currentDrawing: Drawing?
    var finishedDrawings: [Drawing] = []
    var currentColor = UIColor.black
    var imageViews: [UIImageView] = []
    var leftImageViews: [UIImageView] = []
    var rightImageViews: [UIImageView] = []
    var setOfTwoImages:(first: UIImageView?, second: UIImageView?)
    var selectedImages:[UIImageView] = []
    var imageSelectionStatus: ImageSelectionStatus = .nothingIsSelected

    override func draw(_ rect: CGRect) {
        for drawing in finishedDrawings {
            drawing.color.setStroke()
            stroke(drawing: drawing)
        }

        if let drawing = currentDrawing {
            drawing.color.setStroke()
            stroke(drawing: drawing)
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)



        imageViews.forEach { imageView in

            if imageView.frame.minX <= location.x
                && imageView.frame.maxX >= location.x
                && imageView.frame.minY <= location.y
                && imageView.frame.maxY >= location.y {
                if selectedImages.contains(imageView) {
                    // TODO: アラート表示する。
                    delegate.selectedSelectionAlert()

                    return
                }
                currentDrawing = Drawing(startPoint: imageView.center)
                currentDrawing?.color = currentColor
                setNeedsDisplay()
                // 選択された１つ目の画像
                setOfTwoImages.first = imageView
                if leftImageViews.contains(imageView) {
                    leftImageViews.forEach { imageView in
                        imageView.isHidden = true

                    }
                    imageSelectionStatus = .leftImage
                } else {
                    if rightImageViews.contains(imageView) {
                        rightImageViews.forEach { image in
                            image.isHidden = true
                            print(image)
                        }
                        imageSelectionStatus = .rightImage
                    }
                }
                return
            } else {
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = touches.first!
        let location = touch.location(in: self)
        currentDrawing?.endPoint = location
        setNeedsDisplay()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard var drawing = currentDrawing else { return }
        let touch = touches.first!
        let location = touch.location(in: self)

        switch imageSelectionStatus {
        case .rightImage:
            leftImageViews.forEach { imageView in
                if imageView.frame.minX <= location.x
                    && imageView.frame.maxX >= location.x
                    && imageView.frame.minY <= location.y
                    && imageView.frame.maxY >= location.y {
                    if selectedImages.contains(imageView) {
                        // TODO: アラート表示する。
                        delegate.selectedSelectionAlert()

                        return
                    }
                    drawing.endPoint = imageView.center
                    finishedDrawings.append(drawing)
                    setOfTwoImages.second = imageView
                    selectedImages.append(setOfTwoImages.first!)
                    selectedImages.append(setOfTwoImages.second!)
                }
            }
        case .leftImage:
            rightImageViews.forEach { imageView in
                if imageView.frame.minX <= location.x
                    && imageView.frame.maxX >= location.x
                    && imageView.frame.minY <= location.y
                    && imageView.frame.maxY >= location.y {
                    if selectedImages.contains(imageView) {
                        // TODO: アラート表示する。
                        delegate.selectedSelectionAlert()

                        return
                    }
                    drawing.endPoint = imageView.center
                    finishedDrawings.append(drawing)
                    setOfTwoImages.second = imageView
                    selectedImages.append(setOfTwoImages.first!)
                    selectedImages.append(setOfTwoImages.second!)
                }
            }
        case .nothingIsSelected:
            break
        }

        imageViews.forEach { imageView in
            imageView.isHidden = false
        }
        currentDrawing = nil
        setNeedsDisplay()
    }

    func clear() {
        selectedImages = []
        finishedDrawings.removeAll()
        setNeedsDisplay()
    }

    func undo() {
        if finishedDrawings.count == 0 {
            return
        }
        finishedDrawings.remove(at: finishedDrawings.count - 1)
        setNeedsDisplay()
    }

    func setDrawingColor(color : UIColor){
        currentColor = color
    }

    func stroke(drawing: Drawing) {
        let path = UIBezierPath()

        path.lineWidth = 10.0
        path.lineCapStyle = .round
        path.lineJoinStyle = .round

        let begin = drawing.startPoint
        path.move(to: begin)

        guard let end = drawing.endPoint else { return }
        path.addLine(to: end)
        path.close()
        path.stroke()
    }
}

protocol ProtocolDrawView {
    func selectedSelectionAlert()
}
