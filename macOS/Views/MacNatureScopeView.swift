//
//  MacNatureScopeView.swift
//  Cosmofy macOS
//
//  Created by Arryan Bhatnagar on 12/4/24.
//

import SwiftUI
import MapKit

struct MacMapWithEvents: View {
    @ObservedObject var viewModel: GQLViewModel
    @State private var selectedEvent: GQLEvent?
    @State private var isSelected = false

    var body: some View {
        ZStack {
            Map(selection: $selectedEvent) {
                ForEach(viewModel.events, id: \.id) { event in
                    if let coords = event.geometry?.last?.coordinates, coords.count >= 2 {
                        Marker(
                            "",
                            systemImage: markerImage(for: event.categories?.first?.id ?? "default"),
                            coordinate: CLLocationCoordinate2D(latitude: coords[1], longitude: coords[0])
                        )
                        .tint(markerTint(for: event.categories?.first?.id ?? "default"))
                        .tag(event)
                    }
                }
            }
            .onChange(of: selectedEvent) { _, new in
                withAnimation { isSelected = new != nil }
            }
            .mapControls {
                MapCompass()
                MapScaleView()
                MapPitchToggle()
            }
            .mapStyle(.standard(elevation: .realistic))

            if isSelected, let event = selectedEvent {
                VStack {
                    Spacer()

                    VStack(alignment: .leading, spacing: 12) {
                        // Title
                        VStack(alignment: .leading, spacing: 4) {
                            Text("EVENT TITLE")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Divider()
                            Text(event.title ?? "")
                                .font(Font.custom("SF Pro Rounded Medium", size: 18))
                        }

                        // Category
                        if let category = event.categories?.first {
                            HStack(spacing: 8) {
                                ZStack {
                                    Circle()
                                        .fill(markerTint(for: category.id ?? "default").gradient)
                                        .frame(width: 35, height: 35)
                                    Image(systemName: markerImage(for: category.id ?? "default"))
                                        .foregroundStyle(markerTint(for: category.id ?? "default") == .white ? .black : .white)
                                }

                                VStack(alignment: .leading) {
                                    Text(category.title ?? "")
                                        .font(Font.custom("SF Pro Rounded Medium", size: 16))
                                    Text("Category")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }

                        // Date
                        if let geometry = event.geometry,
                           let firstDate = geometry.first?.date,
                           let lastDate = geometry.last?.date {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(firstDate == lastDate ? "DATE" : "DATES")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Divider()
                                if firstDate == lastDate {
                                    Text(formattedDate(from: firstDate))
                                        .font(Font.custom("SF Pro Rounded Medium", size: 18))
                                } else {
                                    Text("\(formattedDate(from: firstDate)) to \(formattedDate(from: lastDate))")
                                        .font(Font.custom("SF Pro Rounded Medium", size: 18))
                                }
                            }
                        }

                        // Sources
                        if let sources = event.sources, !sources.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("SOURCES")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Divider()
                                ForEach(sources, id: \.id) { source in
                                    Text(sourceFullName(for: source.id))
                                        .font(Font.custom("SF Pro Rounded Medium", size: 14))
                                }
                            }
                        }
                    }
                    .padding()
                    .frame(maxWidth: 400)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .padding()
                }
            }
        }
        .navigationTitle("Map")
    }

    func markerImage(for categoryId: String) -> String {
        switch categoryId {
        case "drought": return "drop.triangle"
        case "dustHaze": return "aqi.medium"
        case "earthquakes": return "waveform.path.ecg"
        case "floods": return "water.waves"
        case "landslides": return "mountain.2"
        case "manmade": return "building.2"
        case "seaLakeIce": return "snowflake"
        case "severeStorms": return "cloud.bolt.rain"
        case "snow": return "cloud.snow"
        case "tempExtremes": return "thermometer.sun"
        case "volcanoes": return "flame"
        case "waterColor": return "drop"
        case "wildfires": return "flame.fill"
        default: return "mappin"
        }
    }

    func markerTint(for categoryId: String) -> Color {
        switch categoryId {
        case "drought": return .orange
        case "dustHaze": return .brown
        case "earthquakes": return .purple
        case "floods": return .blue
        case "landslides": return .brown
        case "manmade": return .gray
        case "seaLakeIce": return .cyan
        case "severeStorms": return .indigo
        case "snow": return .white
        case "tempExtremes": return .red
        case "volcanoes": return .red
        case "waterColor": return .teal
        case "wildfires": return .orange
        default: return .gray
        }
    }

    func sourceFullName(for id: String) -> String {
        switch id {
        case "GDACS": return "Global Disaster Alert and Coordination System"
        case "AVO": return "Alaska Volcano Observatory"
        case "ABFIRE": return "Alberta Wildfire"
        case "AU_BOM": return "Australia Bureau of Meteorology"
        case "BYU_ICE": return "Brigham Young University Antarctic Iceberg Tracking Database"
        case "BCWILDFIRE": return "British Columbia Wildfire Service"
        case "CALFIRE": return "California Department of Forestry and Fire Protection"
        case "CEMS": return "Copernicus Emergency Management Service"
        case "EO": return "Earth Observatory"
        case "Earthdata": return "Earthdata"
        case "FEMA": return "Federal Emergency Management Agency (FEMA)"
        case "FloodList": return "FloodList"
        case "GLIDE": return "GLobal IDEntifier Number (GLIDE)"
        case "InciWeb": return "InciWeb"
        case "IRWIN": return "Integrated Reporting of Wildfire Information (IRWIN) Observer"
        case "IDC": return "International Charter on Space and Major Disasters"
        case "JTWC": return "Joint Typhoon Warning Center"
        case "MRR": return "LANCE Rapid Response"
        case "MBFIRE": return "Manitoba Wildfire Program"
        case "NASA_ESRS": return "NASA Earth Science and Remote Sensing Unit"
        case "NASA_DISP": return "NASA Earth Science Disasters Program"
        case "NASA_HURR": return "NASA Hurricane And Typhoon Updates"
        case "NOAA_NHC": return "National Hurricane Center"
        case "NOAA_CPC": return "NOAA Center for Weather and Climate Prediction"
        case "PDC": return "Pacific Disaster Center"
        case "ReliefWeb": return "ReliefWeb"
        case "SIVolcano": return "Smithsonian Institution Global Volcanism Program"
        case "NATICE": return "U.S. National Ice Center"
        case "UNISYS": return "Unisys Weather"
        case "USGS_EHP": return "USGS Earthquake Hazards Program"
        case "USGS_CMT": return "USGS Emergency Operations Collection Management Tool"
        case "HDDS": return "USGS Hazards Data Distribution System"
        case "DFES_WA": return "Western Australia Department of Fire and Emergency Services"
        default: return id
        }
    }
}
