//
//  TVRNNMaybach.swift
//  Cosmofy
//
//  Created by Arryan Bhatnagar on 7/12/24.
//

import Foundation
import SwiftUI
import MapKit


struct MapWithEvents: View {
    @ObservedObject var viewModel: GQLViewModel
    @State var event: GQLEvent?
    @State var selected: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                Map(selection: $event) {
                    ForEach(viewModel.events) { event in
                        let categoryId = event.categories?.first?.id ?? "default"
                        let lat = event.geometry?.last?.coordinates?.last ?? -999
                        let lon = event.geometry?.last?.coordinates?.first ?? -999
                        Marker("", systemImage: markerImage(for: categoryId),
                               coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon)
                        )
                        .tint(markerTint(for: categoryId))
                        .tag(event)
                    }
                }

                .onChange(of: event, { old, new in
                    if new != nil {
                        withAnimation {
                            selected = true
                        }
                    } else {
                        withAnimation {
                            selected = false
                        }
                    }
                })
                .mapControls {
                    MapCompass()
                    MapScaleView()
                    MapPitchToggle()
                }
                .mapStyle(.standard(elevation: .realistic))
                .alert(isPresented: .constant(viewModel.eventsFailed), content: {
                    Alert(title: Text("Error"), message: Text("Failed to load events"), dismissButton: .default(Text("OK")))
                })

                if selected {
                    HStack {
                        ZStack {
                            VStack {
                                // View 1
                                VStack {
                                    VStack(spacing: 2) {
                                        HStack {
                                            Text("Event name")
                                                .font(.caption2)
                                                .textCase(.uppercase)
                                                .foregroundStyle(.secondary)
                                            Spacer()
                                        }
                                        Divider()
                                    }

                                    HStack {
                                        Text(event?.title ?? "")
                                            .multilineTextAlignment(.leading)
                                            .font(.caption)
                                            .fontDesign(.rounded)
                                            .fontWeight(.medium)
                                        Spacer()
                                    }

                                    if let categories = event?.categories {
                                        ForEach(categories) { category in
                                            HStack(spacing: 8) {
                                                ZStack {
                                                    Circle().fill(Color(markerTint(for: category.id)).gradient)
                                                    Image(systemName: markerImage(for: category.id))
                                                }
                                                .foregroundStyle(markerTint(for: category.id) == .white ? .black : .white)
                                                .frame(maxHeight: 50)

                                                VStack(spacing: 0) {
                                                    HStack {
                                                        Text(category.title ?? "")
                                                            .font(.caption)
                                                            .fontDesign(.rounded)
                                                            .fontWeight(.medium)
                                                        Spacer()
                                                    }
                                                    HStack {
                                                        Text("Event Category")
                                                            .font(.caption2)
                                                            .fontDesign(.rounded)
                                                            .fontWeight(.medium)
                                                            .foregroundStyle(.secondary)
                                                        Spacer()
                                                    }
                                                }
                                                Spacer()
                                            }
                                        }
                                    }
                                }


                                // View 2
                                VStack {
                                    if let geometry = event?.geometry, geometry.count == 1,
                                       let first = geometry.first?.coordinates, first.count >= 2 {
                                        let lat = first[1]
                                        let lon = first[0]
                                        Map(coordinateRegion: .constant(MKCoordinateRegion(
                                            center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                                            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))),
                                            interactionModes: [])
                                            .frame(height: 250)
                                            .mapStyle(.hybrid(showsTraffic: false))

                                    } else if let geometry = event?.geometry {
                                        Map(interactionModes: []) {
                                            ForEach(geometry) { geo in
                                                if let coords = geo.coordinates, coords.count >= 2 {
                                                    Annotation(coordinate: CLLocationCoordinate2D(
                                                        latitude: coords[1],
                                                        longitude: coords[0]), content: {
                                                            Circle()
                                                                .foregroundStyle(.red)
                                                                .frame(width: 6, height: 6)
                                                        }) {

                                                        }
                                                }
                                            }
                                        }
                                        .frame(height: 250)
                                        .mapStyle(.hybrid(showsTraffic: false))
                                    }
                                }
                                .clipShape(RoundedRectangle(cornerRadius: 12))

                                // View 3
                                VStack {
                                    let firstDate = event?.geometry?.first?.date
                                    let lastDate = event?.geometry?.last?.date

                                    if firstDate == lastDate {
                                        VStack(spacing: 4) {
                                            VStack(spacing: 2) {
                                                HStack {
                                                    Text("Recorded on")
                                                        .font(.caption2)
                                                        .textCase(.uppercase)
                                                        .foregroundStyle(.secondary)
                                                    Spacer()
                                                }
                                                Divider()
                                            }

                                            HStack {
                                                Text(formattedDate(from: firstDate ?? ""))
                                                    .font(.caption)
                                                    .fontDesign(.rounded)
                                                    .fontWeight(.medium)
                                                Spacer()
                                            }
                                        }
                                        .padding(.top, 6)
                                    } else {
                                        VStack(spacing: 4) {
                                            VStack(spacing: 2) {
                                                HStack {
                                                    Text("First Record")
                                                        .font(.caption2)
                                                        .textCase(.uppercase)
                                                        .foregroundStyle(.secondary)
                                                    Spacer()
                                                }
                                                Divider()
                                            }

                                            HStack {
                                                Text(formattedDate(from: firstDate ?? ""))
                                                    .font(.caption)
                                                    .fontDesign(.rounded)
                                                    .fontWeight(.medium)
                                                Spacer()
                                            }
                                        }
                                        .padding(.top, 6)


                                        VStack(spacing: 4) {
                                            VStack(spacing: 2) {
                                                HStack {
                                                    Text("Latest Record")
                                                        .font(.caption2)
                                                        .textCase(.uppercase)
                                                        .foregroundStyle(.secondary)
                                                    Spacer()
                                                }
                                                Divider()
                                            }

                                            HStack {
                                                Text(formattedDate(from: lastDate ?? ""))
                                                    .font(.caption)
                                                    .fontDesign(.rounded)
                                                    .fontWeight(.medium)
                                                Spacer()
                                            }
                                        }
                                        .padding(.top, 6)
                                    }


                                    if let sources = event?.sources {

                                        VStack(spacing: 2) {
                                            HStack {
                                                Text("source")
                                                    .font(.caption2)
                                                    .textCase(.uppercase)
                                                    .foregroundStyle(.secondary)
                                                Spacer()
                                            }
                                            Divider()
                                        }
                                        .padding(.top, 6)

                                        ForEach(sources) { source in
                                            VStack(spacing: 4) {
                                                HStack {
                                                    Text(getSourceTitle(by: source.id) ?? source.id)
                                                        .font(.caption).fontDesign(.rounded).fontWeight(.medium)
                                                    Spacer()
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .padding()
                            .frame(maxWidth: 500)
                            .background(.ultraThinMaterial)
                            .clipShape(RoundedRectangle(cornerRadius: 24))

                        }

                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 24)
                }


            }
        }
    }
}



struct RNNMaybach: View {
    @ObservedObject var viewModel: GQLViewModel
    @Binding var complete: Bool
    @Binding var failed: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    HStack {
                        Text("from the NASA Earth Observatory")
                            .font(.caption)
                            .textCase(.uppercase)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    Divider()

                    VStack {
                        HStack {
                            Text("Browse the Entire Globe Daily and Look For Natural Events as They Occur")
                                .multilineTextAlignment(.leading)
                                .textCase(.uppercase)
                                .font(.title2)
                                .bold()
                                .fontWidth(.compressed)
                            Spacer()
                        }
                    }

                    HStack {
                        Text("Displaying all events since \(getFormattedDate14DaysAgo())")
                            .multilineTextAlignment(.leading)
                            .foregroundStyle(.secondary)
                            .fontDesign(.serif)
                            .italic()
                        Spacer()
                    }
                    .padding(.top, 2)
                    .padding(.bottom, 8)

                    if complete {

                        NavigationLink(destination: MapWithEvents(viewModel: viewModel)) {

                            Text("Enter Nature Scope")
                                .fontDesign(.rounded)
                            .fontWeight(.medium)
                            .foregroundColor(Color.green)
                            .frame(maxWidth: .infinity)
                            .frame(height: 30)
                            .padding()

                        }
                    } else if failed {
                        Text("Failed to Launch")
                        .fontWeight(.medium)
                        .foregroundColor(Color.red)
                        .frame(maxWidth: .infinity)
                        .frame(height: 30)
                        .padding()
                    } else {
                        ProgressView("Loading...")
                            .frame(height: 30)
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding()
                    }

                    HStack {
                        Text("Current categories")
                            .font(.caption)
                            .textCase(.uppercase)
                            .foregroundStyle(.secondary)
                        Spacer()
                    }
                    .padding(.top)
                    Divider()

                    ForEach(categories) { category in
                        VStack {
                            HStack {
                                Text(category.id)
                                    .font(.largeTitle)
                                    .fontDesign(.serif)
                                    .frame(width: 75)
                                VStack {
                                    HStack {
                                        Text(category.title)
                                            .fontDesign(.rounded)
                                            .fontWeight(.medium)
                                        Spacer()
                                    }

                                    HStack {
                                        Text(category.description)
                                            .font(.caption)
                                            .multilineTextAlignment(.leading)
                                            .foregroundStyle(.secondary)
                                            .fontDesign(.serif)
                                            .italic()
                                        Spacer()
                                    }
                                }
                            }
                            .focusable()
                        }
                        .padding(.vertical, 8)
                    }
                    Spacer()
                }
                .padding()
            }
        }

    }
}
