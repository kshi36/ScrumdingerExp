//
//  ScrumdingerApp.swift
//  Scrumdinger
//
//  Created by Kevin on 6/15/22.
//

import SwiftUI

@main
struct ScrumdingerApp: App {
    //source of truth
    @State private var scrums = DailyScrum.sampleData
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ScrumsView(scrums: $scrums)
            }
        }
    }
}
