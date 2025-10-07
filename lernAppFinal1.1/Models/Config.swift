//
//  Config.swift
//  lernAppFinal1.1
//
//  Created by Kasi  on 04.09.25.
//

import Foundation

struct Config {
    static func value(for key: String) -> String? {
        guard let url = Bundle.main.url(forResource: "Config", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(from: data, options: [], format: nil) as? [String: Any] else {
            return nil
        }
        return plist[key] as? String
    }
}
