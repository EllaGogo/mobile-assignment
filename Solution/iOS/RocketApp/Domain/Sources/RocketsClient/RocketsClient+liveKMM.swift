import CoreToolkit
import Dependencies
import ErrorReporting
import Foundation
import NetworkClientExtensions
import Networking
import RequestBuilder
import KMMmodule
import KMPNativeCoroutinesCore
import KMPNativeCoroutinesAsync

public extension RocketsClient {
  static var liveKMM: Self {
    @Dependency(\.rocketConverterKMM) var rocketConverterKMM
    @Dependency(\.rocketsConverterKMM) var rocketsConverterKMM
    
    //MARK: KMM Rocket library integration
    let rocketApi = RocketApi()
    
    return Self(
      getRocket: { id in
        do {
          let rocket = try await asyncFunction(for: rocketApi.fetchRocketById(rocketId: id))
          if let success = rocket as? RocketResultSuccess<AnyObject> {
            guard let result = rocketConverterKMM.domainModel(fromExternal: success.data as! RocketKMM) else {
              throw RocketsClientAsyncError.modelConversionError
            }
            
            return result
          } else if let failure = rocket as? RocketResult<RocketException> {
            throw errorFromRocketFailure(failure)
          }
          
          throw RocketsClientAsyncError.undefinedError
        } catch {
          throw error
        }
      },
      getAllRockets: {
        do {
          let rockets = try await asyncFunction(for: rocketApi.fetchAllRockets())
          if let success = rockets as? RocketResultSuccess<AnyObject> {
            guard let result = rocketsConverterKMM.domainModel(fromExternal: success.data as! [RocketKMM]) else {
              throw RocketsClientAsyncError.modelConversionError
            }
            
            return result
          } else if let failure = rockets as? RocketResult<RocketException> {
            throw errorFromRocketFailure(failure)
          }
          
          throw RocketsClientAsyncError.undefinedError
        } catch {
          throw error
        }
      }
    )
  }
}
