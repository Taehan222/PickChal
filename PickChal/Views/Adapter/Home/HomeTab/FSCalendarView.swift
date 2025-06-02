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
        calendar.appearance.titleDefaultColor = .black // ✅ 기본은 블랙
        calendar.locale = Locale(identifier: "ko_KR")
        calendar.firstWeekday = 1
        calendar.placeholderType = .none
        calendar.scope = .month
        calendar.scopeGesture.isEnabled = true

        calendar.register(CustomCell.self, forCellReuseIdentifier: "cell")

        applyTheme(to: calendar)

        return calendar
    }

    func updateUIView(_ uiView: FSCalendar, context: Context) {
        uiView.select(selectedDate)
        applyTheme(to: uiView)
    }

    private func applyTheme(to calendar: FSCalendar) {
        let theme = themeManager.currentTheme
        calendar.appearance.todayColor = theme.accentColor.uiColor
        calendar.appearance.selectionColor = theme.accentColor.uiColor.withAlphaComponent(0.3)
        calendar.appearance.weekdayFont = UIFont.boldSystemFont(ofSize: 14)
        calendar.appearance.weekdayTextColor = .black
        calendar.appearance.titleFont = UIFont.systemFont(ofSize: 16, weight: .regular)
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
        }

        // ✅ 기본 색상은 블랙, 오늘/선택된 날짜는 흰색
        func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
            if Calendar.current.isDateInToday(date) || Calendar.current.isDate(date, inSameDayAs: parent.selectedDate) {
                return .white
            }
            return .black
        }

        func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
            DispatchQueue.main.async {
                self.parent.calendarHeight = bounds.height
            }
        }

        func calendar(_ calendar: FSCalendar, cellFor date: Date, at monthPosition: FSCalendarMonthPosition) -> FSCalendarCell {
            let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: monthPosition) as! CustomCell
            let isToday = Calendar.current.isDateInToday(date)
            let isSelected = Calendar.current.isDate(date, inSameDayAs: parent.selectedDate)
            let theme = parent.themeManager.currentTheme
            cell.showSelection(isSelected, isToday: isToday, theme: theme)
            return cell
        }
    }
}

extension Color {
    var uiColor: UIColor {
        UIColor(self)
    }
}
