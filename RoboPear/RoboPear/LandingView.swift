import SwiftUI

struct LandingView: View {
    @Binding var showContentView: Bool
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(gradient: Gradient(colors: [Color.white, Color.blue.opacity(0.2)]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 30) {
                Text("XLaunch")
                    .font(.system(size: 60, weight: .heavy, design: .default))
                    .foregroundColor(.blue)
                    .shadow(color: .gray.opacity(0.3), radius: 2, x: 0, y: 2)
                
                Text("Automate marketing")
                    .font(.system(size: 24, weight: .medium, design: .default))
                    .foregroundColor(.gray)
                
                SVGAnimationView()
                    .frame(height: 250)
                    .shadow(color: .gray.opacity(0.2), radius: 5, x: 0, y: 5)
                
                Button(action: {
                    showContentView = true
                }) {
                    Text("Get Started")
                        .font(.system(size: 18, weight: .semibold, design: .default))
                        .padding(.horizontal, 40)
                        .padding(.vertical, 15)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 5)
                }
                .padding(.top, 20)
            }
            .padding()
        }
    }
}

struct LandingView_Previews: PreviewProvider {
    static var previews: some View {
        LandingView(showContentView: .constant(false))
    }
}
