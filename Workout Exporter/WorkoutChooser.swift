import SwiftUI
import HealthKit

struct WorkoutChooser: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var workouts: [HKWorkout] = []
    var onWorkoutSelected: (HKWorkout) -> Void

    var body: some View {
        NavigationView {
            List(workouts, id: \.uuid) { workout in
                Button(action: {
                    onWorkoutSelected(workout)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    VStack(alignment: .leading) {
                        Text(workout.workoutActivityType.name)
                        Text(workout.startDate, style: .date)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("Choose a Workout")
            .task {
                await fetchWorkouts()
            }
        }
    }

    private func fetchWorkouts() async {
        do {
            workouts = try await HealthKitManager.shared.fetchWorkouts()
        } catch {
            print("Error fetching workouts: \(error)")
        }
    }
}

extension HKWorkoutActivityType {
    var name: String {
        switch self {
        case .cycling:
            return "Cycling"
        case .hiking:
            return "Hiking"
        case .elliptical:
            return "Elliptical"
        case .rowing:
            return "Rowing"
        case .walking:
            return "Walking"
        case .running:
            return "Running"
        case .traditionalStrengthTraining:
            return "Strength Training"
        case .functionalStrengthTraining:
            return "Functional Strength Training"
        case .highIntensityIntervalTraining:
            return "HIIT"
        case .swimming:
            return "Swimming"
        case .other:
            return "Other"
        default:
            return "Other (\(rawValue))"
        }
    }
}
