//
//  VKSlider.swift
//  VKSlider
//
//  Created by Viacheslav Karamov on 29.09.15.
//  Copyright © 2015 Viacheslav Karamov. All rights reserved.
//

import UIKit

@IBDesignable
public class VKSlider: UIControl
{
    /// Start color of gradient background. Has no effect if gradientColorEnd is nil. Default nil.
    @IBInspectable public var gradientColorStart: UIColor? = nil
    {
        didSet
        {
            updateBackgroundColor();
        }
    }
    
    /// End color of gradient background. Has no effect if gradientColorStart is nil. Default nil.
    @IBInspectable public var gradientColorEnd: UIColor? = nil
    {
        didSet
        {
            updateBackgroundColor();
        }
    }
    
    /// Knob's colour
    @IBInspectable public var knobColor: UIColor = UIColor.whiteColor()
    {
        didSet
        {
            sliderView.backgroundColor = knobColor
        }
    }
    /// Knob's label text colour
    @IBInspectable public var knobTextColor: UIColor = UIColor.darkGrayColor()
    
    /// Slider's text colour
    @IBInspectable public var textColor: UIColor = UIColor.greenColor()
    {
        didSet
        {
            for label in backgroundLabels
            {
                label.textColor = textColor
            }
        }
    }
    
    /// Slider's corner radius
    @IBInspectable public var cornerRadius: CGFloat = 5.0
    {
        didSet
        {
            layer.cornerRadius = cornerRadius
        }
    }
    
    /// Slider's corner radius
    @IBInspectable public var knobCornerRadius: CGFloat = 2.0
        {
        didSet
        {
            sliderView.layer.cornerRadius = knobCornerRadius;
        }
    }
    
    /// Knob inset
    @IBInspectable public var knobInset: CGFloat = 2.0
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
    
    
    public var font: UIFont = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
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
    private var selectedIndex: Int = 0
    private var knobFrameUpdated = false;
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
        if titles == nil || titles.count == 0
        {
            titles = ["one", "two", "three"];
        }
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
        setupBackground();
        setupSliderView();

        setNeedsLayout();
    }
    
    private func setupBackground()
    {
        userInteractionEnabled = true;
        layer.cornerRadius = cornerRadius;
        self.clipsToBounds = true;
    }
    
    private func setupBackgroundLabels()
    {
        for (index, title) in titles.enumerate()
        {
            let label = UILabel()
            label.tag = index
            label.font = font
            label.textColor = textColor
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
    
    private func updateBackgroundColor()
    {
        if let start = gradientColorStart, end = gradientColorEnd
        {
            var gradientLayer : CAGradientLayer;
            if let firstLayer = layer.sublayers?.first as? CAGradientLayer
            {
                gradientLayer = firstLayer;
            }
            else
            {
                gradientLayer = CAGradientLayer();
                gradientLayer.startPoint = CGPoint(x: 0, y: 0.5);
                gradientLayer.endPoint = CGPoint(x: 1, y: 0.5);
            }
            gradientLayer.frame = bounds;
            gradientLayer.colors = [start.CGColor, end.CGColor];
            layer.insertSublayer(gradientLayer, atIndex: 0);
        }
    }
    
    private func setupSliderView()
    {
        sliderView = UIView();
        sliderView.backgroundColor = knobColor;
        sliderView.clipsToBounds = true;
        sliderView.userInteractionEnabled = true;
        
        let sliderRecognizer = UIPanGestureRecognizer(target: self, action: "sliderMoved:");
        self.addGestureRecognizer(sliderRecognizer);
        
        sliderView.layer.cornerRadius = knobCornerRadius;
        
        addSubview(sliderView);
    }

    
    // MARK: Layout
    
    override public func layoutSubviews()
    {
        super.layoutSubviews();
        
        layoutBackgroundLabels();
        layoutKnob(selectedIndex);
        updateBackgroundColor();
    }
    
    private func layoutKnob(index: Int)
    {
        let label = backgroundLabels[index]
        let sliderWidth = self.sliderWidth
        
        sliderView.frame = CGRect(x: CGRectGetMinX(label.frame), y: knobInset, width: sliderWidth, height: bounds.height - knobInset * 2)
    }
    
    private func updateKnobFrame(index : Int)
    {
        let label = backgroundLabels[index];
        var frame = sliderView.frame;
        frame.size.width = CGRectGetWidth(label.frame);
        
        self.sliderView.frame = frame;
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
        if let lastLabel = backgroundLabels.last
        {
            let extraSpace = CGRectGetWidth(self.frame) - CGRectGetMaxX(lastLabel.frame);
            if (extraSpace > 4.0) // let it be 4.0 pt
            {
                let spaceForEach = extraSpace / CGFloat(backgroundLabels.count);
                for (index, label) in backgroundLabels.enumerate()
                {
                    var frame = label.frame;
                    frame.size.width += spaceForEach;
                    frame.origin.x = (index > 0) ? CGRectGetMaxX(backgroundLabels[index - 1].frame) + labelMargin: labelMargin;

                    label.frame = frame;
                }
            }
        }
    }
    
    // MARK: Selection
    
    public func setSelectedIndex(index: Int, animated: Bool)
    {
        if selectedIndex != index
        {
            assert(index >= 0 && index < titles.count);
            updateSlider(index, animated: animated);
        }
    }
    
    public func getSelectedIndex() -> Int
    {
        return selectedIndex;
    }
    
    // MARK: Update Slider
    
    private func updateSlider(index: Int, animated: Bool)
    {
        animated ? updateSliderWithAnimation(index) : updateSliderWithoutAnimation(index)
    }
    
    private func updateSliderWithoutAnimation(index: Int)
    {
        layoutKnob(index)
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
            label.textColor = i == index ? knobTextColor : textColor
            label.userInteractionEnabled = i != index
        }
    }
    
    private func updateSliderWithAnimation(index: Int)
    {
        let duration = calculateAnimationDuration(index)
        UIView.animateWithDuration(duration, delay: 0, options: .CurveEaseIn, animations: { () -> Void in
            self.updateSelectedIndex(index)
            self.layoutKnob(index)
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
        let minPos = knobInset
        let maxPos = CGRectGetMinX((backgroundLabels.last?.frame)!);
        
        let translation = recognizer.translationInView(sliderView)
        sliderView.center.x += translation.x
        recognizer.setTranslation(CGPointZero, inView: recognizer.view!)
        
        if sliderView.frame.origin.x < minPos
        {
            sliderView.frame.origin.x = minPos
        }
        else if sliderView.frame.origin.x > maxPos
        {
            sliderView.frame.origin.x = maxPos
        }
        
        if (!knobFrameUpdated)
        {
            let index = getOverlappedLabelIndex(translation.x >= 0 ? .Max : .Min);
            if (index != selectedIndex)
            {
                updateKnobFrame(index);
                knobFrameUpdated = true;
            }
        }
    }
    
    private func getOverlappedLabelIndex(check: CheckPosition) -> Int
    {
        var x = sliderView.center.x;
        
        switch (check)
        {
        case .Min:
            x = CGRectGetMinX(sliderView.frame);
            break;
        
        case .Center:
            x = sliderView.center.x;
            break;
            
        case .Max:
            x = CGRectGetMaxX(sliderView.frame);
            break;
        }
        
        var index = 0;
        for (i, label) in backgroundLabels.enumerate()
        {
            if (x >= CGRectGetMinX(label.frame) && x <= CGRectGetMaxX(label.frame))
            {
                index = i;
                break;
            }
        }
        return index;
    }
    
    private func panGestureRecognizerFinished(recognizer: UIPanGestureRecognizer)
    {
        let index = getOverlappedLabelIndex(.Center);
        updateSliderWithAnimation(index);
        knobFrameUpdated = false;
    }
}

private enum CheckPosition
{
    case Min, Center, Max;
}