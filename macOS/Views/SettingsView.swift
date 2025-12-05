//
//  SettingsView.swift
//  Cosmofy macOS
//
//  Created by Arryan Bhatnagar on 12/4/24.
//

import SwiftUI

struct SettingsView: View {
    @AppStorage("firstName") private var firstName: String = ""
    @AppStorage("showSummaries") private var showSummaries: Bool = true

    var body: some View {
        TabView {
            Form {
                Section {
                    TextField("Your Name", text: $firstName)
                        .textFieldStyle(.roundedBorder)
                } header: {
                    Text("Profile")
                }

                Section {
                    Toggle("Show AI summaries for APOD", isOn: $showSummaries)
                } header: {
                    Text("Content")
                }
            }
            .formStyle(.grouped)
            .tabItem {
                Label("General", systemImage: "gear")
            }

            Form {
                Section {
                    LabeledContent("Version", value: "3.0.0")
                    LabeledContent("Build", value: "1")
                } header: {
                    Text("App Info")
                }

                Section {
                    Link(destination: URL(string: "https://github.com/bhatnag8/Cosmofy")!) {
                        Label("View on GitHub", systemImage: "link")
                    }
                } header: {
                    Text("Links")
                }
            }
            .formStyle(.grouped)
            .tabItem {
                Label("About", systemImage: "info.circle")
            }
        }
        .frame(width: 450, height: 250)
    }
}
