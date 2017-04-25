import Foundation
import TempoKit
import NetworkKit

protocol NetworkService {
    func load<A>(_ resource: Resource<A>, completion: @escaping (Result<A>) -> Void)
}

protocol UsesNetworkService {
    var networkService: NetworkService { get }
}

public final class MixinNetworkService: NetworkService, TempoNetworkService {
    private let networking: NetworkKit
    
    public init() {
        networking = NetworkKit()
    }
    
    internal func load<A>(_ resource: Resource<A>, completion: @escaping (Result<A>) -> Void) {
        networking.load(resource: resource, completion: completion)
    }
    
    public func load(worklog: TempoRequest, completion: @escaping ([[String : Any]]) -> Void) {
        let rq = Request(url: worklog.url,
                         method: RequestMethod(rawValue: worklog.method)!,
                         headers: worklog.headers,
                         params: worklog.params)
        let r = Resource<[[String : Any]]>(request: rq) { r in
            guard let response = r  as? [[String : Any]] else { return nil }
            return response
        }
        
        networking.load(resource: r) { result in
            guard case let .success(json) = result else { return }
            completion(json)
        }
    }
}
	
