//
//  MapHelpers.swift
//  Cosmofy
//
//  Created by Arryan Bhatnagar on 7/22/24.
//

import Foundation
import SwiftUI

func getFormattedDate14DaysAgo() -> String {
    // Get the current date
    let currentDate = Date()
    
    // Subtract 14 days from the current date
    guard let date14DaysAgo = Calendar.current.date(byAdding: .day, value: -15, to: currentDate) else {
        return "Date calculation error"
    }
    
    // Format the date as "MMMM d"
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM d"
    
    return dateFormatter.string(from: date14DaysAgo)
}

func markerImage(for title: String) -> String {
    switch title.lowercased() {
    case "drought":
        return "drop.circle"
    case "dusthaze":
        return "sun.haze"
    case "earthquakes":
        return "waveform.path.ecg"
    case "floods":
        return "cloud.rain"
    case "landslides":
        return "arrowtriangle.down.circle"
    case "manmade":
        return "hammer"
    case "sealakeice":
        return "snowflake"
    case "severestorms":
        return "cloud.bolt.rain"
    case "snow":
        return "snowflake"
    case "tempextremes":
        return "thermometer.snowflake"
    case "volcanoes":
        return "mountain.2"
    case "watercolor":
        return "drop.triangle.fill"
    case "wildfires":
        return "flame"
    default:
        return "mappin.circle"
    }
}

func markerTint(for title: String) -> Color {
    switch title.lowercased() {
    case "drought":
        return .yellow
    case "dusthaze":
        return .green
    case "earthquakes":
        return .gray
    case "floods":
        return .blue
    case "landslides":
        return .orange
    case "manmade":
        return .SOUR
    case "sealakeice":
        return .white
    case "severestorms":
        return .mint
    case "snow":
        return .white
    case "tempextremes":
        return .miamiBlue
    case "volcanoes":
        return .red
    case "watercolor":
        return .black
    case "wildfires":
        return .orange
    default:
        return .yellow
    }
}

func getSourceTitle(by id: String) -> String? {
    return sources.first { $0.id == id }?.title
}

func formattedDate(from dateString: String) -> String {
    let inputFormatter = DateFormatter()
    inputFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
    
    let outputFormatter = DateFormatter()
    outputFormatter.dateStyle = .long
    outputFormatter.timeStyle = .short
    
    if let date = inputFormatter.date(from: dateString) {
        return outputFormatter.string(from: date)
    } else {
        return "Invalid Date"
    }
}

struct Category: Identifiable {
    var id: String
    var title: String
    var description: String
}

let categories: [Category] = [
    Category(id: "1", title: "Drought", description: "Long lasting absence of precipitation affecting agriculture and livestock, and the overall availability of food and water."),
    Category(id: "2", title: "Dust and Haze", description: "Related to dust storms, air pollution and other non-volcanic aerosols. Volcano-related plumes shall be included with the originating eruption event."),
    Category(id: "3", title: "Earthquakes", description: "Related to all manner of shaking and displacement. Certain aftermath of earthquakes may also be found under landslides and floods."),
    Category(id: "4", title: "Floods", description: "Related to aspects of actual flooding--e.g., inundation, water extending beyond river and lake extents."),
    Category(id: "5", title: "Landslides", description: "Related to landslides and variations thereof: mudslides, avalanche."),
    Category(id: "6", title: "Manmade", description: "Events that have been human-induced and are extreme in their extent."),
    Category(id: "7", title: "Sea and Lake Ice", description: "Related to all ice that resides on oceans and lakes, including sea and lake ice (permanent and seasonal) and icebergs."),
    Category(id: "8", title: "Severe Storms", description: "Related to the atmospheric aspect of storms (hurricanes, cyclones, tornadoes, etc.). Results of storms may be included under floods, landslides, etc."),
    Category(id: "9", title: "Snow", description: "Related to snow events, particularly extreme/anomalous snowfall in either timing or extent/depth."),
    Category(id: "10", title: "Temperature Extremes", description: "Related to anomalous land temperatures, either heat or cold."),
    Category(id: "11", title: "Volcanoes", description: "Related to both the physical effects of an eruption (rock, ash, lava) and the atmospheric (ash and gas plumes)."),
    Category(id: "12", title: "Water Color", description: "Related to events that alter the appearance of water: phytoplankton, red tide, algae, sediment, whiting, etc."),
    Category(id: "13", title: "Wildfires", description: "Wildfires includes all nature of fire, including forest and plains fires, as well as urban and industrial fire events. Fires may be naturally caused or manmade.")
]

struct Source: Identifiable {
    let id: String
    let title: String
    let source: String
}

let sources: [Source] = [
    Source(id: "AVO", title: "Alaska Volcano Observatory", source: "https://www.avo.alaska.edu/"),
    Source(id: "ABFIRE", title: "Alberta Wildfire", source: "https://wildfire.alberta.ca/"),
    Source(id: "AU_BOM", title: "Australia Bureau of Meteorology", source: "http://www.bom.gov.au/"),
    Source(id: "BYU_ICE", title: "Brigham Young University Antarctic Iceberg Tracking Database", source: "http://www.scp.byu.edu/data/iceberg/database1.html"),
    Source(id: "BCWILDFIRE", title: "British Columbia Wildfire Service", source: "http://bcwildfire.ca/"),
    Source(id: "CALFIRE", title: "California Department of Forestry and Fire Protection", source: "http://www.calfire.ca.gov/"),
    Source(id: "CEMS", title: "Copernicus Emergency Management Service", source: "http://emergency.copernicus.eu/"),
    Source(id: "EO", title: "Earth Observatory", source: "https://earthobservatory.nasa.gov/"),
    Source(id: "Earthdata", title: "Earthdata", source: "https://earthdata.nasa.gov"),
    Source(id: "FEMA", title: "Federal Emergency Management Agency (FEMA)", source: "https://www.fema.gov/"),
    Source(id: "FloodList", title: "FloodList", source: "http://floodlist.com/"),
    Source(id: "GDACS", title: "Global Disaster Alert and Coordination System", source: "http://www.gdacs.org/"),
    Source(id: "GLIDE", title: "GLobal IDEntifier Number (GLIDE)", source: "http://www.glidenumber.net/"),
    Source(id: "InciWeb", title: "InciWeb", source: "https://inciweb.nwcg.gov/"),
    Source(id: "IRWIN", title: "Integrated Reporting of Wildfire Information (IRWIN) Observer", source: "https://irwin.doi.gov/observer/"),
    Source(id: "IDC", title: "International Charter on Space and Major Disasters", source: "https://www.disasterscharter.org/"),
    Source(id: "JTWC", title: "Joint Typhoon Warning Center", source: "http://www.metoc.navy.mil/jtwc/jtwc.html"),
    Source(id: "MRR", title: "LANCE Rapid Response", source: "https://lance.modaps.eosdis.nasa.gov/cgi-bin/imagery/gallery.cgi"),
    Source(id: "MBFIRE", title: "Manitoba Wildfire Program", source: "http://www.gov.mb.ca/sd/fire/Fire-Maps/"),
    Source(id: "NASA_ESRS", title: "NASA Earth Science and Remote Sensing Unit", source: "https://eol.jsc.nasa.gov/ESRS/"),
    Source(id: "NASA_DISP", title: "NASA Earth Science Disasters Program", source: "https://disasters.nasa.gov/"),
    Source(id: "NASA_HURR", title: "NASA Hurricane And Typhoon Updates", source: "https://blogs.nasa.gov/hurricanes/"),
    Source(id: "NOAA_NHC", title: "National Hurricane Center", source: "https://www.nhc.noaa.gov/"),
    Source(id: "NOAA_CPC", title: "NOAA Center for Weather and Climate Prediction", source: "http://www.cpc.ncep.noaa.gov/"),
    Source(id: "PDC", title: "Pacific Disaster Center", source: "http://www.pdc.org/"),
    Source(id: "ReliefWeb", title: "ReliefWeb", source: "http://reliefweb.int/"),
    Source(id: "SIVolcano", title: "Smithsonian Institution Global Volcanism Program", source: "http://www.volcano.si.edu/"),
    Source(id: "NATICE", title: "U.S. National Ice Center", source: "http://www.natice.noaa.gov/Main_Products.htm"),
    Source(id: "UNISYS", title: "Unisys Weather", source: "http://weather.unisys.com/hurricane/"),
    Source(id: "USGS_EHP", title: "USGS Earthquake Hazards Program", source: "https://earthquake.usgs.gov/"),
    Source(id: "USGS_CMT", title: "USGS Emergency Operations Collection Management Tool", source: "https://cmt.usgs.gov/"),
    Source(id: "HDDS", title: "USGS Hazards Data Distribution System", source: "https://hddsexplorer.usgs.gov/"),
    Source(id: "DFES_WA", title: "Western Australia Department of Fire and Emergency Services", source: "https://www.dfes.wa.gov.au/")
]
