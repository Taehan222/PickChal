//
//  OpenAIChoice.swift
//  PickChal
//
//  Created by 윤태한 on 5/20/25.
//


struct OpenAIChoice: Codable {
    struct Message: Codable {
        let content: String
        let role: String
    }
    let message: Message
}

struct OpenAIResponse: Codable {
    let choices: [OpenAIChoice]
}
