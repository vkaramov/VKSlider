//
//  VKSlider.swift
//  VKSlider
//
//  Created by Viacheslav Karamov on 29.09.15.
//  Copyright © 2015 Viacheslav Karamov. All rights reserved.
//

import UIKit

public class VKSlider: UIControl
{
    
    @IBInspectable public var sliderColor: UIColor = UIColor.whiteColor()
        {
        didSet
        {
            sliderView.backgroundColor = sliderColor
        }
    }
    
    @IBInspectable public var textColorFront: UIColor = UIColor.darkGrayColor()
    
    @IBInspectable public var textColorBack: UIColor = UIColor.greenColor()
        {
        didSet
        {
            for label in backgroundLabels
            {
                label.textColor = textColorBack
            }
        }
    }
    
    @IBInspectable public var cornerRadius: CGFloat = 12.0
        {
        didSet
        {
            layer.cornerRadius = cornerRadius
            sliderView.layer.cornerRadius = cornerRadius - 2
        }
    }
    
    @IBInspectable public var sliderInset: CGFloat = 2.0
        {
        didSet
        {
            setNeedsLayout()
        }
    }
    
    public var titles:[String]!
        {
        didSet
        {
            setupBackgroundLabels()
        }
    }
    
    var selectedIndex: Int = 0
    var font: UIFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
        {
        didSet
        {
            for label in backgroundLabels
            {
                label.font = font
            }
        }
    }
    
    private var labelMargin:CGFloat = 4.0
    private var backgroundLabels: [UILabel] = []
    private var sliderView: UIView!
    private var sliderWidth: CGFloat
    {
        return CGRectGetWidth(backgroundLabels[selectedIndex].frame)
    }
    
    // MARK: Initializers
    
    override public init(frame: CGRect)
    {
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        setup()
    }
    
    override public func prepareForInterfaceBuilder()
    {
        super.prepareForInterfaceBuilder()
        titles = ["One", "Two", "One more"]
    }
    
    override public func intrinsicContentSize() -> CGSize
    {
        var size  = CGSize(width: labelMargin, height: CGRectGetHeight(self.frame))
        for label in backgroundLabels
        {
            size.width += CGRectGetWidth(label.frame) + labelMargin
        }
        return size
    }
    
    // MARK: Setup
    
    private func setup()
    {
        setupBackground()
        setupSliderView()

        setNeedsLayout()
    }
    
    private func setupBackground()
    {
        userInteractionEnabled = true
        layer.cornerRadius = cornerRadius
    }
    
    private func setupBackgroundLabels()
    {
        for (index, title) in titles.enumerate()
        {
            let label = UILabel()
            label.tag = index
            label.font = font
            label.textColor = textColorBack
            label.adjustsFontSizeToFitWidth = true
            label.textAlignment = .Center
            addSubview(label)
            backgroundLabels.append(label)
            label.text = title
            label.sizeToFit()
            
            label.userInteractionEnabled = true
            let recognizer = UITapGestureRecognizer(target: self, action: "handleRecognizerTap:")
            label.addGestureRecognizer(recognizer)
        }
        invalidateIntrinsicContentSize()
    }
    
    private func setupSliderView()
    {
        sliderView = UIView()
        sliderView.backgroundColor = sliderColor
        sliderView.clipsToBounds = true
        
        let sliderRecognizer = UIPanGestureRecognizer(target: self, action: "sliderMoved:")
        sliderView.addGestureRecognizer(sliderRecognizer)
        
        layer.cornerRadius = cornerRadius
        sliderView.layer.cornerRadius = cornerRadius - 2
        
        addSubview(sliderView)
    }

    
    // MARK: Layout
    
    override public func layoutSubviews()
    {
        super.layoutSubviews()
        
        layoutBackgroundLabels()
        layoutSliderView(selectedIndex)
    }
    
    private func layoutSliderView(index: Int)
    {
        let label = backgroundLabels[index]
        let sliderWidth = self.sliderWidth
        
        sliderView.frame = CGRect(x: CGRectGetMinX(label.frame), y: sliderInset, width: sliderWidth, height: bounds.height - sliderInset * 2)
    }
    
    private func layoutBackgroundLabels()
    {
        for (index, _) in titles.enumerate()
        {
            let label = backgroundLabels[index]
            label.sizeToFit()
            var frame = label.frame
            frame.origin.x = (index > 0) ? CGRectGetMaxX(backgroundLabels[index - 1].frame) + labelMargin: labelMargin
            frame.origin.y = 0
            frame.size.height = bounds.height
            label.frame = frame
        }
    }
    
    // MARK: Set Selection
    
    func setSelectedIndex(index: Int, animated: Bool)
    {
        assert(index >= 0 && index < titles.count)
        updateSlider(index, animated: animated)
    }
    
    // MARK: Update Slider
    
    private func updateSlider(index: Int, animated: Bool)
    {
        animated ? updateSliderWithAnimation(index) : updateSliderWithoutAnimation(index)
    }
    
    private func updateSliderWithoutAnimation(index: Int)
    {
        layoutSliderView(index)
        updateSelectedIndex(index)
    }
    
    private func updateSelectedIndex(index: Int)
    {
        if selectedIndex != index
        {
            selectedIndex = index
            sendActionsForControlEvents(UIControlEvents.ValueChanged)
        }
    }
    
    private func updateColors(index : Int)
    {
        for (i, label) in backgroundLabels.enumerate()
        {
            label.textColor = i == index ? textColorFront : textColorBack
            label.userInteractionEnabled = i != index
        }
    }
    
    private func updateSliderWithAnimation(index: Int)
    {
        let duration = calculateAnimationDuration(index)
        UIView.animateWithDuration(duration, delay: 0, options: .CurveEaseIn, animations: { () -> Void in
            self.updateSelectedIndex(index)
            self.layoutSliderView(index)
            }, completion: { (finished) -> Void in
                self.updateColors(index)
        })
    }
    
    private func calculateAnimationDuration(index: Int) -> NSTimeInterval
    {
        let targetX = CGRectGetMinX(backgroundLabels[index].frame)
        let distance = targetX - sliderView.frame.origin.x
        let duration = NSTimeInterval(distance / 300)
        return abs(duration)
    }
    
    // MARK: UITapGestureRecognizer
    
    func handleRecognizerTap(recognizer: UITapGestureRecognizer)
    {
        let index = recognizer.view!.tag
        updateSliderWithAnimation(index)
    }
    
    // MARK: UIPanGestureRecognizer
    
    func sliderMoved(recognizer: UIPanGestureRecognizer)
    {
        switch recognizer.state
        {
        case .Changed:
            panGestureRecognizerChanged(recognizer)
        case .Ended, .Cancelled, .Failed:
            panGestureRecognizerFinished(recognizer)
        default:
            return
        }
    }
    
    private func panGestureRecognizerChanged(recognizer: UIPanGestureRecognizer)
    {
        let minPos = sliderInset
        let maxPos = minPos + sliderView.bounds.width
        
        let translation = recognizer.translationInView(recognizer.view!)
        recognizer.view!.center.x += translation.x
        recognizer.setTranslation(CGPointZero, inView: recognizer.view!)
        
        if sliderView.frame.origin.x < minPos
        {
            sliderView.frame.origin.x = minPos
        }
        else if sliderView.frame.origin.x > maxPos
        {
            sliderView.frame.origin.x = maxPos
        }
    }
    
    private func panGestureRecognizerFinished(recognizer: UIPanGestureRecognizer)
    {
        let index = sliderView.center.x > sliderWidth ? 1 : 0
        updateSliderWithAnimation(index)
    }
    
}