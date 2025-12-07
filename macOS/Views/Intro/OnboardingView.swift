//
//  OnboardingView.swift
//  Cosmofy iOS
//
//  Created by Arryan Bhatnagar on 7/29/24.
//

import SwiftUI

struct OnboardingView: View {

    @State var onboardingState: Int = 0
    @State var selectedProfile: Int = 2 // 1 kids. 2 adults.
    @State var firstName: String = ""
    
    let transition: AnyTransition = .asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading))
    
    @AppStorage("selectedProfile") var currentSelectedProfile: Int?
    @AppStorage("firstName") var currentFirstName: String?
    @AppStorage("signed_in") var currentUserSignedIn: Bool = false
    
    @State var showAlert: Bool = false

    
    var body: some View {
        VStack {
            switch onboardingState {
            case 0:
                welcomeScreen
                    .transition(transition)
            case 1:
                aboutScreen
                    .transition(transition)
            case 2:
                roleSelectionScreen
                    .transition(transition)
            case 3:
                nameScreen
                    .transition(transition)
            default:
                VStack {
                    Spacer()
                    Text("You should not see this - Line 40 OnboardingView.swift")
                    Spacer()
                }
            }
            
            Spacer()
            bottomButton
                
        }
        .padding()
    }
    
    private var bottomButton: some View {
        Text(
            onboardingState == 0 ? "Continue" :
            onboardingState == 3 ? "Get Started" : "Next"
            )
            .font(.headline)
            .foregroundStyle(.white)
            .frame(height: 60)
            .frame(maxWidth: .infinity)
            .background(.green.gradient)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding()
            .onTapGesture {
                handleNextButtonPress()
            }
    }
    
    private var welcomeScreen: some View {
        VStack {
            Spacer()
            VStack(spacing: 0) {
                HStack {
                    Text("Welcome to")
                        .fontDesign(.rounded)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                HStack {
                    Text("Cosmofy.")
                        .fontDesign(.rounded)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                    Spacer()
                }
            }
            Spacer()
        }
    }
    
    private var aboutScreen: some View {
        VStack {
            Spacer()
            HStack() {
                Text("What is Cosmofy?")
                    .fontDesign(.rounded)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding()
            
            HStack() {
                Text("Cosmofy is a multi-platfrom application about astronomy and space.")
                    .fontDesign(.rounded)
                    .fontWeight(.regular)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding(.horizontal)
            Spacer()
            
        }
    }
    
    private var roleSelectionScreen: some View {
        
        VStack {
            Spacer()
            HStack() {
                Text("Which Profile Suits You?")
                    .fontDesign(.rounded)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
            }
//            
//            VStack {
//                HStack() {
//                    Text("Cosmic Expert")
//                        .fontDesign(.rounded)
//                        .font(.title2)
//                        .fontWeight(.semibold)
//                    Spacer()
//                    if selectedProfile == 3 {
//                        HStack {
//                            Text("Selected")
//                                .foregroundStyle(.green)
//                                .fontDesign(.rounded)
//                                .font(.subheadline)
//                                .fontWeight(.medium)
//                            
//                            Image(systemName: "checkmark.circle.fill")
//                                .foregroundStyle(.green)
//                        }
//                    }
//                    
//                }
//                .padding()
//                HStack() {
//                    Text("Advanced understanding of space for enthusiasts and professionals.")
//                        .foregroundStyle(.secondary)
//                        .fontDesign(.rounded)
//                    Spacer()
//                }
//                .padding(.horizontal)
//                Spacer()
//            }
//            .frame(maxWidth: .infinity)
//            .frame(height: 130)
//            .background(.ultraThinMaterial)
//            .clipShape(RoundedRectangle(cornerRadius: 24))
//            .overlay {
//                if selectedProfile == 3 {
//                    RoundedRectangle(cornerRadius: 24)
//                        .stroke(.green.gradient, lineWidth: 2)
//                }
//            }
//            .padding(.bottom)
//            .onTapGesture {
//                selectedProfile = 3
//            }
            
           
            VStack {
                HStack() {
                    Text("Stellar Scholar")
                        .fontDesign(.rounded)
                        .font(.title2)
                        .fontWeight(.semibold)
                    Spacer()
                    if selectedProfile == 2 {
                        HStack {
                            Text("Default")
                                .foregroundStyle(.green)
                                .fontDesign(.rounded)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }
                    }
                }
                .padding()
                HStack() {
                    Text("Intermediate knowledge of space, perfect for curious minds.")
                        .foregroundStyle(.secondary)
                        .fontDesign(.rounded)
                    Spacer()
                }
                .padding(.horizontal)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 130)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay {
                if selectedProfile == 2 {
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(.green.gradient, lineWidth: 2)
                }
            }
            .padding(.bottom)
            .onTapGesture {
                selectedProfile = 2
            }

            
            VStack {
                HStack() {
                    Text("kids")
                        .foregroundStyle(Color(hex: 0xFAF42A))
                        .fontDesign(.rounded)
                        .font(.title2)
                        .frame(width: 70)
                        .fontWeight(.semibold)
                        .background(
                            VStack(spacing: 0) {
                                Rectangle().fill(Color.pink.opacity(0.8).gradient)
                                Rectangle().fill(Color.purple.opacity(0.8).gradient)
                                Rectangle().fill(Color.blue.opacity(0.8).gradient)
                                Rectangle().fill(Color.green.opacity(0.8).gradient)
                            }
                            .frame(width: 80, height: 80)
                            .rotationEffect(.degrees(45))
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .clipped()
                    Spacer()
                    if selectedProfile == 1 {
                        HStack {
                            Text("Selected")
                                .foregroundStyle(.green)
                                .fontDesign(.rounded)
                                .font(.subheadline)
                                .fontWeight(.medium)
                            
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }
                    }
                }
                .padding()
                HStack() {
                    Text("Basic introduction to space concepts for young learners.")
                        .foregroundStyle(.secondary)
                        .fontDesign(.rounded)
                    Spacer()
                }
                .padding(.horizontal)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: 130)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 24))
            .overlay {
                if selectedProfile == 1 {
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(.green.gradient, lineWidth: 2)
                }
            }
            .onTapGesture {
                selectedProfile = 1
            }
            
            Text("You can change this later.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fontDesign(.rounded)
                .padding()
            Spacer()
        }
        .padding(.horizontal)
    }
    
    private var nameScreen: some View {
        VStack {
            Spacer()
            Text("Who are you?")
                .fontDesign(.rounded)
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            
            TextField("First Name", text: $firstName)
                .fontDesign(.rounded)
                .frame(height: 50)
                .padding(.horizontal)
                .background(Color.gray.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .padding(.horizontal)
            
            if showAlert {
                Text("Your name should at least be 2 characters.")
                    .foregroundStyle(.red)
                    .font(.caption)
                    .fontDesign(.rounded)
                    .padding(.top)
            } else {
                Text(" ")
                    .foregroundStyle(.red)
                    .font(.caption)
                    .fontDesign(.rounded)
                    .padding(.top, 8)
            }
            Spacer()
            
        }
    }
    
    func handleNextButtonPress() {
        
        switch onboardingState {
            case 3:
                guard firstName.count >= 2 else {
                    showAlert = true
                    return
                }
            default: break
        }
        
        if onboardingState == 3 {
            signIn()
        } else {
            withAnimation(.spring()) {
                onboardingState += 1
            }
        }
        
    }
    
    func signIn() {
        print("Signing In")
        currentSelectedProfile = selectedProfile
        currentFirstName = firstName
        withAnimation(.spring()) {
            currentUserSignedIn = true
        }
    }
}

#Preview {
    OnboardingView()
}
