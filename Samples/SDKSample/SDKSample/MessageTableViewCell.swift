//
//  MessageTableViewCell.swift
//  SDKSample
//
//  Created by Robert Walsh on 11/24/15.
//  Copyright © 2015 Apigee Inc. All rights reserved.
//

import Foundation
import UIKit

public class MessageTableViewCell : UITableViewCell {

    var titleLabel : UILabel
    var bodyLabel  : UILabel
    var thumbnailView : UIImageView
    var indexPath : NSIndexPath?

    public static let kMessageTableViewCellMinimumHeight: CGFloat = 50.0;
    public static let kMessageTableViewCellAvatarHeight: CGFloat = 30.0;

    static var defaultFontSize: CGFloat {
        return 16.0
    }

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        self.titleLabel = UILabel(frame: CGRect.zero)
        self.bodyLabel = UILabel(frame: CGRect.zero)
        self.thumbnailView = UIImageView(frame: CGRect.zero)

        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.backgroundColor = UIColor.whiteColor()
        self.configureSubviews()
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func prepareForReuse() {
        self.selectionStyle = UITableViewCellSelectionStyle.None
        self.titleLabel.font = UIFont.boldSystemFontOfSize(MessageTableViewCell.defaultFontSize)
        self.bodyLabel.font = UIFont.boldSystemFontOfSize(13)
        self.titleLabel.text = ""
        self.bodyLabel.text = ""
    }

    func configureSubviews() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.backgroundColor = UIColor.clearColor()
        self.titleLabel.userInteractionEnabled = false
        self.titleLabel.numberOfLines = 0
        self.titleLabel.textColor = UIColor.grayColor()
        self.titleLabel.font = UIFont.boldSystemFontOfSize(MessageTableViewCell.defaultFontSize)

        self.bodyLabel.translatesAutoresizingMaskIntoConstraints = false
        self.bodyLabel.backgroundColor = UIColor.clearColor()
        self.bodyLabel.userInteractionEnabled = false
        self.bodyLabel.numberOfLines = 0
        self.bodyLabel.textColor = UIColor.grayColor()
        self.bodyLabel.font = UIFont.boldSystemFontOfSize(13)

        self.thumbnailView.translatesAutoresizingMaskIntoConstraints = false
        self.thumbnailView.userInteractionEnabled = false
        self.thumbnailView.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
        self.thumbnailView.layer.cornerRadius = 15
        self.thumbnailView.layer.masksToBounds = true

        self.contentView.addSubview(self.thumbnailView)
        self.contentView.addSubview(self.titleLabel)
        self.contentView.addSubview(self.bodyLabel)

        let views = ["thumbnailView":self.thumbnailView, "titleLabel":self.titleLabel, "bodyLabel":self.bodyLabel]
        let metrics = ["thumbSize":MessageTableViewCell.kMessageTableViewCellAvatarHeight, "padding":15, "right":10, "left":5]

        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-left-[thumbnailView(thumbSize)]-right-[titleLabel(>=0)]-right-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-left-[thumbnailView(thumbSize)]-right-[bodyLabel(>=0)]-right-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-right-[titleLabel(20)]-left-[bodyLabel(>=0@999)]-left-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views))
        self.contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-right-[thumbnailView(thumbSize)]-(>=0)-|", options: NSLayoutFormatOptions(rawValue: 0), metrics: metrics, views: views))
    }
}