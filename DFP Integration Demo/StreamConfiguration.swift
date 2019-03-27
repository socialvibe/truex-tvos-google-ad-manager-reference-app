//
//  StreamConfiguration.swift
//  DFP Integration Demo
//
//  Created by Isaiah Mann on 3/20/19.
//  Copyright © 2019 true[X]. All rights reserved.
//

struct StreamConfiguration : Decodable, Equatable {
    let title : String
    let description : String
    let cover : String
    let preview : String
    let googleContentID : String
    let googleVideoID : String
    
    static func == (lhs: StreamConfiguration, rhs: StreamConfiguration) -> Bool {
        return lhs.title == rhs.title &&
                lhs.description == rhs.description &&
                lhs.cover == rhs.cover &&
                lhs.preview == rhs.preview &&
                lhs.googleContentID == rhs.googleContentID &&
                lhs.googleVideoID == rhs.googleVideoID
    }
    
    enum CodingKeys : String, CodingKey {
        case title
        case description
        case cover
        case preview
        case googleContentID = "google_content_id"
        case googleVideoID = "google_video_id"
    }
}
