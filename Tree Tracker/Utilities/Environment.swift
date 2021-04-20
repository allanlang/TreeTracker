import Foundation
import class Photos.PHCachingImageManager

struct Environment {
    let api: Api
    let database: Database
    let defaults: Defaults
    let imageCache: ImageCaching
    let screenLockManager: ScreenLockManaging
    let photosCachingManager: PHCachingImageManager
    let recentSpeciesManager: RecentSpeciesManaging
    let logger: Logging
}

let CurrentEnvironment: Environment = {
    let logger = Logger(output: .print)
    let defaults = Defaults()
    
    return Environment(
        api: Api(logger: logger),
        database: Database(logger: logger),
        defaults: defaults,
        imageCache: GRDBImageCache(logger: logger),
        screenLockManager: UIScreenLockManager(),
        photosCachingManager: PHCachingImageManager(),
        recentSpeciesManager: RecentSpeciesManager(defaults: defaults, strategy: .todayUsedSpecies),
        logger: logger
    )
}()
