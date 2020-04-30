//
//  RouteStepTableViewCell.swift
//  CampusPartner
//
//  Created by Cindy Zastudil on 4/7/20.
//  Copyright © 2020 Cindy Zastudil. All rights reserved.
//

import UIKit

class RouteStepTableViewCell: UITableViewCell {
    
    var routeStep:RouteStep? {
        didSet {
            guard let routeStepItem = routeStep else {return}
            if let instruction = routeStepItem.instruction {
                instructionLabel.text = instruction
            }
            if let distance = routeStepItem.distance, let min = routeStepItem.timeMin, let sec = routeStepItem.timeSec {
                detailsLabel.text = "Distance: \(distance) feet, Time: \(min) minutes \(sec) seconds"
            }
        }
    }
    
    let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        return view
    }()
    
    let instructionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textColor = .black
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.numberOfLines = 0
        return label
    }()
    
    let detailsLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .black
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        containerView.addSubview(instructionLabel)
        containerView.addSubview(detailsLabel)
        self.contentView.addSubview(containerView)
        
        containerView.centerYAnchor.constraint(equalTo:self.contentView.centerYAnchor, constant: 10).isActive = true
        containerView.leadingAnchor.constraint(equalTo:self.contentView.leadingAnchor, constant: 10).isActive = true
        containerView.trailingAnchor.constraint(equalTo:self.contentView.trailingAnchor).isActive = true
        containerView.heightAnchor.constraint(equalToConstant:75).isActive = true
        containerView.bottomAnchor.constraint(equalTo:self.contentView.bottomAnchor).isActive = true
        
        instructionLabel.topAnchor.constraint(equalTo: self.containerView.topAnchor).isActive = true
        instructionLabel.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor).isActive = true
        instructionLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor).isActive = true
        
        detailsLabel.topAnchor.constraint(equalTo:self.instructionLabel.bottomAnchor).isActive = true
        detailsLabel.leadingAnchor.constraint(equalTo:self.containerView.leadingAnchor).isActive = true
        detailsLabel.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
