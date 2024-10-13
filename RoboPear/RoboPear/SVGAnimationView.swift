import SwiftUI

enum SVGState: String, CaseIterable {
    case drinkslide,videoslide, phoneslide
}

struct SVGAnimationView: View {
    @State private var currentSVG: SVGState = .drinkslide
    @State private var timer: Timer? = nil
    
    var body: some View {
        ZStack {
            ForEach(SVGState.allCases, id: \.self) { state in
                Image(state.rawValue)
                    .resizable()
                    .scaledToFit()
                    .opacity(state == currentSVG ? 1 : 0)
                    .cornerRadius(40)
                    .padding()
            }
        }
        .animation(.easeInOut(duration: 0.5), value: currentSVG)
        .onAppear(perform: startTimer)
        .onDisappear(perform: stopTimer)
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                currentSVG = SVGState.allCases[(SVGState.allCases.firstIndex(of: currentSVG)! + 1) % SVGState.allCases.count]
            }
        }
    }
    
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

struct SVGAnimationView_Previews: PreviewProvider {
    static var previews: some View {
        SVGAnimationView()
    }
}
