//
//  FSCalendarView.swift
//  PickChal
//
//  Created by 조수원 on 5/25/25.
//

import SwiftUI
import FSCalendar

struct CalendarView: UIViewRepresentable {
    @Binding var selectedDate: Date
    @Binding var calendarHeight: CGFloat
    @EnvironmentObject var themeManager: ThemeManager

    func makeUIView(context: Context) -> FSCalendar {
        let calendar = FSCalendar(frame: .zero)
        calendar.delegate = context.coordinator
        calendar.dataSource = context.coordinator
        calendar.headerHeight = 0
        calendar.appearance.todayColor = .clear
        calendar.appearance.selectionColor = .clear
        calendar.appearance.weekdayFont = UIFont.boldSystemFont(ofSize: 14)
        calendar.appearance.weekdayTextColor = .black
        calendar.appearance.titleFont = UIFont.systemFont(ofSize: 16, weight: .regular)
        calendar.appearance.titleDefaultColor = .label
        calendar.locale = Locale(identifier: "ko_KR")
        calendar.firstWeekday = 1
        calendar.placeholderType = .none
        calendar.scope = .month
        calendar.scopeGesture.isEnabled = true

        calendar.register(CustomCell.self, forCellReuseIdentifier: "cell")
        return calendar
    }

    func updateUIView(_ uiView: FSCalendar, context: Context) {
        uiView.select(selectedDate)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self, theme: themeManager.currentTheme)
    }

    class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
        var parent: CalendarView
        let theme: AppTheme

        init(_ parent: CalendarView, theme: AppTheme) {
            self.parent = parent
            self.theme = theme
        }

        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            parent.selectedDate = date
            calendar.reloadData()
        }

        // 숫자 색상 처리
        func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
            let isToday = Calendar.current.isDateInToday(date)
            let isSelected = Calendar.current.isDate(date, inSameDayAs: parent.selectedDate)
            if isToday {
                return .systemBlue // 오늘 날짜는 파란색
            } else if isSelected {
                return .white // 선택된 날짜는 흰색
            }
            return nil // 기본 색상
        }
        
        func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleSelectionColorFor date: Date) -> UIColor? {
            if Calendar.current.isDateInToday(date) {
                return .systemBlue // 오늘 날짜 선택 시 파란색
            }
            return .white // 기본적으로 흰색
        }

        func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
            DispatchQueue.main.async {
                self.parent.calendarHeight = bounds.height
            }
        }

        // 셀별로 배경 스타일 설정
        func calendar(_ calendar: FSCalendar, cellFor date: Date, at monthPosition: FSCalendarMonthPosition) -> FSCalendarCell {
            let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: monthPosition) as! CustomCell
            let isToday = Calendar.current.isDateInToday(date)
            let isSelected = Calendar.current.isDate(date, inSameDayAs: parent.selectedDate)
            cell.showSelection(isSelected, isToday: isToday, theme: theme)
            return cell
        }
    }
}
