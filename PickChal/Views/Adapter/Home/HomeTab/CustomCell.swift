//
//  CustomCell.swift
//  PickChal
//
//  Created by 조수원 on 6/2/25.
//

import FSCalendar

class CustomCell: FSCalendarCell {
    private let selectionLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.systemBlue.cgColor // 기본은 파란색 배경
        layer.isHidden = true
        return layer
    }()

    private let todayLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = UIColor.systemGray5.cgColor // 오늘 날짜의 회색 배경
        layer.isHidden = true
        return layer
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.insertSublayer(todayLayer, at: 0)
        contentView.layer.insertSublayer(selectionLayer, at: 0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let diameter = min(bounds.width, bounds.height) - 12
        let circleRect = CGRect(
            x: (bounds.width - diameter) / 2,
            y: (bounds.height - diameter) / 2 - 4,
            width: diameter,
            height: diameter
        )
        let path = UIBezierPath(ovalIn: circleRect).cgPath
        selectionLayer.path = path
        todayLayer.path = path

        if let titleLabel = self.value(forKey: "titleLabel") as? UILabel {
            contentView.bringSubviewToFront(titleLabel)
        }
    }

    func showSelection(_ selected: Bool, isToday: Bool) {
        todayLayer.isHidden = !isToday
        selectionLayer.isHidden = isToday || !selected
    }
}
