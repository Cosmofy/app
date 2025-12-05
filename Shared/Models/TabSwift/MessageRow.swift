//  ========================================
//  MessageRow.swift
//  Cosmofy
//  4th Edition
//  Created by Arryan Bhatnagar on 10/24/23.
//  Abstract: Each VStack of the chat.
//  ========================================


import Foundation
import SwiftUI

struct MessageRow: Identifiable {
    
    let id = UUID()
    var isInteractingWithChatGPT: Bool
    
    let sendImage: String
    let sendText: String
    
    let responseImage: String
    var responseText: String?
    var responseError: String?
    
}
