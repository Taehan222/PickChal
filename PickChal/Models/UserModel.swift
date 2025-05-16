//
//  UserModel.swift
//  PickChal
//
//  Created by 윤태한 on 5/16/25.
//

import Foundation

struct UserModel {
    var id: String
    var age: String
    var personality: String
    var mbti: MBTIType
    var interests: [String]
}

enum MBTIType: String, CaseIterable, Codable, Identifiable {
    case istj, istp, infj, infp
    case estj, estp, enfj, enfp
    case intj, intp, entj, entp
    case isfj, isfp, esfj, esfp

    var id: String { rawValue.uppercased() }

    var displayName: String {
        rawValue.uppercased()
    }
}
