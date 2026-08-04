//
//  UpdateCostInfoUseCase.swift
//  TaxiMeter
//

import Foundation

/// Update Cost Info UseCase
/// - Check for update of cost info, and update it if needed
public final class UpdateCostInfoUseCase: @unchecked Sendable {
    private let appLogger: AppLogger
    private let costRepository: CostRepository

    public init(
        appLogger: AppLogger = AppLoggerImpl(),
        costRepository: CostRepository = RepositoryProvider.shared.costRepository
    ) {
        self.appLogger = appLogger
        self.costRepository = costRepository
    }

    public func execute() async -> UpdateCostInfoResult {
        do {
            // Get local version info
            let localVersion = costRepository.getLocalVersion()

            // Get remote version info; if remote version cannot be fetched, keep local data without showing failure toast
            guard let remoteVersion = await costRepository.getRemoteVersion() else {
                return .upToDate
            }

            // Check if update is needed
            if localVersion >= remoteVersion {
                return .upToDate
            }

            // Update to latest cost info
            let updateResult = await costRepository.updateToLatest()

            return updateResult ? .success : .failure
        } catch is CancellationError {
            return .canceled
        } catch {
            appLogger.recordError(error, message: "Failed to update cost info")
            return .failure
        }
    }
}
