//
//  FSCalendarView.swift
//  PickChal
//
//  Created by 조수원 on 5/25/25.
//

import SwiftUI
import FSCalendar

struct FSCalendarView: UIViewRepresentable {
    @Binding var selectedDate: Date

    func makeUIView(context: Context) -> FSCalendar {
        let calendar = FSCalendar()
        calendar.delegate = context.coordinator
        calendar.dataSource = context.coordinator
        calendar.scope = .month
        calendar.locale = Locale(identifier: "ko_KR")
        calendar.appearance.headerDateFormat = "YYYY년 M월"
        calendar.appearance.todayColor = .systemGreen
        calendar.appearance.selectionColor = .systemBlue
        calendar.appearance.weekdayTextColor = .darkGray
        calendar.appearance.titleDefaultColor = .label
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        calendar.placeholderType = .none
        calendar.appearance.weekdayTextColor = .black
        calendar.appearance.weekdayFont = UIFont.boldSystemFont(ofSize: 14)
        return calendar
    }

    func updateUIView(_ uiView: FSCalendar, context: Context) {
        uiView.select(selectedDate)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
        var parent: FSCalendarView

        init(_ parent: FSCalendarView) {
            self.parent = parent
        }
        // 날짜 선택 시 호출
        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            parent.selectedDate = date
        }
        // 주말은 빨간색으로 표시
        func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
            let weekday = Calendar.current.component(.weekday, from: date)
            if weekday == 1 || weekday == 7 {
                return .red
            }
            return nil
        }
    }
}
