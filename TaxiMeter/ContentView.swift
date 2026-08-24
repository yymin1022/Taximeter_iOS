//
//  ContentView.swift
//  TaxiMeter
//

import SwiftUI

struct ContentView: View {
    @State private var themeMode: ThemeModeSetting = RepositoryProvider.shared.settingRepository.getThemeMode()

    var body: some View {
        TaxiMeterNavHost()
            .preferredColorScheme(colorScheme)
            .task {
                for await mode in RepositoryProvider.shared.settingRepository.observeThemeMode() {
                    themeMode = mode
                }
            }
    }

    private var colorScheme: ColorScheme? {
        switch themeMode {
        case .system: return nil
        case .dark: return .dark
        case .light: return .light
        }
    }
}

#Preview {
    ContentView()
}
