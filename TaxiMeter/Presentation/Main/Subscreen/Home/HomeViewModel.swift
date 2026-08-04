//
//  HomeViewModel.swift
//  TaxiMeter
//

import Foundation
import Observation

@Observable
public final class HomeViewModel {
    public var uiState: HomeUiState = HomeUiState()
    private let updateCostInfoUseCase: UpdateCostInfoUseCase
    private var hasCheckedUpdate: Bool = false

    public init(updateCostInfoUseCase: UpdateCostInfoUseCase = UseCaseProvider.shared.updateCostInfoUseCase) {
        self.updateCostInfoUseCase = updateCostInfoUseCase
    }

    /// Clear Toast Message
    public func clearToast() {
        uiState.toastMessage = nil
    }

    /// Check and apply cost info update (executed only once per app session)
    public func updateCostInfo() {
        guard !hasCheckedUpdate else { return }
        hasCheckedUpdate = true

        Task { @MainActor in
            let updateResult = await updateCostInfoUseCase.execute()
            switch updateResult {
            case .canceled, .upToDate:
                break
            case .success:
                uiState.toastMessage = "Cost info is updated."
            case .failure:
                uiState.toastMessage = "Cost info update failed. Please check network state."
            }
        }
    }
}
