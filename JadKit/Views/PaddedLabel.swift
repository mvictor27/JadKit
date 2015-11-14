//
//  PaddedLabel.swift
//  JadKit
//
//  Created by Jad Osseiran on 11/14/15.
//  Copyright © 2015 Jad Osseiran. All rights reserved.
//

import UIKit

@IBDesignable
public class PaddedLabel: UILabel {

    @IBInspectable public var inset: CGSize = CGSize(width: 0.0, height: 0.0)

    public var padding: UIEdgeInsets {
        var hasText: Bool = false

        if let text = text?.characters.count where text > 0 {
            hasText = true
        } else if let text = attributedText?.length where text > 0 {
            hasText = true
        }

        return hasText ? UIEdgeInsets(top: inset.height, left: inset.width, bottom: inset.height, right: inset.width) : UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    public override func drawTextInRect(rect: CGRect) {
        super.drawTextInRect(UIEdgeInsetsInsetRect(rect, padding))
    }

    // FIXME: This is still not perfect. Spend some time trying to understand it.
    override public func textRectForBounds(bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        var rect = super.textRectForBounds(bounds, limitedToNumberOfLines: numberOfLines)

        if let text = text {
            let estimatedWidth = CGRectGetWidth(rect) - (2 * (padding.left + padding.right))
            let estimatedHeight = CGFloat.max

            let boundingSize = CGSize(width: estimatedWidth, height: estimatedHeight)
            let calculatedFrame = NSString(string: text).boundingRectWithSize(boundingSize, options: .UsesLineFragmentOrigin, attributes: [NSFontAttributeName : font], context: nil)

            let calculatedWidth = ceil(CGRectGetWidth(calculatedFrame))
            let calculatedHeight = ceil(CGRectGetHeight(calculatedFrame))

//            let finalHeight = (calculatedHeight + padding.top + padding.bottom)
            rect.size = CGSize(width: calculatedWidth, height: calculatedHeight)
        }

        return rect
    }

    public override func intrinsicContentSize() -> CGSize {
        let superContentSize = super.intrinsicContentSize()

        let width = superContentSize.width + padding.left + padding.right
        let heigth = superContentSize.height + padding.top + padding.bottom

        return CGSize(width: width, height: heigth)
    }

    public override func sizeThatFits(size: CGSize) -> CGSize {
        let superSizeThatFits = super.sizeThatFits(size)

        let width = superSizeThatFits.width + padding.left + padding.right
        let heigth = superSizeThatFits.height + padding.top + padding.bottom

        return CGSize(width: width, height: heigth)
    }
}
