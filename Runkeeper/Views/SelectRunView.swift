import SwiftUI
import SwiftData

struct SelectRunView: View {
    @ObservedObject var viewModel: RunManagerViewModel
    @EnvironmentObject private var themeManager: ThemeManager
    @Binding var showSettings: Bool
    @State private var selectedRunRecord: RunRecord?
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                HStack {
                    Button(action: { showSettings.toggle() }) {
                        Image(systemName: "gear")
                            .fixedSize()
                            .frame(width: 24, height: 24)
                            .font(.title)
                            .foregroundColor(.primary)
                            .padding()
                            
                    }
                    Spacer()
                }
                
                Image("mountains")
                    .resizable()
                    .scaledToFit()
                    .frame(height: geometry.size.height * 0.25)
                    .clipped()
                    .ignoresSafeArea()
                
                Text("Next Up: Week \(viewModel.getNextRun()?.week ?? 1), Day \(viewModel.getNextRun()?.day ?? 1)")
                    .font(.headline)
                    .padding(.vertical, 10)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(viewModel.runManager.runRecords.sorted { ($0.week * 10 + $0.day) < ($1.week * 10 + $1.day) }) { runRecord in
                            RunSquare(runRecord: runRecord, isSelected: selectedRunRecord?.id == runRecord.id)
                                .onTapGesture {
                                    selectedRunRecord = runRecord
                                }
                        }
                    }
                    .padding(.horizontal, 4)
                }
                .frame(height: 100)
                
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
                .padding(.vertical, 16)
                .frame(height: geometry.size.height * 0.3)
                
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
            .frame(width: geometry.size.width, height: geometry.size.height)
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
            Circle()
                .fill(runRecord.completedDate != nil ? Color.black : Color.clear)
                .frame(width: 40, height: 40)
                .overlay(Circle().stroke(Color.black, lineWidth: 2))
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
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal)
    }
    
    private func segmentDescription(for segment: RunSegment, index: Int) -> String {
        let action = segment.segmentType == .run ? "Run" : "Walk"
        let duration = Int(segment.duration)
        let prefix = index == 0 ? "" : (index == run.segments.count - 1 ? "And finally " : "Then ")
        return "\(prefix)\(action.lowercased()) for \(duration) seconds"
    }
}
