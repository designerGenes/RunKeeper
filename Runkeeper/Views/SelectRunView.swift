import SwiftUI
import SwiftData

struct SelectRunView: View {
    @ObservedObject var viewModel: RunManagerViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @Binding var showSettings: Bool
    @State private var selectedRunRecord: RunRecord?
    @State private var scrolledToNextRun = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ZStack {
                    Color(hex: 0x383232)
                        .edgesIgnoringSafeArea(.top)
                    
                    VStack {
                        HStack {
                            Text("Lace")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(themeManager.themeColor.lighten(by: 0.4))
                            
                            Image("mountains")
                                .resizable()
                                .scaledToFit()
                                .frame(height: geometry.size.height * 0.2)
                            
                            Button(action: { showSettings.toggle() }) {
                                Image(systemName: "gear")
                                    .font(.title)
                                    .foregroundColor(self.showSettings ? .clear : themeManager.themeColor.lighten(by: 0.4))
                                    
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, geometry.safeAreaInsets.top)
                        
                        
                    }
                }
                .frame(height: geometry.size.height * 0.3)
                
                ScrollViewReader { proxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(viewModel.runManager.runRecords.sorted { ($0.week * 10 + $0.day) < ($1.week * 10 + $1.day) }) { runRecord in
                                RunSquare(runRecord: runRecord, isSelected: selectedRunRecord?.id == runRecord.id)
                                    .onTapGesture {
                                        selectedRunRecord = runRecord
                                    }
                                    .id(runRecord.id)
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: 100)
                    .padding(.top, 10)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            if !scrolledToNextRun {
                                if let nextRun = viewModel.getNextRun() {
                                    withAnimation(.easeOut(duration: 0.3)) {
                                        proxy.scrollTo(nextRun.id, anchor: .leading)
                                    }
                                }
                                scrolledToNextRun = true
                            }
                        }
                    }
                }
                
                ScrollView {
                    if let selectedRun = selectedRunRecord,
                       let run = viewModel.getPredefinedRun(for: selectedRun) {
                        RunDetailsView(run: run)
                            .transition(.opacity)
                    } else {
                        Text("Select a run to see details")
                            .foregroundColor(.secondary)
                            .frame(height: 100)  // Minimum height to prevent layout shift
                    }
                }
                .frame(height: geometry.size.height * 0.35)
                .padding(.top, 16)
                
                Spacer(minLength: 20)
                
                NavigationLink(destination: RunView(viewModel: viewModel, runRecord: selectedRunRecord ?? viewModel.getNextRun()!).environmentObject(themeManager)) {
                    Text("Run")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Capsule().fill(Color.black))
                }
                .padding(.horizontal)
                .disabled(selectedRunRecord == nil)
                .padding(.bottom, 20)
            }
            .background(themeManager.backgroundGradient.ignoresSafeArea())
        }
    }
}

struct RunSquare: View {
    let runRecord: RunRecord
    let isSelected: Bool
    @EnvironmentObject private var themeManager: ThemeManager
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .fill(runRecord.completedDate != nil ? Color.black : Color.clear)
                    .frame(width: 40, height: 40)
                    .overlay(Circle().stroke(Color.black, lineWidth: 2))
                
                if runRecord.completedDate != nil {
                    Image(systemName: "checkmark")
                        .foregroundColor(themeManager.themeColor.lighten(by: 0.4))
                        .font(.system(size: 20, weight: .bold))
                }
            }
            
            Text("Day \(runRecord.day)")
                .font(.caption)
            Text("Week \(runRecord.week)")
                .font(.caption2)
        }
        .padding(8)
        .background(isSelected ? themeManager.themeColor.opacity(0.3) : Color.clear)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? themeManager.themeColor : Color.clear, lineWidth: 2)
        )
    }
}

struct RunDetailsView: View {
    let run: Run
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(run.segments.indices, id: \.self) { index in
                Text(segmentDescription(for: run.segments[index], index: index))
                    .font(.subheadline)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal, 8)
    }
    
    private func segmentDescription(for segment: RunSegment, index: Int) -> String {
        let action = segment.segmentType == .run ? "Run" : "Walk"
        let duration = Int(segment.duration)
        let prefix = index == 0 ? "" : "Then "
        return "\(prefix)\(action.lowercased()) for \(duration) seconds"
    }
}

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}
